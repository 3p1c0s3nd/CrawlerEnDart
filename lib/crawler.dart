import 'package:crawler/class/ClassCrawler.dart';
import 'package:crawler/class/ClassScanner.dart';
import 'package:args/args.dart';

void main(List<String> arguments) async {
  print(
      """ 
  
   ██████████  █████ █████             █████        █████████                                                          
░░███░░░░███░░███ ░░███             ░░███        ███░░░░░███                                                         
 ░███   ░░███░███  ░███ █ ████████  ███████     ░███    ░░░   ██████  ██████  ████████  ████████    ██████  ████████ 
 ░███    ░███░███████████░░███░░███░░░███░      ░░█████████  ███░░███░░░░░███░░███░░███░░███░░███  ███░░███░░███░░███
 ░███    ░███░░░░░░░███░█ ░███ ░░░   ░███        ░░░░░░░░███░███ ░░░  ███████ ░███ ░███ ░███ ░███ ░███████  ░███ ░░░ 
 ░███    ███       ░███░  ░███       ░███ ███    ███    ░███░███  ██████░░███ ░███ ░███ ░███ ░███ ░███░░░   ░███     
 ██████████        █████  █████      ░░█████    ░░█████████ ░░██████░░████████████ █████████ █████░░██████  █████    
░░░░░░░░░░        ░░░░░  ░░░░░        ░░░░░      ░░░░░░░░░   ░░░░░░  ░░░░░░░░░░░░ ░░░░░░░░░ ░░░░░  ░░░░░░  ░░░░░     

  """);

  final ArgParser argParser = ArgParser()
    ..addOption(
      'url',
      abbr: 'u',
      help: 'URL a procesar',
    )
    ..addOption('depth', abbr: 'd', help: 'Profundidad de navegación')
    ..addFlag('help', abbr: 'h', help: 'Ayuda');

  try {
    final ArgResults argResults = argParser.parse(arguments);
    int numdepth = 3;
    if (argResults['url'] != null) {
      if (argResults['depth'] != null) {
        numdepth = int.tryParse(argResults['depth']) ?? 3;
      }
      final startUrl = argResults['url']!;
      final int depth = numdepth;
      final dominio = Uri.parse(startUrl.toString()).host;
      final bool checkSubdomain = false;
      final webCrawler = WebCrawler(depth, dominio, checkSubdomain);
      final List<String> processedUrls = await webCrawler.crawl(startUrl);
      final scanner = ClassScanner(urls: processedUrls);
      await scanner.scan();
    } else {
      print(
          'Por favor, proporciona una URL usando --url o -u. y opcionamente --depth o -d.');
    }
  } catch (e) {
    print('Error al procesar los argumentos: $e');
  }
  // Establece la URL de inicio y la profundidad máxima
}
