import 'dart:typed_data';
import 'package:bg_remove_without_package/new/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';


class RemoveBgController extends GetxController {
  Uint8List? imageFile;
  Uint8List? bgImageFile;
  String? imagePath;
  ScreenshotController controller = ScreenshotController();
  var isLoading = false.obs;

  Future<Uint8List> removeBg(String imagePath) async {
    isLoading = true.obs;
    update();
    var request = http.MultipartRequest(
        "POST", Uri.parse("https://api.remove.bg/v1.0/removebg"));
    request.files
        .add(await http.MultipartFile.fromPath("image_file", imagePath));
    request.headers.addAll(
        {"X-API-Key": "XH5axMWfLx5SSxSFLqEvJcMA"}); //XH5axMWfLx5SSxSFLqEvJcMA
    final response = await request.send();
    if (response.statusCode == 200) {
      http.Response imgRes = await http.Response.fromStream(response);
      isLoading = false.obs;
      update();
      return imgRes.bodyBytes;
    } else {
      throw Exception("Error");
      isLoading = false.obs;
    }
  }

  void pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        update();
      }
    } catch (e) {
      imageFile = null;
      update();
    }
  }

// clean up the image file after it is used
  void cleanUp() {
    imageFile = null;
    update();
  }

  void saveImage() async {
    if (imageFile != null) {
      try {
        final result = await ImageGallerySaver.saveImage(imageFile!);
        if (result['isSuccess']) {
          showSnackBar("Success", "Image saved successfully", false);
        } else {
          showSnackBar("Error", "Failed to save image", true);
        }
      } catch (e) {
        showSnackBar("Error", "Failed to save image: $e", true);
      }
    } else {
      showSnackBar("Error", "Please select an image", true);
    }
  }
}
