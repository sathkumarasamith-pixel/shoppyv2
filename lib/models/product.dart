class Product {
  final String id;
  final String name;
  final String image;
  final double price;
  final String source;
  final double rating;
  final int reviews;
  final String description;
  bool isSelected;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.source,
    required this.rating,
    required this.reviews,
    required this.description,
    this.isSelected = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Product copyWith({bool? isSelected}) {
    return Product(
      id: id,
      name: name,
      image: image,
      price: price,
      source: source,
      rating: rating,
      reviews: reviews,
      description: description,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}