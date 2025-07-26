import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  // Dummy contact data
  final List<Contact> _contacts = [
    Contact('Alice Johnson', '+1 (555) 123-4567', false),
    Contact('Bob Smith', '+1 (555) 234-5678', false),
    Contact('Carol Williams', '+1 (555) 345-6789', true),
    Contact('David Brown', '+1 (555) 456-7890', false),
    Contact('Emma Davis', '+1 (555) 567-8901', false),
    Contact('Frank Miller', '+1 (555) 678-9012', true),
    Contact('Grace Wilson', '+1 (555) 789-0123', false),
    Contact('Henry Moore', '+1 (555) 890-1234', false),
    Contact('Isabella Taylor', '+1 (555) 901-2345', false),
    Contact('Jack Anderson', '+1 (555) 012-3456', false),
  ];

  final String _inviteMessage = 'Hey! I\'m using Knowble to learn amazing courses. Join me and start your learning journey today! Download the app: https://knowble.app';

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Invite Friends',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderSubtle,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search contacts...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                      ),
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Contacts list
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.borderSubtle,
                    width: 1,
                  ),
                ),
                elevation: 2,
                shadowColor: AppTheme.shadowLight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.contacts,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Contacts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_contacts.length} contacts',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _contacts.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppTheme.borderSubtle,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          return _buildContactTile(contact, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Share invite via section
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.surfaceWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.borderSubtle,
                    width: 1,
                  ),
                ),
                elevation: 2,
                shadowColor: AppTheme.shadowLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.share,
                            color: AppTheme.primaryTeal,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share Invite Via',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSocialButton(
                            icon: Icons.facebook,
                            label: 'Facebook',
                            color: const Color(0xFF1877F2),
                            onTap: () => _shareVia('Facebook'),
                          ),
                          _buildSocialButton(
                            icon: Icons.alternate_email,
                            label: 'Twitter',
                            color: const Color(0xFF1DA1F2),
                            onTap: () => _shareVia('Twitter'),
                          ),
                          _buildSocialButton(
                            icon: Icons.email,
                            label: 'Gmail',
                            color: const Color(0xFFEA4335),
                            onTap: () => _shareVia('Gmail'),
                          ),
                          _buildSocialButton(
                            icon: Icons.chat,
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            onTap: () => _shareVia('WhatsApp'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(Contact contact, int index) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.accentLight,
            child: Text(
              contact.name[0].toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phoneNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            height: 32,
            child: ElevatedButton(
              onPressed: contact.isInvited 
                  ? null 
                  : () => _inviteContact(contact, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: contact.isInvited 
                    ? AppTheme.borderSubtle 
                    : AppTheme.primaryTeal,
                foregroundColor: contact.isInvited 
                    ? AppTheme.textSecondary 
                    : AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: contact.isInvited ? 0 : 2,
              ),
              child: Text(
                contact.isInvited ? 'Sent' : 'Invite',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: contact.isInvited 
                      ? AppTheme.textSecondary 
                      : AppTheme.surfaceWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.lightTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _inviteContact(Contact contact, int index) {
    setState(() {
      _contacts[index] = Contact(contact.name, contact.phoneNumber, true);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to ${contact.name}'),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    // Simulate sending invite (in real app, this would be an API call)
    _sendInvite(contact);
  }

  void _sendInvite(Contact contact) {
    // In a real app, you would send an SMS or use a messaging API
    // For now, we'll just copy the invite message to clipboard
    Clipboard.setData(ClipboardData(text: _inviteMessage));
  }

  void _shareVia(String platform) {
    // Copy invite message to clipboard for sharing
    Clipboard.setData(ClipboardData(text: _inviteMessage));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite message copied to clipboard! Share it via $platform.'),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class Contact {
  final String name;
  final String phoneNumber;
  final bool isInvited;

  Contact(this.name, this.phoneNumber, this.isInvited);
}
