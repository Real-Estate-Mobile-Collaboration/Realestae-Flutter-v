const express = require('express');
const {
  getConversations,
  getMessages,
  sendMessage,
  markAsRead,
  deleteConversation,
  deleteMessage
} = require('../controllers/messageController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/conversations', protect, getConversations);
router.get('/:userId', protect, getMessages);
router.post('/', protect, sendMessage);
router.put('/:id/read', protect, markAsRead);
router.delete('/conversation/:userId', protect, deleteConversation);
router.delete('/:messageId', protect, deleteMessage);

module.exports = router;
