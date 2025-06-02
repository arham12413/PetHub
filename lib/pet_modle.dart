class Pet {
  final String category;
  final String nickname;
  final String age;
  final String description;
  final String breed;
  final String disorder;
  final List<String> imagePaths;

  Pet({
    required this.category,
    required this.nickname,
    required this.age,
    required this.description,
    required this.breed,
    required this.disorder,
    required this.imagePaths,
  });

  factory Pet.fromMap(Map<dynamic, dynamic> data) {
    return Pet(
      category: data['category'] ?? '',
      nickname: data['nickname'] ?? '',
      age: data['age'] ?? '',
      description: data['description'] ?? '',
      breed: data['breed'] ?? '',
      disorder: data['disorder'] ?? '',
      imagePaths: List<String>.from(data['imagePaths'] ?? []),
    );
  }
}