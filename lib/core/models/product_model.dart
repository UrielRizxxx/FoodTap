class ProductModel {
  final String id;

  final String title;
  final String description;
  final double price;

  final String category;

  final String imageUrl;

  final String sellerId;
  final String sellerName;
  final String? sellerPhoto;

  final String status;

  final int stock;

  final int views;
  final int favorites;

  final double? latitude;
  final double? longitude;
  final String? address;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final DateTime? approvedAt;
  final String? approvedBy;

  final String? rejectionReason;

  const ProductModel({
    required this.id,

    required this.title,
    required this.description,
    required this.price,

    required this.category,

    required this.imageUrl,

    required this.sellerId,
    required this.sellerName,
    this.sellerPhoto,

    required this.status,

    required this.stock,

    required this.views,
    required this.favorites,

    this.latitude,
    this.longitude,
    this.address,

    required this.createdAt,
    this.updatedAt,

    this.approvedAt,
    this.approvedBy,

    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,

      'title': title,
      'description': description,
      'price': price,

      'category': category,

      'imageUrl': imageUrl,

      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhoto': sellerPhoto,

      'status': status,

      'stock': stock,

      'views': views,
      'favorites': favorites,

      'latitude': latitude,
      'longitude': longitude,
      'address': address,

      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,

      'approvedAt': approvedAt?.millisecondsSinceEpoch,
      'approvedBy': approvedBy,

      'rejectionReason': rejectionReason,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',

      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),

      category: map['category'] ?? '',

      imageUrl: map['imageUrl'] ?? '',

      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerPhoto: map['sellerPhoto'],

      status: map['status'] ?? 'pending',

      stock: map['stock'] ?? 0,

      views: map['views'] ?? 0,
      favorites: map['favorites'] ?? 0,

      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],

      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'],
      ),

      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['updatedAt'],
            )
          : null,

      approvedAt: map['approvedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['approvedAt'],
            )
          : null,

      approvedBy: map['approvedBy'],

      rejectionReason: map['rejectionReason'],
    );
  }
}