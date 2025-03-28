import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../orders/orders_manager.dart';
import '../../models/order_item.dart';
import 'package:provider/provider.dart';

const Color primaryColor = Color.fromARGB(255, 231, 110, 110);
const Color secondaryColor = Color(0xFFFFDDE1);
const Color cardBackgroundColor = Colors.white;

class OrderItemCard extends StatefulWidget {
  final OrderItem order;

  const OrderItemCard(this.order, {super.key});

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  var _expanded = false;
  var _isEditing = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromARGB(255, 94, 181, 97);
      case 'canceled':
        return const Color.fromARGB(255, 253, 72, 72);
      case 'pending':
        return Colors.orange;
      default:
        return const Color.fromARGB(255, 71, 172, 255);
    }
  }

  Color _getSoftStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromARGB(255, 225, 245, 225);
      case 'canceled':
        return const Color.fromARGB(255, 255, 235, 238);
      case 'pending':
        return const Color.fromARGB(255, 255, 248, 230);
      default:
        return const Color.fromARGB(255, 235, 245, 255);
    }
  }
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'canceled':
        return Icons.cancel_outlined;
      case 'pending':
        return Icons.access_time;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: <Widget>[
            _buildOrderHeader(),
            if (_expanded) _buildOrderDetails(),
            if (_isEditing &&
                widget.order.status != 'completed' &&
                widget.order.status != 'canceled')
              _buildEditOptions(context),
            if (widget.order.status == 'completed' ||
                widget.order.status == 'canceled')
              _buildOrderStatusInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                '\$${widget.order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getSoftStatusColor(widget.order.status),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(widget.order.status).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(widget.order.status),
                    size: 12,
                    color: _getStatusColor(widget.order.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.order.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(widget.order.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        trailing: SizedBox(
          width: 100,
          child: _buildActionButtons(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: primaryColor,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
        ),
        if (widget.order.status != 'completed' &&
            widget.order.status != 'canceled')
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.blue,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Items in Order:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(
              maxHeight: min(widget.order.productCount * 35.0 + 10, 180),
            ),
            child: ListView(
              children: widget.order.products.map((prod) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${prod.quantity}x',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          prod.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '\$${prod.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${widget.order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Update Order Status:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOutlinedStatusButton(
                context,
                'Completed',
                _getStatusColor('completed'),
                'completed',
              ),
              _buildOutlinedStatusButton(
                context,
                'Canceled',
                _getStatusColor('canceled'),
                'canceled',
              ),
              _buildCancelButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedStatusButton(
      BuildContext context, String label, Color color, String status) {
    return OutlinedButton(
      onPressed: () => _updateOrderStatus(context, status),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _isEditing = false;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: primaryColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: const Text('Cancel'),
    );
  }

  Widget _buildOrderStatusInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.order.status).withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.order.status == 'completed'
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            color: _getStatusColor(widget.order.status),
          ),
          const SizedBox(width: 8),
          Text(
            widget.order.status == 'completed'
                ? 'This order has been completed'
                : 'This order has been canceled',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _getStatusColor(widget.order.status),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(BuildContext context, String status) async {
    final ordersManager = Provider.of<OrdersManager>(context, listen: false);
    final updatedOrder = widget.order.copyWith(status: status);
    print('Updating order status to: $status');

    await ordersManager.updateOrderStatus(updatedOrder.id!, status);
    setState(() {
      _isEditing = false;
    });
  }
}
