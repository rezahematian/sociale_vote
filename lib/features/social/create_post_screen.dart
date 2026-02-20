import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  final void Function(String content) onCreate;

  const CreatePostScreen({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLength: 280,
              decoration: const InputDecoration(
                hintText: 'Write something civic...',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onCreate(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Publish'),
            )
          ],
        ),
      ),
    );
  }
}
