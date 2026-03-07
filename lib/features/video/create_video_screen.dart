import 'package:flutter/material.dart';

class CreateVideoScreen extends StatefulWidget {
  final void Function(
    String title,
    String description,
    String url,
  ) onCreate;

  const CreateVideoScreen({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _url = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Video')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(hintText: 'Title')),
            TextField(controller: _description, decoration: const InputDecoration(hintText: 'Description')),
            TextField(controller: _url, decoration: const InputDecoration(hintText: 'Video URL')),
            ElevatedButton(
              onPressed: () {
                widget.onCreate(
                  _title.text,
                  _description.text,
                  _url.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }
}
