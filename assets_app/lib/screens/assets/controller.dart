import 'dart:async';

import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/components/tree_view/tree_node.dart';
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

      debouncer.run(applyFilter);
    }
  }

  void _statusListener() => debouncer.run(applyFilter);
  void _sensorListener() => debouncer.run(applyFilter);

  TreeNode? _filter({
    required TreeNode node,
    required bool shouldCheckParent,
  }) {
    bool match = true;

    // Apply filters
    if (searchController.text.isNotEmpty) {
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

    // If the node matches, return it
    if (match) return node;

    // Check children recursively
    for (TreeNode child in node.children) {
      TreeNode? result = _filter(node: child, shouldCheckParent: false);

      if (result != null) {
        // If a child matches, include the parent branch
        return node;
      }
    }

    // If the node has a parent and should be included, return the parent branch
    if (shouldCheckParent && node.parent != null) {
      return getParent(node: node);
    }

    return null;
  }

  Future<void> applyFilter() async {
    final Set<String> seenIds = {}; // Track unique nodes
    List<TreeNode> filteredData = [];

    if (searchController.text.isNotEmpty ||
        sensorController.value ||
        statusController.value) {
      for (TreeNode node in treeData) {
        TreeNode? result = _filter(node: node, shouldCheckParent: true);

        // Include the parent branch if a child matches
        while (result != null) {
          if (seenIds.add(result.data.id)) {
            filteredData.add(result);
          }

          result = result.parent;
        }
      }

      presentable.value = filteredData;
    } else {
      presentable.value = treeData;
    }
  }

  TreeNode? getParent({required TreeNode node}) {
    TreeNode? parent = node;

    while (parent?.parent != null) {
      parent = parent?.parent;
    }

    return parent;
  }

  void fillTree({
    /// List of location resources
    required List<Resource> locations,

    /// List of asset resources
    required List<Resource> assets,

    /// Destination list to store the root nodes of the tree
    required List<TreeNode> destination,
  }) {
    // Map to store all nodes by their ID
    final Map<String, TreeNode> nodes = {};
    // Map to store children nodes that are waiting for their parent to be created
    final Map<String, List<TreeNode>> pendingChildren = {};

    // Map to store asset nodes that are waiting for their location to be created
    final Map<String, List<TreeNode>> pendingAssets = {};

    // Process each location resource
    for (final location in locations) {
      final node = TreeNode(
        data: location,
        parent: null,
        children: [],
        depth: 0,
      );

      nodes[location.id] = node;

      if (location.parentId != null) {
        // Add the node to its parent's children list
        if (nodes.containsKey(location.parentId)) {
          final parent = nodes[location.parentId]!;

          parent.children.add(node);

          node.parent = parent;
          node.depth = parent.depth + 1;
        } else {
          // Add the node to pendingChildren if the parent is not yet created
          pendingChildren.putIfAbsent(location.parentId!, () => []).add(node);
        }
      } else {
        // Add the node to the destination if it has no parent
        destination.add(node);
      }

      // Add pending children to the node
      if (pendingChildren.containsKey(location.id)) {
        for (final child in pendingChildren.remove(location.id)!) {
          node.children.add(child);

          child.parent = node;
          child.depth = node.depth + 1;
        }
      }
    }

    // Process each asset resource
    for (final asset in assets) {
      final node = TreeNode(
        data: asset,
        parent: null,
        children: [],
        depth: 0,
      );

      nodes[asset.id] = node;

      if (asset.parentId != null) {
        // Add the node to its parent's children list
        if (nodes.containsKey(asset.parentId)) {
          final parent = nodes[asset.parentId]!;

          parent.children.add(node);

          node.parent = parent;
          node.depth = parent.depth + 1;
        } else {
          // Add the node to pendingChildren if the parent is not yet created
          pendingChildren.putIfAbsent(asset.parentId!, () => []).add(node);
        }
      } else if (asset.locationId != null) {
        // Add the node to its location's children list
        if (nodes.containsKey(asset.locationId)) {
          final locationNode = nodes[asset.locationId]!;

          locationNode.children.add(node);

          node.parent = locationNode;
          node.depth = locationNode.depth + 1;
        } else {
          // Add the node to pendingAssets if the location is not yet created
          pendingAssets.putIfAbsent(asset.locationId!, () => []).add(node);
        }
      } else {
        // Add the node to the destination if it has no parent or location
        destination.add(node);
      }

      // Add pending children to the node
      if (pendingChildren.containsKey(asset.id)) {
        for (final child in pendingChildren.remove(asset.id)!) {
          node.children.add(child);

          child.parent = node;
          child.depth = node.depth + 1;
        }
      }
    }

    // Process pending assets that are waiting for their location to be created
    for (final locationId in pendingAssets.keys) {
      if (nodes.containsKey(locationId)) {
        final locationNode = nodes[locationId]!;

        // Add the asset to its location's children list
        for (final asset in pendingAssets.remove(locationId)!) {
          locationNode.children.add(asset);

          asset.parent = locationNode;
          asset.depth = locationNode.depth + 1;
        }
      } else {
        // Add the asset to the destination if its location is not created
        for (final asset in pendingAssets[locationId]!) {
          destination.add(asset);
        }
      }
    }
  }

  Future<bool> getAssets({required String companyId}) async {
    treeData.clear();

    await Future.delayed(Duration(seconds: 1));

    Api api = Api();

    Response companyLocations = await api.sendGet(
      route: ApiMap.locationsByCompanyId(companyId: companyId),
    );

    List<Resource> locations = [];

    if (companyLocations.statusCode == 200) {
      for (Map<String, dynamic> data in companyLocations.data) {
        Resource location = Resource.fromJson(
          data: data,
          type: ResourceType.location,
        );

        locations.add(location);
      }
    }

    Response companyAssets = await api.sendGet(
      route: ApiMap.assetsByCompanyId(companyId: companyId),
    );

    List<Resource> assets = [];

    if (companyAssets.statusCode == 200) {
      for (Map<String, dynamic> object in companyAssets.data) {
        Resource asset = Resource.fromJson(
          data: object,
          type: ResourceType.asset,
        );

        assets.add(asset);
      }
    }

    // Fill the tree with the locations and assets
    fillTree(locations: locations, assets: assets, destination: treeData);

    locations.clear();
    assets.clear();

    // Create a clone of the tree data to avoid modifying the original list
    presentable.value = treeData;

    return true;
  }
}
