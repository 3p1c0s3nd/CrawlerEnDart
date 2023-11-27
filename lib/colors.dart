void printColor(String mensaje, String color) {
  final String rojo = "\x1B[31m${mensaje}\x1B[0m";
  final String verde = "\x1B[32m${mensaje}\x1B[0m";

  switch (color) {
    case "red":
      print(rojo);
      break;
    case "green":
      print(verde);
      break;
    default:
      print(mensaje);
  }
}
