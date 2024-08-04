import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/treeview.dart';
import 'package:assets_app/models/resources.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

TextEditingController searchController = TextEditingController();
ValueNotifier<bool> sensorController = ValueNotifier<bool>(false);
ValueNotifier<bool> criticalController = ValueNotifier<bool>(false);

List<TreeNode> treeData = [];

Future<bool> getAssets({required String companyId}) async {
  treeData.clear();

  Api api = Api();

  Response companyLocations = await api.sendGet(
    route: ApiMap.locationsByCompanyId(companyId: companyId),
  );

  if (companyLocations.statusCode == 200) {
    List<Resource> locations = [];

    for (Map<String, dynamic> object in companyLocations.data) {
      locations.add(Resource.fromJson(
        data: object,
        type: ResourceType.location,
      ));
    }

    fillTree(source: locations, destination: treeData);

    locations.clear();
  }

  Response companyAssets = await api.sendGet(
    route: ApiMap.assetsByCompanyId(companyId: companyId),
  );

  if (companyAssets.statusCode == 200) {
    List<Resource> assets = [];

    for (Map<String, dynamic> object in companyAssets.data) {
      assets.add(Resource.fromJson(
        data: object,
        type: ResourceType.asset,
      ));
    }

    fillTree(source: assets, destination: treeData);

    assets.clear();
  }

  return true;
}
