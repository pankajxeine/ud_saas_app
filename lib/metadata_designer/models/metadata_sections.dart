class MetadataSection {
  const MetadataSection({
    required this.id,
    required this.title,
    this.icon,
    this.permission = const {},
  });

  final String id;
  final String title;
  final String? icon;
  final Map<String, String> permission;

  factory MetadataSection.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    return MetadataSection(
      id: id,
      title: json['title']?.toString() ?? id,
      icon: json['icon']?.toString().trim().isEmpty == true
          ? null
          : json['icon']?.toString().trim(),
      permission: _parsePermissions(json['permission'] ?? json['permissions'], id),
    );
  }

  static Map<String, String> _parsePermissions(dynamic value, String id) {
    if (value is Map) {
      return value.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }

    final prefix = value?.toString().trim().isNotEmpty == true
        ? value.toString().trim()
        : id;
    return {
      'read': '$prefix.read',
      'edit': '$prefix.edit',
      'delete': '$prefix.delete',
      'create': '$prefix.create',
    };
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    if (icon != null && icon!.isNotEmpty) 'icon': icon,
    'permission': permission,
  };
}
