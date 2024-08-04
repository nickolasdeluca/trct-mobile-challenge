class Resource {
  String id;
  String? locationId;
  String name;
  String? parentId;
  String? status;
  String? gatewayId;
  String? sensorType;

  Resource({
    required this.id,
    this.locationId,
    required this.name,
    this.parentId,
    this.status,
    this.gatewayId,
    this.sensorType,
  });

  factory Resource.fromJson(Map<String, dynamic> data) {
    Resource asset = Resource(id: data['id'], name: data['name']);

    asset.locationId = data['locationId'];
    asset.parentId = data['parentId'];
    asset.gatewayId = data['gatewayId'];
    asset.sensorType = data['sensorType'];
    asset.status = data['status'];

    return asset;
  }
}
