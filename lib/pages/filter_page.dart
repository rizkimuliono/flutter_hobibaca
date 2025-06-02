import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'detail_page.dart';

class FilterPage extends StatefulWidget {
  final String initialQuery;
  final String initialCategory;

  const FilterPage(
      {super.key, this.initialQuery = '', this.initialCategory = ''});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  TextEditingController searchController = TextEditingController();
  
  bool isLoading = true;
  bool hasError = false;
  String currentSearchText = '';
  String? selectedCategory; // Menyimpan kategori yang dipilih

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await ApiService.getProducts();
      final fetchedBooks = data['data'] ?? [];

      setState(() {
        books = fetchedBooks;
        filteredBooks = fetchedBooks;
        isLoading = false;
      });

      // Lakukan filter setelah data berhasil dimuat
      if (widget.initialQuery.isNotEmpty) {
        filterSearch(widget.initialQuery);
      } else if (widget.initialCategory.isNotEmpty) {
        filterByCategory(widget.initialCategory);
      }

      // tampilkan nilai pada text field
      searchController.text = widget.initialQuery.isNotEmpty
          ? widget.initialQuery
          : widget.initialCategory;
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
    searchController.text = widget.initialQuery;
    currentSearchText = widget.initialQuery;
    loadData();
  }

  void filterSearch(String query) {
    setState(() {
      currentSearchText = query; // update teks pencarian
      selectedCategory = null; // Reset kategori saat pencarian teks aktif
      if (query.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books
            .where((book) => book['title']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      currentSearchText = '';
      searchController
          .clear(); // Kosongkan TextField saat filter kategori aktif
      filteredBooks = books
          .where((book) =>
              book['category']?.toString().toLowerCase() ==
              category.toLowerCase())
          .toList();
    });
  }

  Widget buildSearchResultLabel() {
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black, // Pastikan warna teks sesuai tema Anda
          ),
          children: [
            const TextSpan(
              text: 'Hasil pencarian kategori : ',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: selectedCategory,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (currentSearchText.trim().isNotEmpty) {
      return Text(
        'Hasil pencarian : $currentSearchText',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    } else {
      return const SizedBox.shrink(); // Tidak menampilkan apa-apa jika kosong
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
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book['image'],
              width: 100,
              height: 130,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Your Book"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError || books.isEmpty
                ? const Center(
                    child: Text(
                      'Data tidak tersedia.\nPeriksa koneksi internet Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
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
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          buildSearchResultLabel(),
                          // if (currentSearchText.trim().isNotEmpty ||
                          //     widget.initialCategory.trim().isNotEmpty)
                          //   Text(
                          //     'Hasil pencarian: "${currentSearchText.isNotEmpty ? currentSearchText : widget.initialCategory}"',
                          //     style: const TextStyle(
                          //         fontSize: 16, fontWeight: FontWeight.bold),
                          //   ),
                          const SizedBox(height: 15),
                          if (filteredBooks.isEmpty)
                            const Text(
                              'Buku tidak ditemukan.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 253, 83, 83)),
                            )
                          else
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
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
