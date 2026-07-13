import 'package:flutter/material.dart';

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
  int currentIndex = 0;

  String? selectedCategory;

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
              const HomeHeader(
                userName: 'Uriel',
              ),

              const SizedBox(height: 24),

              const HomeSearchBar(),

              const SizedBox(height: 28),

              const HomeSectionTitle(
                title: 'Categorías',
              ),

              const SizedBox(height: 14),

              CategoryList(
                selectedCategory: selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 28),

              const HomeSectionTitle(
                title: 'Productos',
              ),

              const SizedBox(height: 16),

              const Expanded(
                child: ProductGrid(),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: HomeBottomNavigation(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}