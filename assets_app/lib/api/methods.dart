import 'package:dio/dio.dart';

Response handleException(DioException exception) {
  if (exception.response != null) {
    return exception.response!;
  } else {
    return Response(
      requestOptions: exception.requestOptions,
      statusCode: 500,
      data: {'message': exception.message},
    );
  }
}

class Api {
  Api();

  Future<Response> sendGet({
    required String route,
  }) async {
    Response? response;

    Dio dio = Dio();

    Uri uri = Uri.parse(route);

    try {
      response = await dio.getUri(uri);
    } on DioException catch (e) {
      response = handleException(e);
    }

    return response;
  }
}
