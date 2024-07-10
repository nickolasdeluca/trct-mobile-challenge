import 'package:assets_app/screens/assets/view.dart';
import 'package:assets_app/components/appbar.dart';
import 'package:assets_app/constants/palette.dart';
import 'package:assets_app/screens/home/controller.dart';
import 'package:assets_app/models/companies.dart';
import 'package:flutter/material.dart';

class UnitTile extends StatelessWidget {
  final Company company;

  const UnitTile({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30,
        left: 21,
        right: 22,
        bottom: 10,
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => CompanyAssets(
              company: company,
            ),
          ),
        ),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              5,
            ),
            color: Palette.chefchaouenBlue,
          ),
          child: Center(
            child: ListTile(
              leading: const Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
              ),
              title: Text(
                company.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AssetsAppBar(),
      body: SafeArea(
        child: FutureBuilder(
          future: getUnits(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<Company>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UnitTile(company: snapshot.data![index]);
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
