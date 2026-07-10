import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

class NearbyService {
  static final String _placesApiKey = Config.placesApiKey;

  static Future<List<Map<String, dynamic>>> findNearbyStores(
    String productName,
    Position position,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${position.latitude},${position.longitude}'
      '&radius=5000'
      '&keyword=${Uri.encodeComponent(productName)}'
      '&type=store'
      '&key=$_placesApiKey',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Places API error: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final List<dynamic> results = data['results'] ?? [];

    return results.map<Map<String, dynamic>>((place) {
      String photoRef = '';

      if (place['photos'] != null &&
          place['photos'] is List &&
          (place['photos'] as List).isNotEmpty) {
        photoRef = place['photos'][0]['photo_reference'] ?? '';
      }

      return {
        'name': place['name'] ?? '',
        'address': place['vicinity'] ?? '',
        'rating': (place['rating'] as num?)?.toDouble() ?? 0.0,
        'photoRef': photoRef,
        'lat': place['geometry']?['location']?['lat'] ?? 0.0,
        'lng': place['geometry']?['location']?['lng'] ?? 0.0,
      };
    }).toList();
  }
}