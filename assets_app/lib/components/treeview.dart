import 'package:assets_app/constants/assets.dart';
import 'package:assets_app/models/resources.dart';
import 'package:flutter/material.dart';

class TreeNode {
  final Resource data;
  final List<TreeNode> children;

  TreeNode({required this.data, this.children = const []});
}

class TreeView extends StatelessWidget {
  final List<TreeNode> data;

  const TreeView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: data.map((node) => _buildNode(node)).toList(),
    );
  }

  Widget _leadingIcon({required Resource resource}) {
    bool isComponent = resource.type == ResourceType.asset &&
        (resource.sensorType == SensorType.energy ||
            resource.sensorType == SensorType.vibration) &&
        (resource.status == Status.alert ||
            resource.status == Status.operating);

    String asset = resource.type == ResourceType.location
        ? Assets.png.locationIcon
        : Assets.png.assetIcon;

    if (isComponent) {
      asset = Assets.png.componentIcon;
    }

    Image image = Image.asset(asset);

    return SizedBox(width: 24, height: 24, child: image);
  }

  Widget? _buildTrailing({required Resource resource}) {
    Icon? icon;

    if (resource.sensorType == SensorType.energy) {
      icon = const Icon(
        Icons.bolt,
        color: Colors.green,
        size: 22,
      );
    }

    if (resource.status == Status.alert) {
      icon = const Icon(
        Icons.circle,
        color: Colors.red,
        size: 14,
      );
    }

    return icon;
  }

  Widget _buildNode(TreeNode node) {
    if (node.children.isEmpty) {
      return ListTile(
        title: Row(
          children: [
            _leadingIcon(resource: node.data),
            const VerticalDivider(width: 5),
            Flexible(
              child: Text(
                node.data.name,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const VerticalDivider(width: 5),
            _buildTrailing(resource: node.data) ?? Container(),
          ],
        ),
      );
    }

    return ExpansionTile(
      title: Row(
        children: [
          _leadingIcon(resource: node.data),
          const VerticalDivider(width: 5),
          Flexible(
            child: Text(
              node.data.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      children: node.children.map((child) => _buildNode(child)).toList(),
    );
  }
}

bool isParentOrLocationMatch(TreeNode node, Resource asset) {
  return node.data.id == asset.parentId || node.data.id == asset.locationId;
}

bool analyzeNode({
  required TreeNode currentNode,
  required Resource asset,
  required List<TreeNode> destination,
}) {
  if (isParentOrLocationMatch(currentNode, asset)) {
    currentNode.children.add(TreeNode(data: asset, children: []));
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
}) {
  List<Resource> sideList = [];

  for (Resource resource in source) {
    bool found = false;

    if (resource.parentId == null && resource.locationId == null) {
      destination.add(TreeNode(data: resource, children: []));
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

  if (sideList.isNotEmpty) {
    fillTree(source: sideList, destination: destination);
  }
}
