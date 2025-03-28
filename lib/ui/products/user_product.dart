import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:provider/provider.dart';
import 'products_manager.dart';
import '../cart/cart_manager.dart';
import 'product_detail_screen.dart';

const Color laranaPink = Color.fromARGB(255, 255, 158, 158);
const Color laranaPinkLight = Color(0xFFFF0F0);

class UserProduct extends StatefulWidget {
  final Product product;

  const UserProduct(this.product, {super.key});

  @override
  State<UserProduct> createState() => _UserProduct();
}

class _UserProduct extends State<UserProduct>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateAddToCart() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  void _handleTap() {
    _controller.forward().then((_) {
      Navigator.of(context)
          .push(
        MaterialPageRoute(
          builder: (ctx) => ProductDetailScreen(widget.product),
        ),
      )
          .then((_) {
        _controller.reverse();
      });
    });
  }

  void _handleAddToCart() async {
    _animateAddToCart();
    final cart = context.read<CartManager>();

    if (widget.product.stockQuantity <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
                'Product is out of stock. Current stock quantity: ${widget.product.stockQuantity}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      return;
    }
    setState(() {
      _isAddingToCart = true;
    });

    try {
      await cart.addItem(widget.product);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Item added to cart'),
            duration: const Duration(seconds: 3),
            backgroundColor: laranaPink,
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () {
                cart.removeItem(widget.product.pid!);
              },
            ),
          ),
        );
    } catch (error) {
      String errorMessage = error.toString();
      if (errorMessage.contains('Product is out of stock')) {
      } else if (errorMessage.contains('Failed to add product to cart')) {
        errorMessage = 'Unable to add item to cart. Please try again.';
      } else {
        errorMessage = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: 1.0 - (_controller.value * 0.05),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: laranaPink.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: laranaPinkLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 143,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              color: Colors.white,
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.network(
                                widget.product.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                        color: laranaPink),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.image_not_supported,
                                  size: 39,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            bottom: 0,
                            child: AnimatedScale(
                              scale: widget.product.isFavorite ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: IconButton(
                                onPressed: () {
                                  context.read<ProductsManager>().updateProduct(
                                        widget.product.copyWith(
                                          isFavorite:
                                              !widget.product.isFavorite,
                                        ),
                                      );
                                },
                                icon: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: laranaPink.withOpacity(0.3),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    widget.product.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: laranaPink,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 7,
                            left: 12,
                            right: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.product.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(201, 0, 0, 0),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Stock: ${widget.product.stockQuantity}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "\$${widget.product.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontFamily: 'Lato',
                                      color: laranaPink,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ScaleTransition(
                                    scale: _scaleAnimation,
                                    child: IconButton(
                                      onPressed: _isAddingToCart
                                          ? null
                                          : _handleAddToCart,
                                      icon: _isAddingToCart
                                          ? SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: laranaPink,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: laranaPink
                                                        .withOpacity(0.3),
                                                    blurRadius: 7,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.shopping_cart,
                                                color: laranaPink,
                                                size: 24,
                                              ),
                                            ),
                                    ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
