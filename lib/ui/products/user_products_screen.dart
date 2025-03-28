import '../admin/auth/auth_manager.dart';
import 'products_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_product.dart';
import 'products_manager.dart';
import '../cart/cart_screen.dart';
import '../shared/app_drawer.dart';
import '../cart/cart_manager.dart';

const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
const Color laranaYellow = Color(0xFFFFF8DC);

enum FilterOptions { favorites, all }

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({super.key});
  static const routeName = '/user_products';

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen>
    with TickerProviderStateMixin {
  int _visibleItemCount = 6;

  String searchQuery = "";
  String selectedCategory = "All";

  final ScrollController _scrollController = ScrollController();
  final int _loadMoreItemCount = 6;

  var _currentFilter = FilterOptions.all;

  late Future<void> _fetchProducts;

  late AnimationController _appBarButtonController;
  late Animation<double> _appBarScaleAnimation;
  late Animation<double> _appBarFadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProducts = context.read<ProductsManager>().fetchProducts();
    context.read<CartManager>().fetchCartItems();
    _scrollController.addListener(_onScroll);

    _appBarButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _appBarScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _appBarButtonController, curve: Curves.easeInOut),
    );
    _appBarFadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _appBarButtonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _appBarButtonController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        _visibleItemCount += _loadMoreItemCount;
      });
    }
  }

  void _animateAppBarButton() {
    _appBarButtonController.forward().then((_) {
      _appBarButtonController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authManager = Provider.of<AuthManager>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Transform.translate(
          offset: const Offset(-40, 0),
          child: Image.asset(
            'assets/images/lanara.png',
            height: 140,
            fit: BoxFit.contain,
          ),
        ),
        iconTheme: IconThemeData(color: laranaPink),
        actions: <Widget>[
          AnimatedBuilder(
            animation: _appBarButtonController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _appBarFadeAnimation,
                child: ScaleTransition(
                  scale: _appBarScaleAnimation,
                  child: ProductFilterMenu(
                    currentFilter: _currentFilter,
                    onFilterSelected: (filter) {
                      _animateAppBarButton();
                      setState(() {
                        _currentFilter = filter;
                      });
                    },
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _appBarButtonController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _appBarFadeAnimation,
                child: ScaleTransition(
                  scale: _appBarScaleAnimation,
                  child: ShoppingCartButton(
                    onPressed: () {
                      _animateAppBarButton();
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: AppDrawer(isAdmin: authManager.isStaff),
      body: FutureBuilder(
        future: _fetchProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 15.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: laranaPink,
                      ),
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: laranaPink.withOpacity(0.7)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: laranaPink.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: laranaPink.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 244, 95, 95),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    height: 50, 
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (ctx, index) {
                        final category = categories[index]["name"] as String;
                        final categoryIcon =
                            categories[index]["icon"] as IconData;
                        return CategoryItem(
                          category: category,
                          categoryIcon: categoryIcon,
                          isSelected: selectedCategory == category,
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _currentFilter == FilterOptions.favorites
                      ? ProductsGrid(true)
                      : UserProductList(
                          searchQuery: searchQuery,
                          selectedCategory: selectedCategory,
                          visibleItemCount: _visibleItemCount,
                          scrollController: _scrollController,
                          showFavorites:
                              _currentFilter == FilterOptions.favorites,
                        ),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.category},
    {"name": "Lipstick", "icon": Icons.face},
    {"name": "Foundation", "icon": Icons.face_retouching_natural},
    {"name": "Mascara", "icon": Icons.remove_red_eye},
    {"name": "Blush", "icon": Icons.format_paint},
    {"name": "Concealer", "icon": Icons.blur_on},
    {"name": "Highlighter", "icon": Icons.cloud},
    {"name": "Eye Shadow", "icon": Icons.visibility},
    {"name": "Setting Powder", "icon": Icons.edit},
  ];
}

class UserProductList extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final int visibleItemCount;
  final ScrollController scrollController;
  final bool showFavorites;

  const UserProductList({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.visibleItemCount,
    required this.scrollController,
    required this.showFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsManager>(
      builder: (ctx, productsManager, child) {
        final baseProducts = showFavorites
            ? productsManager.favoriteItems
            : productsManager.items;

        final filteredProducts = baseProducts.where((product) {
          final matchesSearch =
              product.title.toLowerCase().contains(searchQuery);
          final matchesCategory =
              selectedCategory == "All" || product.category == selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        final productsToShow = filteredProducts.sublist(
          0,
          visibleItemCount < filteredProducts.length
              ? visibleItemCount
              : filteredProducts.length,
        );

        return GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            childAspectRatio: 0.68,
          ),
          itemCount: productsToShow.length,
          itemBuilder: (ctx, i) => UserProduct(
            productsToShow[i],
          ),
        );
      },
    );
  }
}

class ProductFilterMenu extends StatelessWidget {
  const ProductFilterMenu({
    super.key,
    this.currentFilter,
    this.onFilterSelected,
  });

  final FilterOptions? currentFilter;
  final void Function(FilterOptions selectedValue)? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      initialValue: currentFilter,
      onSelected: onFilterSelected,
      icon: const Icon(
        Icons.more_vert,
        color: laranaPink,
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: FilterOptions.favorites,
          child: Text('Only Favorites'),
        ),
        const PopupMenuItem(
          value: FilterOptions.all,
          child: Text('Show All'),
        ),
      ],
    );
  }
}

class ShoppingCartButton extends StatelessWidget {
  const ShoppingCartButton({super.key, this.onPressed});

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartManager>(
      builder: (ctx, cartManager, child) {
        return IconButton(
          icon: Badge.count(
            count: cartManager.productCount,
            child: const Icon(
              Icons.shopping_cart,
              color: laranaPink,
            ),
          ),
          onPressed: onPressed,
        );
      },
    );
  }
}

class CategoryItem extends StatefulWidget {
  final String category;
  final IconData categoryIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.category,
    required this.categoryIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _translateAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.02),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animate() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _animate();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _translateAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 7, horizontal: 15),
              margin: const EdgeInsets.symmetric(
                  horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: widget.isSelected ? laranaPink : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.categoryIcon,
                    size: 20,
                    color: widget.isSelected ? Colors.white : laranaPink,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.isSelected ? Colors.white : laranaPink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
