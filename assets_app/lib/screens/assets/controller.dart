import 'dart:async';

import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/lazy_tree_view.dart';
import 'package:assets_app/helpers/debouncer.dart';
import 'package:assets_app/models/resources.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AssetsController {
  late TextEditingController searchController;
  late ValueNotifier<bool> sensorController;
  late ValueNotifier<bool> statusController;
  final Debouncer debouncer = Debouncer(milliseconds: 500);
  List<TreeNode> treeData = [];
  ValueNotifier<List<TreeNode>?> presentable = ValueNotifier(null);
  String _currentSearchFilterCriteria = '';

  init({required String companyId}) {
    searchController = TextEditingController();
    searchController.addListener(_onTextChanged);

    sensorController = ValueNotifier<bool>(false);
    sensorController.addListener(_sensorListener);

    statusController = ValueNotifier<bool>(false);
    statusController.addListener(_statusListener);

    getAssets(companyId: companyId);
  }

  Function()? updateViewCallBack;

  dispose() {
    searchController.removeListener(_onTextChanged);
    searchController.dispose();

    sensorController.removeListener(_sensorListener);
    sensorController.dispose();

    statusController.removeListener(_statusListener);
    statusController.dispose();

    debouncer.dispose();
  }

  void _onTextChanged() {
    if (searchController.text != _currentSearchFilterCriteria) {
      _currentSearchFilterCriteria = searchController.text;
      debouncer.run(doFilter);
    }
  }

  void _statusListener() => debouncer.run(doFilter);
  void _sensorListener() => debouncer.run(doFilter);

  TreeNode? filterProc({
    required TreeNode node,
    required bool shouldCheckParent,
  }) {
    bool match = true;
    TreeNode? resultingNode;

    if (match && searchController.text.isNotEmpty) {
      match = node.data.name.toLowerCase().contains(
            searchController.text.toLowerCase(),
          );
    }

    if (match && sensorController.value) {
      match = node.data.sensorType == SensorType.energy;
    }

    if (match && statusController.value) {
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

  bool isParentOrLocationMatch(TreeNode node, Resource asset) {
    return node.data.id == asset.parentId || node.data.id == asset.locationId;
  }

  TreeNode? getParent({required TreeNode node}) {
    TreeNode? parent = node;

    while (parent?.parent != null) {
      parent = parent?.parent;
    }

    return parent;
  }

  bool analyzeNode({
    required TreeNode currentNode,
    required Resource asset,
    required List<TreeNode> destination,
  }) {
    if (isParentOrLocationMatch(currentNode, asset)) {
      currentNode.children.add(
        TreeNode(
          data: asset,
          parent: currentNode,
          children: [],
          depth: currentNode.depth + 1,
        ),
      );
      return true;
    }

    for (TreeNode child in currentNode.children) {
      if (analyzeNode(
        currentNode: child,
        asset: asset,
        destination: destination,
      )) {
        return true;
      }
    }

    return false;
  }

  void fillTree({
    required List<Resource> source,
    required List<TreeNode> destination,
    final int analyzeDepth = 0,
  }) {
    List<Resource> sideList = [];

    for (Resource resource in source) {
      bool found = false;

      if (resource.parentId == null && resource.locationId == null) {
        destination.add(TreeNode(data: resource, parent: null, children: []));
        continue;
      }

      for (TreeNode node in destination) {
        found = analyzeNode(
          currentNode: node,
          asset: resource,
          destination: destination,
        );

        if (found) {
          break;
        }
      }

      if (!found) {
        sideList.add(resource);
      }
    }

    if ((sideList.isNotEmpty) && (analyzeDepth < 100)) {
      fillTree(
          source: sideList,
          destination: destination,
          analyzeDepth: analyzeDepth + 1);
    }
  }

  Future<bool> getAssets({required String companyId}) async {
    treeData.clear();

    await Future.delayed(Duration(seconds: 1));

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
