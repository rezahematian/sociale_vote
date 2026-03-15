import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/app/router.dart';
import 'package:sociale_vote/features/map/application/civic_map_controller.dart';
import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';

class HomeMapSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeMapSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CivicMapController>(
      create: (_) => AppDI.instance.createCivicMapController(),
      child: _HomeMapSectionView(
        scopeShortLabel: scopeShortLabel,
      ),
    );
  }
}

class _HomeMapSectionView extends StatelessWidget {
  final String scopeShortLabel;

  const _HomeMapSectionView({
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CivicMapController>();

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              CivicMapWidget(
                controller: controller,
                currentScopeLabel: scopeShortLabel,
                onTap: () {
                  Navigator.of(context).pushNamed(AppRouter.civicMap);
                },
                onItemTap: (_) {
                  Navigator.of(context).pushNamed(AppRouter.civicMap);
                },
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.civicMap);
                  },
                  icon: const Icon(Icons.open_in_full),
                  label: const Text('Apri mappa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
