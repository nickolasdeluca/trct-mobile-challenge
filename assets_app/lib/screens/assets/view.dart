import 'package:assets_app/components/appbar.dart';
import 'package:assets_app/models/companies.dart';
import 'package:flutter/material.dart';

class CompanyAssets extends StatefulWidget {
  const CompanyAssets({super.key, required this.company});

  final Company company;

  @override
  State<CompanyAssets> createState() => _CompanyAssetsState();
}

class _CompanyAssetsState extends State<CompanyAssets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AssetsAppBar(
        title: 'Assets',
      ),
      body: Center(
        child: Text(widget.company.name),
      ),
    );
  }
}
