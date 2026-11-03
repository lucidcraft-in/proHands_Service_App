import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File?> cropImage({
  required String imagePath,
  String title = 'Crop Image',
  bool isCircle = false,
}) async {
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imagePath,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: title,
        toolbarColor: Colors.black,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: isCircle,
        cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
        aspectRatioPresets: isCircle
            ? [CropAspectRatioPreset.square]
            : [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
      ),
      IOSUiSettings(
        title: title,
        cropStyle: isCircle ? CropStyle.circle : CropStyle.rectangle,
        aspectRatioPresets: isCircle
            ? [CropAspectRatioPreset.square]
            : [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
      ),
    ],
  );

  if (croppedFile == null) return null;

  return File(croppedFile.path);
}

void showFullScreenImage(String imageUrl, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
    ),
  );
}
