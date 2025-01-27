import 'package:assets_app/constants/assets.dart';
import 'package:assets_app/models/resources.dart';
import 'package:flutter/material.dart';
import 'dart:collection';

class TreeNode {
  final Resource data;
  final TreeNode? parent;
  final List<TreeNode> children;
  final int depth;

  TreeNode({
    required this.data,
    required this.parent,
    this.children = const [],
    this.depth = 0,
  });
}

class LazyTreeView extends StatefulWidget {
  const LazyTreeView({
    super.key,
    required this.data,
  });

  final List<TreeNode> data;

  @override
  State<LazyTreeView> createState() => _LazyTreeViewState();
}

class _LazyTreeViewState extends State<LazyTreeView> {
  final Map<TreeNode, bool> _expandedNodes = HashMap();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildTreeSliver(widget.data),
      ],
    );
  }

  SliverList _buildTreeSliver(List<TreeNode> nodes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return _buildNode(context, nodes[index]);
        },
        childCount: nodes.length,
      ),
    );
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

  Widget _buildNode(BuildContext context, TreeNode node) {
    bool isExpanded = _expandedNodes[node] ?? false;

    if (node.children.isEmpty) {
      return ListTile(
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
      );
    }

    return Theme(
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
        initiallyExpanded: isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _expandedNodes[node] = expanded;
          });
        },
        children: isExpanded
            ? node.children.map((child) => _buildNode(context, child)).toList()
            : [],
      ),
    );
  }

  Widget _leadingIcon({required Resource resource}) {
    String asset = resource.type == ResourceType.location
        ? Assets.png.locationIcon
        : Assets.png.assetIcon;
    return SizedBox(
      width: 24,
      height: 24,
      child: Image.asset(asset),
    );
  }
}
