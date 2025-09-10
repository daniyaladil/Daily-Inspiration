import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoriteScreen extends StatefulWidget {
  final ThemeMode themeMode;

  const FavoriteScreen({super.key, required this.themeMode});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Box favoritesBox;
  List<Map<String, String>> favorites = [];

  @override
  void initState() {
    super.initState();
    favoritesBox = Hive.box('favoritesBox');
    _loadFavorites();
  }

  void _loadFavorites() {
    final stored = favoritesBox.get('favorites', defaultValue: []);
    setState(() {
      favorites = List<Map<String, String>>.from(
        (stored as List).map((item) => Map<String, String>.from(item)),
      );
    });
  }

  void _removeFavorite(Map<String, String> item) {
    final removedIndex = favorites.indexWhere((fav) =>
    fav["quote"] == item["quote"] && fav["author"] == item["author"]);
    if (removedIndex == -1) return;

    final removedItem = favorites[removedIndex];

    setState(() {
      favorites.removeAt(removedIndex);
      favoritesBox.put('favorites', favorites);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Removed from favorites"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            setState(() {
              favorites.insert(removedIndex, removedItem);
              favoritesBox.put('favorites', favorites);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final isDark = widget.themeMode == ThemeMode.dark;
    final bgAsset = isDark ? 'assets/black_bg.jpg' : 'assets/white_bg.jpg';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: favorites.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_border,
                size: 84,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(height: 18),
              Text(
                "No favorites yet.",
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tap on any quote to save it here.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 360),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                        Colors.black.withOpacity(0.45),
                        Colors.black.withOpacity(0.28)
                      ]
                          : [
                        Colors.white.withOpacity(0.65),
                        Colors.white.withOpacity(0.45)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.black.withOpacity(0.06),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.15),
                        offset: const Offset(0, 6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.deepPurpleAccent
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "“${item["quote"]}”",
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "- ${item["author"]}",
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: isDark
                              ? Colors.redAccent.shade200
                              : Colors.redAccent,
                        ),
                        onPressed: () => _removeFavorite(item),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
