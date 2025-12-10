import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/call_service.dart';
import '../../services/video_conference_service.dart';
import './widgets/two_factor_auth_tab_widget.dart';
import './widgets/video_conference_tab_widget.dart';
import './widgets/voice_calling_tab_widget.dart';

class CompleteTwilioCommunicationSuite extends StatefulWidget {
  const CompleteTwilioCommunicationSuite({Key? key}) : super(key: key);

  @override
  State<CompleteTwilioCommunicationSuite> createState() =>
      _CompleteTwilioCommunicationSuiteState();
}

class _CompleteTwilioCommunicationSuiteState
    extends State<CompleteTwilioCommunicationSuite>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CallService _callService = CallService();
  final VideoConferenceService _videoService = VideoConferenceService();

  int _missedCallsCount = 0;
  int _activeSessionsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _callService.getCallStatistics();
      final sessions = await _videoService.getActiveVideoSessions();

      setState(() {
        _missedCallsCount = stats['missed'] ?? 0;
        _activeSessionsCount = sessions.length;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _videoService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Twilio Communication Suite',
              style: TextStyle(
                color: Colors.grey[900],
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Voice · Video · Verify',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon:
                    Icon(Icons.notifications_outlined, color: Colors.grey[700]),
                onPressed: () {},
              ),
              if (_missedCallsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_missedCallsCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Color(0xFF0066FF),
              indicatorWeight: 3,
              labelColor: Color(0xFF0066FF),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.phone),
                  text: 'Voice Calls',
                ),
                Tab(
                  icon: Icon(Icons.video_call),
                  text: 'Video',
                  iconMargin: EdgeInsets.only(bottom: 4.h),
                ),
                Tab(
                  icon: Icon(Icons.verified_user),
                  text: '2FA Verify',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          VoiceCallingTabWidget(callService: _callService),
          VideoConferenceTabWidget(videoService: _videoService),
          TwoFactorAuthTabWidget(),
        ],
      ),
    );
  }
}
