import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_header.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/progress_report/presentation/bloc/weekly_report_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/water_intake/presentation/bloc/water_intake_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/coach_bloc.dart';
import '../coach_context_mapper.dart';
import '../cubit/on_device_model_cubit.dart';
import '../widgets/coach_message_bubble.dart';
import '../widgets/on_device_model_card.dart';

/// Chat with the AI coach, grounded in the user's own data.
class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  static const suggestions = [
    'How am I doing this week?',
    'How can I hit my protein goal?',
    'Plan a 30-minute workout for today',
    'What should I eat after a workout?',
  ];

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<OnDeviceModelCubit>().check();
    // Load the data the coach is grounded in, if Home hasn't yet.
    final report = context.read<WeeklyReportBloc>();
    if (report.state.status == ReportStatus.initial) {
      report.add(const WeeklyReportRequested());
    }
    final water = context.read<WaterIntakeBloc>();
    if (water.state.status == WaterStatus.initial) {
      water.add(const WaterIntakeStarted());
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final question = (text ?? _input.text).trim();
    if (question.isEmpty) return;
    final c = context;
    c.read<CoachBloc>().add(
      CoachQuestionSubmitted(
        question,
        coachContextFrom(
          profile: c.read<ProfileBloc>().state,
          health: c.read<HealthBloc>().state,
          streak: c.read<StreakBloc>().state,
          water: c.read<WaterIntakeBloc>().state,
          report: c.read<WeeklyReportBloc>().state,
        ),
      ),
    );
    _input.clear();
    FocusScope.of(context).unfocus();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _confirmDeleteModel() async {
    final cubit = context.read<OnDeviceModelCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove on-device model?'),
        content: const Text(
          'This frees up storage. The coach will use cloud AI until you download the model again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final modelReady = context.select<OnDeviceModelCubit, bool>(
      (c) => c.state.isReady,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'AI Coach',
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (v) => switch (v) {
              'clear' => context.read<CoachBloc>().add(const CoachCleared()),
              'model' => _confirmDeleteModel(),
              _ => null,
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear', child: Text('Clear chat')),
              if (modelReady)
                const PopupMenuItem(
                  value: 'model',
                  child: Text('Remove on-device model'),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<CoachBloc, CoachState>(
                listener: (_, _) => _scrollToEnd(),
                builder: (context, state) => ListView(
                  controller: _scroll,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
                  children: [
                    const OnDeviceModelCard(),
                    if (state.messages.isEmpty)
                      _Welcome(onPick: _send)
                    else
                      for (final (i, m) in state.messages.indexed)
                        CoachMessageBubble(
                          message: m,
                          streaming:
                              state.generating &&
                              i == state.messages.length - 1,
                        ),
                  ],
                ),
              ),
            ),
            _Composer(controller: _input, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.onPick});

  final void Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask me anything about training, food or recovery.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'I use your profile, today\'s activity and this week\'s report to tailor answers. General guidance, not medical advice.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final s in CoachPage.suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => onPick(s),
                  backgroundColor: AppColors.surface,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.sp,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final generating = context.select<CoachBloc, bool>(
      (b) => b.state.generating,
    );
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDim,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              maxLength: 500,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => generating ? null : onSend(),
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'Ask your coach…',
                counterText: '',
                isDense: true,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 10.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          generating
              ? IconButton(
                  tooltip: 'Stop',
                  onPressed: () =>
                      context.read<CoachBloc>().add(const CoachStopRequested()),
                  icon: const Icon(Icons.stop_circle_outlined),
                  color: AppColors.accentPink,
                )
              : IconButton(
                  tooltip: 'Send',
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded),
                  color: AppColors.primary,
                ),
        ],
      ),
    );
  }
}
