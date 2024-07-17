import 'package:flutter/material.dart';
import 'package:monmanchitra/main.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaPro extends StatefulWidget {
  @override
  _MangaProState createState() => _MangaProState();
}

class _MangaProState extends State<MangaPro> {
  int _fixed_link_length = 4;
  bool _fixed_link_expand = false;
  String _tag_for_fixed_link = "more";
  int _google_search_count = 2;
  bool _google_history_expand = false;
  String _tag_for_google_history = "more";
  int _fixed_manga_history_count = 2;
  bool _fixed_manga_history_expand = false;
  String _tag_for_fixed_manga_history = "more";
  final TextEditingController _controller = TextEditingController();
  List<String> _bookmarks = [];
  List<Map<String, String>> _googleHistory = [];
  List<Map<String, String>> _fixedMangaHistory = [];

  final List<Map<String, String>> _fixedLinks = [
    {'url': 'https://asuracomic.net/', 'name': 'AsuraScan.net'},
    {'url': 'https://manhuafast.com/', 'name': 'Manhuafast.com'},
    {'url': 'https://manhuafast.net/', 'name': 'Manhuafast.net'},
    {'url': 'https://manhuaus.com/', 'name': 'Manhuaus.com'},
    {'url': 'https://www.mgeko.cc/jumbo/manga/', 'name': 'Mgeko.cc'},
    {'url': 'https://mangakakalot.com/', 'name': 'MangaKakalot.com'},
    {'url': 'https://drake-scans.com/', 'name': 'DarkScans.com'},
    {'url': 'https://mangapark.net/', 'name': 'MangaPark.net'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGoogleHistory();
    _loadFixedMangaHistory();
  }

  Future<void> _loadGoogleHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('googleHistory') ?? [];
    setState(() {
      _googleHistory = history.reversed.map((entry) {
        final parts = entry.split('||');
        return {'query': parts[0], 'url': parts[1]};
      }).toList();
    });
  }

  Future<void> _addGoogleHistory(String query, String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final entry = '$query||$url';
    final history = prefs.getStringList('googleHistory') ?? [];
    history.add(entry);
    await prefs.setStringList('googleHistory', history);
    setState(() {
      _googleHistory.add({'query': query, 'url': url});
    });
  }

