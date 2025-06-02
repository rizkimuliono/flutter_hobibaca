import 'package:flutter/material.dart';

import 'pages/splash_screen.dart';
import 'package:provider/provider.dart';
import 'providers/saldo_provider.dart';

void main() async{
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = SaldoProvider();
        provider.loadSaldo(); // panggil langsung saat provider dibuat
        return provider;
        
      },
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hobi Baca App',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
