import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'main.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env.prod");
  runApp(const ProviderScope(child: MyApp()));
}
