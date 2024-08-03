class BrandData {
  final String id;
  final String name;
  final String image;
  final String slug;

  BrandData({
    required this.id,
    required this.name,
    required this.image,
    required this.slug,
  });

  factory BrandData.fromJson(Map<String, dynamic> json) {
    return BrandData(
      id: json['id'].toString(),
      name: json['name'].toString(),
      image: json['image'].toString(),
      slug: json['slug'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'slug': slug,
    };
  }

  @override
  String toString() {
    return 'TestData(id: $id, name: $name, image: $image, slug: $slug)';
  }
}
