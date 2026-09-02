import 'package:flutter/material.dart';

import 'package:sociale_vote/domain/organization/entities/organization_models.dart';

class OrganizationExternalChannelIcon extends StatelessWidget {
  final OrganizationExternalLinkProvider provider;
  final double size;

  const OrganizationExternalChannelIcon({
    super.key,
    required this.provider,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: switch (provider) {
        OrganizationExternalLinkProvider.youtube => _BrandBox(
            size: size,
            color: const Color(0xFFFF0033),
            radius: size * 0.24,
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: size * 0.72,
            ),
          ),
        OrganizationExternalLinkProvider.linkedin => _BrandBox(
            size: size,
            color: const Color(0xFF0A66C2),
            radius: size * 0.18,
            child: Text(
              'in',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.48,
                height: 1,
              ),
            ),
          ),
        OrganizationExternalLinkProvider.whatsapp => _BrandBox(
            size: size,
            color: const Color(0xFF25D366),
            radius: size / 2,
            child: Icon(
              Icons.call_rounded,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        OrganizationExternalLinkProvider.instagram => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Color(0xFFFFC107),
                  Color(0xFFF44336),
                  Color(0xFFE1306C),
                  Color(0xFF833AB4),
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.24),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              color: Colors.white,
              size: size * 0.58,
            ),
          ),
        OrganizationExternalLinkProvider.telegram => _BrandBox(
            size: size,
            color: const Color(0xFF229ED9),
            radius: size / 2,
            child: Transform.translate(
              offset: Offset(-size * 0.03, size * 0.02),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: size * 0.54,
              ),
            ),
          ),
      },
    );
  }
}

class OrganizationWebsiteIcon extends StatelessWidget {
  final double size;

  const OrganizationWebsiteIcon({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _BrandBox(
      size: size,
      color: colors.primaryContainer,
      radius: size / 2,
      child: Icon(
        Icons.public_rounded,
        color: colors.onPrimaryContainer,
        size: size * 0.58,
      ),
    );
  }
}

class _BrandBox extends StatelessWidget {
  final double size;
  final Color color;
  final double radius;
  final Widget child;

  const _BrandBox({
    required this.size,
    required this.color,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
