import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/api_constants.dart';

class PropertyFilters {
  double? minPrice;
  double? maxPrice;
  double? minArea;
  double? maxArea;
  String? type;
  String? status;
  int? bedrooms;
  int? bathrooms;
  String? city;
  List<String>? amenities;
  bool? furnished;
  bool? parking;
  bool? petsAllowed;
  String? sortBy;
  bool? sortAscending;
  DateTime? postedAfter;

  PropertyFilters({
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.type,
    this.status,
    this.bedrooms,
    this.bathrooms,
    this.city,
    this.amenities,
    this.furnished,
    this.parking,
    this.petsAllowed,
    this.sortBy,
    this.sortAscending,
    this.postedAfter,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (minPrice != null) map['minPrice'] = minPrice;
    if (maxPrice != null) map['maxPrice'] = maxPrice;
    if (minArea != null) map['minArea'] = minArea;
    if (maxArea != null) map['maxArea'] = maxArea;
    if (type != null) map['type'] = type;
    if (status != null) map['status'] = status;
    if (bedrooms != null) map['bedrooms'] = bedrooms;
    if (bathrooms != null) map['bathrooms'] = bathrooms;
    if (city != null) map['city'] = city;
    if (amenities != null && amenities!.isNotEmpty) map['amenities'] = amenities;
    if (furnished != null) map['furnished'] = furnished;
    if (parking != null) map['parking'] = parking;
    if (petsAllowed != null) map['petsAllowed'] = petsAllowed;
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortAscending != null) map['sortAscending'] = sortAscending;
    if (postedAfter != null) map['postedAfter'] = postedAfter!.toIso8601String();
    return map;
  }
}

class PropertyFilterDialog extends StatefulWidget {
  final PropertyFilters? currentFilters;

  const PropertyFilterDialog({super.key, this.currentFilters});

  @override
  State<PropertyFilterDialog> createState() => _PropertyFilterDialogState();
}

