import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_bloc.dart';
import 'package:fitness_app/features/health/presentation/bloc/health_state.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_bloc.dart';
import 'package:fitness_app/features/streak/presentation/bloc/streak_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home-screen AI insights, fed by real health, streak and profile data.
///
/// It requests insights once those inputs are loaded. The repository serves
/// them from a daily cache, so Gemini is called at most once per day per user.
class AIInsightsSection extends StatefulWidget {
  const AIInsightsSection({super.key});

  @override
  State<AIInsightsSection> createState() => _AIInsightsSectionState();
}

class _AIInsightsSectionState extends State<AIInsightsSection> {
  static const _accent = AppColors.primary;
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  /// Builds the request from the current blocs, or null if inputs aren't
  /// ready yet.
  LoadAIInsightsEvent? _buildRequest({bool forceRefresh = false}) {
    final health = context.read<HealthBloc>().state;
    final streak = context.read<StreakBloc>().state;
    final profile = context.read<ProfileBloc>().state;

    if (profile is! ProfileLoaded || streak.isLoading) return null;
    if (health is! HealthLoaded && health is! HealthError) return null;

    final p = profile.profile;
    final heightM = p.height / 100;
    final bmi = heightM > 0 ? p.weight / (heightM * heightM) : 0.0;
    final data = health is HealthLoaded ? health.data : null;

    return LoadAIInsightsEvent(
      steps: data?.steps ?? 0,
      calories: data?.calories.round() ?? 0,
      streak: streak.currentStreak,
      bmi: bmi,
      forceRefresh: forceRefresh,
    );
  }

  void _maybeLoad() {
    if (_requested || !mounted) return;
    final request = _buildRequest();
    if (request == null) return;
    _requested = true;
    context.read<AIInsightsBloc>().add(request);
  }

  void _retry() {
    final request = _buildRequest(forceRefresh: true);
    if (request != null) context.read<AIInsightsBloc>().add(request);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HealthBloc, HealthState>(listener: (_, _) => _maybeLoad()),
        BlocListener<StreakBloc, StreakState>(listener: (_, _) => _maybeLoad()),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (_, _) => _maybeLoad(),
        ),
      ],
      child: BlocBuilder<AIInsightsBloc, AIInsightsState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: 18.h),
              if (state is AIInsightsLoaded)
                ...state.insights.map((i) => AIInsightCard(insight: i))
              else if (state is AIInsightsError)
                _message(
                  icon: state.offline ? Icons.wifi_off : Icons.error_outline,
                  text: state.message,
                  onRetry: _retry,
                )
              else
                _loading(),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Text(
          'AI Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'AI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loading() {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          height: 72.h,
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24.r),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: _accent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _message({
    required IconData icon,
    required String text,
    required VoidCallback onRetry,
  }) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white70, fontSize: 13.sp),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: _accent)),
          ),
        ],
      ),
    );
  }
}
