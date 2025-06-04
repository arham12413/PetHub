import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_adoption/petForm.dart';
import 'package:pet_adoption/pet_modle.dart';
import 'package:pet_adoption/search.dart';

import 'my_listings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Pet> pets = [];
  List<Pet> filteredPets = [];
  String currentFilter = 'all';
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? fullName;
  String? email;
  String? phone;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _listenForPets();
  }

  void _listenForPets() {
    _dbRef.child('pets').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map<dynamic, dynamic> petsMap = data as Map<dynamic, dynamic>;
        final loadedPets = petsMap.values.map((e) => Pet.fromMap(e)).toList();
        setState(() {
          pets = loadedPets;
          _applyFilters();
          isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      if (currentFilter == 'all') {
        filteredPets = List.from(pets);
      } else {
        filteredPets = pets.where((pet) =>
        pet.category.toLowerCase() == currentFilter.toLowerCase()
        ).toList();
      }
    });
  }

  void _handleFilterChanged(String category) {
    setState(() {
      currentFilter = category;
      _applyFilters();
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _dbRef.child('users/${user.uid}').get();
        if (snapshot.exists) {
          final data = snapshot.value as Map;
          setState(() {
            fullName = data['fullName'];
            email = data['email'];
            phone = data['phone'];
          });
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  void _showProfileDialog() {
    final user = _auth.currentUser;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(fullName ?? user?.displayName ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(email ?? user?.email ?? 'N/A'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone ?? user?.phoneNumber ?? 'N/A'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _showMyListings() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      Get.to(() => MyListingsPage(
        pets: pets,
        currentUserId: userId,
        onDelete: _deletePet,
      ));
    }
  }


  void _showPurchasedPets() {
    final userId = _auth.currentUser?.uid;
    final purchasedPets = pets.where((pet) => pet.isPurchased && pet.ownerId != userId).toList();
    _showPetDialog("Purchased Pets", purchasedPets);
  }

  void _showPetDialog(String title, List<Pet> petList) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: petList.isEmpty
              ? const Text("No pets found.")
              : ListView.builder(
            shrinkWrap: true,
            itemCount: petList.length,
            itemBuilder: (context, index) {
              final pet = petList[index];
              return ListTile(
                leading: pet.imageURLs.isNotEmpty
                    ? Image.network(
                  pet.imageURLs.first,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error, color: Colors.red),
                )
                    : Icon(Icons.pets, color: Colors.red),
                title: Text(pet.nickname),
                subtitle: Text("${pet.breed}, Age: ${pet.age}"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Future<void> _deletePet(Pet pet) async {
    try {
      // Delete images from storage first
      for (var url in pet.imageURLs) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (e) {
          print('Error deleting image: $e');
        }
      }

      // Delete pet record from database
      await _dbRef.child('pets/${pet.petId}').remove();

      Get.snackbar("Success", "Pet deleted successfully",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to delete pet: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red.shade300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red.shade100,
                    child: Icon(Icons.person, size: 30, color: Colors.red.shade800),
                  ),
                  SizedBox(height: 10),
                  Text(
                    fullName ?? 'Loading...',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    email ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.red),
              title: Text('User Profile'),
              onTap: _showProfileDialog,
            ),
            ListTile(
              leading: Icon(Icons.list_alt, color: Colors.red),
              title: Text('My Listings'),
              onTap: _showMyListings,
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.red),
              title: Text('Purchased Pets'),
              onTap: _showPurchasedPets,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Log Out'),
              onTap: () async {
                await _auth.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddPetForm()),
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: Icon(Icons.menu, color: Colors.red.shade800),
                    ),
                  ),
                  Spacer(),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.red.shade300,
                    child: const Icon(Icons.pets, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Find your new best friend",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Search(
                onFilterChanged: _handleFilterChanged,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredPets.isEmpty
                  ? Center(
                child: Text("No pets available",
                    style: TextStyle(color: Colors.red.shade300)),
              )
                  : ListView.builder(
                itemCount: filteredPets.length,
                itemBuilder: (context, index) {
                  final pet = filteredPets[index];
                  return Dismissible(
                    key: Key(pet.petId),
                    direction: pet.ownerId == _auth.currentUser?.uid
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (pet.ownerId != _auth.currentUser?.uid) {
                        return false;
                      }
                      return await Get.dialog(
                        AlertDialog(
                          title: Text("Delete Pet"),
                          content: Text("Are you sure you want to delete ${pet.nickname}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) => _deletePet(pet),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: pet.imageURLs.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pet.imageURLs.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error, color: Colors.red, size: 40),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        )
                            : Icon(Icons.pets, size: 40, color: Colors.red),
                        title: Text(pet.nickname),
                        subtitle: Text("${pet.breed}, Age: ${pet.age}"),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(pet.nickname),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (pet.imageURLs.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          pet.imageURLs.first,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    SizedBox(height: 16),
                                    _buildPetDetailRow("Category", pet.category),
                                    _buildPetDetailRow("Breed", pet.breed),
                                    _buildPetDetailRow("Age", pet.age),
                                    _buildPetDetailRow("Disorder", pet.disorder),
                                    SizedBox(height: 8),
                                    Text(
                                      pet.description,
                                      style: TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPetDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}