import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail.dart';

class CompareScreen extends StatefulWidget {
  final List<Product> initialProducts;

  const CompareScreen({
    super.key,
    this.initialProducts = const [],
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  late List<Product> _selectedProducts;

  @override
  void initState() {
    super.initState();
    _selectedProducts = List.from(widget.initialProducts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Products'),
        actions: [
          if (_selectedProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedProducts.clear();
                });
              },
            ),
        ],
      ),
      body: _selectedProducts.isEmpty
          ? _emptyState()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 25,
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                columns: [
                  const DataColumn(
                    label: Text(
                      'Feature',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ..._selectedProducts.map(
                    (product) => DataColumn(
                      label: SizedBox(
                        width: 120,
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: [
                  _buildRow(
                    'Image',
                    _selectedProducts
                        .map(
                          (p) => GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: p),
                                ),
                              );
                            },
                            child: Image.network(
                              p.image,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  _buildRow(
                    'Price',
                    _selectedProducts
                        .map(
                          (p) => Text(
                            '\$${p.price.toStringAsFixed(2)}',
                          ),
                        )
                        .toList(),
                  ),
                  _buildRow(
                    'Store',
                    _selectedProducts
                        .map((p) => Text(p.source))
                        .toList(),
                  ),
                  _buildRow(
                    'Rating',
                    _selectedProducts
                        .map(
                          (p) => Text(
                            '⭐ ${p.rating} (${p.reviews})',
                          ),
                        )
                        .toList(),
                  ),
                  _buildRow(
                    'Description',
                    _selectedProducts
                        .map(
                          (p) => SizedBox(
                            width: 120,
                            child: Text(
                              p.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products selected',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Search and tap the checkbox on products',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(String label, List<Widget> cells) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...cells.map(
          (cell) => DataCell(cell),
        ),
      ],
    );
  }
}