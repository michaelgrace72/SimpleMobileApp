import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'quote.dart';
import 'quote_card.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Flutter Mikha Home Page'),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <String>[];
  var profile = Profile(name: 'User', email: 'user@example.com', bio: 'Flutter enthusiast');
  List<Quote> quotes = [
    Quote(author: 'Oscar Wilde', text: 'Be yourself; everyone else is already taken'),
    Quote(author: 'Oscar Wilde', text: 'I have nothing to declare except my genius'),
    Quote(author: 'Oscar Wilde', text: 'The truth is rarely pure and never simple'),
  ];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    final word = current.asPascalCase;
    if (favorites.contains(word)) {
      favorites.remove(word);
    } else {
      favorites.add(word);
    }
    notifyListeners();
  }

  void addCustomFavorite(String word) {
    if (word.isNotEmpty && !favorites.contains(word)) {
      favorites.add(word);
      notifyListeners();
    }
  }

  void deleteFavorite(String word) {
    favorites.remove(word);
    notifyListeners();
  }

  void updateProfile(String name, String email, String bio) {
    profile = Profile(name: name, email: email, bio: bio);
    notifyListeners();
  }

  void addQuote(Quote quote) {
    quotes.add(quote);
    notifyListeners();
  }

  void updateQuote(int index, Quote newQuote) {
    if (index >= 0 && index < quotes.length) {
      quotes[index] = newQuote;
      notifyListeners();
    }
  }

  void removeQuote(int index) {
    if (index >= 0 && index < quotes.length) {
      quotes.removeAt(index);
      notifyListeners();
    }
  }
}

class Profile {
  String name;
  String email;
  String bio;

  Profile({required this.name, required this.email, required this.bio});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 0 = Home, 1 = Favorites, 2 = Quote, 3 = Profile

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _selectedIndex == 0
          ? const HomeContent()
          : _selectedIndex == 1
              ? const FavoritesPage()
              : _selectedIndex == 2
                  ? const QuotePage()
                  : const ProfilePage(),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.deepPurple,
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Colors.yellowAccent, 
        unselectedItemColor: Colors.yellowAccent[100], 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    )
    );
    
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            appState.current.asPascalCase,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(
                  appState.favorites.contains(appState.current.asPascalCase)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final TextEditingController _textController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Add your own favorite word!',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final word = _textController.text.trim();
                  if (word.isNotEmpty) {
                    appState.addCustomFavorite(word);
                    _textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: appState.favorites.isEmpty
              ? const Center(
                  child: Text('No favorites yet.'),
                )
              : ListView(
                  children: [
                    for (var word in appState.favorites)
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: Text(word),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            appState.deleteFavorite(word);
                          },
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;
  int? _editingIndex;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Awesome Quotes'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddQuoteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _authorController,
                        decoration: const InputDecoration(labelText: 'Author'),
                      ),
                      TextField(
                        controller: _textController,
                        decoration: const InputDecoration(labelText: 'Quote'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _authorController.clear();
                                _textController.clear();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              if (_authorController.text.isNotEmpty &&
                                  _textController.text.isNotEmpty) {
                                setState(() {
                                  if (_editingIndex != null) {
                                    appState.quotes[_editingIndex!] = Quote(
                                      author: _authorController.text,
                                      text: _textController.text,
                                    );
                                  } else {
                                    appState.quotes.add(Quote(
                                      author: _authorController.text,
                                      text: _textController.text,
                                    ));
                                  }
                                  _isEditing = false;
                                  _authorController.clear();
                                  _textController.clear();
                                  _editingIndex = null;
                                });
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < appState.quotes.length; i++)
                  QuoteCard(
                    key: ValueKey(i),
                    quote: appState.quotes[i],
                    delete: () {
                      setState(() {
                        appState.quotes.removeAt(i);
                      });
                    },
                    edit: () {
                      setState(() {
                        _isEditing = true;
                        _editingIndex = i;
                        _authorController.text = appState.quotes[i].author;
                        _textController.text = appState.quotes[i].text;
                      });
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddQuoteDialog(BuildContext context) {
    setState(() {
      _isEditing = true;
      _editingIndex = null;
      _authorController.clear();
      _textController.clear();
    });
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final TextEditingController _nameController =
        TextEditingController(text: appState.profile.name);
    final TextEditingController _emailController =
        TextEditingController(text: appState.profile.email);
    final TextEditingController _bioController =
        TextEditingController(text: appState.profile.bio);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _nameController),
          const SizedBox(height: 10),
          const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _emailController),
          const SizedBox(height: 10),
          const Text('Bio:', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _bioController, maxLines: 3),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                appState.updateProfile(
                  _nameController.text,
                  _emailController.text,
                  _bioController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              },
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}