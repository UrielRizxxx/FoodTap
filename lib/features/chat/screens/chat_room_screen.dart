import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chat_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/theme/app_colors.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.chatId,
  });

  final String chatId;

  @override
  State<ChatRoomScreen> createState() =>
      _ChatRoomScreenState();
}

class _ChatRoomScreenState
    extends State<ChatRoomScreen> {
  final TextEditingController _messageController =
      TextEditingController();

  final FocusNode _messageFocusNode = FocusNode();

  bool _isSending = false;

  String? get _currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatService.instance.markMessagesAsRead(
        chatId: widget.chatId,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await ChatService.instance.sendMessage(
        chatId: widget.chatId,
        text: text,
      );

      _messageController.clear();
      _messageFocusNode.requestFocus();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/chats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _currentUserId;

    if (currentUserId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Debes iniciar sesión para ver el chat.',
          ),
        ),
      );
    }

    return StreamBuilder<ChatModel?>(
      stream: ChatService.instance.getChat(
        widget.chatId,
      ),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState ==
                ConnectionState.waiting &&
            !chatSnapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (chatSnapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
            ),
            body: const Center(
              child: Text(
                'No fue posible cargar la conversación.',
              ),
            ),
          );
        }

        final chat = chatSnapshot.data;

        if (chat == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
            ),
            body: const Center(
              child: Text(
                'La conversación no existe.',
              ),
            ),
          );
        }

        if (!chat.participantIds.contains(
          currentUserId,
        )) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back,
                ),
              ),
            ),
            body: const Center(
              child: Text(
                'No tienes permiso para ver este chat.',
              ),
            ),
          );
        }

        final otherUserName =
            chat.getOtherUserName(currentUserId);

        final otherUserPhoto =
            chat.getOtherUserPhotoUrl(currentUserId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: _goBack,
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  backgroundImage:
                      otherUserPhoto != null &&
                              otherUserPhoto
                                  .trim()
                                  .isNotEmpty
                          ? NetworkImage(
                              otherUserPhoto,
                            )
                          : null,
                  child: otherUserPhoto == null ||
                          otherUserPhoto
                              .trim()
                              .isEmpty
                      ? const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUserName,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      Text(
                        chat.productTitle,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          body: Column(
            children: [
              _ProductHeader(
                title: chat.productTitle,
                imageUrl: chat.productImageUrl,
              ),
              Expanded(
                child: StreamBuilder<
                    List<MessageModel>>(
                  stream:
                      ChatService.instance.getMessages(
                    widget.chatId,
                  ),
                  builder: (
                    context,
                    messageSnapshot,
                  ) {
                    if (messageSnapshot
                                .connectionState ==
                            ConnectionState.waiting &&
                        !messageSnapshot.hasData) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (messageSnapshot.hasError) {
                      return const Center(
                        child: Text(
                          'No fue posible cargar los mensajes.',
                        ),
                      );
                    }

                    final messages =
                        messageSnapshot.data ?? [];

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) {
                      ChatService.instance
                          .markMessagesAsRead(
                        chatId: widget.chatId,
                      );
                    });

                    if (messages.isEmpty) {
                      return const _EmptyMessages();
                    }

                    return ListView.builder(
                      reverse: true,
                      padding:
                          const EdgeInsets.fromLTRB(
                        16,
                        18,
                        16,
                        18,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final message =
                            messages[index];

                        final isMine =
                            message.senderId ==
                                currentUserId;

                        return _MessageBubble(
                          message: message,
                          isMine: isMine,
                        );
                      },
                    );
                  },
                ),
              ),
              _MessageInput(
                controller: _messageController,
                focusNode: _messageFocusNode,
                isSending: _isSending,
                onSend: _sendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({
    required this.title,
    required this.imageUrl,
  });

  final String title;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Conversación sobre',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final MessageModel message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat(
      'h:mm a',
      'es',
    ).format(message.createdAt);

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.sizeOf(context).width * 0.76,
        ),
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.fromLTRB(
          14,
          10,
          12,
          7,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primary
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(
              isMine ? 17 : 4,
            ),
            bottomRight: Radius.circular(
              isMine ? 4 : 17,
            ),
          ),
          border: isMine
              ? null
              : Border.all(
                  color: AppColors.border,
                ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMine
                      ? Colors.white
                      : AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMine
                        ? Colors.white.withValues(
                            alpha: 0.78,
                          )
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all
                        : Icons.done,
                    size: 15,
                    color: Colors.white.withValues(
                      alpha: message.isRead
                          ? 1
                          : 0.75,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          12,
          10,
          12,
          12,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                minLines: 1,
                maxLines: 5,
                textCapitalization:
                    TextCapitalization.sentences,
                textInputAction:
                    TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  filled: true,
                  fillColor:
                      AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.border,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            SizedBox(
              width: 48,
              height: 48,
              child: FilledButton(
                onPressed:
                    isSending ? null : onSend,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Inicia la conversación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pregunta por la disponibilidad, entrega o características del producto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}