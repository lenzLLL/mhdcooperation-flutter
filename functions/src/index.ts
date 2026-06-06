import {
  onDocumentUpdated,
  onDocumentCreated,
} from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { Message } from "firebase-admin/messaging";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ─── Helpers ─────────────────────────────────────────────────────────────────

async function sendToToken(
  token: string,
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<void> {
  if (!token) return;
  const message: Message = {
    token,
    notification: { title, body },
    data,
    android: {
      priority: "high",
      notification: { channelId: "mhd_high_importance", sound: "default" },
    },
    apns: { payload: { aps: { sound: "default", badge: 1 } } },
  };
  try {
    await messaging.send(message);
  } catch (err) {
    console.error("[FCM] sendToToken error:", err);
  }
}

async function getUserToken(userId: string): Promise<string | null> {
  const doc = await db.collection("users").doc(userId).get();
  return (doc.data()?.fcm_token as string) ?? null;
}

async function notifyAdmins(
  title: string,
  body: string,
  data: Record<string, string> = {}
): Promise<void> {
  const snap = await db
    .collection("users")
    .where("role", "in", ["ADMIN", "SADMIN"])
    .get();

  const sends: Promise<void>[] = [];
  snap.forEach((doc) => {
    const token = doc.data().fcm_token as string | undefined;
    if (token) sends.push(sendToToken(token, title, body, data));
  });
  await Promise.all(sends);
}

const STATUS_LABELS: Record<string, string> = {
  approved: "approuvé ✅",
  rejected: "rejeté ❌",
  pending: "en attente ⏳",
  revision_requested: "en révision 🔄",
  under_review: "en cours d'examen 🔍",
  submitted: "soumis 📤",
  paid: "payé 💰",
};

// ─── 1. Dossier mis à jour ────────────────────────────────────────────────────
//
// Champ attendu dans le document Firestore : last_updated_by_role = 'USER' | 'ADMIN' | 'SADMIN'
// À ajouter côté Dart lors de chaque écriture (voir note dans les contrôleurs).
//
export const onDossierUpdated = onDocumentUpdated(
  "dossiers/{dossierId}",
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    const dossierId = event.params.dossierId;
    const userId = after.user_id as string;
    const itemTitle = (after.item_title as string) ?? "votre dossier";
    const updaterRole = after.last_updated_by_role as string | undefined;
    const statusChanged = before.status !== after.status;
    const messagesChanged = before.messages !== after.messages;

    const isAdminUpdate =
      updaterRole === "ADMIN" ||
      updaterRole === "SADMIN" ||
      // Fallback : si aucun rôle fourni mais statut changé, on suppose admin
      (!updaterRole && statusChanged);

    // Admin → notifier l'utilisateur
    if (isAdminUpdate) {
      const token = await getUserToken(userId);
      if (!token) return;

      if (statusChanged) {
        const label = STATUS_LABELS[after.status as string] ?? after.status;
        await sendToToken(
          token,
          "Mise à jour de dossier",
          `Votre dossier "${itemTitle}" a été ${label}.`,
          { type: "dossier", id: dossierId }
        );
      } else if (messagesChanged) {
        await sendToToken(
          token,
          "Nouveau message sur votre dossier",
          `Un administrateur a laissé un commentaire sur "${itemTitle}".`,
          { type: "dossier", id: dossierId }
        );
      }
      return;
    }

    // Utilisateur → notifier les admins
    if (updaterRole === "USER") {
      const userName = (after.user_name as string) ?? "Un utilisateur";
      if (statusChanged) {
        await notifyAdmins(
          "Dossier mis à jour",
          `${userName} a modifié son dossier "${itemTitle}" → statut : ${after.status}.`,
          { type: "dossier", id: dossierId }
        );
      } else if (messagesChanged) {
        await notifyAdmins(
          "Nouveau message",
          `${userName} a ajouté un message sur son dossier "${itemTitle}".`,
          { type: "dossier", id: dossierId }
        );
      }
    }
  }
);

