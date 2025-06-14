import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pet_adoption/pet_modle.dart';
import 'package:get/get.dart';

class MyListingsPage extends StatelessWidget {
  final List<Pet> pets;
  final String currentUserId;
  final Function(Pet) onDelete;

  const MyListingsPage({
    Key? key,
    required this.pets,
    required this.currentUserId,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final myPets = pets.where((pet) => pet.ownerId == currentUserId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings'),
        backgroundColor: Colors.red.shade400,
      ),
      body: myPets.isEmpty
          ? Center(
        child: Text(
          'You haven\'t listed any pets yet',
          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        ),
      )
          : ListView.builder(
        itemCount: myPets.length,
        itemBuilder: (context, index) {
          final pet = myPets[index];
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 2,
            child: ListTile(
              leading: pet.imageBase64.isNotEmpty
                  ? Image.memory(
                base64Decode(pet.imageBase64.first),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : Icon(Icons.pets, size: 40, color: Colors.red),
              title: Text(pet.nickname),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${pet.breed} • ${pet.age} years"),
                  Text(
                    pet.category,
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context, pet),
              ),
              onTap: () => _showPetDetails(context, pet),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${pet.nickname}?'),
        content: Text('This will permanently remove your pet listing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(pet);
              Get.back(); // Close the MyListingsPage after deletion
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet.nickname),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pet.imageBase64.isNotEmpty)
                Image.memory(
                  base64Decode(pet.imageBase64.first),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 16),
              _buildDetailRow('Category', pet.category),
              _buildDetailRow('Breed', pet.breed),
              _buildDetailRow('Age', pet.age),
              _buildDetailRow('Disorder', pet.disorder),
              SizedBox(height: 8),
              Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(pet.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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