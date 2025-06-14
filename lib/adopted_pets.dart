import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pet_adoption/pet_modle.dart';

class AdoptedPetsPage extends StatelessWidget {
  final List<Pet> pets;
  final String currentUserId;

  const AdoptedPetsPage({
    Key? key,
    required this.pets,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adoptedPets = pets.where((pet) => pet.isPurchased && pet.ownerId != currentUserId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopted Pets'),
        backgroundColor: Colors.red.shade400,
      ),
      body: adoptedPets.isEmpty
          ? Center(child: Text('No adopted pets found.'))
          : ListView.builder(
        itemCount: adoptedPets.length,
        itemBuilder: (context, index) {
          final pet = adoptedPets[index];
          return Card(
            margin: const EdgeInsets.all(10),
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
              subtitle: Text("${pet.breed}, Age: ${pet.age}"),
            ),
          );
        },
      ),
    );
  }
}