class ApiMap {
  static const String baseUrl = 'https://fake-api.tractian.com';
  static const String companies = '$baseUrl/companies';
  static String locationsByCompanyId({required String companyId}) =>
      '$baseUrl/companies/$companyId/locations';
  static String assetsByCompanyId({required String companyId}) =>
      '$baseUrl/companies/$companyId/assets';
}
