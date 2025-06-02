import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/api_service.dart';
import '../providers/saldo_provider.dart';
import 'detail_page.dart';
import 'collection_page.dart';
import 'filter_page.dart';
import 'transaction_page.dart';
import 'account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  List<dynamic> categories = [];
  String? name;
  int currentIndex = 0;
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  final List<Widget> pages = const [
    Placeholder(), // akan diganti oleh konten Home
    CollectionPage(),
    TransactionPage(),
    AccountPage(),
  ];

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');

    final data = await ApiService.getProducts();
    final dataCategories = await ApiService.getCategories();
    // print(data['data']);
    setState(() {
      products = data['data'] ?? [];
      categories = dataCategories['data'] ?? [];
      isLoading = false;
    });
  }

  void _submitSearch(BuildContext context) {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilterPage(initialQuery: query),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, index) => ListTile(
        leading: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: const CircleAvatar(radius: 24),
        ),
        title: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
              height: 12, width: double.infinity, color: Colors.white),
        ),
        subtitle: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 10, width: 150, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildBookSection(String title, List<dynamic> items) {
    if (items.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title + View All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    // Arahkan ke halaman 'View All' jika ingin.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('View All "$title" belum tersedia')),
                    );
                  },
                  child: const Chip(
                    label: Text(
                      "View All",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    backgroundColor: Colors.white10,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.grey, // Warna border
                        width: 1.2, // Ketebalan border (opsional)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length > 10 ? 10 : items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: SizedBox(
                    width: 120,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(productId: item['id']),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item['image'] ?? '',
                              height: 150,
                              width: 120,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  width: 120,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                height: 150,
                                width: 120,
                                color: Colors.grey.shade300,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image, size: 40),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item['price'] != null &&
                                    item['price'].toString().isNotEmpty
                                ? '\$${item['price']}'
                                : '',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 110, 4),
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item['category'] ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent() {
    return isLoading
        ? buildShimmerList()
        : RefreshIndicator(
            onRefresh: loadData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // agar bisa ditarik meskipun data sedikit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // welcome text
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Keep Reading dengan ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'HobiBaca',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (_) => _submitSearch(context),
                      decoration: InputDecoration(
                        hintText: "Cari Buku Favorite Anda...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.green),
                          onPressed: () => _submitSearch(context),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.green),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: categories.map<Widget>((item) {
                        return buildCategoryChip(item['category']);
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Column(
                    children: [
                      if (products.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                              child: Text(
                            'Data Tidak Tersedia, periksa jaringan internet anda!',
                            style: TextStyle(color: Colors.redAccent),
                          )),
                        ),
                      if (products.isNotEmpty) ...[
                        buildBookSection("Populer", products),
                        buildBookSection(
                            "New Book", products.reversed.toList()),
                        buildBookSection(
                            "Mungkin Anda Suka",
                            products.length >= 5
                                ? products.sublist(0, 5)
                                : products),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
  }

  Widget buildCustomNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => currentIndex = index);
          Provider.of<SaldoProvider>(context, listen: false).loadSaldo();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
            border: isSelected
                ? const Border(top: BorderSide(color: Colors.green, width: 4))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.green : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.green : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryChip(String label) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FilterPage(initialCategory: label), // kirim kategori
          ),
        );
      },
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 153, 5),
          ),
        ),
        backgroundColor: const Color.fromARGB(39, 53, 255, 60),
        shape: const StadiumBorder(
          side: BorderSide(
            color: Color.fromARGB(255, 0, 153, 5), // Warna border
            width: 1.2, // Ketebalan border (opsional)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<SaldoProvider>(context, listen: false).loadSaldo();

    return Scaffold(
      appBar: currentIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.emoji_emotions,
                                    color: Colors.white)),
                            const SizedBox(width: 8),
                            Text(
                              "Hi, ${name ?? 'User...'}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                                  color: Colors.black, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                  context
                                      .watch<SaldoProvider>()
                                      .saldo
                                      .toStringAsFixed(2),
                                  style: const TextStyle(color: Colors.black))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: currentIndex == 0 ? buildHomeContent() : pages[currentIndex],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            buildCustomNavItem(icon: Icons.home, label: "Home", index: 0),
            buildCustomNavItem(icon: Icons.list, label: "Koleksi", index: 1),
            buildCustomNavItem(
                icon: Icons.shopping_cart, label: "Transaksi", index: 2),
            buildCustomNavItem(
                icon: Icons.account_circle, label: "Akun", index: 3),
          ],
        ),
      ),
    );
  }
}
