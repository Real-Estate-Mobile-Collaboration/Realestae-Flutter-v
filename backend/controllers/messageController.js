const Message = require('../models/Message');
const mongoose = require('mongoose');

// @desc    Get conversations for a user
// @route   GET /api/messages/conversations
// @access  Private
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('🔍 Fetching conversations for user:', userId);

    // First, check all messages for this user
    const allMessages = await Message.find({
      $or: [
        { sender: new mongoose.Types.ObjectId(userId) },
        { receiver: new mongoose.Types.ObjectId(userId) }
      ]
    }).sort({ createdAt: -1 });
    
    console.log('📨 Total messages found:', allMessages.length);
    const uniqueConversations = [...new Set(allMessages.map(m => m.conversationId))];
    console.log('💬 Unique conversation IDs:', uniqueConversations.length, uniqueConversations);

    // Get unique conversations with last message
    const conversations = await Message.aggregate([
      {
        $match: {
          $or: [
            { sender: new mongoose.Types.ObjectId(userId) },
            { receiver: new mongoose.Types.ObjectId(userId) }
          ]
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      // Group by conversation to get last message
      {
        $group: {
          _id: '$conversationId',
          messages: { $push: '$$ROOT' }
        }
      },
      // Add last message and calculate unread count
      {
        $addFields: {
          lastMessage: { $arrayElemAt: ['$messages', 0] },
          unreadCount: {
            $size: {
              $filter: {
                input: '$messages',
                as: 'msg',
                cond: {
                  $and: [
                    { $eq: ['$$msg.receiver', new mongoose.Types.ObjectId(userId)] },
                    { $eq: ['$$msg.isRead', false] }
                  ]
                }
              }
            }
          }
        }
      },
      // Lookup sender details
      {
        $lookup: {
          from: 'users',
          localField: 'lastMessage.sender',
          foreignField: '_id',
          as: 'senderDetails'
        }
      },
      // Lookup receiver details
      {
        $lookup: {
          from: 'users',
          localField: 'lastMessage.receiver',
          foreignField: '_id',
          as: 'receiverDetails'
        }
      },
      // Add sender and receiver to lastMessage
      {
        $addFields: {
          'lastMessage.sender': { $arrayElemAt: ['$senderDetails', 0] },
          'lastMessage.receiver': { $arrayElemAt: ['$receiverDetails', 0] }
        }
      },
      // Project to remove password and unnecessary fields
      {
        $project: {
          _id: 1,
          lastMessage: {
            _id: 1,
            conversationId: 1,
            content: 1,
            propertyRef: 1,
            isRead: 1,
            createdAt: 1,
            sender: {
              _id: 1,
              name: 1,
              email: 1,
              photo: 1
            },
            receiver: {
              _id: 1,
              name: 1,
              email: 1,
              photo: 1
            }
          },
          unreadCount: 1
        }
      },
      {
        $sort: { 'lastMessage.createdAt': -1 }
      }
    ]);

    console.log('📊 Found conversations:', conversations.length);

    res.status(200).json({
      success: true,
      count: conversations.length,
      data: conversations
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get messages in a conversation
// @route   GET /api/messages/:userId
// @access  Private
exports.getMessages = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;

    const conversationId = Message.createConversationId(currentUserId, otherUserId);

    const messages = await Message.find({ conversationId })
      .populate('sender', 'name photo')
      .populate('receiver', 'name photo')
      .sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      {
        conversationId,
        receiver: currentUserId,
        isRead: false
      },
      { isRead: true }
    );

    res.status(200).json({
      success: true,
      count: messages.length,
      data: messages
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Send a message
// @route   POST /api/messages
// @access  Private
exports.sendMessage = async (req, res) => {
  try {
    const { receiverId, content, propertyRef } = req.body;
    const senderId = req.user.id;

    const conversationId = Message.createConversationId(senderId, receiverId);

    const message = await Message.create({
      conversationId,
      sender: senderId,
      receiver: receiverId,
      content,
      propertyRef
    });

    const populatedMessage = await Message.findById(message._id)
      .populate('sender', 'name photo')
      .populate('receiver', 'name photo');

    res.status(201).json({
      success: true,
      data: populatedMessage
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Mark message as read
// @route   PUT /api/messages/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
  try {
    const message = await Message.findByIdAndUpdate(
      req.params.id,
      { isRead: true },
      { new: true }
    );

    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    res.status(200).json({
      success: true,
      data: message
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete a conversation
// @route   DELETE /api/messages/conversation/:userId
// @access  Private
exports.deleteConversation = async (req, res) => {
  try {
    const currentUserId = req.user.id;
    const otherUserId = req.params.userId;

    const conversationId = Message.createConversationId(currentUserId, otherUserId);

    const result = await Message.deleteMany({ conversationId });

    res.status(200).json({
      success: true,
      message: 'Conversation deleted successfully',
      deletedCount: result.deletedCount
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete a single message
// @route   DELETE /api/messages/:messageId
// @access  Private
exports.deleteMessage = async (req, res) => {
  try {
    const messageId = req.params.messageId;
    const currentUserId = req.user.id;

    const message = await Message.findById(messageId);

    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    // Check if user is sender or receiver of the message
    if (message.sender.toString() !== currentUserId && message.receiver.toString() !== currentUserId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this message'
      });
    }

    await Message.findByIdAndDelete(messageId);

    res.status(200).json({
      success: true,
      message: 'Message deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
