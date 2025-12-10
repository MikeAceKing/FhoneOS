import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/contact.dart';

class FavoritesSectionWidget extends StatelessWidget {
  final List<Contact> favorites;
  final Function(Contact) onFavoriteToggle;
  final Function(Contact) onDelete;

  const FavoritesSectionWidget({
    super.key,
    required this.favorites,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber, size: 24.0),
              SizedBox(width: 8.w),
              Text(
                'Favorites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final contact = favorites[index];
                return Container(
                  width: 80.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(contact.fullName),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone: ${contact.phoneNumber}'),
                                  if (contact.email != null)
                                    Text('Email: ${contact.email}'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 32.0,
                          backgroundColor:
                              Theme.of(context).primaryColor.withAlpha(26),
                          backgroundImage: contact.avatarUrl != null
                              ? NetworkImage(contact.avatarUrl!)
                              : null,
                          child: contact.avatarUrl == null
                              ? Text(
                                  contact.fullName.isNotEmpty
                                      ? contact.fullName[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        contact.fullName.split(' ').first,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Divider(height: 24.h),
        ],
      ),
    );
  }
}