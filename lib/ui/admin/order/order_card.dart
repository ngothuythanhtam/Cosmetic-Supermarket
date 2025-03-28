import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order_item.dart';
import '../../../components/colors.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback? onTap;

  const OrderItemCard(this.order, {super.key, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromARGB(255, 94, 181, 97); 
      case 'canceled':
        return const Color.fromARGB(255, 253, 72, 72); 
      case 'confirmed':
        return Colors.blue; 
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, 
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), 
      ),
      color: color2, 
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(
              16.0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('dd/MM/yyyy [HH:mm:ss]').format(order.dateTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "\$${order.amount.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                                color: color11,  
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: color4.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.user?.username ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.w600,
                            color: color4,
                          ),
                          overflow: TextOverflow.ellipsis,
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
