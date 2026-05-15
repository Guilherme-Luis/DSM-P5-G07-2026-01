class ApiConstants {
  //http://localhost:3003/development/api/docs
  //http://mini-box-ferreira-api.canadacentral.cloudapp.azure.com/production/api/docs/
  static const String baseUrl = 'http://mini-box-ferreira-api.canadacentral.cloudapp.azure.com';

  static const String environment = 'production';

  static String get apiBase => '$baseUrl/$environment/api';
}