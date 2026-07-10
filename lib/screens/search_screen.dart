import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:io';
import '../services/search_service.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import 'compare_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  final SearchService _searchService = SearchService();

  List<Product> _results = [];
  bool _loading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String _currentQuery = '';
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
    );
    if (mounted) setState(() {});
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _results = [];
      _currentPage = 1;
      _hasMore = true;
      _currentQuery = query;
      _loading = true;
    });
    try {
      final products = await _searchService.search(query, page: _currentPage);
      setState(() {
        _results = products;
        _loading = false;
        _currentPage++;
        if (products.length < 10) _hasMore = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search error: $e')));
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _loading) return;
    setState(() => _isLoadingMore = true);
    try {
      final newProducts = await _searchService.search(_currentQuery, page: _currentPage);
      setState(() {
        _results.addAll(newProducts);
        _currentPage++;
        if (newProducts.length < 10) _hasMore = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    if (_currentQuery.isNotEmpty) {
      _performSearch(_currentQuery);
    }
  }

  void _voiceSearch() async {
    if (!_speechAvailable) {
      _initSpeech();
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
        return;
      }
    }

    bool isListening = await _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _controller.text = result.recognizedWords;
            if (result.finalResult) {
              _performSearch(_controller.text);
            }
          });
        }
      },
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
      ),
    );

    if (!isListening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please speak clearly into the microphone')),
      );
    }
  }

  void _imageSearch() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    _showSearchFromImageDialog();
  }

  void _showSearchFromImageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.image, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Search by Image'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the product name you want to search for:'),
            const SizedBox(height: 12),
            TextField(
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() => _controller.text = value);
                  _performSearch(value);
                }
              },
              decoration: const InputDecoration(
                hintText: 'e.g., iPhone 15',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(Product product) {
    setState(() {
      final index = _results.indexOf(product);
      _results[index] = product.copyWith(isSelected: !product.isSelected);
    });
  }

  void _goToCompare() {
    final selected = _results.where((p) => p.isSelected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompareScreen(initialProducts: selected),
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: List.generate(5, (index) =>
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: const ListTile(
                leading: SizedBox(width: 60, height: 60, child: ColoredBox(color: Colors.white)),
                title: ColoredBox(color: Colors.white, child: SizedBox(height: 16)),
                subtitle: ColoredBox(color: Colors.white, child: SizedBox(height: 12)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _controller.clear(),
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Shoppy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            onPressed: _goToCompare,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: _speechAvailable ? Colors.deepPurple : Colors.grey,
                        ),
                        onPressed: _voiceSearch,
                        tooltip: _speechAvailable ? 'Search by voice' : 'Speech not available',
                      ),
                    ),
                    onSubmitted: _performSearch,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _imageSearch,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? _buildShimmer()
                : _results.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          itemCount: _results.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _results.length) {
                              if (_isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              if (_hasMore) {
                                _loadMore();
                                return const SizedBox.shrink();
                              }
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: Text('No more products.')),
                              );
                            }
                            return ProductCard(
                              product: _results[index],
                              onToggle: () => _toggleSelection(_results[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}