import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/saldo_provider.dart';
import 'login_page.dart';
import '../services/api_service.dart';
import 'transaction_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? email;
  Future<Map<String, dynamic>?>? futureUserDetail;

  Future<void> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailValue = prefs.getString('email');

    setState(() {
      email = emailValue;
      futureUserDetail = ApiService.getUserDetail();
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // logout();
    getUserInfo();
  }
  

  @override
  Widget build(BuildContext context) {
    if (futureUserDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: futureUserDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!['data'] == null) {
          return const Center(
            child: Text(
              'Data tidak tersedia.\nPeriksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        }

        final user = snapshot.data!['data'];
        final fullName = '${user['name']}';
        final userEmail = '${user['email']}';
        final nomorHp = '${user['no_hp']}';

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: logout,
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(45, 34, 255, 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Text(fullName,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text(userEmail,
                                  style: const TextStyle(color: Colors.grey)),
                              Text(nomorHp,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(45, 34, 255, 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Saldo Koin",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.black, size: 32),
                                    const SizedBox(width: 4),
                                    Text(
                                      context
                                          .watch<SaldoProvider>()
                                          .saldo
                                          .toStringAsFixed(2),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getInt('user_id');
                            if (userId != null) {
                              _showTopUpDialog(userId);
                            }
                          },
                          icon: const Icon(Icons.upload),
                          label: const Text('TOP UP',
                              style: TextStyle(fontSize: 24)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              fixedSize: const Size(150, 50)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTopUpDialog(int userId) {
    final TextEditingController nominalController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Top Up Saldo'),
          content: TextField(
            controller: nominalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Masukkan nominal',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nominal = double.tryParse(nominalController.text);
                if (nominal != null && nominal > 0) {
                  Navigator.pop(dialogContext); // Tutup dialog top up input

                  final response = await ApiService.topUp(userId, nominal);
                  
                  final bool isSuccess = response['success'] == true;
                  final String message =
                      response['message'] ?? 'Terjadi kesalahan';

                  if (!mounted) return; // pastikan widget masih aktif

                  showDialog(
                    context: context,
                    builder: (BuildContext alertContext) {
                      return AlertDialog(
                        title: Text(isSuccess ? 'Berhasil' : 'Gagal'),
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(alertContext).pop(); // tutup alert

                              // Navigasi jika sukses
                              if (isSuccess) {
                                Future.microtask(() {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const TransactionPage(),
                                    ),
                                  );
                                });
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }


}
