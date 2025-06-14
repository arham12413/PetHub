import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pet_modle.dart';

class PetDetailsPage extends StatelessWidget {
  final Pet pet;

  const PetDetailsPage({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.nickname),
        backgroundColor: Colors.red.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (pet.imageBase64.isNotEmpty)
              Image.memory(
                base64Decode(pet.imageBase64.first),
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            _buildDetailRow('Category', pet.category),
            _buildDetailRow('Breed', pet.breed),
            _buildDetailRow('Age', pet.age),
            _buildDetailRow('Disorder', pet.disorder),
            SizedBox(height: 16),
            Text('Description:', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
            Text(pet.description),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}