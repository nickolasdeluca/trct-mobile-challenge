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

  for (Resource asset in source) {
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
