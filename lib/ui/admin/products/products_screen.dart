import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/colors.dart';
import '../../../models/product.dart';
import '../../shared/app_drawer.dart';
import '../../shared/dialog_utils.dart';
import 'add_product.dart';
import 'edit_product.dart';
import 'products_manager.dart';
import '../auth/auth_manager.dart';

class AdminProductsScreen extends StatefulWidget {
  static const routeName = '/admin_product_screen';
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductScreenState();
}

class _AdminProductScreenState extends State<AdminProductsScreen> {
  String? _selectedCategory;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final productsManager =
        Provider.of<AdminProductsManager>(context, listen: false);
    await productsManager.fetchCategories(); // First fetch categories
    await productsManager.fetchProducts(); // Then fetch all products

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsManager =
        Provider.of<AdminProductsManager>(context, listen: true);
        final authManager = Provider.of<AuthManager>(context);

    // Filter products based on category and search query
    var filteredProducts = productsManager.items;
    if (_selectedCategory != null) {
      filteredProducts = filteredProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((product) =>
              product.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(isAdmin: authManager.isStaff),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                margin: EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu, color: color4, size: 30),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 220,
                          padding: EdgeInsets.only(left: 15.0, right: 10.0),
                          decoration: BoxDecoration(
                            color: color17,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Product name...",
                                    hintStyle: TextStyle(color: color4),
                                  ),
                                  style: TextStyle(color: color4),
                                ),
                              ),
                              Icon(Icons.search, color: color4, size: 25.0),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AddProductScreen.routeName,
                              arguments: null,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color14,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: color4, size: 25.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: 50,
                      width: 390,
                      margin: EdgeInsets.only(left: 10, right: 20),
                      decoration: BoxDecoration(
                        color: color13,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: RawScrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        thumbColor: color4.withOpacity(0.5),
                        radius: Radius.circular(10),
                        thickness: 4,
                        minThumbLength: 50,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: productsManager.categories.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _selectedCategory = null;
                                    _isLoading = false; 
                                  });
                                  await productsManager.fetchProducts();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == null
                                        ? color17
                                        : color13,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'All',
                                      style: TextStyle(
                                        color: _selectedCategory == null
                                            ? color4
                                            : color1,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              final category =
                                  productsManager.categories[index - 1];
                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _selectedCategory = category;
                                    _isLoading = false; 
                                  });
                                  await productsManager.fetchProducts(
                                      category: category);
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == category
                                        ? color17
                                        : color13,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: _selectedCategory == category
                                            ? color4
                                            : color1,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : filteredProducts.isEmpty
                            ? Expanded(
                                child: Center(
                                  child: Text(
                                    _searchQuery.isNotEmpty
                                        ? "No products found matching '$_searchQuery'"
                                        : _selectedCategory != null
                                            ? "No products found in $_selectedCategory category"
                                            : "No products found",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: GridView.builder(
                                  padding: EdgeInsets.only(left: 8, right: 16),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.595,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    return ProductItem(product: product);
                                  },
                                ),
                              ),
                  ],
                ),
              ),
            ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: color2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Center(
                child: product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl,
                          width: double.infinity,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Price: \$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: color4),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'In Stock: ${product.stockQuantity.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, color: color4),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: color7, size: 20),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              EditProductScreen.routeName,
                              arguments: product.pid,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: color7, size: 20),
                          onPressed: () async {
                            final confirm = await showConfirmDialog(
                              context,
                              'Do you want to delete this product?',
                            );

                            if (confirm == true) {
                              Provider.of<AdminProductsManager>(context,
                                      listen: false)
                                  .deleteProduct(product.pid!);
                            }
                          },
                        ),
                      ],
                    ),
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
