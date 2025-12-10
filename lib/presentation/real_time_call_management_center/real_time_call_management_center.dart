import 'package:flutter/material.dart';

import '../../models/call.dart';
import '../../models/contact.dart';
import '../../services/call_service.dart';
import '../../services/messaging_service.dart';
import './widgets/active_call_controls_widget.dart';
import './widgets/call_history_item_widget.dart';
import './widgets/dialpad_widget.dart';

class RealTimeCallManagementCenter extends StatefulWidget {
  const RealTimeCallManagementCenter({super.key});

  @override
  State<RealTimeCallManagementCenter> createState() =>
      _RealTimeCallManagementCenterState();
}

class _RealTimeCallManagementCenterState
    extends State<RealTimeCallManagementCenter>
    with SingleTickerProviderStateMixin {
  final _callService = CallService();
  final _messagingService = MessagingService();
  late TabController _tabController;

  List<Call> _callHistory = [];
  List<Contact> _contacts = [];
  Call? _activeCall;
  bool _isLoading = true;
  String _dialedNumber = '';

  dynamic _callsChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _callsChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final callHistory = await _callService.getCallHistory();
      final contacts = await _messagingService.getContacts(''); // Add this - pass empty string as required argument

      if (mounted) {
        setState(() {
          _callHistory = callHistory;
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    }
  }

  void _setupRealtimeSubscription() {
    _callsChannel = _callService.subscribeToCallUpdates((call) {
      if (mounted) {
        setState(() {
          if (call.isActive) {
            _activeCall = call;
          } else {
            _activeCall = null;
          }
          _loadData(); // Refresh call history
        });
      }
    });
  }

  void _onNumberInput(String digit) {
    setState(() => _dialedNumber += digit);
  }

  void _onBackspace() {
    if (_dialedNumber.isNotEmpty) {
      setState(() =>
          _dialedNumber = _dialedNumber.substring(0, _dialedNumber.length - 1));
    }
  }

  Future<void> _makeCall() async {
    if (_dialedNumber.isEmpty) return;

    try {
      final call = await _callService.createCall(
        callType: CallType.outgoing,
        fromNumber: '', // Get from active phone number
        toNumber: _dialedNumber,
      );

      setState(() {
        _activeCall = call;
        _dialedNumber = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initiate call: $e')),
        );
      }
    }
  }

  void _onCallEnded() {
    setState(() => _activeCall = null);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeCall != null) {
      return ActiveCallControlsWidget(
        call: _activeCall!,
        onCallEnded: _onCallEnded,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFB347),
        title: const Text(
          'Phone',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Keypad'),
            Tab(text: 'Recents'),
            Tab(text: 'Contacts'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildKeypadTab(),
                _buildRecentsTab(),
                _buildContactsTab(),
              ],
            ),
    );
  }

  Widget _buildKeypadTab() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Dialed number display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Text(
            _dialedNumber.isEmpty ? 'Enter number' : _dialedNumber,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: _dialedNumber.isEmpty ? Colors.grey[400] : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),

        // Dialpad
        DialpadWidget(
          onNumberInput: _onNumberInput,
          onBackspace: _onBackspace,
        ),

        const SizedBox(height: 20),

        // Call button
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_dialedNumber.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: FloatingActionButton(
                    heroTag: 'backspace',
                    backgroundColor: Colors.grey[300],
                    onPressed: _onBackspace,
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.black87,
                    ),
                  ),
                ),
              FloatingActionButton(
                heroTag: 'call',
                backgroundColor: const Color(0xFF4CAF50),
                onPressed: _dialedNumber.isEmpty ? null : _makeCall,
                child: const Icon(
                  Icons.phone,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecentsTab() {
    if (_callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recent calls',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _callHistory.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final call = _callHistory[index];
          return CallHistoryItemWidget(
            call: call,
            onCallBack: () {
              setState(() => _dialedNumber = call.callType == CallType.incoming
                  ? call.fromNumber
                  : call.toNumber);
              _tabController.animateTo(0);
            },
          );
        },
      ),
    );
  }

  Widget _buildContactsTab() {
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No contacts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _contacts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: contact.avatarUrl != null
                ? NetworkImage(contact.avatarUrl!)
                : null,
            child: contact.avatarUrl == null
                ? Text(contact.fullName[0].toUpperCase())
                : null,
          ),
          title: Text(
            contact.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(contact.phoneNumber),
          trailing: IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF4CAF50)),
            onPressed: () {
              setState(() => _dialedNumber = contact.phoneNumber);
              _tabController.animateTo(0);
              _makeCall();
            },
          ),
        );
      },
    );
  }
}