/// Voice input contract. [MockVoiceService] simulates live recognition so the
/// UI is fully testable. To go live, implement this with the `speech_to_text`
/// package (add RECORD_AUDIO permission) and yield partial results the same way.
abstract class VoiceService {
  Stream<String> listen();
}

class MockVoiceService implements VoiceService {
  static const _samples = [
    'show me a black backpack under 5000 rupees',
    'white sneakers for running',
    'wireless headphones under 20000',
  ];
  static int _i = 0;

  @override
  Stream<String> listen() async* {
    final words = _samples[_i++ % _samples.length].split(' ');
    await Future.delayed(const Duration(milliseconds: 900));
    final spoken = <String>[];
    for (final w in words) {
      spoken.add(w);
      yield spoken.join(' ');
      await Future.delayed(const Duration(milliseconds: 280));
    }
  }
}
