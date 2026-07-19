import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/models/chat_model.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/widgets/home_bottom_navigation.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  void _handleNavigationTap(
    BuildContext context,
    int index,
  ) {
    switch (index) {
      case 0:
        context.go('/home');
        break;

      case 1:
        context.go('/orders');
        break;

      case 2:
        context.go('/publish-product');
        break;

      case 3:
        break;

      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                44,
                24,
                28,
              ),
              child: Text(
                'Chats',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Divider(
              height: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: currentUserId == null
                  ? const _ChatsEmptyState(
                      title:
                          'Debes iniciar sesión',
                      message:
                          'Inicia sesión para consultar tus conversaciones.',
                      icon:
                          Icons.lock_outline,
                    )
                  : StreamBuilder<
                      List<ChatModel>>(
                      stream: ChatService.instance
                          .getUserChats(),
                      builder: (
                        context,
                        snapshot,
                      ) {
                        if (snapshot
                                    .connectionState ==
                                ConnectionState
                                    .waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child:
                                CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const _ChatsEmptyState(
                            title:
                                'No fue posible cargar los chats',
                            message:
                                'Revisa tu conexión e inténtalo nuevamente.',
                            icon:
                                Icons.error_outline,
                          );
                        }

                        final chats =
                            snapshot.data ?? [];

                        if (chats.isEmpty) {
                          return const _ChatsEmptyState(
                            title:
                                'No hay conversaciones',
                            message:
                                'Cuando contactes a un vendedor, tus chats aparecerán aquí.',
                            icon:
                                Icons.chat_bubble_outline,
                          );
                        }

                        return ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(
                            24,
                            22,
                            24,
                            110,
                          ),
                          itemCount:
                              chats.length,
                          separatorBuilder: (
                            _,
                            __,
                          ) {
                            return const Divider(
                              height: 34,
                              color:
                                  AppColors.border,
                            );
                          },
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final chat =
                                chats[index];

                            return _ChatTile(
                              chat: chat,
                              currentUserId:
                                  currentUserId,
                              onTap: () {
                                context.push(
                                  '/chat-room/${chat.id}',
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          HomeBottomNavigation(
        currentIndex: 3,
        onTap: (index) {
          _handleNavigationTap(
            context,
            index,
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final otherUserName =
        chat.getOtherUserName(
      currentUserId,
    );

    final otherUserPhoto =
        chat.getOtherUserPhotoUrl(
      currentUserId,
    );

    final unreadCount =
        chat.getUnreadCount(
      currentUserId,
    );

    final timeText =
        _formatChatTime(
      chat.updatedAt,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(16),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
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
                child:
                    otherUserPhoto == null ||
                            otherUserPhoto
                                .trim()
                                .isEmpty
                        ? const Icon(
                            Icons.person,
                            color:
                                AppColors.primary,
                            size: 34,
                          )
                        : null,
              ),
              const SizedBox(width: 18),
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
                      style: TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight:
                            unreadCount > 0
                                ? FontWeight.w900
                                : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      chat.productTitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style:
                          const TextStyle(
                        color: AppColors
                            .textSecondary,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chat.lastMessage.isEmpty
                          ? 'Sin mensajes todavía'
                          : chat.lastMessage,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unreadCount > 0
                            ? AppColors
                                .textPrimary
                            : AppColors
                                .textSecondary,
                        fontSize: 14,
                        fontWeight:
                            unreadCount > 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    timeText,
                    style: TextStyle(
                      color: unreadCount > 0
                          ? AppColors.primary
                          : AppColors
                              .textSecondary,
                      fontSize: 13,
                      fontWeight:
                          unreadCount > 0
                              ? FontWeight.w800
                              : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (unreadCount > 0)
                    Container(
                      constraints:
                          const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration:
                          const BoxDecoration(
                        color:
                            AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment:
                          Alignment.center,
                      child: Text(
                        unreadCount > 99
                            ? '99+'
                            : '$unreadCount',
                        style:
                            const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatChatTime(
    DateTime date,
  ) {
    if (date.millisecondsSinceEpoch == 0) {
      return '';
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final chatDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today.difference(chatDate).inDays;

    if (difference == 0) {
      return DateFormat(
        'h:mm a',
        'es',
      ).format(date);
    }

    if (difference == 1) {
      return 'Ayer';
    }

    if (difference < 7) {
      return DateFormat(
        'EEEE',
        'es',
      ).format(date);
    }

    return DateFormat(
      'dd/MM/yyyy',
      'es',
    ).format(date);
  }
}

class _ChatsEmptyState
    extends StatelessWidget {
  const _ChatsEmptyState({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(34),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color:
                    AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 52,
                color:
                    AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors.textPrimary,
                fontSize: 22,
                fontWeight:
                    FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    AppColors.textSecondary,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () {
                context.go('/home');
              },
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                minimumSize:
                    const Size(
                  210,
                  52,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),
              icon: const Icon(
                Icons.storefront_outlined,
              ),
              label: const Text(
                'Explorar productos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}