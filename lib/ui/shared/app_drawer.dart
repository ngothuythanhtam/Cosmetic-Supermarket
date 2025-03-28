
import 'package:ct312h_project/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../admin/auth/auth_manager.dart';
import '../admin/order/order_screen.dart';
import '../admin/products/add_product.dart';
import '../admin/products/products_screen.dart';
import '../admin/user/adminUser_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../user/edit_user_screen.dart';
import '../user/users_manager.dart';

const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
const Color laranaPinkLight = Color(0xFFFFF0F0);

class AppDrawer extends StatefulWidget {
  final bool isAdmin; // Admin status passed from parent widget
  const AppDrawer({super.key, required this.isAdmin});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoadingUser = true; // Track loading state for user data

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();

    // Fetch user data and determine if the user is an admin
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoadingUser = true;
    });
    try {
      await Provider.of<UsersManager>(context, listen: false).fetchUser();
      setState(() {
      _isLoadingUser = true;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load user data: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Common method to build a menu item (used by both admin and regular drawers)
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool isAdminStyle = false,
  }) {
    if (isAdminStyle) {
      // Admin style
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? color4, size: 28),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? color4,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: onTap ??
              () {
                Navigator.of(context).pushNamed(route);
              },
        ),
      );
    } else {
      // Regular user style 
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: ListTile(
            leading: Icon(
              icon,
              color: laranaPink,
              size: 30,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: laranaPink,
                fontFamily: 'Pacifico',
              ),
            ),
            tileColor: laranaPinkLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: onTap ??
                () {
                  Navigator.of(context).pushReplacementNamed(
                    route,
                    arguments: Provider.of<UsersManager>(context, listen: false)
                        .currentUser,
                  );
                },
            hoverColor: laranaPink.withOpacity(0.2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
        ),
      );
    }
  }

  // Common divider for regular user drawer
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Divider(
        color: laranaPink.withOpacity(0.4),
        thickness: 1.5,
        height: 20,
      ),
    );
  }

  // Build the admin drawer content
  Widget _buildAdminDrawerContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color2,
            color10.withOpacity(1),
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          // Header Section (Admin)
          Container(
            height: 150,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
            decoration: BoxDecoration(
              color: color4.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: color4.withOpacity(0.1),
                      child: const Icon(
                        Icons.store,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Larana Cosmetics',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu Items (Admin)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: AdminProductsScreen.routeName,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  backgroundColor: color4.withOpacity(0.2),
                  isAdminStyle: true,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit,
                  title: 'Add Products',
                  route: AddProductScreen.routeName,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  backgroundColor: color4.withOpacity(0.2),
                  isAdminStyle: true,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.payment,
                  title: 'Manage Orders',
                  route: AdminOrdersScreen.routeName,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  backgroundColor: color4.withOpacity(0.2),
                  isAdminStyle: true,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people,
                  title: 'Manage Users',
                  route: AdminUsersScreen.routeName,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  backgroundColor: color4.withOpacity(0.2),
                  isAdminStyle: true,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Profile',
                  route: EditUserScreen.routeName,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  backgroundColor: color4.withOpacity(0.2),
                  isAdminStyle: true,
                ),
              ],
            ),
          ),
          // Logout Button (Admin)
          Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app,
                  color: Colors.redAccent, size: 28),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context)
                  ..pop()
                  ..pushReplacementNamed('/');
                context.read<AuthManager>().logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the regular user drawer content
  Widget _buildRegularDrawerContent(BuildContext context) {
    final userManager = Provider.of<UsersManager>(context);
    final user = userManager.currentUser;

    return Column(
      children: <Widget>[
        // Header Section (Regular User)
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [laranaPink.withOpacity(0.3), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoadingUser
                    ? const CircularProgressIndicator(
                        color: laranaPink,
                      )
                    : CircleAvatar(
                        radius: 45,
                        backgroundColor: laranaPink.withOpacity(0.2),
                        child: user?.avatar != null && user!.avatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  user.avatar!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const CircularProgressIndicator(
                                      color: laranaPink,
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.favorite,
                                    size: 50,
                                    color: laranaPink,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.favorite,
                                size: 50,
                                color: laranaPink,
                              ),
                      ),
                const SizedBox(height: 12),
                _isLoadingUser
                    ? const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: laranaPink,
                          fontFamily: 'Pacifico',
                        ),
                      )
                    : Text(
                        user?.username != null && user!.username.isNotEmpty
                            ? 'Hello, ${user.username}!'
                            : 'Hello, Friend!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: laranaPink,
                          fontFamily: 'Pacifico',
                          shadows: [
                            Shadow(
                              color: Colors.black12,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        // Menu Items (Regular User)
        _buildMenuItem(
          context: context,
          icon: Icons.shop,
          title: 'Shop',
          route: '/',
          isAdminStyle: false,
        ),
        _buildDivider(),
        _buildMenuItem(
          context: context,
          icon: Icons.payment,
          title: 'Orders',
          route: OrdersScreen.routeName,
          isAdminStyle: false,
        ),
        _buildDivider(),
        _buildMenuItem(
          context: context,
          icon: Icons.shopping_cart,
          title: 'Cart',
          route: CartScreen.routeName,
          isAdminStyle: false,
        ),
        _buildDivider(),
        _buildMenuItem(
          context: context,
          icon: Icons.person,
          title: 'Edit User',
          route: EditUserScreen.routeName,
          isAdminStyle: false,
        ),
        _buildDivider(),
        _buildMenuItem(
          context: context,
          icon: Icons.exit_to_app,
          title: 'Logout',
          route: '/',
          onTap: () async {
            try {
              await Provider.of<AuthManager>(context, listen: false).logout();
              Navigator.of(context)
                ..pop() // Close Drawer
                ..pushReplacementNamed('/'); // Navigate to home screen
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: $error'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          isAdminStyle: false,
        ),
        const Spacer(),
        // Footer (Regular User)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Made with ',
                style: TextStyle(
                  color: laranaPink,
                  fontSize: 14,
                  fontFamily: 'Pacifico',
                ),
              ),
              const Icon(
                Icons.favorite,
                color: laranaPink,
                size: 16,
              ),
              const Text(
                ' by Larana',
                style: TextStyle(
                  color: laranaPink,
                  fontSize: 14,
                  fontFamily: 'Pacifico',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.isAdmin ? Colors.transparent : Colors.white,
      elevation: widget.isAdmin ? 0 : 5,
      shape: widget.isAdmin
          ? null
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
            ),
      child: widget.isAdmin
          ? _buildAdminDrawerContent(context)
          : _buildRegularDrawerContent(context),
    );
  }
}
