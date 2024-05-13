import 'dart:io';
import 'dart:typed_data';

import 'package:bg_remove_without_package/new/choose_image.dart';
import 'package:bg_remove_without_package/new/primanry_button.dart';
import 'package:bg_remove_without_package/new/remove_bg_controller.dart';
import 'package:bg_remove_without_package/new/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class RemoveBackroundScreen extends StatefulWidget {
  const RemoveBackroundScreen({super.key});

  @override
  State<RemoveBackroundScreen> createState() => _RemoveBackroundScreenState();
}

class _RemoveBackroundScreenState extends State<RemoveBackroundScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScreenshotController _screenshotController = ScreenshotController();
  Color _backgroundColor = Colors.white; // Initial background color
  Uint8List? _backgroundImage;

  Future<void> _saveScreenshot() async {
    try {
      final image = await _screenshotController.capture();
      await ImageGallerySaver.saveImage(image!);
      showSnackBar("Success", 'Screenshot saved to gallery', false);
    } catch (e) {
      showSnackBar("Error", 'Failed to save screenshot: $e', true);
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _backgroundImage = File(pickedImage.path).readAsBytesSync();
      });
    }
  }

  void _changeBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Remove Background'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: GetBuilder<RemoveBgController>(
                init: RemoveBgController(),
                builder: (controller) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (controller.imageFile != null)
                          ? Column(
                              children: [
                                // Color picker button using flex_color_picker package
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Pick a color'),
                                              content: SingleChildScrollView(
                                                child: ColorPicker(
                                                  pickerColor: _backgroundColor,
                                                  onColorChanged:
                                                      _changeBackgroundColor,
                                                  pickerAreaHeightPercent: 0.8,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Change BG Color'),
                                    ),
                                    ElevatedButton(
                                        onPressed: _pickImage,
                                        child: const Text('Change BG image'))
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Screenshot(
                                    controller: _screenshotController,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: _backgroundColor,
                                          image: DecorationImage(
                                              image: MemoryImage(
                                                  _backgroundImage!),
                                              fit: BoxFit.cover)),
                                      child: Image.memory(
                                        controller.imageFile!,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                controller.isLoading.value
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : isLoading == true
                                        ? const LinearProgressIndicator()
                                        : ReusablePrimaryButton(
                                            childText: "Remove Background",
                                            textColor: Colors.white,
                                            buttonColor:
                                                Colors.deepPurpleAccent,
                                            onPressed: () async {
                                              if (controller.imageFile ==
                                                  null) {
                                                showSnackBar(
                                                    "Error",
                                                    "Please select an image",
                                                    true);
                                              } else {
                                                try {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  controller.imageFile =
                                                      await RemoveBgController()
                                                          .removeBg(controller
                                                              .imagePath!);
                                                  debugPrint("Success");
                                                } catch (e) {
                                                  // Handle error here
                                                  debugPrint("Error: $e");
                                                  showSnackBar(
                                                      "Error", '$e', true);
                                                  // Maybe show a snackbar for error handling
                                                } finally {
                                                  setState(() {
                                                    isLoading = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                const SizedBox(height: 20),
                                ReusablePrimaryButton(
                                  childText: "Save Image",
                                  textColor: Colors.white,
                                  buttonColor: Colors.deepPurpleAccent,
                                  onPressed: _saveScreenshot,
                                ),
                                const SizedBox(height: 20),
                                ReusablePrimaryButton(
                                    childText: "Add New Image",
                                    textColor: Colors.white,
                                    buttonColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      controller.cleanUp();
                                    }),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                ReusablePrimaryButton(
                                    childText: "Select Image",
                                    textColor: Colors.white,
                                    buttonColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return bottomSheet(
                                                controller, context);
                                          });
                                    }),
                              ],
                            ),
                    ],
                  );
                }),
          ),
        ));
  }
}
