import 'package:assets_app/models/assets.dart';
import 'package:flutter/material.dart';

class TreeNode {
  final Asset data;
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

  Widget _buildNode(TreeNode node) {
    if (node.children.isEmpty) {
      return ListTile(
        title: Text(node.data.name),
        subtitle: Text(node.data.id),
      );
    }

    return ExpansionTile(
      title: Text(node.data.name),
      subtitle: Text(node.data.id),
      children: node.children.map((child) => _buildNode(child)).toList(),
    );
  }
}

bool analyzeNode({
  required TreeNode currentNode,
  required Asset asset,
  required List destination,
}) {
  bool found = false;

  if ((currentNode.data.id == asset.parentId) ||
      (currentNode.data.id == asset.locationId)) {
    currentNode.children.add(TreeNode(data: asset, children: []));
    found = true;
  }

  if ((!found) && (currentNode.children.isNotEmpty)) {
    for (TreeNode child in currentNode.children) {
      if ((child.data.id == asset.parentId) ||
          (child.data.id == asset.locationId)) {
        child.children.add(TreeNode(data: asset, children: []));

        found = true;
        break;
      } else {
        found = analyzeNode(
          currentNode: child,
          asset: asset,
          destination: destination,
        );

        if (found) {
          break;
        }
      }
    }
  }

  return found;
}

void fillTree({
  required List<Asset> source,
  required List<TreeNode> destination,
}) {
  List<Asset> sideList = [];

  for (Asset asset in source) {
    bool found = false;

    if (asset.parentId == null && asset.locationId == null) {
      destination.add(TreeNode(data: asset, children: []));
      continue;
    }

    for (TreeNode node in destination) {
      found = analyzeNode(
        currentNode: node,
        asset: asset,
        destination: destination,
      );

      if (found) {
        break;
      }
    }

    if (!found) {
      sideList.add(asset);
    }
  }

  if (sideList.isNotEmpty) {
    fillTree(source: sideList, destination: destination);
  }
}
