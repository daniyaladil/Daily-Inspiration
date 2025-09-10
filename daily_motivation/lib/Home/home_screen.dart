import 'package:daily_motivation/Home/favorite_screen.dart';
import 'package:daily_motivation/Home/quote_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;

    final List<Widget> screens = [
      QuoteScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
      FavoriteScreen(themeMode: _themeMode),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: isDark ? Colors.tealAccent : Colors.blueAccent,
          unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.format_quote_outlined),
              label: "Quotes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: "Favorites",
            ),
          ],
        ),
      ),
    );
  }
}
