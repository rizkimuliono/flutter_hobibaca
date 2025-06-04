import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  Future<List<Map<String, dynamic>>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      throw Exception("User ID tidak ditemukan di SharedPreferences");
    }

    final response = await ApiService.getTransactions(userId);
    if (response['status'] == 'success') {
      final data = response['data'] as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal mengambil data transaksi');
    }
  }

  String formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  String formatCurrency(String nominal) {
    final amount = double.tryParse(nominal) ?? 0;
    return amount.toStringAsFixed(2);
  }

  Widget getStatusWidget(int status) {
    String text;
    Color color;

    switch (status) {
      case 0:
        text = "Pending";
        color = Colors.orange;
        break;
      case 1:
        text = "Sukses";
        color = Colors.green;
        break;
      case 2:
        text = "Gagal";
        color = Colors.red;
        break;
      default:
        text = "-";
        color = Colors.grey;
    }

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaksi"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(child: Text("Belum ada transaksi."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            scrollDirection: Axis.vertical,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                  const Color.fromARGB(51, 28, 255, 8)),
              border: TableBorder.all(color: Colors.grey.shade300),
              columnSpacing: 16,
              columns: const [
                DataColumn(label: Text('No')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Keterangan')),
                DataColumn(label: Text('Nominal')),
                DataColumn(label: Text('Status')),
              ],
              rows: List.generate(transactions.length, (index) {
                final tx = transactions[index];
                return DataRow(cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(formatDate(tx['created_at']))),
                  DataCell(
                    Text(
                      (tx['keterangan'] ?? '-').toString().length > 15
                          ? '${tx['keterangan'].toString().substring(0, 15)}...'
                          : tx['keterangan'].toString(),
                    ),
                  ),
                  DataCell(Text(formatCurrency(tx['biaya'] ?? '0'))),
                  DataCell(getStatusWidget(tx['status'] ?? 0)),
                ]);
              }),
            ),
          );
        },
      ),
    );
  }
}
