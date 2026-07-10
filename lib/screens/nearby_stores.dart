import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/nearby_service.dart';

class NearbyStoresScreen extends StatefulWidget {
  final String productName;
  const NearbyStoresScreen({super.key, required this.productName});

  @override
  State<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  List<Map<String, dynamic>> _stores = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'Location permission is required to find nearby stores. Please enable it in settings.';
          _loading = false;
        });
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 'Location permission is permanently denied. Please enable it in your phone settings.';
        _loading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final stores = await NearbyService.findNearbyStores(
          widget.productName, position);
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not find nearby stores: $e';
        _loading = false;
      });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No stores found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'No stores selling ${widget.productName} within 5km',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = '';
              });
              _fetchStores();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Stores for ${widget.productName}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loading = true;
                            _error = '';
                          });
                          _fetchStores();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _stores.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _stores.length,
                      itemBuilder: (context, index) {
                        final store = _stores[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.store, color: Colors.green),
                            title: Text(
                              store['name'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(store['address']),
                            trailing: Chip(
                              label: Text('⭐ ${store['rating']}'),
                              backgroundColor: Colors.amber.shade100,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}