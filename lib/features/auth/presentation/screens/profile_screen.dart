import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/auth/presentation/widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _customUrlController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedAvatarUrl;
  bool _isCustomAvatarMode = false;
  bool _isPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _presetAvatars = const [
    'assets/images/8b4635fd93dc6e874f686435da83a210.jpg',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Felix',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Aneka',
    'https://api.dicebear.com/7.x/bottts/png?seed=Buster',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Lily',
    'https://api.dicebear.com/7.x/lorelei/png?seed=Maya',
    'https://api.dicebear.com/7.x/open-peeps/png?seed=Gizmo',
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewmodel>().currentUser;
    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _selectedAvatarUrl = user?.photoUrl;
    _customUrlController = TextEditingController(
      text: (user?.photoUrl != null &&
              user!.photoUrl!.startsWith('http') &&
              !_presetAvatars.contains(user.photoUrl))
          ? user.photoUrl
          : '',
    );
    _isCustomAvatarMode = _customUrlController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _customUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewmodel>();
    final newPassword = _newPasswordController.text;
    final currentPassword = _currentPasswordController.text;

    final avatarUrl = _isCustomAvatarMode
        ? _customUrlController.text.trim()
        : _selectedAvatarUrl;

    final error = await authViewModel.updateProfile(
      fullName: _fullNameController.text.trim(),
      photoUrl: avatarUrl,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
      currentPassword: currentPassword.isNotEmpty ? currentPassword : null,
    );

    if (error == null) {
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewmodel>();
    final user = authViewModel.currentUser;
    final isLoading = authViewModel.isLoading;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    // Check if signed in with Google
    final isGoogleUser = user?.email.endsWith('@gmail.com') == true &&
        (user?.photoUrl?.contains('googleusercontent') == true ||
            authViewModel.currentUser?.photoUrl == null); 

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Selection Section
                    _buildAvatarSection(theme, ext, isDark, isLoading),
                    const SizedBox(height: 32),

                    // User Info Section
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Info',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Full Name'),
                          TextFormField(
                            controller: _fullNameController,
                            style: TextStyle(color: theme.colorScheme.onSurface),
                            decoration: _buildInputDecoration(
                              hintText: 'Enter your full name',
                              icon: Icons.person_outline,
                              theme: theme,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildLabel('Email Address (Disabled)'),
                          TextFormField(
                            initialValue: user?.email ?? '',
                            enabled: false,
                            style: TextStyle(color: ext.subtext),
                            decoration: _buildInputDecoration(
                              hintText: '',
                              icon: Icons.email_outlined,
                              theme: theme,
                            ).copyWith(
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.black.withValues(alpha: 0.02),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password Settings Section
                    _buildPasswordSection(theme, ext, isGoogleUser, isDark),
                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildAvatarSection(ThemeData theme, AppThemeExtension ext, bool isDark, bool isLoading) {
    final avatarUrl = _isCustomAvatarMode ? _customUrlController.text : _selectedAvatarUrl;

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: UserAvatar(
                  photoUrl: avatarUrl,
                  radius: 54,
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Presets'),
              selected: !_isCustomAvatarMode,
              onSelected: (val) {
                setState(() {
                  _isCustomAvatarMode = false;
                });
              },
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: !_isCustomAvatarMode ? AppColors.accent : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('Custom URL'),
              selected: _isCustomAvatarMode,
              onSelected: (val) {
                setState(() {
                  _isCustomAvatarMode = true;
                });
              },
              selectedColor: AppColors.accent.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: _isCustomAvatarMode ? AppColors.accent : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_isCustomAvatarMode)
          Container(
            height: 80,
            alignment: Alignment.center,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _presetAvatars.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final preset = _presetAvatars[index];
                final isSelected = _selectedAvatarUrl == preset;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarUrl = preset;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.accent : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: UserAvatar(
                      photoUrl: preset,
                      radius: 28,
                    ),
                  ),
                );
              },
            ),
          )
        else
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Avatar Image URL'),
                TextFormField(
                  controller: _customUrlController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: _buildInputDecoration(
                    hintText: 'https://example.com/avatar.png',
                    icon: Icons.link,
                    theme: theme,
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordSection(ThemeData theme, AppThemeExtension ext, bool isGoogleUser, bool isDark) {
    if (isGoogleUser) {
      return GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.g_mobiledata_rounded, color: Colors.blue, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linked with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Password management is securely handled by Google.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ext.subtext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          _buildLabel('Current Password'),
          TextFormField(
            controller: _currentPasswordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: _buildInputDecoration(
              hintText: 'Required if changing password',
              icon: Icons.lock_outline,
              theme: theme,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: ext.subtext,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            validator: (val) {
              if (_newPasswordController.text.isNotEmpty && (val == null || val.isEmpty)) {
                return 'Current password is required to set a new password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('New Password'),
          TextFormField(
            controller: _newPasswordController,
            obscureText: !_isNewPasswordVisible,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: _buildInputDecoration(
              hintText: 'At least 6 characters',
              icon: Icons.lock_outline,
              theme: theme,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: ext.subtext,
                ),
                onPressed: () {
                  setState(() {
                    _isNewPasswordVisible = !_isNewPasswordVisible;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val != null && val.isNotEmpty && val.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Confirm New Password'),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: _buildInputDecoration(
              hintText: 'Retype new password',
              icon: Icons.lock_outline,
              theme: theme,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: ext.subtext,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            validator: (val) {
              if (_newPasswordController.text.isNotEmpty && val != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
