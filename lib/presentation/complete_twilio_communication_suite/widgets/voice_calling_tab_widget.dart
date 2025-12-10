import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/call.dart';
import '../../../services/call_service.dart';

class VoiceCallingTabWidget extends StatefulWidget {
  final CallService callService;

  const VoiceCallingTabWidget({Key? key, required this.callService})
      : super(key: key);

  @override
  State<VoiceCallingTabWidget> createState() => _VoiceCallingTabWidgetState();
}

class _VoiceCallingTabWidgetState extends State<VoiceCallingTabWidget> {
  List<Call> _recentCalls = [];
  bool _isLoading = true;
  String _dialedNumber = '';
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentCalls();
  }

  Future<void> _loadRecentCalls() async {
    try {
      final calls = await widget.callService.getCallHistory(limit: 20);
      setState(() {
        _recentCalls = calls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load call history')),
        );
      }
    }
  }

  void _makeCall() async {
    if (_dialedNumber.isEmpty) return;

    try {
      await widget.callService.createCall(
        callType: CallType.outgoing,
        fromNumber: '+1234567890',
        toNumber: _dialedNumber,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Initiating call to $_dialedNumber...')),
        );
      }

      setState(() => _dialedNumber = '');
      _numberController.clear();
      _loadRecentCalls();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRecentCalls,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialerCard(),
              SizedBox(height: 24.h),
              _buildRecentCallsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialerCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dialpad, color: Color(0xFF0066FF), size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                'Smart Dialer',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          TextField(
            controller: _numberController,
            onChanged: (value) => setState(() => _dialedNumber = value),
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter phone number',
              prefixIcon: Icon(Icons.phone, color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFF0066FF), width: 2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _dialedNumber.isNotEmpty ? _makeCall : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0066FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Make Call',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCallsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Calls',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
        SizedBox(height: 16.h),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : _recentCalls.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _recentCalls.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final call = _recentCalls[index];
                      return _buildCallHistoryCard(call);
                    },
                  ),
      ],
    );
  }

  Widget _buildCallHistoryCard(Call call) {
    final isIncoming = call.callType == CallType.incoming;
    final isMissed = call.callStatus == CallStatus.missed;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isMissed
                  ? Colors.red[50]
                  : isIncoming
                      ? Colors.green[50]
                      : Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncoming ? Icons.call_received : Icons.call_made,
              color: isMissed
                  ? Colors.red
                  : isIncoming
                      ? Colors.green
                      : Colors.blue,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.toNumber,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${call.callStatus.name.toUpperCase()} · ${_formatDuration(call.durationSeconds)}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Color(0xFF0066FF)),
            onPressed: () {
              setState(() => _dialedNumber = call.toNumber);
              _numberController.text = call.toNumber;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          children: [
            Icon(Icons.phone_disabled, size: 64.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'No recent calls',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Make your first call using the dialer above',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '0:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}
