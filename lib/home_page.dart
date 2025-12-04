import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'form_page.dart';
import 'records_page.dart';
import 'me_section_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late PageController _pageController;
  bool _isLoading = true; // Show only Lottie animation initially

  final List<Widget> _pages = [
    const FormPage(),
    const RecordsPage(),
    const MeSectionPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Show Lottie animation for 2 seconds before loading the main page
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show ONLY Lottie animation while loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Lottie.asset(
            'assets/load.json', // Your Lottie animation file
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // ✅ Main content after loading
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 16, 125, 215),
        unselectedItemColor: const Color.fromARGB(255, 120, 119, 119),
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Form'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
      ),
    );
  }
}
