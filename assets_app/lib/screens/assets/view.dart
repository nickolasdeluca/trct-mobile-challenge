import 'package:assets_app/components/appbar.dart';
import 'package:assets_app/components/buttons.dart';
import 'package:assets_app/components/inputs.dart';
import 'package:assets_app/components/lazy_tree_view.dart';
import 'package:assets_app/models/companies.dart';
import 'package:assets_app/screens/assets/controller.dart';
import 'package:flutter/material.dart';

class CompanyAssets extends StatefulWidget {
  const CompanyAssets({super.key, required this.company});

  final Company company;

  @override
  State<CompanyAssets> createState() => _CompanyAssetsState();
}

class _CompanyAssetsState extends State<CompanyAssets> {
  late AssetsController controller;

  @override
  void initState() {
    controller = AssetsController();

    controller.updateViewCallBack = () => setState(() {});

    controller.init(companyId: widget.company.id);

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AssetsAppBar(
        title: 'Assets',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            children: [
              Input(controller: controller.searchController),
              Row(
                children: [
                  ToggleButton(
                    controller: controller.sensorController,
                    icon: Icons.energy_savings_leaf_outlined,
                    label: 'Sensor de Energia',
                    onPressed: () => controller.doFilter(),
                  ),
                  const VerticalDivider(width: 10),
                  ToggleButton(
                    controller: controller.statusController,
                    icon: Icons.error_outline_outlined,
                    label: 'Crítico',
                    onPressed: () => controller.doFilter(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ValueListenableBuilder(
                  builder: (context, value, child) => LazyTreeView(
                    data: controller.presentable.value,
                  ),
                  valueListenable: controller.presentable,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
