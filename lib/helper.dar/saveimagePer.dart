import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File> saveImagePermanently(XFile image) async {
  final dir = await getApplicationDocumentsDirectory();

  final fileName = p.basename(image.path);

  final savedImage = await File(image.path).copy('${dir.path}/$fileName');

  return savedImage;
}
