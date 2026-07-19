import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/product_model.dart';

class ChatService {
  ChatService._();

  static final ChatService instance = ChatService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _chats {
    return _firestore.collection('chats');
  }

  String? get currentUserId {
    return _auth.currentUser?.uid;
  }

  String generateChatId({
    required String buyerId,
    required String sellerId,
    required String productId,
  }) {
    return '${productId}_${buyerId}_$sellerId';
  }

  Future<String> createOrGetChat({
    required ProductModel product,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'Debes iniciar sesión para comenzar un chat.',
      );
    }

    if (currentUser.uid == product.sellerId) {
      throw Exception(
        'No puedes iniciar un chat contigo mismo.',
      );
    }

    final buyerId = currentUser.uid;
    final sellerId = product.sellerId;

    final chatId = generateChatId(
      buyerId: buyerId,
      sellerId: sellerId,
      productId: product.id,
    );

    final chatReference = _chats.doc(chatId);
    final chatSnapshot = await chatReference.get();

    if (chatSnapshot.exists) {
      return chatId;
    }

    final buyerName =
        currentUser.displayName?.trim().isNotEmpty == true
            ? currentUser.displayName!.trim()
            : 'Comprador';

    final buyerPhotoUrl =
        currentUser.photoURL?.trim().isNotEmpty == true
            ? currentUser.photoURL!.trim()
            : null;

    final now = DateTime.now();

    final chat = ChatModel(
      id: chatId,
      productId: product.id,
      productTitle: product.title,
      productImageUrl: product.imageUrl,
      buyerId: buyerId,
      buyerName: buyerName,
      buyerPhotoUrl: buyerPhotoUrl,
      sellerId: sellerId,
      sellerName: product.sellerName,
      sellerPhotoUrl: product.sellerPhoto,
      participantIds: [
        buyerId,
        sellerId,
      ],
      lastMessage: '',
      lastMessageSenderId: '',
      unreadCountBuyer: 0,
      unreadCountSeller: 0,
      createdAt: now,
      updatedAt: now,
    );

    await chatReference.set(
      chat.toMap(),
    );

    return chatId;
  }

  Stream<List<ChatModel>> getUserChats() {
    final userId = currentUserId;

    if (userId == null) {
      return Stream.value([]);
    }

    return _chats
        .where(
          'participantIds',
          arrayContains: userId,
        )
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs
          .map(ChatModel.fromDocument)
          .toList();

      chats.sort(
        (first, second) {
          return second.updatedAt.compareTo(
            first.updatedAt,
          );
        },
      );

      return chats;
    });
  }

  Stream<ChatModel?> getChat(String chatId) {
    return _chats.doc(chatId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) {
          return null;
        }

        return ChatModel.fromDocument(snapshot);
      },
    );
  }

  Stream<List<MessageModel>> getMessages(
    String chatId,
  ) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(MessageModel.fromDocument)
          .toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final currentUser = _auth.currentUser;
    final normalizedText = text.trim();

    if (currentUser == null) {
      throw Exception(
        'Debes iniciar sesión para enviar mensajes.',
      );
    }

    if (normalizedText.isEmpty) {
      return;
    }

    final chatReference = _chats.doc(chatId);
    final chatSnapshot = await chatReference.get();

    if (!chatSnapshot.exists) {
      throw Exception(
        'La conversación no existe.',
      );
    }

    final chat = ChatModel.fromDocument(
      chatSnapshot,
    );

    if (!chat.participantIds.contains(currentUser.uid)) {
      throw Exception(
        'No tienes permiso para enviar mensajes aquí.',
      );
    }

    final messageReference =
        chatReference.collection('messages').doc();

    final message = MessageModel(
      id: messageReference.id,
      chatId: chatId,
      senderId: currentUser.uid,
      text: normalizedText,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final batch = _firestore.batch();

    batch.set(
      messageReference,
      message.toMap(),
    );

    final chatUpdate = <String, dynamic>{
      'lastMessage': normalizedText,
      'lastMessageSenderId': currentUser.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (currentUser.uid == chat.buyerId) {
      chatUpdate['unreadCountSeller'] =
          FieldValue.increment(1);
    } else {
      chatUpdate['unreadCountBuyer'] =
          FieldValue.increment(1);
    }

    batch.update(
      chatReference,
      chatUpdate,
    );

    await batch.commit();
  }

  Future<void> markMessagesAsRead({
    required String chatId,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return;
    }

    final chatReference = _chats.doc(chatId);
    final chatSnapshot = await chatReference.get();

    if (!chatSnapshot.exists) {
      return;
    }

    final chat = ChatModel.fromDocument(
      chatSnapshot,
    );

    if (!chat.participantIds.contains(currentUser.uid)) {
      return;
    }

    final unreadMessages = await chatReference
        .collection('messages')
        .where(
          'isRead',
          isEqualTo: false,
        )
        .get();

    final batch = _firestore.batch();

    for (final messageDocument
        in unreadMessages.docs) {
      final message = MessageModel.fromDocument(
        messageDocument,
      );

      if (message.senderId != currentUser.uid) {
        batch.update(
          messageDocument.reference,
          {
            'isRead': true,
          },
        );
      }
    }

    if (currentUser.uid == chat.buyerId) {
      batch.update(
        chatReference,
        {
          'unreadCountBuyer': 0,
        },
      );
    } else if (currentUser.uid == chat.sellerId) {
      batch.update(
        chatReference,
        {
          'unreadCountSeller': 0,
        },
      );
    }

    await batch.commit();
  }

  Future<void> deleteChat(String chatId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'Debes iniciar sesión.',
      );
    }

    final chatReference = _chats.doc(chatId);
    final chatSnapshot = await chatReference.get();

    if (!chatSnapshot.exists) {
      return;
    }

    final chat = ChatModel.fromDocument(
      chatSnapshot,
    );

    if (!chat.participantIds.contains(currentUser.uid)) {
      throw Exception(
        'No tienes permiso para eliminar este chat.',
      );
    }

    final messagesSnapshot =
        await chatReference.collection('messages').get();

    final batch = _firestore.batch();

    for (final message in messagesSnapshot.docs) {
      batch.delete(message.reference);
    }

    batch.delete(chatReference);

    await batch.commit();
  }
}