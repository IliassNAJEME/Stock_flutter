import 'package:dio/dio.dart';

class AppDio {
  AppDio()
      : client = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: const {'Content-Type': 'application/json'},
          ),
        );

  final Dio client;
}
