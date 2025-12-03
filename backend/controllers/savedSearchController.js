const SavedSearch = require('../models/SavedSearch');
const Property = require('../models/Property');

// Get all saved searches for user
exports.getSavedSearches = async (req, res) => {
  try {
    const searches = await SavedSearch.find({ user: req.user.id })
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: searches.length,
      data: searches
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Create saved search
exports.createSavedSearch = async (req, res) => {
  try {
    const { name, filters, notificationsEnabled } = req.body;

    const savedSearch = await SavedSearch.create({
      user: req.user.id,
      name,
      filters,
      notificationsEnabled: notificationsEnabled !== false
    });

    res.status(201).json({
      success: true,
      data: savedSearch
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Update saved search
exports.updateSavedSearch = async (req, res) => {
  try {
    const { name, filters, notificationsEnabled } = req.body;

    let savedSearch = await SavedSearch.findById(req.params.id);

    if (!savedSearch) {
      return res.status(404).json({
        success: false,
        message: 'Saved search not found'
      });
    }

    // Check ownership
    if (savedSearch.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this search'
      });
    }

    savedSearch = await SavedSearch.findByIdAndUpdate(
      req.params.id,
      { name, filters, notificationsEnabled },
      { new: true, runValidators: true }
    );

    res.json({
      success: true,
      data: savedSearch
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Delete saved search
exports.deleteSavedSearch = async (req, res) => {
  try {
    const savedSearch = await SavedSearch.findById(req.params.id);

    if (!savedSearch) {
      return res.status(404).json({
        success: false,
        message: 'Saved search not found'
      });
    }

    // Check ownership
    if (savedSearch.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this search'
      });
    }

    await savedSearch.deleteOne();

    res.json({
      success: true,
      message: 'Saved search deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get matching properties for a saved search
exports.getMatchingProperties = async (req, res) => {
  try {
    const savedSearch = await SavedSearch.findById(req.params.id);

    if (!savedSearch) {
      return res.status(404).json({
        success: false,
        message: 'Saved search not found'
      });
    }

    // Check ownership
    if (savedSearch.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this search'
      });
    }

    // Build query from filters
    const query = {};
    const { filters } = savedSearch;

    if (filters.minPrice || filters.maxPrice) {
      query.price = {};
      if (filters.minPrice) query.price.$gte = filters.minPrice;
      if (filters.maxPrice) query.price.$lte = filters.maxPrice;
    }

    if (filters.minArea || filters.maxArea) {
      query.area = {};
      if (filters.minArea) query.area.$gte = filters.minArea;
      if (filters.maxArea) query.area.$lte = filters.maxArea;
    }

    if (filters.type) query.propertyType = filters.type;
    if (filters.status) query.status = filters.status;
    if (filters.bedrooms) query.bedrooms = { $gte: filters.bedrooms };
    if (filters.bathrooms) query.bathrooms = { $gte: filters.bathrooms };
    if (filters.city) query['location.city'] = new RegExp(filters.city, 'i');
    if (filters.amenities && filters.amenities.length > 0) {
      query.amenities = { $all: filters.amenities };
    }

    const properties = await Property.find(query)
      .populate('owner', 'name email phone')
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      success: true,
      count: properties.length,
      data: properties
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
