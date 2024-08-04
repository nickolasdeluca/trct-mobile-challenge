import 'package:assets_app/constants/assets.dart';
import 'package:assets_app/models/resources.dart';
import 'package:flutter/material.dart';

class TreeNode {
  final Resource data;
  final List<TreeNode> children;
  final int depth;

  TreeNode({required this.data, this.children = const [], this.depth = 0});
}

class TreeView extends StatelessWidget {
  final List<TreeNode> data;

  const TreeView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children:
          data.map((node) => _buildNode(context: context, node: node)).toList(),
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

  Widget _buildNode({required BuildContext context, required TreeNode node}) {
    Widget widget;

    widget = node.children.isEmpty
        ? ListTile(
            minVerticalPadding: 0,
            minTileHeight: 30,
            title: Padding(
              padding: EdgeInsets.only(left: node.depth * 10.0),
              child: Row(
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
            ),
          )
        : Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: ListTileTheme.of(context).copyWith(
                minVerticalPadding: 0,
                minTileHeight: 30,
              ),
            ),
            child: ExpansionTile(
              shape: const Border(),
              title: Padding(
                padding: EdgeInsets.only(left: node.depth * 10.0),
                child: Row(
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
              ),
              children: node.children
                  .map((child) => _buildNode(context: context, node: child))
                  .toList(),
            ),
          );

    return widget;
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
    currentNode.children
        .add(TreeNode(data: asset, children: [], depth: currentNode.depth + 1));
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
