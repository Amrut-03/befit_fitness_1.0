import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/coach_delta.dart';
import '../../domain/entities/coach_message.dart';
import '../../domain/repositories/coach_repository.dart';
import '../../domain/services/coach_prompt_builder.dart';
import '../datasources/coach_cloud_datasource.dart';

class CoachRepositoryImpl implements CoachRepository {
  CoachRepositoryImpl({required this.onDevice, required this.cloud});

  final OnDeviceLlm onDevice;
  final CoachCloudDatasource cloud;

  @override
  Stream<CoachDelta> reply(String prompt) async* {
    if (await onDevice.status() == OnDeviceModelStatus.ready) {
      var answered = false;
      try {
        final tokens = await onDevice.generate(
          prompt,
          systemInstruction: CoachPromptBuilder.systemInstruction,
        );
        await for (final t in tokens) {
          answered = true;
          yield CoachDelta(t, CoachSource.onDevice);
        }
        if (answered) return;
      } catch (e) {
        // Mid-answer failures surface; failures before the first token
        // (engine couldn't load) fall back to the cloud.
        if (answered) rethrow;
        debugPrint('On-device coach failed, using cloud: $e');
      }
    }
    yield* cloud.stream(prompt).map((t) => CoachDelta(t, CoachSource.cloud));
  }
}
