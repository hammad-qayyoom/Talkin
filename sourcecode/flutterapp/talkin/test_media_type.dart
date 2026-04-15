import 'package:http_parser/http_parser.dart';

void main() {
  final mediaType = MediaType('image', 'jpeg');
  if (mediaType.toString().isEmpty) {
    throw StateError('MediaType conversion failed.');
  }
}
