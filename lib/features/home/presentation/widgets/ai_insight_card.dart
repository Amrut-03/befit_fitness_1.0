import 'package:fitness_app/core/widgets/app_loader.dart';
import 'package:fitness_app/features/ai_insights/presentation/bloc/ai_insights_bloc.dart';
import 'package:fitness_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class AIInsightsSection extends StatelessWidget {
  const AIInsightsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AIInsightsBloc, AIInsightsState>(
      builder: (context, state) {
        /// LOADING
        if (state is AIInsightsLoading) {
          return const AppLoader();
        }

        /// ERROR
        if (state is AIInsightsError) {
          return Text(state.message);
        }

        /// LOADED
        if (state is AIInsightsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Text(
                    "AI Insights",

                    style: TextStyle(
                      color: Colors.white,

                      fontSize: 18.sp,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(width: 8.w),

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,

                      vertical: 4.h,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF),

                      borderRadius: BorderRadius.circular(20.r),
                    ),

                    child: Text(
                      "AI",

                      style: TextStyle(
                        color: Colors.black,

                        fontSize: 11.sp,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              Column(
                children: state.insights.map((insight) {
                  return AIInsightCard(insight: insight);
                }).toList(),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
