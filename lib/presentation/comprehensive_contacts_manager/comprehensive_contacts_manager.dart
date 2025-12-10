import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/contact.dart';
import '../../services/supabase_service.dart';
import './widgets/add_contact_dialog_widget.dart';
import './widgets/contact_card_widget.dart';
import './widgets/contact_groups_widget.dart';
import './widgets/favorites_section_widget.dart';
import './widgets/search_bar_widget.dart';

class ComprehensiveContactsManager extends StatefulWidget {
  const ComprehensiveContactsManager({super.key});

  @override
  State<ComprehensiveContactsManager> createState() =>
      _ComprehensiveContactsManagerState();
}

class _ComprehensiveContactsManagerState
    extends State<ComprehensiveContactsManager> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  List<Contact> _favoriteContacts = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Favorites',
    'Work',
    'Family',
    'Friends'
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to view contacts')),
          );
        }
        return;
      }

      final response = await _supabaseService.client
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('full_name', ascending: true);

      final contacts =
          (response as List).map((json) => Contact.fromJson(json)).toList();

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _favoriteContacts = contacts.where((c) => c.isFavorite).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e')),
        );
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _allContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.fullName.toLowerCase().contains(query.toLowerCase()) ||
              contact.phoneNumber.contains(query) ||
              (contact.email?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'All') {
        _filteredContacts = _allContacts;
      } else if (filter == 'Favorites') {
        _filteredContacts = _favoriteContacts;
      } else {
        _filteredContacts = _allContacts.where((contact) {
          return contact.tags.contains(filter.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _toggleFavorite(Contact contact) async {
    try {
      await _supabaseService.client
          .from('contacts')
          .update({'is_favorite': !contact.isFavorite}).eq('id', contact.id);

      await _loadContacts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              contact.isFavorite
                  ? 'Removed from favorites'
                  : 'Added to favorites',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorite: $e')),
        );
      }
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Delete ${contact.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.client
            .from('contacts')
            .delete()
            .eq('id', contact.id);

        await _loadContacts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting contact: $e')),
          );
        }
      }
    }
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AddContactDialogWidget(
        onContactAdded: _loadContacts,
      ),
    );
  }

  Map<String, List<Contact>> _groupContactsByInitial() {
    final grouped = <String, List<Contact>>{};
    for (final contact in _filteredContacts) {
      final initial =
          contact.fullName.isNotEmpty ? contact.fullName[0].toUpperCase() : '#';
      grouped.putIfAbsent(initial, () => []).add(contact);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupedContacts = _groupContactsByInitial();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _loadContacts,
            tooltip: 'Sync contacts',
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onChanged: _filterContacts,
          ),
          ContactGroupsWidget(
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            onFilterSelected: _applyFilter,
          ),
          if (_favoriteContacts.isNotEmpty && _selectedFilter == 'All')
            FavoritesSectionWidget(
              favorites: _favoriteContacts,
              onFavoriteToggle: _toggleFavorite,
              onDelete: _deleteContact,
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contacts_outlined,
                                size: 80.h, color: Colors.grey),
                            SizedBox(height: 16.h),
                            Text(
                              'No contacts found',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.grey),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Add your first contact',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: groupedContacts.length,
                        itemBuilder: (context, index) {
                          final initial = groupedContacts.keys.elementAt(index);
                          final contacts = groupedContacts[initial]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                child: Text(
                                  initial,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ),
                              ...contacts.map(
                                (contact) => ContactCardWidget(
                                  contact: contact,
                                  onFavoriteToggle: () =>
                                      _toggleFavorite(contact),
                                  onDelete: () => _deleteContact(contact),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddContactDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
    );
  }
}