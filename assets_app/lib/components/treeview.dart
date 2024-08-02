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

void analyzeNode(
    {required TreeNode node, required Asset asset, required List destination}) {
  if (node.children.isEmpty) {
    if (node.data.id == asset.parentId) {
      node.children.add(node);
    } else {
      return;
    }
  } else {
    for (TreeNode child in node.children) {
      if (child.data.id == asset.parentId) {
        child.children.add(
          TreeNode(
            data: asset,
            children: [],
          ),
        );
        return;
      } else {
        analyzeNode(node: child, asset: asset, destination: destination);
      }
    }
  }
}
