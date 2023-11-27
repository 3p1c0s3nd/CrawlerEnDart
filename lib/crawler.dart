import 'package:crawler/class/ClassCrawler.dart';
import 'package:crawler/class/ClassScanner.dart';

void main() async {
  // Establece la URL de inicio y la profundidad máxima
  final startUrl = 'https://www.spectrummedtech.com/products.php';
  final maxDepth = 5;
  final dominio = Uri.parse(startUrl).host;
  final webCrawler = WebCrawler(maxDepth, dominio);
  final List<String> processedUrls = await webCrawler.crawl(startUrl);
  //print('\x1B[31mProcessed URLs:\x1B[0m $processedUrls');

  final scanner = ClassScanner(urls: processedUrls);
  await scanner.scan();
}
