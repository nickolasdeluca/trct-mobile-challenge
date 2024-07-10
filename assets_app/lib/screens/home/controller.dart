import 'package:assets_app/api/map.dart';
import 'package:assets_app/api/methods.dart';
import 'package:assets_app/models/companies.dart';
import 'package:dio/dio.dart';

Future<List<Company>> getUnits() async {
  Api api = Api();

  Response response = await api.sendGet(route: ApiMap.companies);

  if (response.statusCode == 200) {
    List<Company> companies = [];

    for (var company in response.data) {
      companies.add(Company.fromJson(company));
    }

    return companies;
  } else {
    throw Exception('Failed to load companies');
  }
}
