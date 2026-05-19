import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/user_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _collegeController;
  late TextEditingController _courseController;
  int _currentYear = 3; // 1 to 4
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userDocProvider).asData?.value;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _collegeController = TextEditingController(text: user?.college ?? 'VIT Pune');
    _courseController = TextEditingController(text: 'B.Tech CSE');
    
    void onChange() => setState(() => _hasChanges = true);
    _nameController.addListener(onChange);
    _collegeController.addListener(onChange);
    _courseController.addListener(onChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_hasChanges) return;
    
    await ref.read(userNotifierProvider.notifier).updateProfile({
      'displayName': _nameController.text.trim(),
      'college': _collegeController.text.trim(),
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated ✓ Looking good!', style: AppTypography.bodyMedium(color: AppColors.white)),
          backgroundColor: AppColors.sageDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userDocProvider).asData?.value;
    final initials = (user?.displayName ?? 'AS').split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    final email = user?.email ?? 'arjun@gmail.com';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8B8070), size: 14),
                const SizedBox(width: 4),
                Text('Settings', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
        ),
        title: Text('Edit Profile', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
        actions: [
          GestureDetector(
            onTap: _save,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Save',
                style: AppTypography.bodyMedium(
                  color: _hasChanges ? AppColors.amber : const Color(0xFFC8C0B8),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              
              // Avatar Edit
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(initials, style: AppTypography.titleLarge(color: AppColors.textPrimary).copyWith(fontSize: 28)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Take photo', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 12)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('|', style: TextStyle(color: Color(0xFFD1C5AE))),
                  ),
                  Text('Choose from gallery', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 12)),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Form Fields
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  children: [
                    _buildField(
                      label: 'FULL NAME',
                      child: TextField(
                        controller: _nameController,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                      trailing: Text('${_nameController.text.length} / 40', style: AppTypography.bodySmall(color: const Color(0xFFC8C0B8)).copyWith(fontSize: 11)),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'EMAIL',
                      child: Text(email, style: AppTypography.bodyMedium(color: AppColors.textSecondary)),
                      trailing: Text('Verified ✓', style: AppTypography.bodyMedium(color: const Color(0xFF4CAF82)).copyWith(fontWeight: FontWeight.w500, fontSize: 11)),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'COLLEGE',
                      child: TextField(
                        controller: _collegeController,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'COURSE',
                      child: TextField(
                        controller: _courseController,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                    const _Div(),
                    _buildField(
                      label: 'CURRENT YEAR',
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [1, 2, 3, 4].map((y) {
                            final sel = _currentYear == y;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentYear = y;
                                  _hasChanges = true;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.amber : const Color(0xFFF8F5F0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  ['1st', '2nd', '3rd', '4th'][y - 1],
                                  style: AppTypography.labelMedium(color: sel ? AppColors.textPrimary : const Color(0xFF8B8070)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Change Password
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF8B8070)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Change password →', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasChanges ? AppColors.amber : const Color(0xFFF5EFEB),
                    foregroundColor: _hasChanges ? AppColors.textPrimary : const Color(0xFFC8C0B8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _hasChanges ? _save : null,
                  child: Text('Save Changes', style: AppTypography.bodyMedium(color: _hasChanges ? AppColors.textPrimary : const Color(0xFFC8C0B8)).copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required Widget child, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall(color: const Color(0xFFB0A898)).copyWith(letterSpacing: 1.2, fontSize: 10),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: Color(0xFFF5EFE8));
}
