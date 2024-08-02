class Asset {
  String id;
  String? locationId;
  String name;
  String? parentId;
  String? status;
  String? gatewayId;
  String? sensorType;

  Asset({
    required this.id,
    this.locationId,
    required this.name,
    this.parentId,
    this.status,
    this.gatewayId,
    this.sensorType,
  });

  factory Asset.fromJson(Map<String, dynamic> data) {
    Asset asset = Asset(id: data['id'], name: data['name']);

    asset.locationId = data['locationId'];
    asset.parentId = data['parentId'];
    asset.gatewayId = data['gatewayId'];
    asset.sensorType = data['sensorType'];
    asset.status = data['status'];

    return asset;
  }
}
