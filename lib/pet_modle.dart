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
  final List<String> imageURLs;

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
    required this.imageURLs,
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
      imageURLs: List<String>.from(map['imagePaths'] ?? []),
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
      'imagePaths': imageURLs,
    };
  }
}
