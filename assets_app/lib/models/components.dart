class Components {
  final String id;
  final String? locationId;
  final String name;
  final String? parentId;
  final String? sensorType;
  final String? status;

  Components({
    required this.id,
    this.locationId,
    required this.name,
    this.parentId,
    this.sensorType,
    this.status,
  });

  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(
      id: json['id'],
      locationId: json['locationId'],
      name: json['name'],
      parentId: json['parentId'],
      sensorType: json['sensorType'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'name': name,
      'parentId': parentId,
      'sensorType': sensorType,
      'status': status,
    };
  }
}