class _PropertyFilterDialogState extends State<PropertyFilterDialog> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _minAreaController;
  late TextEditingController _maxAreaController;
  late TextEditingController _cityController;
  String? _selectedType;
  String? _selectedStatus;
  int? _selectedBedrooms;
  int? _selectedBathrooms;
  List<String> _selectedAmenities = [];
  bool? _furnished;
  bool? _parking;
  bool? _petsAllowed;
  String? _sortBy;
  bool _sortAscending = false;

  final List<String> _propertyTypes = [
    'apartment',
    'house',
    'villa',
    'condo',
    'townhouse',
    'land',
  ];

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Heating',
    'Swimming Pool',
    'Gym',
    'Parking',
    'Garden',
    'Balcony',
    'Elevator',
    'Security',
  ];

  final List<String> _sortOptions = [
    'price',
    'area',
    'bedrooms',
    'date',
    'views',
  ];

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.currentFilters?.minPrice?.toString() ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentFilters?.maxPrice?.toString() ?? '',
    );
    _minAreaController = TextEditingController(
      text: widget.currentFilters?.minArea?.toString() ?? '',
    );
    _maxAreaController = TextEditingController(
      text: widget.currentFilters?.maxArea?.toString() ?? '',
    );
    _cityController = TextEditingController(
      text: widget.currentFilters?.city ?? '',
    );
    _selectedType = widget.currentFilters?.type;
    _selectedStatus = widget.currentFilters?.status;
    _selectedBedrooms = widget.currentFilters?.bedrooms;
    _selectedBathrooms = widget.currentFilters?.bathrooms;
    _selectedAmenities = widget.currentFilters?.amenities ?? [];
    _furnished = widget.currentFilters?.furnished;
    _parking = widget.currentFilters?.parking;
    _petsAllowed = widget.currentFilters?.petsAllowed;
    _sortBy = widget.currentFilters?.sortBy;
    _sortAscending = widget.currentFilters?.sortAscending ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter Properties',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Filters
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Price Range
                  const Text(
                    'Price Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Min Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Max Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Property Type
                  const Text(
                    'Property Type',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      hintText: 'All Types',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Types')),
                      ..._propertyTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Status
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      hintText: 'All Statuses',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Statuses')),
                      DropdownMenuItem(value: 'sale', child: Text('FOR SALE')),
                      DropdownMenuItem(value: 'rent', child: Text('FOR RENT')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bedrooms
                  const Text(
                    'Bedrooms',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [null, 1, 2, 3, 4, 5].map((count) {
                      return ChoiceChip(
                        label: Text(count == null ? 'Any' : '$count+'),
                        selected: _selectedBedrooms == count,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBedrooms = selected ? count : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Bathrooms
                  const Text(
                    'Bathrooms',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [null, 1, 2, 3, 4].map((count) {
                      return ChoiceChip(
                        label: Text(count == null ? 'Any' : '$count+'),
                        selected: _selectedBathrooms == count,
                        onSelected: (selected) {
                          setState(() {
                            _selectedBathrooms = selected ? count : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // City
                  const Text(
                    'City',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Area Range
                  const Text(
                    'Area Range (m²)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minAreaController,
                          decoration: const InputDecoration(
                            labelText: 'Min Area',
                            suffixText: 'm²',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _maxAreaController,
                          decoration: const InputDecoration(
                            labelText: 'Max Area',
                            suffixText: 'm²',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Amenities
                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableAmenities.map((amenity) {
                      final isSelected = _selectedAmenities.contains(amenity);
                      return FilterChip(
                        label: Text(amenity),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedAmenities.add(amenity);
                            } else {
                              _selectedAmenities.remove(amenity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Features
                  const Text(
                    'Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Furnished'),
                        value: _furnished ?? false,
                        onChanged: (value) {
                          setState(() {
                            _furnished = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Parking Available'),
                        value: _parking ?? false,
                        onChanged: (value) {
                          setState(() {
                            _parking = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Pets Allowed'),
                        value: _petsAllowed ?? false,
                        onChanged: (value) {
                          setState(() {
                            _petsAllowed = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort Options
                  const Text(
                    'Sort By',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: _sortBy,
                    decoration: const InputDecoration(
                      hintText: 'Default Order',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Default Order')),
                      ..._sortOptions.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(option.toUpperCase()),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Sort Order:'),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Ascending'),
                        selected: _sortAscending,
                        onSelected: (selected) {
                          setState(() {
                            _sortAscending = selected;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Descending'),
                        selected: !_sortAscending,
                        onSelected: (selected) {
                          setState(() {
                            _sortAscending = !selected;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Save Search Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSaveSearchDialog(context);
                },
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Save This Search'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, PropertyFilters());
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final filters = PropertyFilters(
                          minPrice: _minPriceController.text.isNotEmpty
                              ? double.tryParse(_minPriceController.text)
                              : null,
                          maxPrice: _maxPriceController.text.isNotEmpty
                              ? double.tryParse(_maxPriceController.text)
                              : null,
                          minArea: _minAreaController.text.isNotEmpty
                              ? double.tryParse(_minAreaController.text)
                              : null,
                          maxArea: _maxAreaController.text.isNotEmpty
                              ? double.tryParse(_maxAreaController.text)
                              : null,
                          type: _selectedType,
                          status: _selectedStatus,
                          bedrooms: _selectedBedrooms,
                          bathrooms: _selectedBathrooms,
                          city: _cityController.text.isNotEmpty
                              ? _cityController.text
                              : null,
                          amenities: _selectedAmenities.isNotEmpty
                              ? _selectedAmenities
                              : null,
                          furnished: _furnished,
                          parking: _parking,
                          petsAllowed: _petsAllowed,
                          sortBy: _sortBy,
                          sortAscending: _sortAscending,
                        );
                        Navigator.pop(context, filters);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSaveSearchDialog(BuildContext context) {
    final nameController = TextEditingController();
    bool notificationsEnabled = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Save Search'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Search Name',
                  hintText: 'e.g., Apartments in Downtown',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
                title: const Text('Enable Notifications'),
                subtitle: const Text(
                  'Get notified when new properties match this search',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.dispose();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a name for this search'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Build filters
                final filters = PropertyFilters(
                  minPrice: _minPriceController.text.isNotEmpty
                      ? double.tryParse(_minPriceController.text)
                      : null,
                  maxPrice: _maxPriceController.text.isNotEmpty
                      ? double.tryParse(_maxPriceController.text)
                      : null,
                  minArea: _minAreaController.text.isNotEmpty
                      ? double.tryParse(_minAreaController.text)
                      : null,
                  maxArea: _maxAreaController.text.isNotEmpty
                      ? double.tryParse(_maxAreaController.text)
                      : null,
                  type: _selectedType,
                  status: _selectedStatus,
                  bedrooms: _selectedBedrooms,
                  bathrooms: _selectedBathrooms,
                  city: _cityController.text.isNotEmpty
                      ? _cityController.text
                      : null,
                  amenities: _selectedAmenities.isNotEmpty
                      ? _selectedAmenities
                      : null,
                  furnished: _furnished,
                  parking: _parking,
                  petsAllowed: _petsAllowed,
                  sortBy: _sortBy,
                  sortAscending: _sortAscending,
                );

                // Save to backend
                try {
                  final response = await ApiService.post(
                    ApiConstants.savedSearches,
                    {
                      'name': nameController.text.trim(),
                      'filters': filters.toMap(),
                      'notificationsEnabled': notificationsEnabled,
                    },
                  );

                  if (!context.mounted) return;

                  if (response['success']) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Search saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? 'Failed to save search'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                nameController.dispose();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
