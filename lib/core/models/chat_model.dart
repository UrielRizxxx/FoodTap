import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  const ChatModel({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhotoUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhotoUrl,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.unreadCountBuyer,
    required this.unreadCountSeller,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String productId;
  final String productTitle;
  final String productImageUrl;

  final String buyerId;
  final String buyerName;
  final String? buyerPhotoUrl;

  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl;

  final List<String> participantIds;

  final String lastMessage;
  final String lastMessageSenderId;

  final int unreadCountBuyer;
  final int unreadCountSeller;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return ChatModel(
      id: document.id,
      productId: data['productId'] as String? ?? '',
      productTitle: data['productTitle'] as String? ?? '',
      productImageUrl:
          data['productImageUrl'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      buyerName: data['buyerName'] as String? ?? '',
      buyerPhotoUrl: data['buyerPhotoUrl'] as String?,
      sellerId: data['sellerId'] as String? ?? '',
      sellerName: data['sellerName'] as String? ?? '',
      sellerPhotoUrl: data['sellerPhotoUrl'] as String?,
      participantIds: List<String>.from(
        data['participantIds'] as List? ?? [],
      ),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageSenderId:
          data['lastMessageSenderId'] as String? ?? '',
      unreadCountBuyer:
          (data['unreadCountBuyer'] as num?)?.toInt() ?? 0,
      unreadCountSeller:
          (data['unreadCountSeller'] as num?)?.toInt() ?? 0,
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'productImageUrl': productImageUrl,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhotoUrl': buyerPhotoUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCountBuyer': unreadCountBuyer,
      'unreadCountSeller': unreadCountSeller,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String getOtherUserId(String currentUserId) {
    if (currentUserId == buyerId) {
      return sellerId;
    }

    return buyerId;
  }

  String getOtherUserName(String currentUserId) {
    if (currentUserId == buyerId) {
      return sellerName;
    }

    return buyerName;
  }

  String? getOtherUserPhotoUrl(String currentUserId) {
    if (currentUserId == buyerId) {
      return sellerPhotoUrl;
    }

    return buyerPhotoUrl;
  }

  int getUnreadCount(String currentUserId) {
    if (currentUserId == buyerId) {
      return unreadCountBuyer;
    }

    if (currentUserId == sellerId) {
      return unreadCountSeller;
    }

    return 0;
  }

  static DateTime _dateFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}