import 'package:flutter/material.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/core/security/participation_policy.dart';
import 'package:sociale_vote/domain/geo/value_objects/geo_scope.dart';
import 'package:sociale_vote/shared/services/auth_guard.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔐 Prima controlliamo i permessi: solo utente loggato può creare post.
    final allowed = await AuthGuard.ensureCanPerformAction(
      context,
      ParticipationAction.createPost,
    );
    if (!allowed) return;

    final userId = AppDI.instance.currentUserId;
    if (userId == null) {
      // Se succede, qualcosa non torna nella policy o nella sessione.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: utente non disponibile nella sessione.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      // v1: nome autore finto derivato da userId.
      final authorName = 'User $userId';

      // Scope geografico corrente (coerente con FeedController / Poll).
      final scope = AppDI.instance.geoScopeController.scope;

      String? countryCode;
      String? cityId;

      switch (scope.level) {
        case GeoScopeLevel.world:
          countryCode = null;
          cityId = null;
          break;
        case GeoScopeLevel.country:
          countryCode = scope.countryCode;
          cityId = null;
          break;
        case GeoScopeLevel.city:
          countryCode = scope.countryCode;
          cityId = scope.cityId;
          break;
      }

      // 🔗 Use case reale CreatePost (il tuo create_post.dart)
      await AppDI.instance.createPost(
        authorId: userId,
        authorName: authorName,
        title: title,
        content: content,
        countryCode: countryCode,
        cityId: cityId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post creato con successo.'),
        ),
      );

      // Ritorniamo true al chiamante (SocialFeedPage) per triggerare il refresh.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella creazione del post: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create post'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'New post',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Condividi una proposta, un’idea o un commento per quest’area geografica.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),

                // Titolo
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 120,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci un titolo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contenuto
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                  minLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il contenuto del post';
                    }
                    if (value.trim().length < 10) {
                      return 'Il contenuto è troppo corto (min 10 caratteri)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}