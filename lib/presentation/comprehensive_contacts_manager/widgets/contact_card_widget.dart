import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/contact.dart';

class ContactCardWidget extends StatelessWidget {
  final Contact contact;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const ContactCardWidget({
    super.key,
    required this.contact,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  Future<void> _makeCall() async {
    final uri = Uri(scheme: 'tel', path: contact.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSMS() async {
    final uri = Uri(scheme: 'sms', path: contact.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail() async {
    if (contact.email != null) {
      final uri = Uri(scheme: 'mailto', path: contact.email);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          radius: 28.sp,
          backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
          backgroundImage: contact.avatarUrl != null
              ? NetworkImage(contact.avatarUrl!)
              : null,
          child: contact.avatarUrl == null
              ? Text(
                  contact.fullName.isNotEmpty
                      ? contact.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.fullName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (contact.isFavorite)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20.sp,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.phone, size: 16.sp, color: Colors.grey[600]),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    contact.phoneNumber,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (contact.email != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.email, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      contact.email!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (contact.tags.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(
                spacing: 4.w,
                children: contact.tags
                    .take(3)
                    .map(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'call':
                _makeCall();
                break;
              case 'sms':
                _sendSMS();
                break;
              case 'email':
                _sendEmail();
                break;
              case 'favorite':
                onFavoriteToggle();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  const Icon(Icons.call, size: 20),
                  SizedBox(width: 12.w),
                  const Text('Call'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sms',
              child: Row(
                children: [
                  const Icon(Icons.message, size: 20),
                  SizedBox(width: 12.w),
                  const Text('Message'),
                ],
              ),
            ),
            if (contact.email != null)
              PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    const Icon(Icons.email, size: 20),
                    SizedBox(width: 12.w),
                    const Text('Email'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'favorite',
              child: Row(
                children: [
                  Icon(
                    contact.isFavorite ? Icons.star : Icons.star_border,
                    size: 20,
                  ),
                  SizedBox(width: 12.w),
                  Text(contact.isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12.w),
                  const Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}