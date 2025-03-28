import 'package:flutter/material.dart';
import '../cart/cart_manager.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item.dart';
import '../shared/dialog_utils.dart';

class CartItemCard extends StatefulWidget {
  final String productId;
  final CartItem cartItem;

  const CartItemCard({
    required this.productId,
    required this.cartItem,
    super.key,
  });

  @override
  _CartItemCardState createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late int _quantity;
  bool _isUpdatingQuantity = false; // Track loading state

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
  }

  Future<void> _incrementQuantity() async {
    if (_isUpdatingQuantity) return;

    setState(() {
      _isUpdatingQuantity = true;
      _quantity++;
    });

    try {
      await context.read<CartManager>().updateItemQuantity(
            widget.cartItem.productId,
            _quantity,
          );
    } catch (error) {
      setState(() {
        _quantity--;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$error'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      setState(() {
        _isUpdatingQuantity = false;
      });
    }
  }

  Future<void> _decrementQuantity() async {
    if (_quantity <= 1 || _isUpdatingQuantity) return;

    setState(() {
      _isUpdatingQuantity = true;
      _quantity--;
    });

    try {
      await context.read<CartManager>().updateItemQuantity(
            widget.cartItem.productId,
            _quantity,
          );
    } catch (error) {
      setState(() {
        _quantity++;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$error'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      setState(() {
        _isUpdatingQuantity = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(widget.cartItem.id),
      background: Container(
        color: colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Color.fromARGB(255, 249, 74, 74),
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showConfirmDialog(
          context,
          'Do you want to remove the item from the cart?',
        );
      },
      onDismissed: (direction) {
        context.read<CartManager>().clearItem(widget.cartItem.id!);
      },
      child: Card(
        color: const Color.fromARGB(255, 255, 235, 235),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.cartItem.imageUrl,
                  fit: BoxFit.cover,
                  width: 110,
                  height: 110,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cartItem.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_quantity x '
                      '\$${widget.cartItem.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 105, 133),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(255, 255, 105, 133),
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: _isUpdatingQuantity
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.remove,
                                        color: Colors.red),
                                onPressed: _decrementQuantity,
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: _isUpdatingQuantity
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.green,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.add,
                                        color: Colors.green),
                                onPressed: _incrementQuantity,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${(widget.cartItem.price * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 102, 102, 102),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
