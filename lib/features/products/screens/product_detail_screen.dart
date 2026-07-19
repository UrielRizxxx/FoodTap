import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product_model.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/theme/app_colors.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
  bool _isOpeningChat = false;

  ProductModel get product => widget.product;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _openChat() async {
    if (_isOpeningChat) {
      return;
    }

    final currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(
        'Debes iniciar sesión para comenzar un chat.',
      );
      return;
    }

    if (currentUser.uid == product.sellerId) {
      _showMessage(
        'No puedes iniciar un chat contigo mismo.',
      );
      return;
    }

    setState(() {
      _isOpeningChat = true;
    });

    try {
      final chatId =
          await ChatService.instance.createOrGetChat(
        product: product,
      );

      if (!mounted) {
        return;
      }

      context.push(
        '/chat-room/$chatId',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningChat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    final isOwnProduct =
        currentUserId != null &&
        currentUserId == product.sellerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.white.withValues(
                  alpha: 0.92,
                ),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            actions: [
              if (!isOwnProduct)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.white.withValues(
                      alpha: 0.92,
                    ),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () {
                        _showMessage(
                          'Favoritos estará disponible pronto.',
                        );
                      },
                      icon: const Icon(
                        Icons.favorite_border,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-image-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 72,
                      ),
                    );
                  },
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child:
                          const CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                120,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (isOwnProduct) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tu publicación',
                            style: TextStyle(
                              color:
                                  Colors.blue.shade700,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    product.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Text(
                          product.stock > 0
                              ? 'Stock: ${product.stock}'
                              : 'Agotado',
                          style: TextStyle(
                            color: product.stock > 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Vendedor',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor:
                              AppColors.primary.withValues(
                            alpha: 0.10,
                          ),
                          backgroundImage:
                              product.sellerPhoto != null &&
                                      product.sellerPhoto!
                                          .trim()
                                          .isNotEmpty
                                  ? NetworkImage(
                                      product
                                          .sellerPhoto!,
                                    )
                                  : null,
                          child:
                              product.sellerPhoto ==
                                          null ||
                                      product
                                          .sellerPhoto!
                                          .trim()
                                          .isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppColors
                                          .primary,
                                      size: 30,
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                product.sellerName,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textPrimary,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                isOwnProduct
                                    ? 'Esta publicación es tuya'
                                    : 'Vendedor de FoodTap',
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isOwnProduct)
                          IconButton(
                            onPressed: _isOpeningChat
                                ? null
                                : _openChat,
                            icon: _isOpeningChat
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons
                                        .chat_bubble_outline,
                                    color: AppColors
                                        .primary,
                                  ),
                          )
                        else
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(
                                alpha: 0.12,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                            child: const Text(
                              'Tú',
                              style: TextStyle(
                                color:
                                    AppColors.primary,
                                fontSize: 12,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (product.address != null &&
                      product.address!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            product.address!,
                            style: const TextStyle(
                              color: AppColors
                                  .textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: AppColors.border,
              ),
            ),
          ),
          child: isOwnProduct
              ? SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.go(
                        '/my-publications',
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.inventory_2_outlined,
                    ),
                    label: const Text(
                      'Administrar publicación',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 58,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isOpeningChat
                            ? null
                            : _openChat,
                        style:
                            OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(
                            color: AppColors.primary,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),
                          ),
                        ),
                        child: _isOpeningChat
                            ? const SizedBox(
                                width: 21,
                                height: 21,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .chat_bubble_outline,
                                color:
                                    AppColors.primary,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed:
                              product.stock > 0
                                  ? () {
                                      _showMessage(
                                        'El proceso de compra se conectará después.',
                                      );
                                    }
                                  : null,
                          style:
                              FilledButton.styleFrom(
                            backgroundColor:
                                AppColors.primary,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'Comprar producto'
                                : 'Producto agotado',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}