import 'dart:convert';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class QuoteScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const QuoteScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  List<Map<String, String>> favorites = [];
  String? quote;
  String? author;
  bool isLoading = true;
  bool isFavorite = false;
  late Box favoritesBox;

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    favoritesBox = Hive.box('favoritesBox');
    _loadFavorites();
  }

  void _loadFavorites() {
    final stored = favoritesBox.get('favorites', defaultValue: []);
    favorites = List<Map<String, String>>.from(
        (stored as List).map((item) => Map<String, String>.from(item)));
    setState(() {});
  }

  void _isFavToggle(String quote, String author) {
    setState(() {
      final exists = favorites.any(
        (fav) => fav["quote"] == quote && fav["author"] == author,
      );

      if (exists) {
        _removeFavorite(quote, author);
        isFavorite = false;
      } else {
        _addFavorite(quote, author);
        isFavorite = true;
      }

      _saveToHive();
    });
  }

  void _addFavorite(String quote, String author) {
    favorites.add({
      "quote": quote,
      "author": author,
    });
    print("Added: $quote");
  }

  void _removeFavorite(String quote, String author) {
    favorites
        .removeWhere((fav) => fav["quote"] == quote && fav["author"] == author);
    print("Removed: $quote");
  }

  void _saveToHive() {
    favoritesBox.put('favorites', favorites);
    print("Hive saved: $favorites");
  }

  void _shareQuote(String quote, String author) {
    final text = "“$quote”\n— $author";
    Share.share(text, subject: "Inspiration for you");
  }

  Future<void> getRandomQuote() async {
    setState(() => isLoading = true);

    try {
      final response =
          await http.get(Uri.parse("https://zenquotes.io/api/random"));
      var data = jsonDecode(response.body.toString());

      if (response.statusCode == 200) {
        final newQuote = data[0]["q"].toString();
        final newAuthor = data[0]["a"].toString();

        setState(() {
          quote = newQuote;
          author = newAuthor;
          isLoading = false;

          // check if this quote is already in favorites
          isFavorite = favorites.any(
            (fav) => fav["quote"] == newQuote && fav["author"] == newAuthor,
          );
        });
      }
    } catch (e) {
      setState(() {
        quote = " Failed to fetch quote. Try again!";
        author = "";
        isLoading = false;
        isFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  isDark ? "assets/black_bg.jpg" : "assets/white_bg.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Center(
            child: isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glass Quote Container
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.4)
                                    : Colors.black45,
                                width: 1.2,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  isDark
                                      ? Colors.black.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.25),
                                  isDark
                                      ? Colors.black.withOpacity(0.25)
                                      : Colors.white.withOpacity(0.25),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "“$quote”",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: "Georgia",
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    height: 1.5,
                                    shadows: [
                                      Shadow(
                                        color: isDark
                                            ? Colors.black87
                                            : Colors.white,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  author ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _isFavToggle(quote!, author!);
                                      },
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _shareQuote(quote!, author!);
                                      },
                                      child: Icon(
                                        Icons.share,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Inspire Me Button
                      GestureDetector(
                        onTap: getRandomQuote,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: 55,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      Colors.deepPurpleAccent,
                                      Colors.indigoAccent
                                    ]
                                  : [
                                      Colors.cyanAccent.shade200,
                                      Colors.blueAccent
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.deepPurpleAccent.withOpacity(0.6)
                                    : Colors.cyanAccent.withOpacity(0.5),
                                offset: const Offset(0, 6),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "Inspire Me",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Floating Theme Toggle (top right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 30,
                  color: isDark ? Colors.amberAccent : Colors.orangeAccent,
                ),
                onPressed: widget.onToggleTheme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
