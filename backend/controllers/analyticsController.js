const Property = require('../models/Property');
const Booking = require('../models/Booking');

// @desc    Get analytics for all of a user's listings
// @route   GET /api/analytics/listings
// @access  Private
exports.getListingAnalytics = async (req, res) => {
    try {
        const properties = await Property.find({ owner: req.user.id });

        let totalViews = 0;
        let totalBookings = 0;
        let totalRevenue = 0;

        for (const property of properties) {
            totalViews += property.views || 0;
            const bookings = await Booking.find({ property: property._id, status: 'confirmed' });
            totalBookings += bookings.length;
            bookings.forEach(booking => {
                totalRevenue += booking.totalPrice;
            });
        }

        res.json({
            totalProperties: properties.length,
            totalViews,
            totalBookings,
            totalRevenue,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get analytics for a specific property
// @route   GET /api/analytics/property/:id
// @access  Private
exports.getPropertyAnalytics = async (req, res) => {
    try {
        const property = await Property.findById(req.params.id);

        if (!property) {
            return res.status(404).json({ message: 'Property not found' });
        }

        // Ensure the user owns the property
        if (property.owner.toString() !== req.user.id) {
            return res.status(401).json({ message: 'Not authorized' });
        }

        const bookings = await Booking.find({ property: property._id, status: 'confirmed' });
        const totalRevenue = bookings.reduce((acc, booking) => acc + booking.totalPrice, 0);

        res.json({
            views: property.views || 0,
            totalBookings: bookings.length,
            totalRevenue,
            bookings,
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error' });
    }
};
