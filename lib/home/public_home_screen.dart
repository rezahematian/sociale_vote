import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';

// NEWS (lasciato legacy perché nel tuo file già funziona con AppBootstrap)
import '../core/bootstrap/app_bootstrap.dart';
import '../features/news/news_card.dart';
import '../features/news/news_controller.dart';
import '../features/news/news_detail_screen.dart';

// MAP
import '../features/map/civic_map_widget.dart';
import '../features/map/civic_map_screen.dart';
import '../navigation/city_navigation_gate.dart';

// AUTH (legacy UI del tuo header)
import '../features/auth/login_screen.dart';

// ✅ POLL (NUOVO STACK)
import 'package:sociale_vote/domain/poll/entities/poll.dart';
import 'package:sociale_vote/features/poll/application/poll_list_controller.dart';
import 'package:sociale_vote/features/poll/presentation/widgets/poll_card.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen>
    with SingleTickerProviderStateMixin {
  late final NewsController _newsController;

  late final AnimationController _controller;
  late final Animation<double> _fade;

  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    // NEWS: tieni la tua pipeline attuale
    _newsController = AppBootstrap.newsController;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _controller.forward();
    _loadNewsOnce();
  }

  void _loadNewsOnce() {
    if (_loaded) return;
    _loaded = true;

    _newsController.loadGlobalNews(
      languageCode: 'it',
      countryCode: 'IT',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 Premium Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B1120),
                  Color(0xFF111827),
                  Color(0xFF1F2937),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// ✨ Subtle glow effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;

                  final content = SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 30),
                        _Header(),
                        SizedBox(height: 60),
                        _HeroSection(),
                        SizedBox(height: 60),
                        _GlassSearch(),
                        SizedBox(height: 70),
                        _MapSection(),
                        SizedBox(height: 80),
                        _NewsSection(),
                        SizedBox(height: 80),

                        // ✅ Poll section ora usa il nuovo stack via AppDI
                        _PollSection(),

                        SizedBox(height: 120),
                      ],
                    ),
                  );

                  if (isMobile) return content;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: content,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HEADER
============================================================ */

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Civic Pulse',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.3,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text(
            'Accedi',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('Registrati'),
        ),
      ],
    );
  }
}

/* ============================================================
   HERO
============================================================ */

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Decidi il futuro.\nInsieme.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Partecipa alle votazioni, esplora notizie globali\n'
          'e osserva la mappa civica in tempo reale.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   GLASS SEARCH
============================================================ */

class _GlassSearch extends StatefulWidget {
  const _GlassSearch();

  @override
  State<_GlassSearch> createState() => _GlassSearchState();
}

class _GlassSearchState extends State<_GlassSearch> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              icon: Icon(Icons.search, color: Colors.white70),
              hintText: 'Cerca città o paese',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;

              CityNavigationGate.openCity(
                context,
                locationId: value.toLowerCase().replaceAll(' ', '_'),
              );
            },
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   MAP
============================================================ */

class _MapSection extends StatelessWidget {
  const _MapSection();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.width < 800 ? 260.0 : 420.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: CivicMapWidget(
          height: height,
          onLocationSelected: (cityId) {
            CityNavigationGate.openCity(context, locationId: cityId);
          },
          onRequestFullscreen: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CivicMapScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/* ============================================================
   NEWS (legacy)
============================================================ */

class _NewsSection extends StatelessWidget {
  const _NewsSection();

  @override
  Widget build(BuildContext context) {
    final controller = AppBootstrap.newsController;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final news = controller.items.take(3).toList();
        if (news.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌍 Notizie globali',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...news.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: NewsCard(
                  news: item,
                  onHot: () => controller.toggleHot(item),
                  onCold: () => controller.toggleCold(item),
                  onReset: () => controller.resetVote(item),
                  onRead: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewsDetailScreen(news: item),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* ============================================================
   POLL (✅ nuovo stack)
============================================================ */

class _PollSection extends StatelessWidget {
  const _PollSection();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PollListController>(
      create: (_) {
        final controller = AppDI.instance.createPollListController();
        final userId = AppDI.instance.currentUserId;
        controller.loadPolls(userId: userId);
        return controller;
      },
      child: Consumer<PollListController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.polls.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final List<Poll> polls = controller.polls;
          if (polls.isEmpty) return const SizedBox.shrink();

          final top = polls.length <= 3 ? polls : polls.take(3).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🗳️ Votazioni attive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ...top.map(
                (poll) => Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.pollDetail,
                        arguments: poll.id,
                      );
                    },
                    child: PollCard(poll: poll),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}