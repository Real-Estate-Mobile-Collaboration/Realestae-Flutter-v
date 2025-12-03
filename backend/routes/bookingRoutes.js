const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getMyBookings,
  getOwnerBookings,
  createBooking,
  updateBookingStatus,
  cancelBooking,
  deleteBooking,
  getAvailableSlots
} = require('../controllers/bookingController');

router.use(protect);

router.get('/my-bookings', getMyBookings);
router.get('/owner-bookings', getOwnerBookings);
router.post('/', createBooking);
router.put('/:id/status', updateBookingStatus);
router.put('/:id/cancel', cancelBooking);
router.delete('/:id', deleteBooking);
router.get('/property/:propertyId/slots', getAvailableSlots);

module.exports = router;
