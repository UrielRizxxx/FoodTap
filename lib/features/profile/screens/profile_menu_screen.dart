import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/widgets/home_bottom_navigation.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_stats.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() =>
      _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSigningOut = false;
  bool _isUploadingPhoto = false;
  bool _isUpdatingName = false;

  User? get _currentUser => AuthService.instance.currentUser;

  void _handleNavigationTap(int index) {
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
        break;
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Future<void> _pickAndUploadProfilePhoto() async {
    if (_isUploadingPhoto) return;

    final user = _currentUser;

    if (user == null) {
      _showMessage(
        'Inicia sesión para cambiar tu fotografía.',
      );
      return;
    }

    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (selectedImage == null || !mounted) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final imageFile = File(selectedImage.path);

      final photoUrl =
          await CloudinaryService.instance.uploadProfileImage(
        image: imageFile,
        userId: user.uid,
      );

      await user.updatePhotoURL(photoUrl);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'photoUrl': photoUrl,
      });

      await user.reload();

      if (!mounted) return;

      setState(() {});

      _showMessage(
        'Fotografía de perfil actualizada.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Error al actualizar fotografía: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible actualizar la fotografía.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _showEditProfileDialog(
    String currentName,
  ) async {
    final nameController = TextEditingController(
      text: currentName,
    );

    final newName = await showDialog<String>(
      context: context,
      barrierDismissible: !_isUpdatingName,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Editar perfil',
          ),
          content: TextField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            maxLength: 60,
            decoration: const InputDecoration(
              labelText: 'Nombre completo',
              hintText: 'Escribe tu nombre',
              prefixIcon: Icon(
                Icons.person_outline,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                final value = nameController.text.trim();

                if (value.isEmpty) {
                  ScaffoldMessenger.of(dialogContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El nombre no puede estar vacío.',
                        ),
                      ),
                    );
                  return;
                }

                if (value.length < 3) {
                  ScaffoldMessenger.of(dialogContext)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El nombre debe tener al menos 3 caracteres.',
                        ),
                      ),
                    );
                  return;
                }

                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text(
                'Guardar',
              ),
            ),
          ],
        );
      },
    );

    if (newName == null || !mounted) return;

    if (newName == currentName) {
      _showMessage(
        'No realizaste ningún cambio.',
      );
      return;
    }

    await _updateProfileName(newName);
  }

  Future<void> _updateProfileName(
    String newName,
  ) async {
    if (_isUpdatingName) return;

    final user = _currentUser;

    if (user == null) {
      _showMessage(
        'Inicia sesión para editar tu perfil.',
      );
      return;
    }

    setState(() {
      _isUpdatingName = true;
    });

    try {
      await user.updateDisplayName(newName);

      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      final userReference = firestore
          .collection('users')
          .doc(user.uid);

      batch.update(
        userReference,
        {
          'name': newName,
        },
      );

      final productsSnapshot = await firestore
          .collection('products')
          .where(
            'sellerId',
            isEqualTo: user.uid,
          )
          .get();

      for (final document in productsSnapshot.docs) {
        batch.update(
          document.reference,
          {
            'sellerName': newName,
          },
        );
      }

      await batch.commit();
      await user.reload();

      if (!mounted) return;

      setState(() {});

      _showMessage(
        'Nombre actualizado correctamente.',
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'Error de Firebase al actualizar nombre: '
        '${error.code} - ${error.message}',
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible actualizar el nombre.',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Error al actualizar nombre: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible actualizar el nombre.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingName = false;
        });
      }
    }
  }

  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Cerrar sesión',
          ),
          content: const Text(
            '¿Seguro que deseas cerrar tu sesión?',
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
                'Cerrar sesión',
              ),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true || !mounted) return;

    await _signOut();
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    try {
      await AuthService.instance.signOut();

      if (!mounted) return;

      context.go('/login');
    } catch (error) {
      debugPrint(
        'Error al cerrar sesión: $error',
      );

      if (!mounted) return;

      _showMessage(
        'No fue posible cerrar la sesión.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState ==
                    ConnectionState.waiting &&
                !userSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (userSnapshot.hasError) {
              return const Center(
                child: Text(
                  'No fue posible cargar el perfil.',
                ),
              );
            }

            final userData = userSnapshot.data?.data();

            final name = _getName(
              authUser: user,
              userData: userData,
            );

            final email = _getEmail(
              authUser: user,
              userData: userData,
            );

            final photoUrl = _getPhotoUrl(
              authUser: user,
              userData: userData,
            );

            final isAdmin =
                userData?['isAdmin'] as bool? ?? false;

            final isSeller =
                userData?['isSeller'] as bool? ?? false;

            final accountType = _getAccountType(
              isAdmin: isAdmin,
              isSeller: isSeller,
            );

            return StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where(
                    'sellerId',
                    isEqualTo: user.uid,
                  )
                  .snapshots(),
              builder: (context, productsSnapshot) {
                final productDocuments =
                    productsSnapshot.data?.docs ?? [];

                final approvedPublications =
                    productDocuments.where((document) {
                  final data = document.data();

                  return data['status'] == 'approved';
                }).length;

                final isFrequentSeller =
                    approvedPublications >= 10;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Mi perfil',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 26),
                      ProfileHeader(
                        name: name,
                        email: email,
                        photoUrl: photoUrl,
                        onPhotoTap:
                            _pickAndUploadProfilePhoto,
                        isUploadingPhoto:
                            _isUploadingPhoto,
                        isVerified:
                            user.emailVerified,
                        isFrequentSeller:
                            isFrequentSeller,
                      ),
                      const SizedBox(height: 26),
                      ProfileStats(
                        publications:
                            approvedPublications,
                        sales: 0,
                        rating: 0,
                      ),
                      const SizedBox(height: 22),
                      ProfileInfoCard(
                        name: name,
                        email: email,
                        accountType: accountType,
                        onEditTap: () {
                          _showEditProfileDialog(name);
                        },
                      ),
                      const SizedBox(height: 22),
                      ProfileMenuItem(
                        icon:
                            Icons.inventory_2_outlined,
                        title: 'Mis publicaciones',
                        subtitle:
                            'Consulta y administra tus productos',
                        onTap: () {
                          context.go(
                            '/my-publications',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon:
                            Icons.shopping_bag_outlined,
                        title: 'Mis pedidos',
                        subtitle:
                            'Consulta tus compras realizadas',
                        onTap: () {
                          context.go('/my-orders');
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon:
                            Icons.chat_bubble_outline,
                        title: 'Mis conversaciones',
                        subtitle:
                            'Habla con compradores y vendedores',
                        onTap: () {
                          context.go('/chats');
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon:
                            Icons.notifications_outlined,
                        title: 'Notificaciones',
                        subtitle:
                            'Configura tus avisos de FoodTap',
                        onTap: () {
                          _showMessage(
                            'Las notificaciones estarán disponibles pronto.',
                          );
                        },
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 12),
                        ProfileMenuItem(
                          icon: Icons
                              .admin_panel_settings_outlined,
                          title:
                              'Panel de administrador',
                          subtitle:
                              'Revisa y modera publicaciones',
                          onTap: () {
                            _showMessage(
                              'El panel de administrador se desarrollará después.',
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      LogoutButton(
                        isLoading: _isSigningOut,
                        onPressed: _confirmSignOut,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: 4,
        onTap: _handleNavigationTap,
      ),
    );
  }

  String _getName({
    required User authUser,
    required Map<String, dynamic>? userData,
  }) {
    final firestoreName =
        userData?['name']?.toString().trim();

    if (firestoreName != null &&
        firestoreName.isNotEmpty) {
      return firestoreName;
    }

    final displayName =
        authUser.displayName?.trim();

    if (displayName != null &&
        displayName.isNotEmpty) {
      return displayName;
    }

    return 'Usuario FoodTap';
  }

  String _getEmail({
    required User authUser,
    required Map<String, dynamic>? userData,
  }) {
    final firestoreEmail =
        userData?['email']?.toString().trim();

    if (firestoreEmail != null &&
        firestoreEmail.isNotEmpty) {
      return firestoreEmail;
    }

    return authUser.email ??
        'Correo no disponible';
  }

  String? _getPhotoUrl({
    required User authUser,
    required Map<String, dynamic>? userData,
  }) {
    final firestorePhoto =
        userData?['photoUrl']?.toString().trim();

    if (firestorePhoto != null &&
        firestorePhoto.isNotEmpty) {
      return firestorePhoto;
    }

    final authPhoto =
        authUser.photoURL?.trim();

    if (authPhoto != null &&
        authPhoto.isNotEmpty) {
      return authPhoto;
    }

    return null;
  }

  String _getAccountType({
    required bool isAdmin,
    required bool isSeller,
  }) {
    if (isAdmin) {
      return 'Administrador';
    }

    if (isSeller) {
      return 'Comprador y vendedor';
    }

    return 'Usuario';
  }
}