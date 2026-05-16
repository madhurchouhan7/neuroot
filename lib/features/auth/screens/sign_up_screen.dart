import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  bool _obscureText = true;

  // Simple password strength: 0–3
  int get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.length < 6) return 0;
    int score = 1;
    if (p.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) score++;
    return score;
  }

  String get _strengthLabel {
    switch (_passwordStrength) {
      case 0:
        return 'Too short';
      case 1:
        return 'Weak';
      case 2:
        return 'Good';
      case 3:
        return 'Strong';
      default:
        return '';
    }
  }

  Color get _strengthColor {
    switch (_passwordStrength) {
      case 0:
        return AppColors.dangerSoftRed;
      case 1:
        return AppColors.warningAmber;
      case 2:
        return AppColors.amber;
      case 3:
        return AppColors.sageDark;
      default:
        return AppColors.softGrey;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _collegeCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack("Please fill in your name, email, and password 🌱");
      return;
    }
    if (password.length < 6) {
      _showSnack("Password needs at least 6 characters 🌱");
      return;
    }

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: email,
          password: password,
          displayName: name,
        );
  }

  Future<void> _signUpWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTypography.bodyMedium(color: AppColors.white)),
        backgroundColor: AppColors.sageDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen for errors
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        _showSnack(next.errorMessage!);
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 20, color: Color(0xFF8B8070)),
                        const SizedBox(width: 4),
                        Text('Back', style: AppTypography.labelMedium(color: const Color(0xFF8B8070))),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushReplacement('/signin'),
                    child: Text('Sign in', style: AppTypography.labelMedium(color: AppColors.primaryContainer)),
                  ),
                ],
              ),
            ),

            // ── Main Content ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: NeurootNetworkImage(
                        url: 'https://lh3.googleusercontent.com/aida/ADBb0ujE3v5hUHYhCPDB2-5hDnxptj0zxlNSCq4qEovHnTz6N6vYmEXSN01Jcd_5PXdu1aszkTf9J8u0E2aW2txy56SuoejlRsJMK8Kdl-xP8i_GR1CbRHZq6K0IeQJ9Y2SxZiU2B8EAL8L9BVC3FDYuS61eHmuVPSlSfMA7p8j6NGgm-z6kcD6Qz34brbYVE24W7W2oRbB0SVmJ35aR6hPxOZXUrx_44soMUsmeN2w_cOPagzQjl3u7QcqmKg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(12),
                        errorIcon: Icons.auto_awesome,
                      ),
                    ),
                    Text(
                      'Join Neuroot 🌱',
                      style: AppTypography.titleXL(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Free forever. No credit card. Just growth.',
                      style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)),
                    ),
                    const SizedBox(height: 32),

                    // ── Name Field ───────────────────────────────────────
                    _buildInputField(
                      label: 'YOUR NAME',
                      icon: Icons.person_outline,
                      hint: 'e.g. Arjun Sharma',
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // ── Email Field ───────────────────────────────────────
                    _buildInputField(
                      label: 'EMAIL',
                      icon: Icons.mail_outline,
                      hint: 'your@email.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // ── Password Field ─────────────────────────────────────
                    Text('PASSWORD', style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
                    const SizedBox(height: 8),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.lock_outline, color: Color(0xFF8B8070), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscureText,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Make it strong!',
                                hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
                              ),
                              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                              textInputAction: TextInputAction.next,
                              enabled: !isLoading,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _obscureText = !_obscureText),
                            child: Icon(
                              _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: const Color(0xFF8B8070),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password Strength
                    if (_passwordCtrl.text.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E0D4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: (_passwordStrength / 3).clamp(0.05, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _strengthColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(_strengthLabel, style: AppTypography.labelSmall(color: _strengthColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 8),

                    // ── College (optional) ─────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('YOUR COLLEGE (optional)', style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
                        GestureDetector(
                          onTap: () => _collegeCtrl.clear(),
                          child: Text('Skip', style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(
                      label: '',
                      icon: Icons.account_balance_outlined,
                      hint: 'e.g. IIT Bombay, VIT Pune',
                      controller: _collegeCtrl,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => isLoading ? null : _signUp(),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),

                    // ── Divider ───────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE8E0D4))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or sign up with', style: AppTypography.labelSmall(color: const Color(0xFFC8C0B8))),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE8E0D4))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Google Sign Up ────────────────────────────────────
                    GestureDetector(
                      onTap: isLoading ? null : _signUpWithGoogle,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: isLoading ? AppColors.softGrey : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeurootNetworkImage(
                              url: 'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorIcon: Icons.g_mobiledata,
                              placeholderColor: Colors.transparent,
                            ),
                            const SizedBox(width: 12),
                            Text('Continue with Google', style: AppTypography.buttonMedium(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Create Account Button ─────────────────────────────
                    NeurootButton(
                      label: isLoading ? 'Creating account…' : 'Create My Account',
                      backgroundColor: AppColors.primaryContainer,
                      textColor: AppColors.textPrimary,
                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Icon(Icons.arrow_forward, size: 20, color: AppColors.textPrimary),
                      onTap: isLoading ? null : _signUp,
                    ),
                    const SizedBox(height: 24),

                    // Footer
                    Center(
                      child: Text(
                        'By signing up, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall(color: const Color(0xFFC8C0B8)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
          const SizedBox(height: 8),
        ],
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? AppColors.white : AppColors.softGrey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: const Color(0xFF8B8070), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
                  ),
                  style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  onSubmitted: onSubmitted,
                  enabled: enabled,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }
}
