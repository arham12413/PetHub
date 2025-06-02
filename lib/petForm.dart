import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddPetForm extends StatefulWidget {
  const AddPetForm({super.key});

  @override
  State<AddPetForm> createState() => _AddPetFormState();
}

class _AddPetFormState extends State<AddPetForm> {
  final _formKey = GlobalKey<FormState>();
  final categoryController = TextEditingController();
  final nicknameController = TextEditingController();
  final ageController = TextEditingController();
  final descriptionController = TextEditingController();
  final breedController = TextEditingController();
  final disorderController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Add Pet Details'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  Text("Upload Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.map((img) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(img.path),
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      )),
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form Fields
                  buildTextField("Category", categoryController),
                  buildTextField("Nickname", nicknameController),
                  buildTextField("Age", ageController, inputType: TextInputType.number),
                  buildTextField("Description", descriptionController, maxLines: 3),
                  buildTextField("Breed", breedController),
                  buildTextField("Disorder", disorderController),

                  const SizedBox(height: 25),

                  // Submit Button
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final DatabaseReference dbRef = FirebaseDatabase.instance.ref("pets").push();

                            List<String> imagePaths = _selectedImages.map((img) => img.path).toList();

                            await dbRef.set({
                              "category": categoryController.text.trim(),
                              "nickname": nicknameController.text.trim(),
                              "age": ageController.text.trim(),
                              "description": descriptionController.text.trim(),
                              "breed": breedController.text.trim(),
                              "disorder": disorderController.text.trim(),
                              "imagePaths": imagePaths,
                              "createdAt": DateTime.now().toIso8601String(),
                            });

                            Get.back();
                            Get.snackbar("Success", "Pet details added!",
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } catch (e) {
                            Get.snackbar("Error", "Failed to add pet: $e",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        }
                      },


                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.red),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Required' : null,
      ),
    );
  }
}