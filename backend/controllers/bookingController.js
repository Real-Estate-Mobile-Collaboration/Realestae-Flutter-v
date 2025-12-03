const Booking = require('../models/Booking');
const Property = require('../models/Property');

// Get user's bookings
exports.getMyBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ user: req.user.id })
      .populate('property')
      .populate('owner', 'name email phone')
      .sort({ visitDate: 1 });

    res.json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get bookings for property owner
exports.getOwnerBookings = async (req, res) => {
  try {
    const bookings = await Booking.find({ owner: req.user.id })
      .populate('property')
      .populate('user', 'name email phone')
      .sort({ visitDate: 1 });

    res.json({
      success: true,
      count: bookings.length,
      data: bookings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Create booking
exports.createBooking = async (req, res) => {
  try {
    const { propertyId, visitDate, visitTime, message } = req.body;

    const property = await Property.findById(propertyId).populate('owner');
    
    if (!property) {
      return res.status(404).json({
        success: false,
        message: 'Property not found'
      });
    }

    // Can't book own property
    if (property.owner._id.toString() === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'You cannot book your own property'
      });
    }

    // Check if date is in the future
    if (new Date(visitDate) < new Date()) {
      return res.status(400).json({
        success: false,
        message: 'Visit date must be in the future'
      });
    }

    const booking = await Booking.create({
      property: propertyId,
      user: req.user.id,
      owner: property.owner._id,
      visitDate,
      visitTime,
      message
    });

    const populatedBooking = await Booking.findById(booking._id)
      .populate('property')
      .populate('owner', 'name email phone');

    res.status(201).json({
      success: true,
      data: populatedBooking
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'You already have a booking for this property at this time'
      });
    }
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Update booking status
exports.updateBookingStatus = async (req, res) => {
  try {
    const { status, notes } = req.body;

    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // Only owner can update status
    if (booking.owner.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this booking'
      });
    }

    booking.status = status;
    if (notes) booking.notes = notes;
    
    if (status === 'confirmed') booking.confirmedAt = Date.now();
    if (status === 'cancelled') booking.cancelledAt = Date.now();
    if (status === 'completed') booking.completedAt = Date.now();

    await booking.save();

    const updatedBooking = await Booking.findById(booking._id)
      .populate('property')
      .populate('user', 'name email phone');

    res.json({
      success: true,
      data: updatedBooking
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Cancel booking
exports.cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // User can cancel their own booking
    if (booking.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to cancel this booking'
      });
    }

    booking.status = 'cancelled';
    booking.cancelledAt = Date.now();
    await booking.save();

    res.json({
      success: true,
      message: 'Booking cancelled successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Delete booking
exports.deleteBooking = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    // User can delete their own booking
    if (booking.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this booking'
      });
    }

    await booking.deleteOne();

    res.json({
      success: true,
      message: 'Booking deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// Get available time slots for a property
exports.getAvailableSlots = async (req, res) => {
  try {
    const { date } = req.query;
    const propertyId = req.params.propertyId;

    if (!date) {
      return res.status(400).json({
        success: false,
        message: 'Please provide a date'
      });
    }

    const bookings = await Booking.find({
      property: propertyId,
      visitDate: new Date(date),
      status: { $in: ['pending', 'confirmed'] }
    });

    const bookedSlots = bookings.map(b => b.visitTime);

    // All possible time slots (9 AM to 6 PM)
    const allSlots = [
      '09:00', '10:00', '11:00', '12:00', 
      '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'
    ];

    const availableSlots = allSlots.filter(slot => !bookedSlots.includes(slot));

    res.json({
      success: true,
      data: {
        allSlots,
        bookedSlots,
        availableSlots
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
