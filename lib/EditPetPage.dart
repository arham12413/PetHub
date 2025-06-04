import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet_adoption/pet_modle.dart';
import 'package:firebase_database/firebase_database.dart';

class EditPetPage extends StatefulWidget {
  final Pet pet;

  const EditPetPage({Key? key, required this.pet}) : super(key: key);

  @override
  _EditPetPageState createState() => _EditPetPageState();
}

class _EditPetPageState extends State<EditPetPage> {
  late TextEditingController nicknameController;
  late TextEditingController breedController;
  late TextEditingController ageController;
  late TextEditingController disorderController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;

  final databaseRef = FirebaseDatabase.instance.ref('pets');

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(text: widget.pet.nickname);
    breedController = TextEditingController(text: widget.pet.breed);
    ageController = TextEditingController(text: widget.pet.age);
    disorderController = TextEditingController(text: widget.pet.disorder);
    descriptionController = TextEditingController(text: widget.pet.description);
    categoryController = TextEditingController(text: widget.pet.category);
  }

  void _saveChanges() async {
    final updatedPet = Pet(
      petId: widget.pet.petId,
      nickname: nicknameController.text,
      breed: breedController.text,
      age: ageController.text,
      disorder: disorderController.text,
      description: descriptionController.text,
      category: categoryController.text,
      ownerId: widget.pet.ownerId,
      imageURLs: widget.pet.imageURLs,
      isPurchased: false,
    );


    await databaseRef.child(widget.pet.petId).update(updatedPet.toMap());
    Get.back(); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Pet'),
        backgroundColor: Colors.red.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('Nickname', nicknameController),
            _buildTextField('Breed', breedController),
            _buildTextField('Age', ageController),
            _buildTextField('Disorder', disorderController),
            _buildTextField('Category', categoryController),
            _buildTextField('Description', descriptionController, maxLines: 4),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
