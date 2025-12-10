import 'package:flutter/material.dart';

import '../../widgets/custom_bottom_bar.dart';
import './widgets/chat_screen_widget.dart';
import './widgets/conversation_list_widget.dart';

/// Messaging Interface Screen
/// Enables real-time communication through WebSocket-based chat with media sharing
class MessagingInterface extends StatefulWidget {
  const MessagingInterface({super.key});

  @override
  State<MessagingInterface> createState() => _MessagingInterfaceState();
}

class _MessagingInterfaceState extends State<MessagingInterface> {
  int _currentBottomNavIndex = 1; // Messages tab is active
  String? _selectedConversationId;
  Map<String, dynamic>? _selectedContact;

  // Mock conversations data
  final List<Map<String, dynamic>> _conversations = [
    {
      "id": "conv_1",
      "contactName": "Sarah Johnson",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17334aace-1765154166701.png",
      "semanticLabel":
          "Profile photo of a woman with long brown hair and a warm smile, wearing a light blue shirt",
      "lastMessage": "Hey! Are you free for a video call later?",
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "unreadCount": 2,
      "isOnline": true,
      "isTyping": false,
    },
    {
      "id": "conv_2",
      "contactName": "Michael Chen",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_16dc65ba1-1763296579934.png",
      "semanticLabel":
          "Profile photo of a man with short black hair and glasses, wearing a dark polo shirt",
      "lastMessage": "Thanks for the files! 📎",
      "timestamp": DateTime.now().subtract(const Duration(hours: 1)),
      "unreadCount": 0,
      "isOnline": false,
      "isTyping": false,
    },
    {
      "id": "conv_3",
      "contactName": "Emma Rodriguez",
      "contactAvatar":
          "https://images.unsplash.com/photo-1694185766501-487b73d10332",
      "semanticLabel":
          "Profile photo of a woman with curly dark hair and bright smile, wearing a yellow top",
      "lastMessage": "Let's catch up soon! 😊",
      "timestamp": DateTime.now().subtract(const Duration(hours: 3)),
      "unreadCount": 1,
      "isOnline": true,
      "isTyping": false,
    },
    {
      "id": "conv_4",
      "contactName": "David Kim",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a9a5eb17-1763294376980.png",
      "semanticLabel":
          "Profile photo of a man with short dark hair and friendly expression, wearing a gray sweater",
      "lastMessage": "Perfect! See you tomorrow.",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "unreadCount": 0,
      "isOnline": false,
      "isTyping": false,
    },
    {
      "id": "conv_5",
      "contactName": "Lisa Anderson",
      "contactAvatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e5c54426-1763299106654.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair in a ponytail, wearing a white blouse",
      "lastMessage": "That sounds great! 🎉",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "unreadCount": 0,
      "isOnline": true,
      "isTyping": false,
    },
  ];

  void _onConversationTap(Map<String, dynamic> conversation) {
    setState(() {
      _selectedConversationId = conversation["id"] as String;
      _selectedContact = conversation;
    });
  }

  void _onBackToList() {
    setState(() {
      _selectedConversationId = null;
      _selectedContact = null;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate to other screens based on bottom nav selection
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/social-hub');
        break;
      case 1:
        // Already on messaging interface
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/app-launcher-desktop');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/user-profile-screen');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _selectedConversationId == null
          ? ConversationListWidget(
              conversations: _conversations,
              onConversationTap: _onConversationTap,
            )
          : ChatScreenWidget(
              contact: _selectedContact!,
              onBack: _onBackToList,
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
