import 'package:flutter/material.dart';

import 'poll_controller.dart';
import 'poll_card.dart';

class PollScreen extends StatefulWidget {
  final PollController controller;

  const PollScreen({
    super.key,
    required this.controller,
  });

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  @override
  void didUpdateWidget(covariant PollScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Mostra feedback SOLO quando il voto va a buon fine
    if (widget.controller.status == PollControllerStatus.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Voto registrato con successo'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Votazione civica'),
            centerTitle: true,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    final controller = widget.controller;

    // =========================
    // LOADING
    // =========================
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // =========================
    // ERROR
    // =========================
    if (controller.status == PollControllerStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage ?? 'Errore sconosciuto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // =========================
    // NO POLL
    // =========================
    final poll = controller.currentPoll;
    if (poll == null) {
      return const Center(
        child: Text(
          'Nessuna votazione disponibile',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    // =========================
    // POLL CONTENT
    // =========================
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PollCard(
        poll: poll,

        /// Adapter: PollCard → PollController
        onVote: (optionId) {
          widget.controller.vote(
            pollId: poll.id,
            optionId: optionId,
          );
        },

        errorMessage: controller.errorMessage,
      ),
    );
  }
}
