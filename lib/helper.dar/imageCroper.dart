// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';

// Future<File?> cropImage(String imagePath) async {
//   final croppedFile = await ImageCropper().cropImage(
//     sourcePath: imagePath,
//     // aspectRatioPresets: [
//     //   CropAspectRatioPreset.square,
//     //   CropAspectRatioPreset.ratio3x2,
//     //   CropAspectRatioPreset.original,
//     // ],
//     uiSettings: [
//       AndroidUiSettings(
//         toolbarTitle: 'Crop Profile Photo',
//         toolbarColor: Colors.black,
//         toolbarWidgetColor: Colors.white,
//         lockAspectRatio: false,
//       ),
//       IOSUiSettings(title: 'Crop Profile Photo'),
//     ],
//   );

//   if (croppedFile == null) return null;

//   return File(croppedFile.path);
// }

import 'package:flutter/material.dart';

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
