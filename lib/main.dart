import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'ui/splash_screen.dart';
import 'ui/products/products_manager.dart';
import 'ui/user/edit_user_screen.dart';
import 'ui/admin/products/edit_product.dart';
import 'models/user.dart';
import 'components/colors.dart';
import 'ui/cart/cart_manager.dart';
import 'ui/orders/orders_manager.dart';
import 'ui/user/users_manager.dart';
import 'ui/cart/cart_screen.dart';
import 'ui/orders/orders_screen.dart';
import 'ui/admin/auth/auth_manager.dart';
import 'ui/admin/products/products_screen.dart';
import 'ui/admin/order/order_screen.dart';
import 'ui/admin/user/adminUser_screen.dart';
import 'ui/products/user_products_screen.dart';
import 'ui/admin/auth/auth_screen.dart';
import 'ui/admin/products/add_product.dart';
import 'ui/admin/order/order_manager.dart';
import 'ui/admin/user/adminUser_manager.dart';
import 'ui/admin/products/products_manager.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
            child: child,
          ),
        );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            )),
            child: child,
          ),
        );
}

class FadeSlideRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.2, 0.0); 
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var slideTween = Tween<Offset>(begin: begin, end: end).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            return FadeTransition(
              opacity: fadeTween,
              child: SlideTransition(
                position: slideTween,
                child: child,
              ),
            );
          },
        );
}
class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
}

class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;

  SlideLeftRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Dotenv loaded successfully!");
  } catch (e) {
    print("❌ Dotenv loaded failed: $e");
  }
  runApp(const Larana());
}

class Larana extends StatefulWidget {
  const Larana({super.key});

  @override
  State<Larana> createState() => _LaranaState();
}

class _LaranaState extends State<Larana> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 158, 158),
      secondary: const Color(0xFFFFF8DC),
      surface: const Color.fromARGB(255, 255, 245, 245),
      surfaceTint: const Color.fromARGB(255, 255, 158, 158),
      primary: const Color.fromARGB(255, 255, 158, 158),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: color13,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ProductsManager()),
        ChangeNotifierProvider(create: (ctx) => CartManager()),
        ChangeNotifierProvider(create: (ctx) => OrdersManager()),
        ChangeNotifierProvider(create: (ctx) => UsersManager()),
        ChangeNotifierProvider(create: (ctx) => AuthManager()),
        ChangeNotifierProvider(create: (ctx) => AdminProductsManager()),
        ChangeNotifierProvider(create: (ctx) => AdminOrdersManager()),
        ChangeNotifierProvider(create: (ctx) => AdminUserManager()),
      ],
      child: Builder(
        builder: (context) {
          final authManager = Provider.of<AuthManager>(context, listen: false);
          if (!authManager.isInitialized) {
            authManager.initialize();
          }

          return Consumer<AuthManager>(
            builder: (ctx, authManager, child) {
              print(
                  '🔴 Building app: isInitialized=${authManager.isInitialized}, isAuth=${authManager.isAuth}, isSplashComplete=${authManager.isSplashComplete}');

              Widget homeScreen;
              if (!authManager.isSplashComplete) {
                homeScreen = const SplashScreen();
              } else if (!authManager.isAuth) {
                homeScreen = const AuthScreen();
              } else {
                homeScreen = authManager.isStaff
                    ? const AdminProductsScreen()
                    : const UserProductsScreen();
              }

              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Cosmetic Supermarket App',
                theme: themeData,
                home: homeScreen,
                routes: {
                  CartScreen.routeName: (ctx) =>
                      const SafeArea(child: CartScreen()),
                  OrdersScreen.routeName: (ctx) =>
                      const SafeArea(child: OrdersScreen()),
                  AuthScreen.routeName: (ctx) =>
                      const SafeArea(child: AuthScreen()),
                  // AdminProductsScreen.routeName: (ctx) =>
                  //     const AdminProductsScreen(),
                  // AddProductScreen.routeName: (ctx) => const AddProductScreen(),
                  // AdminUsersScreen.routeName: (ctx) => const AdminUsersScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                  // AdminOrdersScreen.routeName: (ctx) => AdminOrdersScreen(),
                },
                onGenerateRoute: (settings) {
                  print('🔴 Navigating to route: ${settings.name}');
                  switch (settings.name) {
                    case AdminProductsScreen.routeName:
                      return SlideUpRoute(page: const AdminProductsScreen());
                    case AddProductScreen.routeName:
                      return ScaleRoute(page: const AddProductScreen());
                    case AdminUsersScreen.routeName:
                      return SlideRightRoute(page: const AdminUsersScreen());
                    case AdminOrdersScreen.routeName:
                      return SlideLeftRoute(page: const AdminOrdersScreen());
                    case EditUserScreen.routeName:
                      final user = settings.arguments as User?;
                      return FadeSlideRoute(page: EditUserScreen(user));
                    default:
                      print('🔴 Unknown route: ${settings.name}');
                      return MaterialPageRoute(
                        builder: (ctx) => const SafeArea(
                          child: Scaffold(
                              body: Center(child: Text('Page not found'))),
                        ),
                      );
                  }
                },
                onUnknownRoute: (settings) {
                  return SlideUpRoute(page: const UserProductsScreen());
                },
              );
            },
          );
        },
      ),
    );
  }
}