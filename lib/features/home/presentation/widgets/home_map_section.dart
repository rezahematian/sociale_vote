import 'package:flutter/material.dart';

import 'package:sociale_vote/features/map/presentation/widgets/civic_map_widget.dart';

class HomeMapSection extends StatelessWidget {
  final String scopeShortLabel;

  const HomeMapSection({
    super.key,
    required this.scopeShortLabel,
  });

  @override
  Widget build(BuildContext context) {
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
          child: CivicMapWidget(
            currentScopeLabel: scopeShortLabel,
          ),
        ),
      ),
    );
  }
}