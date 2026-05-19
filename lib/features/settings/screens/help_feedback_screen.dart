import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuroot/core/theme/app_colors.dart';
import 'package:neuroot/core/theme/app_typography.dart';

class HelpFeedbackScreen extends ConsumerStatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  ConsumerState<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends ConsumerState<HelpFeedbackScreen> {
  String _feedbackType = '💡 Suggestion';
  int _rating = 3;
  bool _attachScreenshot = false;
  final TextEditingController _ctrl = TextEditingController();

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do I reset my attendance data?',
      'a': 'Go to Attendance → tap the subject → scroll to the bottom → \'Reset subject data\'. This cannot be undone.',
    },
    {
      'q': 'Can I use Bloom offline?',
      'a': 'Yes, most features work offline and sync when you reconnect.',
    },
    {
      'q': 'How does Sprout level up?',
      'a': 'Complete tasks and maintain attendance streaks to earn XP for Sprout.',
    },
    {
      'q': 'How do I change my timetable?',
      'a': 'Go to Settings → Timetable to edit or add new classes.',
    },
    {
      'q': 'How do I delete a subject?',
      'a': 'Go to Settings → Semester → Manage to remove subjects.',
    },
  ];
  
  int _expandedIndex = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text('Help & Feedback', style: AppTypography.titleSmall(color: AppColors.textPrimary)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Sprout Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Row(
                  children: [
                    const Text('🌱', style: TextStyle(fontSize: 48)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sprout is here to help!', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Can\'t find something? We\'ve got you covered.', style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Feedback Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0E8DC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send feedback', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
                    const SizedBox(height: 16),
                    
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['💡 Suggestion', '🐛 Bug report', '🙏 Appreciation'].map((type) {
                          final sel = _feedbackType == type;
                          return GestureDetector(
                            onTap: () => setState(() => _feedbackType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? AppColors.amber : const Color(0xFFFFF9F1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(type, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontSize: 12, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF0E8DC), width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _ctrl,
                        maxLines: null,
                        style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontSize: 13),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Tell Sprout what you think... What\'s working? What could be better?',
                          hintStyle: AppTypography.bodyMedium(color: const Color(0xFFC8C0B8)).copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Text('Rate your experience:', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () => setState(() => _rating = index + 1),
                              child: Icon(
                                index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: AppColors.amber,
                                size: 22,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Attach screenshot', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                            Text('Helps us understand bugs better', style: AppTypography.bodySmall(color: const Color(0xFFB0A898)).copyWith(fontSize: 11)),
                          ],
                        ),
                        Switch.adaptive(
                          value: _attachScreenshot,
                          onChanged: (v) => setState(() => _attachScreenshot = v),
                          activeThumbColor: AppColors.amber,
                          activeTrackColor: AppColors.amber.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.amber,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Feedback received! Thank you 🌱 Sprout appreciates it.', style: AppTypography.bodyMedium(color: AppColors.white)),
                              backgroundColor: AppColors.sageDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                          _ctrl.clear();
                        },
                        child: Text('Send Feedback →', style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('Frequently asked questions', style: AppTypography.titleSmall(color: AppColors.textPrimary).copyWith(fontSize: 15)),
              ),
              const SizedBox(height: 12),
              
              ..._faqs.asMap().entries.map((e) {
                final i = e.key;
                final faq = e.value;
                final exp = _expandedIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _expandedIndex = exp ? -1 : i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(faq['q']!, style: AppTypography.bodyMedium(color: AppColors.textPrimary).copyWith(fontWeight: FontWeight.w500, fontSize: 13))),
                            Icon(exp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: const Color(0xFF8B8070), size: 20),
                          ],
                        ),
                        if (exp) ...[
                          const SizedBox(height: 12),
                          Text(faq['a']!, style: AppTypography.bodySmall(color: const Color(0xFF8B8070)).copyWith(fontSize: 13, height: 1.4)),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Still stuck? Contact us ', style: AppTypography.bodyMedium(color: const Color(0xFF8B8070)).copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('support@bloomapp.in', style: AppTypography.bodyMedium(color: AppColors.amber).copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
