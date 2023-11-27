import 'package:crawler/ClassCrawler.dart';
import 'package:dio/dio.dart';

void main() async{
  final dio = Dio();
  
  // Establece la URL de inicio y la profundidad máxima
  final startUrl = 'https://www.unisangil.edu.co/';
  final maxDepth = 1;
  final uri = Uri.parse(startUrl);
  final dominio = uri.host;
  //print(dominio);
  final webCrawler = WebCrawler(dio, maxDepth, dominio);
  await webCrawler.crawl(startUrl);
}