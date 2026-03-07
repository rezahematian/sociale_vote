import 'package:flutter/material.dart';
import 'poll_controller.dart';

class VoteScreen extends StatelessWidget {
  final PollController controller;

  const VoteScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vote')),
      body: Center(
        child: PollStatusView(controller: controller),
      ),
    );
  }
}

class PollStatusView extends StatelessWidget {
  final PollController controller;

  const PollStatusView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        switch (controller.status) {
          case PollControllerStatus.voting:
            return const CircularProgressIndicator();
          case PollControllerStatus.success:
            return const Icon(Icons.check_circle,
                color: Colors.green, size: 64);
          case PollControllerStatus.error:
            return Text(
              controller.errorMessage ?? 'Error',
              style: const TextStyle(color: Colors.red),
            );
          default:
            return const Text('Ready to vote');
        }
      },
    );
  }
}
