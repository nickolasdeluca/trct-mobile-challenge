import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/treeview.dart';
import 'package:assets_app/models/resources.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

late TextEditingController searchController;
late ValueNotifier<bool> sensorController;
late ValueNotifier<bool> statusController;

List<TreeNode> treeData = [];

Future<bool> getAssets({required String companyId}) async {
  TreeNode? doFilter(
      {required TreeNode node, required bool shouldCheckParent}) {
    bool match = true;
    TreeNode? resultingNode;

    if (searchController.text.isNotEmpty) {
      match = node.data.name.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );
    }

    if (sensorController.value) {
      match = node.data.sensorType == SensorType.energy;
    }

    if (statusController.value) {
      match = node.data.status == Status.alert;
    }

    if (match) {
      resultingNode = node;
    }

    if (((node.parent != null) && ((shouldCheckParent) || (match)))) {
      resultingNode = getParent(node: node);
    }

    if ((!match) && (node.children.isNotEmpty)) {
      for (TreeNode child in node.children) {
        resultingNode = doFilter(
          node: child,
          shouldCheckParent: false,
        );

        if (resultingNode != null) {
          break;
        }
      }
    }

    return resultingNode;
  }

  treeData.clear();

  Api api = Api();

  Response companyLocations = await api.sendGet(
    route: ApiMap.locationsByCompanyId(companyId: companyId),
  );

  if (companyLocations.statusCode == 200) {
    List<Resource> locations = [];

    for (Map<String, dynamic> data in companyLocations.data) {
      Resource location = Resource.fromJson(
        data: data,
        type: ResourceType.location,
      );

      locations.add(location);
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
      Resource asset = Resource.fromJson(
        data: object,
        type: ResourceType.asset,
      );

      assets.add(asset);
    }

    fillTree(source: assets, destination: treeData);

    assets.clear();
  }

  if (searchController.text.isNotEmpty ||
      sensorController.value ||
      statusController.value) {
    List<TreeNode> filteredData = [];

    for (TreeNode node in treeData) {
      TreeNode? result = doFilter(node: node, shouldCheckParent: true);

      if (result != null) {
        bool alreadyExists = false;

        for (TreeNode node in filteredData) {
          if (node.data.id == result.data.id) {
            alreadyExists = true;
          }
        }

        if (!alreadyExists) {
          filteredData.add(result);
        }
      }
    }

    treeData = filteredData;
  }

  return true;
}
