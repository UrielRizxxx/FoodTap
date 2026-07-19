import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/category_list.dart';
import '../widgets/home_bottom_navigation.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_section_title.dart';
import '../widgets/product_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _selectedCategory;
  String _searchText = '';

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return 'Usuario';
  }

  String? get _photoUrl {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  void _selectCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  void _changeSection(int index) {
    switch (index) {
      case 0:
        setState(() {
          _currentIndex = 0;
        });
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

  void _showNotificationMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Las notificaciones estarán disponibles pronto.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(
                userName: _userName,
                photoUrl: _photoUrl,
                onProfileTap: () {
                  context.go('/profile');
                },
                onNotificationTap: _showNotificationMessage,
              ),
              const SizedBox(height: 24),
              HomeSearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchText = value.trim().toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 28),
              const HomeSectionTitle(
                title: 'Categorías',
              ),
              const SizedBox(height: 14),
              CategoryList(
                selectedCategory: _selectedCategory,
                onCategorySelected: _selectCategory,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: HomeSectionTitle(
                      title: 'Productos',
                    ),
                  ),
                  if (_selectedCategory != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ProductGrid(
                  searchText: _searchText,
                  selectedCategory: _selectedCategory,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _changeSection,
      ),
    );
  }
}