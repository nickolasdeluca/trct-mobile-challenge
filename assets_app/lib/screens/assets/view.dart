import 'dart:async';

import 'package:assets_app/components/appbar.dart';
import 'package:assets_app/components/buttons.dart';
import 'package:assets_app/components/inputs.dart';
import 'package:assets_app/components/treeview.dart';
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
  Timer? _debounce;

  VoidCallback get filter => () {
        if (_debounce?.isActive ?? false) {
          _debounce?.cancel();
        }

        setState(() {});
      };

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(seconds: 2), () => setState(() {}));
  }

  @override
  void initState() {
    searchController = TextEditingController();
    sensorController = ValueNotifier<bool>(false);
    statusController = ValueNotifier<bool>(false);

    sensorController.addListener(filter);
    statusController.addListener(filter);
    searchController.addListener(_onTextChanged);

    super.initState();
  }

  @override
  void dispose() {
    sensorController.removeListener(filter);
    statusController.removeListener(filter);
    searchController.removeListener(_onTextChanged);

    searchController.dispose();
    sensorController.dispose();
    statusController.dispose();

    _debounce?.cancel();

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
              Input(controller: searchController),
              Row(
                children: [
                  ToggleButton(
                    controller: sensorController,
                    icon: Icons.energy_savings_leaf_outlined,
                    label: 'Sensor de Energia',
                  ),
                  const VerticalDivider(width: 10),
                  ToggleButton(
                    controller: statusController,
                    icon: Icons.error_outline_outlined,
                    label: 'Crítico',
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder(
                  future: getAssets(companyId: widget.company.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return TreeView(data: treeData);
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return const Center(
                          child: Text('Nenhum ativo encontrado'),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
