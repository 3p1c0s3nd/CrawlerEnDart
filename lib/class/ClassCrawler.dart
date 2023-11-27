import 'dart:async';
import 'package:crawler/class/ClassFilter.dart';
// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart' show Dio;
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart' show parse;
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import '../colors.dart';

class WebCrawler {
  final int maxDepth;
  final String dominio;
  final bool checkSubdomain;
  final List<String> processedUrls = [];
  final List<String> extensionFilter = [
    ".img",
    ".png",
    ".jpg",
    ".jpeg",
    ".svg",
    ".gif",
    ".pdf",
    ".docx",
    ".doc",
    ".xls",
    ".xlsx",
    ".zip",
    ".rar",
    ".mp4",
    ".mp3",
    ".mov",
    ".avi"
  ];

  WebCrawler(this.maxDepth, this.dominio, this.checkSubdomain);

  Future<List<String>> crawl(String url, {int depth = 0}) async {
    final dio = Dio();
    final urlFilter = ClassFilter();
    if (depth > maxDepth || !urlFilter.shouldProcessUrl(url)) {
      return [];
    }

    try {
      if (hasHttpOrHttpsScheme(url)) {
        final response = await dio.get(url);

        if (response.statusCode == 200) {
          final document = parse(response.data);

          final links = document.querySelectorAll('a');
          for (var link in links) {
            final nextUrl = link.attributes['href'];

            if (nextUrl != null && nextUrl.isNotEmpty) {
              if (checkSubdomain) {
                if (!verificaUrl(nextUrl)) {
                  final fullUrl = addDomainToRelativePath(url, nextUrl);
                  if (!containsPath(processedUrls, fullUrl.toString())) {
                    String extension =
                        path.extension(Uri.parse(fullUrl.toString()).path);
                    if (!extensionFilter.contains(extension)) {
                      processedUrls.add(fullUrl.toString());
                    }
                  }
                } else {
                  if (!containsPath(processedUrls, nextUrl.toString())) {
                    String extension = path.extension(Uri.parse(nextUrl).path);
                    if (!extensionFilter.contains(extension)) {
                      processedUrls.add(nextUrl.toString());
                    }
                  }
                }
              } else {
                if (!verificaUrl(nextUrl)) {
                  final fullUrl = addDomainToRelativePath(url, nextUrl);
                  if (containsUrl(url, fullUrl.toString())) {
                    if (!containsPath(processedUrls, fullUrl.toString())) {
                      String extension =
                          path.extension(Uri.parse(fullUrl.toString()).path);
                      if (!extensionFilter.contains(extension)) {
                        processedUrls.add(fullUrl.toString());
                      }
                    }
                  }
                } else {
                  if (containsUrl(url, nextUrl.toString())) {
                    if (!containsPath(processedUrls, nextUrl.toString())) {
                      String extension =
                          path.extension(Uri.parse(nextUrl).path);
                      if (!extensionFilter.contains(extension)) {
                        processedUrls.add(nextUrl.toString());
                      }
                    }
                  }
                }
              }
            }
          }
        }
        for (var processedUrl in processedUrls) {
          await crawl(processedUrl, depth: depth + 1);
        }
      }
    } catch (e) {
      printColor('Error al cargar la URL $url: $e', 'red');
    }

    return processedUrls;
  }

  bool containsPath(List<String> urlList, String targetUrl) {
    Uri targetUri = Uri.parse(targetUrl);

    return urlList.any((url) {
      Uri uri = Uri.parse(url);
      return uri.path + uri.query == targetUri.path + targetUri.query;
    });
  }

  bool containsUrl(String url, String targetUrl) {
    Uri targetUri = Uri.parse(targetUrl);

    Uri uri = Uri.parse(url);
    return uri.host == targetUri.host;
  }

  bool verificaUrl(String url) {
    final uri = Uri.parse(url);
    final host = uri.host;

    if (host == "") {
      return false;
    }
    return true;
  }

  Uri addDomainToRelativePath(String baseUrl, String relativePath) {
    // Analiza el dominio base
    Uri baseUri = Uri.parse(baseUrl);

    // Combina el dominio base con la ruta relativa
    Uri fullUri = baseUri.resolve(relativePath);

    return fullUri;
  }

  bool hasHttpOrHttpsScheme(String url) {
    Uri uri = Uri.parse(url);
    return uri.scheme == 'http' || uri.scheme == 'https';
  }
}
