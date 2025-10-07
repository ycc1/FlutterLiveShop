import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product; final VoidCallback? onTap;
  const ProductCard({Key? key, required this.product, this.onTap}) : super(key: key);
  @override Widget build(BuildContext context){
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(onTap: onTap, child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: CachedNetworkImage(imageUrl: product.imageUrl, fit: BoxFit.cover)),
          Padding(padding: const EdgeInsets.all(12), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('\$${product.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          )),
        ],
      )),
    );
  }
}
