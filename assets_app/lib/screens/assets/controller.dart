import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/treeview.dart';
import 'package:assets_app/models/assets.dart';
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
    List<Asset> locations = [];

    for (Map<String, dynamic> object in companyLocations.data) {
      locations.add(Asset.fromJson(object));
    }

    for (Asset location
        in locations.where((element) => element.parentId == null)) {
      treeData.add(
        TreeNode(
          data: location,
          children: [],
        ),
      );
    }

    for (Asset location
        in locations.where((element) => element.parentId != null)) {
      TreeNode parent = treeData.firstWhere(
        (element) => element.data.id == location.parentId,
      );

      parent.children.add(
        TreeNode(
          data: location,
          children: [],
        ),
      );
    }

    locations.clear();
  }

  Response companyAssets = await api.sendGet(
    route: ApiMap.assetsByCompanyId(companyId: companyId),
  );

  if (companyAssets.statusCode == 200) {
    List<Asset> assets = [];

    for (Map<String, dynamic> object in companyAssets.data) {
      assets.add(Asset.fromJson(object));
    }

    for (Asset asset in assets.where((element) => element.parentId == null)) {
      if (asset.locationId != null) {
        bool found = false;
        for (TreeNode node in treeData) {
          if (node.children.isNotEmpty) {
            for (TreeNode child in node.children) {
              if (child.data.id == asset.locationId) {
                child.children.add(
                  TreeNode(
                    data: asset,
                    children: [],
                  ),
                );

                found = true;
              }
            }
          }

          if ((!found) && (node.data.id == asset.locationId)) {
            node.children.add(
              TreeNode(
                data: asset,
                children: [],
              ),
            );
          }
        }
      }
    }

    for (Asset asset in assets.where((element) => element.parentId != null)) {
      for (TreeNode node in treeData) {
        analyzeNode(node: node, asset: asset, destination: node.children);
      }
    }

    for (Asset asset in assets.where(
        (element) => element.parentId == null && element.locationId == null)) {
      treeData.add(
        TreeNode(
          data: asset,
          children: [],
        ),
      );
    }
  }

  return true;
}
