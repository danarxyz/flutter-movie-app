import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/screen_utils.dart';
import '../../widgets/responsive/responsive_layout.dart';
import '../../../domain/entities/user_entity.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  // Demo users
  final List<UserEntity> _users = [
    const UserEntity(
      id: '1',
      name: 'Alex Moviebuff',
      email: 'alex@example.com',
      role: 'user',
    ),
    const UserEntity(
      id: '2',
      name: 'Sarah Cinema',
      email: 'sarah@example.com',
      role: 'user',
    ),
    const UserEntity(
      id: '3',
      name: 'Mike Director',
      email: 'mike@example.com',
      role: 'admin',
    ),
    const UserEntity(
      id: '4',
      name: 'Emily Reviewer',
      email: 'emily@example.com',
      role: 'user',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Add user
            },
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobileBody: _buildMobileList(),
        desktopBody: _buildDesktopTable(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppTheme.surfaceDark),
            dataRowColor: WidgetStateProperty.all(AppTheme.surfaceContainer),
            columnSpacing: 24,
            horizontalMargin: 24,
            columns: const [
              DataColumn(
                label: Text('User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
              DataColumn(
                label: Text('Email', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
              DataColumn(
                label: Text('Role', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
              DataColumn(
                label: Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ),
            ],
            rows: _users.map((user) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.surfaceDark,
                          ),
                          child: Icon(Icons.person, size: 20, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 12),
                        Text(user.name, style: const TextStyle(color: Colors.white)),
                      ],
                    )
                  ),
                  DataCell(Text(user.email, style: TextStyle(color: AppTheme.textSecondary))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.role == 'admin' 
                            ? AppTheme.primary.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: user.role == 'admin' ? AppTheme.primary : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blueAccent),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(context, user),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(UserEntity user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceDark,
          ),
          child: user.profileImageUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.profileImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, color: AppTheme.textSecondary),
                  ),
                )
              : Icon(Icons.person, color: AppTheme.textSecondary),
        ),
        title: Row(
          children: [
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (user.role == 'admin') ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Admin',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Icon(Icons.more_horiz, color: AppTheme.textSecondary),
        onTap: () => _showUserOptionsBottomSheet(context, user),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showUserOptionsBottomSheet(BuildContext context, UserEntity user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // User Info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.surfaceContainer,
                      ),
                      child: Icon(Icons.person, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Options
                _buildBottomSheetOption(
                  icon: Icons.edit,
                  title: 'Edit Details',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to edit screen
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.lock_reset,
                  title: 'Reset Password',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset email sent to ${user.email}'),
                        backgroundColor: AppTheme.surfaceContainer,
                      ),
                    );
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.delete,
                  title: 'Delete User',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, user);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.primary : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.primary : Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete User',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${user.name}? This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _users.removeWhere((u) => u.id == user.id);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.name} deleted'),
                    backgroundColor: AppTheme.surfaceContainer,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
