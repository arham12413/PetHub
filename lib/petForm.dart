import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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

  Future<List<String>> _uploadImagesToFirebase() async {
    List<String> downloadUrls = [];
    final storage = FirebaseStorage.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return downloadUrls;

    for (var image in _selectedImages) {
      try {
        // Create unique filename with timestamp
        final filename = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final ref = storage.ref().child('pet_images/${user.uid}/$filename');

        // Upload the file
        await ref.putFile(File(image.path));

        // Get the download URL
        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    return downloadUrls;
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
                  // Image Picker Section
                  Text("Upload Images", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedImages.map((img) => FutureBuilder(
                        future: img.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                snapshot.data!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          return Container(
                            height: 80,
                            width: 80,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
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
                  _buildTextField("Category", categoryController),
                  _buildTextField("Nickname", nicknameController),
                  _buildTextField("Age", ageController, inputType: TextInputType.number),
                  _buildTextField("Description", descriptionController, maxLines: 3),
                  _buildTextField("Breed", breedController),
                  _buildTextField("Disorder", disorderController),

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
                        if (_formKey.currentState!.validate() && _selectedImages.isNotEmpty) {
                          try {
                            // Show loading dialog
                            Get.dialog(
                              Center(child: CircularProgressIndicator()),
                              barrierDismissible: false,
                            );

                            // Upload images and get URLs
                            final imageUrls = await _uploadImagesToFirebase();

                            // Save pet data to Realtime Database
                            final DatabaseReference dbRef = FirebaseDatabase.instance.ref("pets").push();
                            await dbRef.set({
                              "petId": dbRef.key,
                              "ownerId": FirebaseAuth.instance.currentUser!.uid,
                              "isPurchased": false,
                              "category": categoryController.text.trim(),
                              "nickname": nicknameController.text.trim(),
                              "age": ageController.text.trim(),
                              "description": descriptionController.text.trim(),
                              "breed": breedController.text.trim(),
                              "disorder": disorderController.text.trim(),
                              "imageUrls": imageUrls,
                              "createdAt": DateTime.now().millisecondsSinceEpoch,
                            });

                            // Close dialogs and return
                            Get.back(); // Close loading dialog
                            Get.back(); // Close form
                            Get.snackbar("Success", "Pet added successfully!");
                          } catch (e) {
                            Get.back(); // Close loading dialog
                            Get.snackbar("Error", "Failed to add pet: $e");
                          }
                        } else if (_selectedImages.isEmpty) {
                          Get.snackbar("Error", "Please select at least one image");
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

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
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