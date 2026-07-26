/// Sous-option tarifée d'un service (ex. CNI 5 000 / Passeport 15 000).
class ServiceSubOption {
  final String id;
  final String label;
  final double price;

  const ServiceSubOption({
    required this.id,
    required this.label,
    required this.price,
  });

  factory ServiceSubOption.fromJson(Map<String, dynamic> json) {
    return ServiceSubOption(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'price': price};
}

class Services {
  final String id;
  final String name;
  final String desc;
  final String? iconUrl;
  final double? basePrice;
  final List<ServiceSubOption>? subOptions;

  /// Si renseigné, le CTA du service redirige vers WhatsApp (sans compte).
  final String? whatsappNumber;

  Services({
    required this.id,
    required this.name,
    required this.desc,
    this.iconUrl,
    this.basePrice,
    this.subOptions,
    this.whatsappNumber,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      iconUrl: json['icon_url'],
      basePrice:
          (json['base_price'] is num) ? (json['base_price'] as num).toDouble() : null,
      subOptions: (json['sub_options'] is List)
          ? (json['sub_options'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ServiceSubOption.fromJson)
              .toList()
          : null,
      whatsappNumber: json['whatsapp_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'icon_url': iconUrl,
      'base_price': basePrice,
      'sub_options': subOptions?.map((o) => o.toJson()).toList(),
      'whatsapp_number': whatsappNumber,
    };
  }

  Services copyWith({String? name, String? desc, String? iconUrl}) {
    return Services(
      id: id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      iconUrl: iconUrl ?? this.iconUrl,
      basePrice: basePrice,
      subOptions: subOptions,
      whatsappNumber: whatsappNumber,
    );
  }
}
