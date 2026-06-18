import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/auth_service.dart' show AuthException;
import '../../../core/services/profile_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/auth_provider.dart';
import '../profile_provider.dart';
import 'profile_edit_data.dart';
import 'steps/step_children.dart';
import 'steps/step_contact.dart';
import 'steps/step_mandal.dart';
import 'steps/step_personal.dart';
import 'steps/step_spouse.dart';

/// 5-step profile completion / edit flow.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _pageCtrl = PageController();
  final _data = ProfileEditData();
  final _stepKeys = List.generate(5, (_) => GlobalKey<FormState>());

  static const _titles = [
    'Personal Info', 'Contact & Address', 'Mandal & Role', 'Spouse Info', 'Children',
  ];

  int _step = 0;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(profileProvider.notifier).load();
      final bundle = ref.read(profileProvider).bundle;
      if (bundle != null && mounted) {
        setState(() {
          _data.prefill(bundle);
          _prefilled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _data.dispose();
    super.dispose();
  }

  bool get _isLast => _step == 4;

  void _goTo(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(step,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _next() async {
    final form = _stepKeys[_step].currentState;
    if (form != null && !form.validate()) return;

    if (!_isLast) {
      _goTo(_step + 1);
      return;
    }

    // Final step → save everything.
    setState(() => _saving = true);
    try {
      await ProfileService.instance.update(_data.toJson());

      // Role change request (only if changed away from current).
      final bundle = ref.read(profileProvider).bundle;
      if (_data.role != (bundle?.role ?? 'member')) {
        await ProfileService.instance.requestRole(_data.role);
      }

      await ref.read(authProvider.notifier).refreshProfileFlag();
      if (mounted) context.go('/dashboard');
    } on AuthException catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      StepPersonal(data: _data, onChanged: () => setState(() {})),
      StepContact(data: _data),
      StepMandal(data: _data, onChanged: () => setState(() {})),
      StepSpouse(data: _data, onChanged: () => setState(() {})),
      const StepChildren(),
    ];

    return PlatformScaffold(
      backgroundColor: AppColors.background,
      appBar: PlatformAppBar(
        title: Text('Complete your profile',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: AppColors.primary,
        material: (_, __) => MaterialAppBarData(
          foregroundColor: Colors.white,
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
      ),
      body: !_prefilled
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Step progress
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            for (int i = 0; i < 5; i++) ...[
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: i <= _step
                                        ? AppColors.primary
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              if (i < 4) const SizedBox(width: 6),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Step ${_step + 1} of 5 · ${_titles[_step]}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            if (_step == 3)
                              TextButton(
                                onPressed: () => _goTo(4),
                                child: Text('Skip',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Step content
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (int i = 0; i < 5; i++)
                          Form(key: _stepKeys[i], child: steps[i]),
                      ],
                    ),
                  ),
                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _saving ? null : () => _goTo(_step - 1),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _next,
                              child: _saving
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5, color: Colors.white))
                                  : Text(_isLast ? 'Complete Profile' : 'Next'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
