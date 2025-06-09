import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'baca_page.dart';
import 'checkout_page.dart';

class DetailPage extends StatelessWidget {
  final int productId;
  const DetailPage({super.key, required this.productId});

  Future<Map<String, dynamic>> _getProductDetail() async {
    return await ApiService.getProductDetail(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _getProductDetail(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!['data'] == null) {
            return const Center(child: Text('No Detail data found'));
          }

          final book = snapshot.data!['data'];
          // print(book);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Background Info Box
                    Container(
                      margin: const EdgeInsets.only(left: 0, top: 80),
                      padding: const EdgeInsets.fromLTRB(180, 20, 16, 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                            45, 34, 255, 0), // Atau sesuaikan warna hijau muda
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              text: "Author : ",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: book['pengarang'] ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              text: "Terbit : ",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              children: [
                                TextSpan(
                                  text: book['tgl_terbit'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (index) {
                              double rating =
                                  double.tryParse(book['rating'].toString()) ??
                                      0;
                              return Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Book Image (Overlapping)
                    Positioned(
                      top: 0,
                      left: 15,
                      bottom: 15,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          book['image'] ?? '',
                          height: 200,
                          width: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              width: 150,
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            width: 150,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorWeight: 4,
                        indicatorColor: Colors.green,
                        tabs: [
                          Tab(text: "Detail"),
                          Tab(text: "Pengarang"),
                          Tab(text: "Rating"),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                  top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tentang Buku",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(book['description'] ?? '-'),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: Text(book['pengarang'] ?? '-'),
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(12),
                              child: Text('Rating: ${book['rating']}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Harga",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 240, 105),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  color: Colors.black),
                              Text(
                                book['price'] != null
                                    ? '${book['price']}'
                                    : '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FutureBuilder<bool>(
                      future: ApiService.checkIfBookPurchased(book['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        final sudahDibeli = snapshot.data!;
                        print('sudahDibeli: $sudahDibeli');
                        return Column(
                          children: [
                            if (sudahDibeli) ...[
                              Text(
                                'Buku Ini Sudah Dibeli',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BacaPage(bookId: book['id']),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book),
                                label: const Text("Baca",
                                    style: TextStyle(fontSize: 24)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  fixedSize: const Size(150, 50),
                                ),
                              ),
                            ] else ...[
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutPage(
                                        id: book['id'],
                                        title: book['title'],
                                        author: book['pengarang'],
                                        imageUrl: book['image'],
                                        price: double.parse(book['price']),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text("Beli",
                                    style: TextStyle(fontSize: 24)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  fixedSize: const Size(150, 50),
                                ),
                              ),
                            ]
                          ],
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