// ─── 2. Transaction créée → notifier l'utilisateur + les admins ──────────────
//
// Structure attendue dans la collection `transactions` :
//   user_id, user_name, amount, description, status ('success'|'pending'|'failed')
//
export const onTransactionCreated = onDocumentCreated(
  "transactions/{transactionId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const userId = data.user_id as string;
    const amount = data.amount as number;
    const description = (data.description as string) ?? "Transaction";
    const status = (data.status as string) ?? "success";
    const userName = (data.user_name as string) ?? "Un utilisateur";
    const txId = event.params.transactionId;

    const formatted = new Intl.NumberFormat("fr-FR").format(amount);

    // Notification à l'utilisateur
    const userToken = await getUserToken(userId);
    if (userToken) {
      const ok = status === "success" || status === "completed";
      await sendToToken(
        userToken,
        ok ? "Paiement confirmé ✅" : "Transaction en attente ⏳",
        `${description} — ${formatted} FCFA`,
        { type: "notification", id: txId }
      );
    }

    // Notification aux admins
    await notifyAdmins(
      "Nouvelle transaction",
      `${userName} — ${description} : ${formatted} FCFA (${status}).`,
      { type: "notification", id: txId }
    );
  }
);

// ─── 3. Rappel quotidien : concours dans 24h ──────────────────────────────────
//
// Se déclenche chaque jour à 08h00 (heure de Douala, UTC+1).
// Vérifie les dossiers dont la date limite du concours lié est demain.
//
export const dailyConcoursReminder = onSchedule(
  { schedule: "0 8 * * *", timeZone: "Africa/Douala" },
  async () => {
    const now = new Date();
    const tomorrow = new Date(now);
    tomorrow.setDate(now.getDate() + 1);
    tomorrow.setHours(0, 0, 0, 0);

    const dayAfter = new Date(tomorrow);
    dayAfter.setDate(tomorrow.getDate() + 1);

    const concoursSnap = await db
      .collection("concours")
      .where("application_deadline", ">=", tomorrow.toISOString())
      .where("application_deadline", "<", dayAfter.toISOString())
      .get();

    if (concoursSnap.empty) {
      console.log("[Reminder] Aucun concours avec deadline demain.");
      return;
    }

    for (const concoursDoc of concoursSnap.docs) {
      const concours = concoursDoc.data();
      const concoursTitle = concours.title as string;

      const dossiersSnap = await db
        .collection("dossiers")
        .where("concours_id", "==", concoursDoc.id)
        .where("status", "not-in", ["rejected", "cancelled"])
        .get();

      for (const dossierDoc of dossiersSnap.docs) {
        const userId = dossierDoc.data().user_id as string;
        const token = await getUserToken(userId);
        if (!token) continue;

        await sendToToken(
          token,
          "⏰ Rappel — Concours demain !",
          `La date limite pour "${concoursTitle}" est demain. Finalisez votre dossier !`,
          { type: "concours", id: concoursDoc.id }
        );
      }
    }

    console.log(
      `[Reminder] ${concoursSnap.size} concours traités.`
    );
  }
);

// ─── 4. Nouveau concours créé → diffusion aux abonnés ────────────────────────
export const onConcoursCreated = onDocumentCreated(
  "concours/{concoursId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const title = data.title as string;
    const schoolName = (data.school_name as string) ?? "une école";
    const ville = data.ville as string | undefined;
    const concoursId = event.params.concoursId;

    const body = ville
      ? `Nouveau concours à ${ville} : "${title}" — ${schoolName}`
      : `Nouveau concours : "${title}" — ${schoolName}`;

    // Diffusion à tous les abonnés du topic 'concours'
    await messaging.send({
      topic: "concours",
      notification: { title: "🎓 Nouveau Concours", body },
      data: { type: "concours", id: concoursId },
      android: {
        priority: "high",
        notification: { channelId: "mhd_high_importance", sound: "default" },
      },
      apns: { payload: { aps: { sound: "default", badge: 1 } } },
    });

    // Diffusion au topic de la ville si disponible
    if (ville) {
      const safeTopic = ville
        .toLowerCase()
        .replace(/\s+/g, "_")
        .replace(/[^a-z0-9_-]/g, "");
      if (safeTopic) {
        await messaging.send({
          topic: `ville_${safeTopic}`,
          notification: { title: "🎓 Nouveau Concours dans votre ville", body },
          data: { type: "concours", id: concoursId },
          android: {
            priority: "high",
            notification: { channelId: "mhd_high_importance", sound: "default" },
          },
        });
      }
    }

    console.log(`[Concours] Notification envoyée pour : ${title}`);
  }
);
