import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sociale_vote/app/app.dart';
import 'package:sociale_vote/app/di.dart';
import 'package:sociale_vote/features/geo/application/geo_scope_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rbuzlrclwhxaigkgndrb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJidXpscmNsd2h4YWlna2duZHJiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMyNDY3MzYsImV4cCI6MjA4ODgyMjczNn0.dHNA8s3NcqnluakSb-NFnb2jNgCcaVm3Ix24LbbIpHI',
  );

  runApp(
    ChangeNotifierProvider<GeoScopeController>.value(
      value: AppDI.instance.geoScopeController,
      child: const SocialeVoteApp(),
    ),
  );
}