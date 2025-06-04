import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_adoption/pet_modle.dart';
import 'package:get/get.dart';

import 'EditPetPage.dart';

class MyListingsPage extends StatefulWidget {
  final String currentUserId;

  const MyListingsPage({Key? key, required this.currentUserId, required List<Pet> pets, required Future<void> Function(Pet pet) onDelete}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<Pet> myPets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPets();
  }

  Future<void> fetchPets() async {
    final snapshot = await FirebaseDatabase.instance.ref('pets').once();
    final petsMap = snapshot.snapshot.value as Map?;
    if (petsMap != null) {
      final allPets = petsMap.entries.map((entry) {
        final petData = Map<String, dynamic>.from(entry.value);
        petData['id'] = entry.key;
        return Pet.fromMap(petData);
      }).toList();

      final userPets = allPets.where((pet) => pet.ownerId == widget.currentUserId).toList();

      setState(() {
        myPets = userPets;
        isLoading = false;
      });
    } else {
      setState(() {
        myPets = [];
        isLoading = false;
      });
    }
  }

  Future<void> _deletePet(Pet pet) async {
    await FirebaseDatabase.instance.ref('pets/${pet.petId}').remove();
    setState(() {
      myPets.removeWhere((p) => p.petId == pet.petId);
    });
  }

  void _editPet(Pet pet) async {
    await Get.to(() => EditPetPage(pet: pet));
    fetchPets(); // Refresh after edit
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Listings'),
        backgroundColor: Colors.red.shade400,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : myPets.isEmpty
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
              leading: pet.imageURLs.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: pet.imageURLs.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.pets, color: Colors.red),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.error, color: Colors.red),
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
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _editPet(pet),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, pet),
                  ),
                ],
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
              _deletePet(pet);
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
              if (pet.imageURLs.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: pet.imageURLs.first,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
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
