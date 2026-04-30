import 'dart:io';
main() async {
  final r = await HttpClient().getUrl(Uri.parse('https://spoonacular.com/cdn/ingredients_250x250/banana.jpg'));
  final res = await r.close();
  print(res.statusCode);
  exit(0);
}
