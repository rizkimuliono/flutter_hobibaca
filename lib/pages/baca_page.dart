import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class BacaPage extends StatefulWidget {
  final int bookId;
  const BacaPage({super.key, required this.bookId});

  @override
  State<BacaPage> createState() => _BacaPageState();
}

class _BacaPageState extends State<BacaPage> {
  late Future<Map<String, dynamic>> _bookDataFuture;

  @override
  void initState() {
    super.initState();
    _bookDataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final detail = await ApiService.getProductDetail(widget.bookId);
    final item = detail['data'];
    final fileUrl = item['file'];
    final document = await PDFDocument.fromURL(fileUrl);
    return {
      'detail': item,
      'document': document,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookDataFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final item = snapshot.data!['detail'];
          final document = snapshot.data!['document'] as PDFDocument;

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
                  child: PDFViewer(
                    document: document,
                    lazyLoad: false,
                    zoomSteps: 1,
                    numberPickerConfirmWidget: const Text("Confirm"),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
