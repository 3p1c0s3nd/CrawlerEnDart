import 'package:dio/dio.dart';
import '../colors.dart';

class ClassScanner {
  final List<String> urls;

  // Lista de posibles errores SQLi o XSS
  final List<String> errors = [
    // SQLite3
    "<b>Warning</b>:  SQLite3",
    "unrecognized token:",
    "Unable to prepare statement:",

    // SQL syntax error MYSQL
    "You have an error in your SQL",
    "<b>Warning</b>:  MySQLi",
    "You have an error in your SQL syntax",
    "mysql_fetch_array()",
    "mysql_fetch_assoc()",
    "mysql_fetch_object()",
    "mysql_fetch_row()",
    "mysql_num_rows()",

    // POSTGRESQL
    "ERROR:  syntax error",
  ];

  ClassScanner({required this.urls});

  bool checkError(String sourceCode) {
    return errors.any((error) => sourceCode.contains(error));
  }

  Future<bool> scan() async {
    final dio = Dio();

    for (var url in urls) {
      if (hasHttpOrHttpsScheme(url)) {
        try {
          final urlTest = changeValueParam(url, '\'');
          printColor('Scanning $urlTest', 'cualquiera');

          final response = await dio.get(urlTest);

          if (response.data != null && checkError(response.data)) {
            printColor('Error found in $urlTest', 'green');
            return true;
          } else {
            printColor('No error found in $urlTest', 'red');
          }
        } on DioException catch (_) {
          printColor("Error en la conexion", 'red');
        } catch (e) {
          print(e);
        }
      }
    }

    return false;
  }

  String changeValueParam(String url, String payload) {
    Uri uri = Uri.parse(url);
    Map<String, String> params = Map.from(uri.queryParameters);

    for (var key in params.keys) {
      params[key] = payload;
    }

    return uri.replace(queryParameters: params).toString();
  }

  bool hasHttpOrHttpsScheme(String url) {
    Uri uri = Uri.parse(url);
    return uri.scheme == 'http' || uri.scheme == 'https';
  }
}
