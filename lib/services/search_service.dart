import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/product.dart';

class SearchService {
  final String _serperKey = Config.serperApiKey;

  Future<List<Product>> search(String query, {int page = 1}) async {
    final results = await _serperSearch(query, page: page);

    final List<Product> products =
        results.map((json) => Product.fromJson(json)).toList();

    products.sort((a, b) {
      if (a.rating != b.rating) {
        return b.rating.compareTo(a.rating);
      }
      return a.price.compareTo(b.price);
    });

    await _savePriceHistory(products);

    return products;
  }

  Future<List<Map<String, dynamic>>> _serperSearch(
    String query, {
    int page = 1,
  }) async {
    final url = Uri.parse('https://google.serper.dev/shopping');

    final response = await http.post(
      url,
      headers: {
        'X-API-KEY': _serperKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'q': query,
        'gl': 'us',
        'num': 10,
        'page': page,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Serper API error: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> shopping = data['shopping'] ?? [];

    return shopping.map<Map<String, dynamic>>((item) {
      return {
        'id': item['productId'] ??
            item['link'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'name': item['title'] ?? '',
        'image': item['imageUrl'] ?? '',
        'price': double.tryParse(
              item['price']
                      ?.toString()
                      .replaceAll(RegExp(r'[^0-9.]'), '') ??
                  '0',
            ) ??
            0.0,
        'source': item['source'] ?? 'Online Store',
        'rating': (item['rating'] as num?)?.toDouble() ?? 0.0,
        'reviews': item['reviews'] ?? 0,
        'description': item['description'] ?? '',
      };
    }).toList();
  }

  Future<void> _savePriceHistory(List<Product> products) async {
    final firestore = FirebaseFirestore.instance;

    for (final product in products) {
      final docRef = firestore.collection('products').doc(product.id);

      await docRef.set(
        {
          'name': product.name,
          'image': product.image,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await docRef
          .collection('priceHistory')
          .doc(DateTime.now().toIso8601String())
          .set({
        'price': product.price,
        'source': product.source,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }
}