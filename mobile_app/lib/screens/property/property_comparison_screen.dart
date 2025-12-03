import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/property.dart';
import '../../utils/helpers.dart';
import '../../providers/property_provider.dart';

class PropertyComparisonProvider with ChangeNotifier {
  final List<Property> _selectedProperties = [];

  List<Property> get selectedProperties => _selectedProperties;
  int get count => _selectedProperties.length;
  bool get canAddMore => _selectedProperties.length < 3;

  bool isSelected(String propertyId) {
    return _selectedProperties.any((p) => p.id == propertyId);
  }

  void addProperty(Property property) {
    if (_selectedProperties.length < 3 && !isSelected(property.id)) {
      _selectedProperties.add(property);
      notifyListeners();
    }
  }

  void removeProperty(String propertyId) {
    _selectedProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  void clearAll() {
    _selectedProperties.clear();
    notifyListeners();
  }
}

class PropertyComparisonScreen extends StatelessWidget {
  const PropertyComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyComparisonProvider(),
      child: const _PropertyComparisonView(),
    );
  }
}

class _PropertyComparisonView extends StatelessWidget {
  const _PropertyComparisonView();

  @override
  Widget build(BuildContext context) {
    final comparisonProvider = Provider.of<PropertyComparisonProvider>(context);
    final properties = comparisonProvider.selectedProperties;

    return Scaffold(
      appBar: AppBar(
        title: Text('Compare Properties (${properties.length}/3)'),
        actions: [
          if (properties.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                comparisonProvider.clearAll();
              },
            ),
        ],
      ),
      body: properties.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _buildComparisonTable(context, properties),
              ),
            ),
      floatingActionButton: properties.length < 3
          ? FloatingActionButton.extended(
              onPressed: () => _showPropertyPicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Properties to Compare',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            'Add up to 3 properties to compare',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showPropertyPicker(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Property'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context, List<Property> properties) {
    return DataTable(
      columnSpacing: 20,
      horizontalMargin: 20,
      columns: [
        const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
        ...properties.map((p) => DataColumn(
          label: SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () {
                    Provider.of<PropertyComparisonProvider>(context, listen: false)
                        .removeProperty(p.id);
                  },
                ),
              ],
            ),
          ),
        )),
      ],
      rows: [
        _buildRow('Price', properties.map((p) => Helpers.formatCurrency(p.price)).toList()),
        _buildRow('Type', properties.map((p) => p.propertyType.toUpperCase()).toList()),
        _buildRow('Status', properties.map((p) => p.status.toUpperCase()).toList()),
        _buildRow('Bedrooms', properties.map((p) => '${p.bedrooms}').toList()),
        _buildRow('Bathrooms', properties.map((p) => '${p.bathrooms}').toList()),
        _buildRow('Area', properties.map((p) => '${p.area} m²').toList()),
        _buildRow('City', properties.map((p) => p.location.city).toList()),
        _buildRow('Address', properties.map((p) => p.location.address).toList()),
        _buildRow('Available', properties.map((p) => p.isAvailable ? 'Yes' : 'No').toList()),
        _buildRow('Featured', properties.map((p) => p.featured ? 'Yes' : 'No').toList()),
        _buildRow('Rating', properties.map((p) => p.averageRating > 0 ? '${p.averageRating.toStringAsFixed(1)} ⭐' : 'No reviews').toList()),
        _buildRow('Views', properties.map((p) => '${p.views}').toList()),
      ],
    );
  }

  DataRow _buildRow(String label, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        ...values.map((v) => DataCell(Text(v))),
      ],
    );
  }

  void _showPropertyPicker(BuildContext context) async {
    final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    final comparisonProvider = Provider.of<PropertyComparisonProvider>(context, listen: false);
    
    await propertyProvider.fetchProperties();
    
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Property',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<PropertyProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final availableProperties = provider.properties
                      .where((p) => !comparisonProvider.isSelected(p.id))
                      .toList();

                  if (availableProperties.isEmpty) {
                    return const Center(child: Text('No more properties available'));
                  }

                  return ListView.builder(
                    itemCount: availableProperties.length,
                    itemBuilder: (context, index) {
                      final property = availableProperties[index];
                      return ListTile(
                        leading: property.images.isNotEmpty
                            ? Image.network(
                                property.images[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.home),
                        title: Text(property.title),
                        subtitle: Text(Helpers.formatCurrency(property.price)),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () {
                          comparisonProvider.addProperty(property);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
