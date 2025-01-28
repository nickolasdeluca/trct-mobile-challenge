import 'package:assets_app/models/resources.dart';

class TreeNode {
  final Resource data;
  TreeNode? parent;
  final List<TreeNode> children;
  int depth;

  TreeNode({
    required this.data,
    required this.parent,
    this.children = const [],
    this.depth = 0,
  });
}
