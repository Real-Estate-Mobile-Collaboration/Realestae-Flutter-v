const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  property: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Property',
    required: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  visitDate: {
    type: Date,
    required: [true, 'Please provide a visit date']
  },
  visitTime: {
    type: String,
    required: [true, 'Please provide a visit time']
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    default: 'pending'
  },
  message: {
    type: String,
    maxlength: [500, 'Message cannot exceed 500 characters']
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters']
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  confirmedAt: Date,
  cancelledAt: Date,
  completedAt: Date
});

// Index for faster queries
bookingSchema.index({ user: 1, visitDate: -1 });
bookingSchema.index({ owner: 1, visitDate: -1 });
bookingSchema.index({ property: 1, visitDate: 1 });

// Prevent duplicate bookings
bookingSchema.index({ user: 1, property: 1, visitDate: 1, visitTime: 1 }, { unique: true });

module.exports = mongoose.model('Booking', bookingSchema);
