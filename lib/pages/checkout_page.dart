import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/saldo_provider.dart';
import '../services/api_service.dart';
import 'detail_page.dart';
import 'success_page.dart';
import 'gagal_page.dart';

class CheckoutPage extends StatelessWidget {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final double price;

  const CheckoutPage(
      {super.key,
      required this.id,
      required this.title,
      required this.author,
      required this.imageUrl,
      required this.price});

  void prosesBayar(BuildContext context) async {
    final localContext = context; // simpan context sebelum async
    final saldoProvider = localContext.read<SaldoProvider>();
    final currentSaldo = saldoProvider.saldo;

    if (currentSaldo >= price) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        if (localContext.mounted) {
          ScaffoldMessenger.of(localContext).showSnackBar(
            const SnackBar(content: Text('User ID tidak ditemukan')),
          );
        }
        return;
      }

      final result = await ApiService.purchaseBook(
        userId: userId,
        bookId: id,
        keterangan: 'Pembelian Buku $title',
        biaya: price,
      );

      if (!localContext.mounted) return; // pastikan widget masih hidup

      if (result['status'] == 'success') {
        saldoProvider.updateSaldo(currentSaldo - price);

        Navigator.push(
          localContext,
          MaterialPageRoute(
            builder: (_) => SuccessPage(
              onGoToCollection: () {
                Navigator.pop(localContext);
                Navigator.pushAndRemoveUntil(
                  localContext,
                  MaterialPageRoute(builder: (_) => DetailPage(productId: id)),
                  (route) => route.isFirst,
                );
              },
            ),
          ),
        );
      } else {
        showDialog(
          context: localContext,
          builder: (_) => AlertDialog(
            title: const Text('Gagal'),
            content: Text(result['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(localContext),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
      }
    } else {
      showGagalDialog(
          context); // ini aman karena langsung dipanggil tanpa async
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SaldoProvider>(context, listen: false).loadSaldo();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Check Out"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo Coin
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo Coin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        context.watch<SaldoProvider>().saldo.toStringAsFixed(2),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Detail Transaksi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 140,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Author : ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: author,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Harga : ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: '\$${price.toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  prosesBayar(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "BAYAR",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
