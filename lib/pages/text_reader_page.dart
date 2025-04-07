// lib/pages/text_reader_page.dart

import 'package:flutter/material.dart';

class TextReaderPage extends StatefulWidget {
  final String title;
  final String content;

  const TextReaderPage({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  _TextReaderPageState createState() => _TextReaderPageState();
}

class _TextReaderPageState extends State<TextReaderPage> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Tajawal', color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.content,
                style: TextStyle(fontSize: _fontSize, fontFamily: 'Tajawal'),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (_fontSize > 10) _fontSize -= 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.zoom_out, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "تصغير",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _fontSize += 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.zoom_in, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "تكبير",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
