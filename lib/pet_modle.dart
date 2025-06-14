class Pet {
  final String petId;
  final String ownerId;
  final bool isPurchased;
  final String category;
  final String nickname;
  final String age;
  final String description;
  final String breed;
  final String disorder;
  final List<String> imageBase64; // Changed from imageURLs to imageBase64

  Pet({
    required this.petId,
    required this.ownerId,
    required this.isPurchased,
    required this.category,
    required this.nickname,
    required this.age,
    required this.description,
    required this.breed,
    required this.disorder,
    required this.imageBase64,
  });

  factory Pet.fromMap(Map<dynamic, dynamic> map) {
    return Pet(
      petId: map['petId']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      isPurchased: map['isPurchased'] ?? false,
      category: map['category'] ?? '',
      nickname: map['nickname'] ?? '',
      age: map['age'] ?? '',
      description: map['description'] ?? '',
      breed: map['breed'] ?? '',
      disorder: map['disorder'] ?? '',
      imageBase64: List<String>.from(map['imageBase64'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'ownerId': ownerId,
      'isPurchased': isPurchased,
      'category': category,
      'nickname': nickname,
      'age': age,
      'description': description,
      'breed': breed,
      'disorder': disorder,
      'imageBase64': imageBase64,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}