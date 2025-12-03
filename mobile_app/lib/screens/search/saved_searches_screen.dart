import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/api_constants.dart';
import '../../models/property.dart';
import '../property/property_details_screen.dart';

class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  List<SavedSearch> _savedSearches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSearches();
  }

  Future<void> _loadSavedSearches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get(ApiConstants.savedSearches);

      if (response['success']) {
        setState(() {
          _savedSearches = (response['data'] as List)
              .map((json) => SavedSearch.fromJson(json))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading saved searches: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleNotifications(SavedSearch search) async {
    try {
      final response = await ApiService.put(
        ApiConstants.savedSearchById(search.id),
        {
          'name': search.name,
          'filters': search.filters,
          'notificationsEnabled': !search.notificationsEnabled,
        },
      );

      if (response['success']) {
        setState(() {
          search.notificationsEnabled = !search.notificationsEnabled;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                search.notificationsEnabled
                    ? 'Notifications enabled'
                    : 'Notifications disabled',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSavedSearch(String id) async {
    try {
      final response = await ApiService.delete(
        ApiConstants.savedSearchById(id),
      );

      if (response['success']) {
        setState(() {
          _savedSearches.removeWhere((search) => search.id == id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved search deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _viewMatchingProperties(SavedSearch search) async {
    try {
      final response = await ApiService.post(
        ApiConstants.matchingProperties,
        {'filters': search.filters},
      );

      if (response['success']) {
        final properties = (response['data'] as List)
            .map((json) => Property.fromJson(json))
            .toList();

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SavedSearchResultsScreen(
                searchName: search.name,
                properties: properties,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Saved Searches'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedSearches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Saved Searches',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Save your searches to get notified\nwhen new properties match',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedSearches,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedSearches.length,
                    itemBuilder: (context, index) {
                      final search = _savedSearches[index];
                      return _buildSearchCard(search);
                    },
                  ),
                ),
    );
  }

  Widget _buildSearchCard(SavedSearch search) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.search, color: Colors.white),
            ),
            title: Text(
              search.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              _buildFilterSummary(search.filters),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('View Results'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'notifications',
                  child: Row(
                    children: [
                      Icon(
                        search.notificationsEnabled
                            ? Icons.notifications_off
                            : Icons.notifications_active,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        search.notificationsEnabled
                            ? 'Disable Notifications'
                            : 'Enable Notifications',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _viewMatchingProperties(search);
                    break;
                  case 'notifications':
                    _toggleNotifications(search);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(search);
                    break;
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (search.notificationsEnabled)
                  Chip(
                    avatar: const Icon(Icons.notifications_active, size: 16),
                    label: const Text('Notifications On'),
                    backgroundColor: Colors.green[100],
                    labelStyle: TextStyle(
                      color: Colors.green[900],
                      fontSize: 12,
                    ),
                  ),
                ..._buildFilterChips(search.filters),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _viewMatchingProperties(search),
                icon: const Icon(Icons.search),
                label: const Text('View Matching Properties'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildFilterSummary(Map<String, dynamic> filters) {
    final parts = <String>[];

    if (filters['type'] != null && filters['type'] != 'All') {
      parts.add(filters['type']);
    }

    if (filters['minPrice'] != null || filters['maxPrice'] != null) {
      final min = filters['minPrice'] ?? 0;
      final max = filters['maxPrice'] ?? 'Any';
      parts.add('\$$min - \$$max');
    }

    if (filters['bedrooms'] != null && filters['bedrooms'] > 0) {
      parts.add('${filters['bedrooms']}+ beds');
    }

    if (filters['city'] != null && filters['city'].toString().isNotEmpty) {
      parts.add(filters['city']);
    }

    return parts.isEmpty ? 'All properties' : parts.join(' • ');
  }

  List<Widget> _buildFilterChips(Map<String, dynamic> filters) {
    final chips = <Widget>[];

    if (filters['status'] != null && filters['status'] != 'All') {
      chips.add(Chip(
        label: Text(filters['status']),
        backgroundColor: Colors.blue[100],
        labelStyle: const TextStyle(fontSize: 12),
      ));
    }

    if (filters['bathrooms'] != null && filters['bathrooms'] > 0) {
      chips.add(Chip(
        label: Text('${filters['bathrooms']}+ baths'),
        backgroundColor: Colors.purple[100],
        labelStyle: const TextStyle(fontSize: 12),
      ));
    }

    if (filters['furnished'] == true) {
      chips.add(Chip(
        label: const Text('Furnished'),
        backgroundColor: Colors.orange[100],
        labelStyle: const TextStyle(fontSize: 12),
      ));
    }

    if (filters['parking'] == true) {
      chips.add(Chip(
        label: const Text('Parking'),
        backgroundColor: Colors.teal[100],
        labelStyle: const TextStyle(fontSize: 12),
      ));
    }

    return chips;
  }

  void _showDeleteConfirmation(SavedSearch search) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Search'),
        content: Text(
          'Are you sure you want to delete "${search.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSavedSearch(search.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Model class
class SavedSearch {
  final String id;
  final String name;
  final Map<String, dynamic> filters;
  bool notificationsEnabled;
  final DateTime createdAt;

  SavedSearch({
    required this.id,
    required this.name,
    required this.filters,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      id: json['_id'],
      name: json['name'],
      filters: Map<String, dynamic>.from(json['filters'] ?? {}),
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// Results screen
class SavedSearchResultsScreen extends StatelessWidget {
  final String searchName;
  final List<Property> properties;

  const SavedSearchResultsScreen({
    super.key,
    required this.searchName,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(searchName),
      ),
      body: properties.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Matching Properties',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search filters',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                return _buildPropertyCard(context, property);
              },
            ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(property: property),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            if (property.images.isNotEmpty)
              Image.network(
                property.images.first,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.home, size: 50),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.location.address}, ${property.location.city}',
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${property.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          _buildFeature(Icons.bed, property.bedrooms.toString()),
                          const SizedBox(width: 12),
                          _buildFeature(Icons.bathtub, property.bathrooms.toString()),
                          const SizedBox(width: 12),
                          _buildFeature(Icons.square_foot, '${property.area} m²'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
