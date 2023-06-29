      import 'dart:io';
      import 'package:enough_giphy_flutter/enough_giphy_flutter.dart';
      import 'package:flutter/material.dart';
      import 'package:image_picker/image_picker.dart';

    void showSnackBar({
      required BuildContext context,
      required String content,
    }) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(content),
        ),
      );
    }

    Future<File?> pickImageFromGallery(BuildContext context) async {
      File? image;
      try {
        final pickedImage =
            await ImagePicker().pickImage(source: ImageSource.gallery);

        if (pickedImage != null) {
          image = File(pickedImage.path);
        }
      } catch (e) {
        showSnackBar(
          context: context,
          content: e.toString(),
        );
      }
      return image;
    }

    Future<File?> pickVideoFromGallery(BuildContext context) async {
      File? video;
      try {
        final pickedVideo =
            await ImagePicker().pickVideo(source: ImageSource.gallery);

        if (pickedVideo != null) {
          video = File(pickedVideo.path);
        }
      } catch (e) {
        showSnackBar(
          context: context,
          content: e.toString(),
        );
      }
      return video;
    }

    // Giphy.com
    Future<GiphyGif?> pickGIF(BuildContext context) async {
      GiphyGif? gif;
      try {
        gif = await Giphy.getGif(
          context: context,
          apiKey: 'KghWC08Q4hR2mAf3lLckg9Pzo5gSRFwk',
        );
      } catch (e) {
        showSnackBar(
          context: context,
          content: e.toString(),
        );
      }
      return gif;
    }

    // Future<File?> pickImageFromGallery(BuildContext context) async {
    //   File? image;
    //   try {
    //     if (kIsWeb) {
    //       final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    //       if (pickedImage != null) {
    //         image = File(pickedImage.path);
    //       }
    //     } else {
    //       final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    //       if (pickedImage != null) {
    //         image = File(pickedImage.path);
    //       }
    //     }
    //   } catch (e) {
    //     // handle error
    //     print(e.toString());
    //   }
    //   return image;
    // }
