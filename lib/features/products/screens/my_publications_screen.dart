import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/product_status.dart';
import '../../../core/models/product_model.dart';
import '../../../core/services/product_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/widgets/home_bottom_navigation.dart';
import '../widgets/my_publication_card.dart';
import '../widgets/publications_empty_state.dart';

class MyPublicationsScreen extends StatelessWidget {
  const MyPublicationsScreen({super.key});

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
        context.go('/chats');
        break;

      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text(
              'Iniciar sesión',
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              context.go('/profile');
            },
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
            ),
          ),
          title: const Text(
            'Mis publicaciones',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Tab(text: 'Todas'),
              Tab(text: 'Pendientes'),
              Tab(text: 'Aprobadas'),
              Tab(text: 'Rechazadas'),
              Tab(text: 'Suspendidas'),
            ],
          ),
        ),
        body: StreamBuilder<List<ProductModel>>(
          stream: ProductService.instance.getSellerProducts(
            user.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'No fue posible cargar tus publicaciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];

            return TabBarView(
              children: [
                _PublicationsList(
                  products: products,
                  emptyMessage:
                      'Cuando publiques un producto aparecerá aquí.',
                ),
                _PublicationsList(
                  products: _filterProducts(
                    products,
                    ProductStatus.pending,
                  ),
                  emptyMessage:
                      'No tienes productos pendientes de revisión.',
                ),
                _PublicationsList(
                  products: _filterProducts(
                    products,
                    ProductStatus.approved,
                  ),
                  emptyMessage:
                      'Todavía no tienes productos aprobados.',
                ),
                _PublicationsList(
                  products: _filterProducts(
                    products,
                    ProductStatus.rejected,
                  ),
                  emptyMessage:
                      'No tienes productos rechazados.',
                ),
                _PublicationsList(
                  products: _filterProducts(
                    products,
                    ProductStatus.suspended,
                  ),
                  emptyMessage:
                      'No tienes productos suspendidos.',
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.go('/publish-product');
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
        bottomNavigationBar: HomeBottomNavigation(
          currentIndex: 4,
          onTap: (index) {
            _handleNavigationTap(
              context,
              index,
            );
          },
        ),
      ),
    );
  }

  static List<ProductModel> _filterProducts(
    List<ProductModel> products,
    String status,
  ) {
    return products.where((product) {
      return product.status == status;
    }).toList();
  }
}

class _PublicationsList extends StatelessWidget {
  const _PublicationsList({
    required this.products,
    required this.emptyMessage,
  });

  final List<ProductModel> products;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return PublicationsEmptyState(
        message: emptyMessage,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        110,
      ),
      itemCount: products.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        final product = products[index];

        return MyPublicationCard(
          product: product,
          onTap: () {
            _showProductActions(
              context,
              product,
            );
          },
        );
      },
    );
  }

  Future<void> _showProductActions(
    BuildContext context,
    ProductModel product,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        final canSuspend =
            product.status == ProductStatus.approved;

        final canReactivate =
            product.status == ProductStatus.suspended;

        final canDelete =
            product.status != ProductStatus.approved;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              6,
              22,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                _ProductDataRow(
                  label: 'Precio',
                  value:
                      '\$${product.price.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 10),
                _ProductDataRow(
                  label: 'Stock',
                  value: '${product.stock}',
                ),
                const SizedBox(height: 10),
                _ProductDataRow(
                  label: 'Categoría',
                  value: product.category,
                ),
                if (product.rejectionReason != null &&
                    product.rejectionReason!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Motivo del rechazo: '
                      '${product.rejectionReason}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (canSuspend)
                  FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      await _suspendProduct(
                        context,
                        product,
                      );
                    },
                    icon: const Icon(
                      Icons.pause_circle_outline,
                    ),
                    label: const Text(
                      'Suspender publicación',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Colors.orange.shade700,
                      minimumSize:
                          const Size.fromHeight(52),
                    ),
                  ),
                if (canReactivate)
                  FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      await _reactivateProduct(
                        context,
                        product,
                      );
                    },
                    icon: const Icon(
                      Icons.play_circle_outline,
                    ),
                    label: const Text(
                      'Reactivar publicación',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          Colors.green.shade700,
                      minimumSize:
                          const Size.fromHeight(52),
                    ),
                  ),
                if (canDelete) ...[
                  if (canSuspend || canReactivate)
                    const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      await _confirmDeleteProduct(
                        context,
                        product,
                      );
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Eliminar publicación',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(
                        color: Colors.red.shade200,
                      ),
                      minimumSize:
                          const Size.fromHeight(52),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cerrar',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _suspendProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    try {
      await ProductService.instance.suspendProduct(
        product.id,
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'Publicación suspendida.',
      );
    } catch (error) {
      debugPrint(
        'Error al suspender producto: $error',
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'No fue posible suspender la publicación.',
      );
    }
  }

  Future<void> _reactivateProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    try {
      await ProductService.instance.reactivateProduct(
        product.id,
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'Publicación reactivada.',
      );
    } catch (error) {
      debugPrint(
        'Error al reactivar producto: $error',
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'No fue posible reactivar la publicación.',
      );
    }
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    ProductModel product,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar publicación',
          ),
          content: Text(
            '¿Seguro que deseas eliminar "${product.title}"? '
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        !context.mounted) {
      return;
    }

    try {
      await ProductService.instance.deleteProduct(
        product.id,
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'Publicación eliminada.',
      );
    } catch (error) {
      debugPrint(
        'Error al eliminar producto: $error',
      );

      if (!context.mounted) return;

      _showMessage(
        context,
        'No fue posible eliminar la publicación.',
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}

class _ProductDataRow extends StatelessWidget {
  const _ProductDataRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}