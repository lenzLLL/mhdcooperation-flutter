import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync } from 'fs';

// Lire l'icône fournie et l'encoder en base64 pour l'embarquer dans le SVG
const iconBuffer = readFileSync('assets/images/icon (2).png');
const iconBase64 = iconBuffer.toString('base64');

// SVG : fond dégradé + icône centrée avec léger padding
const svg = `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 1024 1024">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#1A3A6E"/>
      <stop offset="100%" stop-color="#3BA8D5"/>
    </linearGradient>
  </defs>
  <!-- Fond dégradé plein (les OS appliquent leur propre masque arrondi) -->
  <rect width="1024" height="1024" fill="url(#bg)"/>
  <!-- Icône centrée avec padding de 80px de chaque côté -->
  <image href="data:image/png;base64,${iconBase64}" x="80" y="80" width="864" height="864"/>
</svg>`;

const resvg = new Resvg(svg, {
  fitTo: { mode: 'width', value: 1024 },
  font: { loadSystemFonts: false },
});

const pngBuffer = resvg.render().asPng();
writeFileSync('assets/images/app_icon.png', pngBuffer);
console.log(`✅  app_icon.png généré (${pngBuffer.length} bytes)`);
