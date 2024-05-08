// ignore_for_file: deprecated_member_use

import 'package:bg_remove_without_package/new/choose_image.dart';
import 'package:bg_remove_without_package/new/primanry_button.dart';
import 'package:bg_remove_without_package/new/remove_bg_controller.dart';
import 'package:bg_remove_without_package/new/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';

class RemoveBackroundScreen extends StatefulWidget {
  const RemoveBackroundScreen({super.key});

  @override
  State<RemoveBackroundScreen> createState() => _RemoveBackroundScreenState();
}

class _RemoveBackroundScreenState extends State<RemoveBackroundScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Screenshot(
                                    controller: controller.controller,
                                    child: Image.memory(
                                      controller.imageFile!,
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
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                controller.imageFile =
                                                    await RemoveBgController()
                                                        .removeBg(controller
                                                            .imagePath!);
                                                debugPrint("Success");
                                                setState(() {
                                                  isLoading = false;
                                                });
                                              }
                                              controller.update();
                                            }),
                                const SizedBox(height: 20),
                                ReusablePrimaryButton(
                                    childText: "Save Image",
                                    textColor: Colors.white,
                                    buttonColor: Colors.deepPurpleAccent,
                                    onPressed: () async {
                                      if (controller.imageFile != null) {
                                        controller.saveImage();

                                        showSnackBar("Success",
                                            "Image saved successfully", false);
                                      } else {
                                        showSnackBar("Error",
                                            "Please select an image", true);
                                      }
                                    }),
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
