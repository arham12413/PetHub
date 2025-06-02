import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:pet_adoption/petForm.dart';
import 'package:pet_adoption/pet_modle.dart';
import 'package:pet_adoption/search.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Pet> pets = [];

  void _listenForPets() {
    _dbRef.child('pets').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map<dynamic, dynamic> petsMap = data as Map<dynamic, dynamic>;
        final loadedPets = petsMap.values.map((e) => Pet.fromMap(e)).toList();
        setState(() {
          pets = loadedPets;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _listenForPets();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String? fullName;
  String? email;


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
          });
        } else {
          print('No user data found.');
        }
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(fullName ?? 'Loading...'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(email ?? 'Loading...'),
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
              onTap: () => Get.snackbar("Listings", "Viewing your pet listings..."),
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag, color: Colors.red),
              title: Text('Purchased Pets'),
              onTap: () => Get.snackbar("Purchased", "Viewing purchased pets..."),
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
              child: const Search(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: pets.isEmpty
                  ? Center(
                child: Text("No pets available",
                    style: TextStyle(color: Colors.red.shade300)),
              )
                  : ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: pet.imagePaths.isNotEmpty
                          ? Image.file(
                        File(pet.imagePaths.first),
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
            )

          ],
        ),
      ),
    );
  }
}