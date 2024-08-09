enum ResourceType {
  location,
  asset,
}

enum SensorType {
  vibration,
  energy,
}

enum Status { alert, operating }

class Resource {
  String id;
  String? locationId;
  String name;
  String? parentId;
  Status? status;
  String? gatewayId;
  SensorType? sensorType;
  ResourceType? type;

  Resource({
    required this.id,
    this.locationId,
    required this.name,
    this.parentId,
    this.status,
    this.gatewayId,
    this.sensorType,
    this.type,
  });

  factory Resource.fromJson(
      {required Map<String, dynamic> data, required ResourceType type}) {
    Resource asset = Resource(id: data['id'], name: data['name']);

    asset.locationId = data['locationId'];
    asset.parentId = data['parentId'];
    asset.gatewayId = data['gatewayId'];

    switch (data['sensorType']) {
      case 'vibration':
        asset.sensorType = SensorType.vibration;
        break;
      case 'energy':
        asset.sensorType = SensorType.energy;
        break;
      default:
        asset.sensorType = null;
    }

    switch (data['status']) {
      case 'alert':
        asset.status = Status.alert;
        break;
      case 'operating':
        asset.status = Status.operating;
        break;
      default:
        asset.status = null;
    }

    asset.type = type;

    return asset;
  }
}
