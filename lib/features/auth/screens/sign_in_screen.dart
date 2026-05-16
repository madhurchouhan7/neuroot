import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';
import 'package:neuroot/features/auth/providers/auth_provider.dart';
import 'package:neuroot/shared/widgets/neuroot_widgets.dart';
import 'package:neuroot/shared/widgets/neuroot_network_image.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;
  bool _keepSignedIn = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please fill in both fields 🌱");
      return;
    }

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: email,
          password: password,
        );
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnack("Enter your email first, then tap Forgot Password 🌱");
      return;
    }
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (mounted) {
      _showSnack("Reset link sent! Check your inbox 🌱");
    }
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
    // Listen for error messages
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
                    onTap: () => context.push('/signup'),
                    child: Text('Create account', style: AppTypography.labelMedium(color: AppColors.primaryContainer)),
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
                        borderRadius: BorderRadius.circular(24),
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
                        borderRadius: BorderRadius.circular(24),
                        errorIcon: Icons.auto_awesome,
                      ),
                    ),
                    Text('Welcome back 🌱', style: AppTypography.titleXL(color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(
                      'Sprout missed you.',
                      style: AppTypography.mascotSpeech(color: const Color(0xFF8B8070)).copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 32),

                    // ── Email Field ──────────────────────────────────────
                    Text('EMAIL', style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
                    const SizedBox(height: 8),
                    _InputContainer(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.mail_outline, color: Color(0xFF8B8070), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _emailCtrl,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your email',
                                hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
                              ),
                              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !isLoading,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Password Field ────────────────────────────────────
                    Text('PASSWORD', style: AppTypography.labelSmall(color: const Color(0xFFB0A898))),
                    const SizedBox(height: 8),
                    _InputContainer(
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.lock_outline, color: Color(0xFF8B8070), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _passwordCtrl,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your password',
                                hintStyle: AppTypography.bodyMedium(color: const Color(0xFFB0A898)),
                              ),
                              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => isLoading ? null : _signIn(),
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: isLoading ? null : _forgotPassword,
                        child: Text('Forgot password?', style: AppTypography.labelSmall(color: AppColors.primaryContainer)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Remember Me ──────────────────────────────────────
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _keepSignedIn = !_keepSignedIn),
                          child: Container(
                            width: 40,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _keepSignedIn ? AppColors.primaryContainer : AppColors.softGrey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              alignment: _keepSignedIn ? Alignment.centerRight : Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Keep me signed in', style: AppTypography.labelMedium(color: const Color(0xFF5A5A5A))),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ── Sign In Button ────────────────────────────────────
                    NeurootButton(
                      label: isLoading ? 'Signing in…' : 'Sign In',
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
                      onTap: isLoading ? null : _signIn,
                    ),
                    const SizedBox(height: 24),

                    // ── Divider ───────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE8E0D4))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('or', style: AppTypography.labelSmall(color: const Color(0xFFC8C0B8))),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE8E0D4))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Google Sign In ────────────────────────────────────
                    GestureDetector(
                      onTap: isLoading ? null : _signInWithGoogle,
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

                    // ── Bottom Link ───────────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? Create one free",
                              style: AppTypography.labelSmall(color: const Color(0xFFB0A898)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 14, color: Color(0xFFB0A898)),
                          ],
                        ),
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
}

/// Shared styled input container used across auth screens.
class _InputContainer extends StatelessWidget {
  const _InputContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E0D4), width: 1.5),
      ),
      child: child,
    );
  }
}
