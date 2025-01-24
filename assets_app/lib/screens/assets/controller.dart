import 'dart:async';

import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/treeview.dart';
import 'package:assets_app/models/resources.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AssetsController {
  late TextEditingController searchController;
  late ValueNotifier<bool> sensorController;
  late ValueNotifier<bool> statusController;
  Timer? _debounce;
  List<TreeNode> treeData = [];
  ValueNotifier<List<TreeNode>> presentable = ValueNotifier([]);

  init({required String companyId}) {
    searchController = TextEditingController();
    sensorController = ValueNotifier<bool>(false);
    statusController = ValueNotifier<bool>(false);

    sensorController.addListener(filter);
    statusController.addListener(filter);
    searchController.addListener(_onTextChanged);

    getAssets(companyId: companyId);
  }

  Function()? updateViewCallBack;

  dispose() {
    sensorController.removeListener(filter);
    statusController.removeListener(filter);
    searchController.removeListener(_onTextChanged);

    searchController.dispose();
    sensorController.dispose();
    statusController.dispose();

    _debounce?.cancel();
  }

  VoidCallback get filter => () {
        if (_debounce?.isActive ?? false) {
          _debounce?.cancel();
        }

        doFilter();
      };

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 2), () => doFilter());
  }

  TreeNode? filterProc(
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
        resultingNode = filterProc(
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

  Future<void> doFilter() async {
    List<TreeNode> filteredData = [];

    if (searchController.text.isNotEmpty ||
        sensorController.value ||
        statusController.value) {
      for (TreeNode node in treeData) {
        TreeNode? result = filterProc(node: node, shouldCheckParent: true);

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

      presentable.value = filteredData;
    } else {
      presentable.value = treeData;
    }

    return;
  }

  Future<bool> getAssets({required String companyId}) async {
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

    presentable.value = treeData;

    return true;
  }
}