  Future<void> _loadFixedMangaHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('fixedMangaHistory') ?? [];
    setState(() {
      _fixedMangaHistory = history.reversed.map((entry) {
        // final parts = entry.split('||');
        return {'name': '', 'url': entry};
      }).toList();
    });
  }

  // Future<void> addFixedMangaHistory(String url) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final entry = '$url';
  //   final history = prefs.getStringList('fixedMangaHistory') ?? [];
  //   history.add(entry);
  //   await prefs.setStringList('fixedMangaHistory', history);
  //   setState(() {
  //     _fixedMangaHistory.add({'url': url});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/mangaPro.png',
        ),
        toolbarHeight: 70,
        backgroundColor: Color.fromARGB(255, 74, 62, 44),
        elevation: 100,
        shadowColor: Color.fromARGB(132, 0, 0, 0),
      ),
      backgroundColor: Color.fromARGB(255, 102, 98, 51),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    color: Color.fromARGB(
                        45, 212, 127, 16), // Background color of the text field
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Search on Google',
                        hintText: 'Search on Google',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 0, 3, 5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16), // Label text color
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(179, 255, 175, 1),
                            ),
                            borderRadius:
                                BorderRadius.circular(20) // Border color
                            ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .orange.shade700), // Focused border color
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16), // Text color
                    ),
                  ),
                ),
                SizedBox(height: 0),
                ElevatedButton(
                  onPressed: () {
                    _searchGoogle(context, _controller.text);
                    _controller.clear();
                  },
                  child: Text(
                    'Google Search',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors
                              .orange.shade400; // Orange color when pressed
                        }
                        return Colors.orange.shade400;
                        // Normal orange color
                      },
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Circular shape
                      ),
                    ),
                    elevation:
                        MaterialStateProperty.all<double>(4.0), // Elevation
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Colors.orange.shade200
                              .withOpacity(0.4); // Overlay color on press
                        }
                        return Colors.orange.shade900;
                      },
                    ),

                    foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black), // Text color
                  ),
                ),
                SizedBox(
                  height: 80,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                      child: Text(
                        'Fixed Manga Sites',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _fixed_link_expand = !_fixed_link_expand;
                          _fixed_link_expand
                              ? _fixed_link_length = _fixedLinks.length
                              : _fixed_link_length = 4;
                          _fixed_link_expand
                              ? _tag_for_fixed_link = "less"
                              : _tag_for_fixed_link = "more";
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 25, 10),
                        child: Text(
                          _tag_for_fixed_link,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _fixed_link_expand
                                ? Color.fromARGB(255, 0, 253, 13)
                                : Color.fromARGB(255, 255, 187, 0),
                            // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _buildLinksList(),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                      child: Text(
                        'Google History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _google_history_expand = !_google_history_expand;
                          _google_history_expand
                              ? _google_search_count = _googleHistory.length
                              : _google_search_count = 2;
                          _google_history_expand
                              ? _tag_for_google_history = "less"
                              : _tag_for_google_history = "more";
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 25, 10),
                        child: Text(
                          _tag_for_google_history,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _google_history_expand
                                ? Color.fromARGB(255, 0, 253, 13)
                                : Color.fromARGB(255, 255, 187, 0),
                            // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _googleHistory.isEmpty
                    ? Center(
                        child: Text(
                        'Empty History',
                        style: TextStyle(fontSize: 16),
                      ))
                    : _buildGoogleHistoryList(),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
                      child: Text(
                        'Fixed Manga History',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _fixed_manga_history_expand =
                              !_fixed_manga_history_expand;
                          _fixed_manga_history_expand
                              ? _fixed_manga_history_count =
                                  _fixedMangaHistory.length
                              : _fixed_manga_history_count = 2;
                          _fixed_manga_history_expand
                              ? _tag_for_fixed_manga_history = "less"
                              : _tag_for_fixed_manga_history = "more";
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 25, 10),
                        child: Text(
                          _tag_for_fixed_manga_history,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _fixed_manga_history_expand
                                ? Color.fromARGB(255, 0, 253, 13)
                                : Color.fromARGB(255, 255, 187, 0),
                            // backgroundColor: Color.fromARGB(64, 51, 40, 9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _fixedMangaHistory.isEmpty
                    ? Center(
                        child: Text(
                        'Empty History',
                        style: TextStyle(fontSize: 16),
                      ))
                    : _buildFixedMangaHistoryList(),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedMangaHistoryList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: _fixedMangaHistory.isEmpty
          ? Center(child: Text('Empty History', style: TextStyle(fontSize: 16)))
          : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _fixed_manga_history_count,
              itemBuilder: (context, index) {
                final entry = _fixedMangaHistory[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: ListTile(
                      tileColor: Colors.orange,
                      title: Text(
                        entry['name']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        entry['url']!,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _launchURL(context, entry['url']!),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildLinksList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
      ),
      itemCount: _fixed_link_length,
      itemBuilder: (context, index) {
        if (index < _fixedLinks.length) {
          final link = _fixedLinks[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: _elevatedButton(context, link['url']!, link['name']!),
          );
        } else {
          return Container(); // or some fallback widget
        }
      },
    );
  }

  Widget _buildGoogleHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _google_search_count,
      itemBuilder: (context, index) {
        final entry = _googleHistory[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
          child: ListTile(
            title: Text(
              entry['query']!,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(entry['url']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            tileColor: Colors.orange,
            onTap: () async {
              _launchURL(context, entry['url']!);
            },
          ),
        );
      },
    );
  }

  ElevatedButton _elevatedButton(
      BuildContext context, String url, String text) {
    return ElevatedButton(
      onPressed: () => _launchURL(context, url),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.orange.shade700; // Orange color when pressed
            }
            return Colors.orange; // Normal orange color
          },
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Circular shape
          ),
        ),
        elevation: MaterialStateProperty.all<double>(4.0), // Elevation
        overlayColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.orange.shade200
                  .withOpacity(0.4); // Overlay color on press
            }
            return Colors.orange.shade900;
          },
        ),

        foregroundColor:
            MaterialStateProperty.all<Color>(Colors.black), // Text color
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 2500), // Animation duration
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewWithSplashScreen(url: url),
      ),
    );
  }

  _searchGoogle(BuildContext context, String query) async {
    final url = 'https://www.google.com/search?q=$query';

    _launchURL(context, url);
    await _addGoogleHistory(query, url);
  }
}
