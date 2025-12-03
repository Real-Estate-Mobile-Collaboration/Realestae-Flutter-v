const mongoose = require('mongoose');

const savedSearchSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Please provide a name for this search'],
    trim: true,
    maxlength: [50, 'Name cannot exceed 50 characters']
  },
  filters: {
    minPrice: Number,
    maxPrice: Number,
    minArea: Number,
    maxArea: Number,
    type: String,
    status: String,
    bedrooms: Number,
    bathrooms: Number,
    city: String,
    amenities: [String],
    furnished: Boolean,
    parking: Boolean,
    petsAllowed: Boolean
  },
  notificationsEnabled: {
    type: Boolean,
    default: true
  },
  lastNotified: Date,
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Index for faster queries
savedSearchSchema.index({ user: 1, createdAt: -1 });

module.exports = mongoose.model('SavedSearch', savedSearchSchema);
