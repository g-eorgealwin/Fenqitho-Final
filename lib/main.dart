import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LyricsGenerator(),
    );
  }
}

class LyricsGenerator extends StatefulWidget {
  @override
  _LyricsGeneratorState createState() => _LyricsGeneratorState();
}

class _LyricsGeneratorState extends State<LyricsGenerator>
    with SingleTickerProviderStateMixin {
  final TextEditingController languageController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController lyricsController = TextEditingController();

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _titleFadeAnimation;

  bool _isLoading = false; // State to manage loading animation

  List<String> quotes = [
    '"Music is the universal language of mankind."',
    '"Music is the strongest form of magic."'
  ];

  int _currentQuoteIndex = 0;
  bool _showQuotes = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: false);

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.grey[850],
    ).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % quotes.length;
      });
    });

    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        _showQuotes = false;
      });
      _timer.cancel();
    });
  }

  Future<void> generateLyrics(String description, String genre) async {
    print('Generating lyrics for: $description in genre: $genre');
    setState(() {
      _isLoading = true;  // Start loading animation
    });
    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:5000/generate_lyrics'), // Use your IP address
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'description': description,
          'genre': genre  // Send genre along with description
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          lyricsController.text = data['lyrics'] ?? 'No lyrics generated';
        });
        print('Generated lyrics: ${data['lyrics']}');
      } else {
        setState(() {
          lyricsController.text = 'Failed to generate lyrics: ${response.statusCode}';
        });
        print('Failed response: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        lyricsController.text = 'Error occurred: $e';
      });
      print('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;  // Stop loading animation
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: FadeTransition(
              opacity: _titleFadeAnimation,
              child: Text(
                'FENQITHO LYRICS GENERATOR',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Language', icon: Icon(Icons.language, color: Colors.white)),
              Tab(text: 'Genre', icon: Icon(Icons.music_note, color: Colors.white)),
              Tab(text: 'Lyrics', icon: Icon(Icons.format_quote, color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.black,
        ),
        body: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              color: _colorAnimation.value,
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      // Language tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: languageController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter Language',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Genre Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: genreController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Enter Genre',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Enter genre to enhance the quality of Lyrics',
                              style: TextStyle(color: Colors.white54),
                            )
                          ],
                        ),
                      ),
                      // Lyrics Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: descriptionController,
                                maxLines: 5,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Describe the song you would like to produce',
                                  labelStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                generateLyrics(descriptionController.text.trim(), genreController.text.trim());
                              },
                              child: Text('Create/Update Lyrics'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            SizedBox(height: 16),
                            _isLoading
                                ? Column(
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Fenqitho is loading, please wait...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  )
                                : Expanded(
                                    child: TextField(
                                      controller: lyricsController,
                                      maxLines: 10,
                                      readOnly: true,
                                      style: TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Generated Lyrics',
                                        labelStyle: TextStyle(color: Colors.white),
                                        border: OutlineInputBorder(),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_showQuotes)
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          quotes[_currentQuoteIndex],
                          style: TextStyle(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Text(
                      'Created by Alwin George',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
