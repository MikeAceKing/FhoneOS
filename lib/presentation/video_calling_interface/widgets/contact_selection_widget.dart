import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './active_call_widget.dart';

/// Contact selection screen with favorites grid and full contact list
class ContactSelectionWidget extends StatefulWidget {
  const ContactSelectionWidget({super.key});

  @override
  State<ContactSelectionWidget> createState() => _ContactSelectionWidgetState();
}

class _ContactSelectionWidgetState extends State<ContactSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock contact data
  final List<Map<String, dynamic>> _favoriteContacts = [
    {
      "id": 1,
      "name": "Sarah Johnson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1caec3487-1765235228493.png",
      "semanticLabel":
          "Profile photo of a woman with blonde hair and blue eyes, wearing a white blouse",
      "status": "online",
    },
    {
      "id": 2,
      "name": "Michael Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1907e5900-1763296402708.png",
      "semanticLabel":
          "Profile photo of an Asian man with short black hair, wearing glasses and a blue shirt",
      "status": "online",
    },
    {
      "id": 3,
      "name": "Emily Rodriguez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e20f0ace-1763299053725.png",
      "semanticLabel":
          "Profile photo of a Hispanic woman with long brown hair, wearing a red top",
      "status": "away",
    },
    {
      "id": 4,
      "name": "David Kim",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_17fea9682-1764690565935.png",
      "semanticLabel":
          "Profile photo of a man with short dark hair and a beard, wearing a gray hoodie",
      "status": "offline",
    },
  ];

  final List<Map<String, dynamic>> _allContacts = [
    {
      "id": 5,
      "name": "Alex Thompson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1577ed5fc-1763296789570.png",
      "semanticLabel":
          "Profile photo of a man with brown hair and green eyes, wearing a black t-shirt",
      "status": "online",
      "phone": "+1 (555) 123-4567",
    },
    {
      "id": 6,
      "name": "Jessica Martinez",
      "avatar":
          "https://images.unsplash.com/photo-1729073723017-a9578371518b",
      "semanticLabel":
          "Profile photo of a woman with curly black hair, wearing a yellow dress",
      "status": "online",
      "phone": "+1 (555) 234-5678",
    },
    {
      "id": 7,
      "name": "Ryan O'Connor",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_11c451189-1764791200984.png",
      "semanticLabel":
          "Profile photo of a man with red hair and freckles, wearing a green polo shirt",
      "status": "away",
      "phone": "+1 (555) 345-6789",
    },
    {
      "id": 8,
      "name": "Priya Patel",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1ac0f6910-1763299885644.png",
      "semanticLabel":
          "Profile photo of an Indian woman with long black hair, wearing traditional jewelry",
      "status": "offline",
      "phone": "+1 (555) 456-7890",
    },
    {
      "id": 9,
      "name": "Marcus Williams",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f2746db7-1763296313857.png",
      "semanticLabel":
          "Profile photo of a Black man with short hair, wearing a blue suit",
      "status": "online",
      "phone": "+1 (555) 567-8901",
    },
    {
      "id": 10,
      "name": "Sophie Anderson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1c2d4d37e-1763298686580.png",
      "semanticLabel":
          "Profile photo of a woman with short blonde hair, wearing a pink sweater",
      "status": "away",
      "phone": "+1 (555) 678-9012",
    },
  ];

  List<Map<String, dynamic>> get _filteredContacts {
    if (_searchQuery.isEmpty) return _allContacts;
    return _allContacts
        .where((contact) => (contact["name"] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _initiateCall(Map<String, dynamic> contact, bool isVideoCall) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveCallWidget(
          contact: contact,
          isVideoCall: isVideoCall,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: CustomIconWidget(
                    iconName: 'search',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ),
          ),

          // Favorites section
          if (_searchQuery.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Text(
                'Favorites',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _favoriteContacts.length,
                itemBuilder: (context, index) {
                  final contact = _favoriteContacts[index];
                  return _buildFavoriteContactCard(contact, theme);
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // All contacts section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              _searchQuery.isEmpty ? 'All Contacts' : 'Search Results',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              return _buildContactListItem(contact, theme);
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFavoriteContactCard(
      Map<String, dynamic> contact, ThemeData theme) {
    final status = contact["status"] as String;
    final isOnline = status == "online";

    return Container(
      width: 20.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showCallOptionsDialog(contact),
            child: Stack(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOnline
                          ? theme.colorScheme.tertiary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: contact["avatar"] as String,
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.cover,
                      semanticLabel: contact["semanticLabel"] as String,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            (contact["name"] as String).split(' ')[0],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactListItem(Map<String, dynamic> contact, ThemeData theme) {
    final status = contact["status"] as String;
    final isOnline = status == "online";

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: Stack(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOnline
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: contact["avatar"] as String,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                  semanticLabel: contact["semanticLabel"] as String,
                ),
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          contact["name"] as String,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: contact["phone"] != null
            ? Text(
                contact["phone"] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: CustomIconWidget(
                iconName: 'videocam',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              onPressed: () => _initiateCall(contact, true),
            ),
            SizedBox(width: 1.w),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'call',
                color: theme.colorScheme.primary,
                size: 22,
              ),
              onPressed: () => _initiateCall(contact, false),
            ),
          ],
        ),
      ),
    );
  }

  void _showCallOptionsDialog(Map<String, dynamic> contact) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Call ${contact["name"]}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'videocam',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Video Call',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _initiateCall(contact, true);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'call',
                color: theme.colorScheme.primary,
                size: 22,
              ),
              title: Text(
                'Audio Call',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _initiateCall(contact, false);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
