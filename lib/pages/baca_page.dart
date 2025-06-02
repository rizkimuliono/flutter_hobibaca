import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BacaPage extends StatelessWidget {
  final int bookId;
  const BacaPage({super.key, required this.bookId});

  Future<Map<String, dynamic>> _getProductDetail() async {
    return await ApiService.getProductDetail(bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text(''),
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

          final item = snapshot.data!['data'];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Pengarang : ${item['pengarang']}',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  height: 650,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item['description'] != null
                      ? Text(item['description'],
                          style: const TextStyle(fontSize: 12))
                      : const Text('No description available',
                          style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_left_sharp),
                      label: const Text(""),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          fixedSize: const Size(60, 30)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_right_sharp),
                      label: const Text(""),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          fixedSize: const Size(60, 30)),
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
