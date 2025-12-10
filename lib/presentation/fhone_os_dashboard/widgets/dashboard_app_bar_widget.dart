import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Dashboard App Bar Widget
/// Top navigation bar with branding and user profile
class DashboardAppBarWidget extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const DashboardAppBarWidget({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: const BoxDecoration(
        color: Color(0xFF020617),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Branding
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Text(
                'R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Rocket CloudOS',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Virtuele smartphone omgeving',
                  style: TextStyle(fontSize: 11.sp, color: Colors.white60),
                ),
              ],
            ),
            const Spacer(),

            // User Profile Menu
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  onLogout();
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFF0F172A),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: TextStyle(fontSize: 9.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      userName,
                      style: TextStyle(fontSize: 11.sp, color: Colors.white),
                    ),
                  ],
                ),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, size: 18),
                          SizedBox(width: 2.w),
                          const Text('Logout'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}
