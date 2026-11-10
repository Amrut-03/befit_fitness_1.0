import 'package:fitness_app/core/ai/gemma_on_device_llm.dart';
import 'package:fitness_app/core/ai/on_device_llm.dart';
import 'package:flutter_test/flutter_test.dart';

/// Only the gating that runs before the plugin is touched; the plugin itself
/// needs a device.
void main() {
  test('no URL means not configured', () async {
    final llm = GemmaOnDeviceLlm(modelUrl: '', isMobile: () => true);
    expect(await llm.status(), OnDeviceModelStatus.notConfigured);
    expect(llm.download, throwsA(isA<OnDeviceLlmUnavailable>()));
  });

  test('desktop and tests are unsupported', () async {
    final llm = GemmaOnDeviceLlm(
      modelUrl: 'https://example.com/gemma3-1b-it-int4.task',
      isMobile: () => false,
    );
    expect(await llm.status(), OnDeviceModelStatus.unsupported);
  });

  test('phones below the RAM floor are unsupported', () async {
    var reads = 0;
    final llm = GemmaOnDeviceLlm(
      modelUrl: 'https://example.com/gemma3-1b-it-int4.task',
      isMobile: () => true,
      memory: () async {
        reads++;
        return 3072;
      },
    );
    expect(await llm.status(), OnDeviceModelStatus.unsupported);
    expect(await llm.status(), OnDeviceModelStatus.unsupported);
    expect(reads, 1, reason: 'RAM is read once');
  });

  test('generate refuses when the model is unavailable', () async {
    final llm = GemmaOnDeviceLlm(modelUrl: '', isMobile: () => true);
    expect(() => llm.generate('hi'), throwsA(isA<OnDeviceLlmUnavailable>()));
  });

  test('model id is the file name', () {
    final llm = GemmaOnDeviceLlm(
      modelUrl:
          'https://firebasestorage.googleapis.com/v0/b/x/o/gemma3-1b-it-int4.task?alt=media&token=t',
    );
    expect(llm.modelId, 'gemma3-1b-it-int4.task');
  });

  test('a file inside a Storage folder is rejected as not configured', () async {
    for (final url in [
      'https://firebasestorage.googleapis.com/v0/b/x/o/models%2Fgemma.task?alt=media',
      'http://example.com/gemma.task',
      'https://example.com/gemma.litertlm',
    ]) {
      final llm = GemmaOnDeviceLlm(modelUrl: url, isMobile: () => true);
      expect(
        await llm.status(),
        OnDeviceModelStatus.notConfigured,
        reason: url,
      );
    }
  });
}
