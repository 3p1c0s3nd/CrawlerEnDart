import 'dart:async';
import 'package:crawler/class/ClassFilter.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class WebCrawler {
  final Dio dio;
  final int maxDepth;
  final String dominio;

  WebCrawler(this.dio, this.maxDepth, this.dominio);

  Future<void> crawl(String url, {int depth = 0}) async {
    final urlFilter = ClassFilter();
    if (depth > maxDepth || !urlFilter.shouldProcessUrl(url)) {
      return;
    }

    if (!verificaUrl(url)) {
      return;
    }

    try {
      print('Crawling $url (Depth: $depth)');
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final document = parse(response.data);
        // Aquí puedes realizar acciones con la página, como extraer información o seguir enlaces.

        // Obtén todos los enlaces de la página
        final links = document.querySelectorAll('a[href]');
        for (var link in links) {
          final nextUrl = link.attributes['href'];
          if (nextUrl != null && nextUrl.isNotEmpty) {
            // Realiza una nueva exploración recursiva para cada enlace
            await crawl(nextUrl, depth: depth + 1);
          }
        }
      }
    } catch (e) {
      print('Error al cargar la URL $url: $e');
    }
  }

  bool verificaUrl(String url) {
    final uri = Uri.parse(url);
    final host = uri.host;
 
    if (host == "") {
      return false;
    }
    return true;
  }
}
