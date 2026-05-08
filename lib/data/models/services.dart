class Services {
  final String id;
  final String name;
  final String desc;
  final String? iconUrl;

  Services({
    required this.id,
    required this.name,
    required this.desc,
    this.iconUrl,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      iconUrl: json['icon_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'desc': desc, 'icon_url': iconUrl};
  }

  Services copyWith({String? name, String? desc, String? iconUrl}) {
    return Services(
      id: id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}
