import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isUploading = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (images != null && images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to select images: ${e.toString()}");
    }
  }

  Future<List<String>> _imagesToBase64() async {
    List<String> base64Images = [];
    for (var image in _selectedImages) {
      final bytes = await File(image.path).readAsBytes();
      base64Images.add(base64Encode(bytes));
    }
    return base64Images;
  }

  Future<void> _submitPetForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      Get.snackbar("Error", "Please select at least one image");
      return;
    }

    setState(() => _isUploading = true);
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final imageBase64List = await _imagesToBase64();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) throw Exception("User not logged in");

      final dbRef = FirebaseDatabase.instance.ref("pets").push();
      await dbRef.set({
        "petId": dbRef.key,
        "ownerId": user.uid,
        "isPurchased": false,
        "category": categoryController.text.trim(),
        "nickname": nicknameController.text.trim(),
        "age": ageController.text.trim(),
        "description": descriptionController.text.trim(),
        "breed": breedController.text.trim(),
        "disorder": disorderController.text.trim(),
        "imageBase64": imageBase64List, // Store as array of base64 strings
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      });

      Get.back(); // Close loading dialog
      Get.back(); // Close form
      Get.snackbar("Success", "Pet added successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar("Error", "Failed to add pet: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    categoryController.dispose();
    nicknameController.dispose();
    ageController.dispose();
    descriptionController.dispose();
    breedController.dispose();
    disorderController.dispose();
    super.dispose();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pet Images", style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._selectedImages.map((img) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(img.path),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )),
                  GestureDetector(
                    onTap: _isUploading ? null : _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_a_photo,
                        color: Colors.red,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField("Category*", categoryController),
              const SizedBox(height: 16),
              _buildTextField("Nickname*", nicknameController),
              const SizedBox(height: 16),
              _buildTextField("Age*", ageController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField("Breed*", breedController),
              const SizedBox(height: 16),
              _buildTextField("Disorder", disorderController),
              const SizedBox(height: 16),
              _buildTextField("Description*", descriptionController,
                  maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _submitPetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'SUBMIT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.red.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (label.endsWith('*') && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}