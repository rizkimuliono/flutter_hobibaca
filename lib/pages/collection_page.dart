import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  bool hasError = false;

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await ApiService.getPurchasedBooks();

      if (data['status'] == 'success' && data['data'] != null) {
        final fetchedBooks = data['data'];

        setState(() {
          books = fetchedBooks;
          filteredBooks = fetchedBooks;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredBooks = books;
      });
    } else {
      setState(() {
        filteredBooks = books
            .where((book) => book['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Widget buildBookCard(dynamic book) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailPage(productId: book['id']),
        ),
      ),
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book['image'],
                height: 150,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              book['title'],
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book['pengarang'],
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              hasError ? 'Gagal memuat data: \nPeriksa koneksi internet Anda.\n' : '',
              style: const TextStyle(color: Colors.red),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : books.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum Data Koleksi Anda...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "My Collection Book’s",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.green),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: searchController,
                                        onChanged: filterSearch,
                                        decoration: const InputDecoration(
                                          hintText: 'Cari Buku Koleksi Anda...',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.search,
                                          color: Colors.green),
                                      onPressed: () =>
                                          filterSearch(searchController.text),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Recent Read",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                height: 190,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filteredBooks.take(6).length,
                                  itemBuilder: (_, index) {
                                    final book = filteredBooks[index];
                                    return buildBookCard(book);
                                  },
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "My Collection",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredBooks.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.6,
                                ),
                                itemBuilder: (_, index) {
                                  final book = filteredBooks[index];
                                  return buildBookCard(book);
                                },
                              )
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
