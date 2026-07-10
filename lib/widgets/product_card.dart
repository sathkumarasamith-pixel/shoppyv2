import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../screens/product_detail.dart';
import '../screens/nearby_stores.dart';
import 'package:share_plus/share_plus.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onToggle;

  const ProductCard({
    super.key,
    required this.product,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Hero(
          tag: product.id,
          child: CachedNetworkImage(
            imageUrl: product.image,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(width: 60, height: 60, color: Colors.grey[300]),
            errorWidget: (context, url, error) => const Icon(Icons.image, size: 60),
          ),
        ),
        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$${product.price.toStringAsFixed(2)} from ${product.source}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${product.rating} (${product.reviews} reviews)'),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                product.isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: product.isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              onPressed: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.storefront),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NearbyStoresScreen(productName: product.name),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              onPressed: () {
                Share.share(
                  'Check out ${product.name} - \$${product.price.toStringAsFixed(2)} from ${product.source}',
                );
              },
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
          );
        },
      ),
    );
  }
}