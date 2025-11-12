import 'package:flutter/material.dart';
import 'package:project/screen_home/posting.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final GlobalKey<PostingScreenState> _postingScreenKey =
      GlobalKey<PostingScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bottom Bar Example'),
        backgroundColor: Colors.blueAccent,
      ),
      body: PostingScreen(key: _postingScreenKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _postingScreenKey.currentState?.showNewPostDialog();
          print('포스팅 버튼 눌림!');
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
