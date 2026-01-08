import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/user_management_provider.dart';
import '../../widgets/error_screen.dart';
import '../../widgets/responsive/responsive_layout.dart';

class AdminUserListScreen extends ConsumerStatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  ConsumerState<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends ConsumerState<AdminUserListScreen> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final managementState = ref.watch(userManagementProvider);

    // Show loading indicator for operations
    if (managementState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Show loading overlay
      });
    }

    // Show success/error messages
    ref.listen(userManagementProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green.shade700,
          ),
        );
        ref.read(userManagementProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        ref.read(userManagementProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showCreateUserDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchAndFilter(),
          
          // Users list
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (error, stack) {
                if (isNetworkError(error)) {
                  return ErrorScreen.noInternet(
                    onRetry: () => ref.invalidate(allUsersProvider),
                  );
                }
                return ErrorScreen.generalError(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(allUsersProvider),
                );
              },
              data: (users) {
                // Apply filters
                final filteredUsers = users.where((user) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      user.email.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesRole = _roleFilter == 'all' || user.role == _roleFilter;
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return ErrorScreen.empty(
                    title: 'No users found',
                    message: _searchQuery.isNotEmpty 
                        ? 'Try adjusting your search or filters' 
                        : 'Add users to get started',
                    icon: Icons.people_outline,
                  );
                }

                return ResponsiveLayout(
                  mobileBody: _buildMobileList(filteredUsers),
                  desktopBody: _buildDesktopTable(filteredUsers),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Role filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Admin', 'admin'),
                const SizedBox(width: 8),
                _buildFilterChip('User', 'user'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _roleFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) => setState(() => _roleFilter = value),
      backgroundColor: AppTheme.surfaceContainer,
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  Widget _buildMobileList(List<UserEntity> users) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
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
            Expanded(
              child: Text(
                user.name.isNotEmpty ? user.name : 'Unnamed User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
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

  Widget _buildDesktopTable(List<UserEntity> users) {
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
            rows: users.map((user) {
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
                        Text(
                          user.name.isNotEmpty ? user.name : 'Unnamed',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ),
                  DataCell(Text(user.email, style: TextStyle(color: AppTheme.textSecondary))),
                  DataCell(
                    GestureDetector(
                      onTap: () => _showRoleChangeDialog(context, user),
                      child: Container(
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
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blueAccent),
                          onPressed: () => _showEditUserDialog(context, user),
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
                            user.name.isNotEmpty ? user.name : 'Unnamed User',
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
                  title: 'Edit User',
                  onTap: () {
                    Navigator.pop(context);
                    _showEditUserDialog(context, user);
                  },
                ),
                _buildBottomSheetOption(
                  icon: Icons.admin_panel_settings,
                  title: 'Change Role',
                  onTap: () {
                    Navigator.pop(context);
                    _showRoleChangeDialog(context, user);
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
        color: isDestructive ? Colors.red.shade300 : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red.shade300 : Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Create User', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  dropdownColor: AppTheme.surfaceContainer,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => selectedRole = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                final newUser = UserEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  email: emailController.text,
                  username: emailController.text.split('@').first,
                  role: selectedRole,
                  createdAt: DateTime.now(),
                );
                Navigator.pop(context);
                await ref.read(userManagementProvider.notifier).createUser(newUser);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserEntity user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit User', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = UserEntity(
                id: user.id,
                name: nameController.text,
                email: emailController.text,
                username: user.username,
                role: user.role,
                profileImageUrl: user.profileImageUrl,
                createdAt: user.createdAt,
              );
              Navigator.pop(context);
              await ref.read(userManagementProvider.notifier).updateUser(updatedUser);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(BuildContext context, UserEntity user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Role', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change role for ${user.name}',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedRole = 'user'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedRole == 'user' 
                              ? AppTheme.primary.withValues(alpha: 0.2)
                              : AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedRole == 'user'
                              ? Border.all(color: AppTheme.primary)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person, color: selectedRole == 'user' ? AppTheme.primary : AppTheme.textSecondary),
                            const SizedBox(height: 8),
                            Text('User', style: TextStyle(color: selectedRole == 'user' ? AppTheme.primary : Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedRole = 'admin'),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedRole == 'admin' 
                              ? AppTheme.primary.withValues(alpha: 0.2)
                              : AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: selectedRole == 'admin'
                              ? Border.all(color: AppTheme.primary)
                              : null,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.admin_panel_settings, color: selectedRole == 'admin' ? AppTheme.primary : AppTheme.textSecondary),
                            const SizedBox(height: 8),
                            Text('Admin', style: TextStyle(color: selectedRole == 'admin' ? AppTheme.primary : Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(userManagementProvider.notifier).updateUserRole(user.id, selectedRole);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.red.shade300),
            const SizedBox(width: 8),
            const Text('Delete User', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${user.name}"? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(userManagementProvider.notifier).deleteUser(user.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
