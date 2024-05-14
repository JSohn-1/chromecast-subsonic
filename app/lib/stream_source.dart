import 'package:just_audio/just_audio.dart';

class AudioStreamSource extends StreamAudioSource {
  final List<int> _data;
  AudioStreamSource(this._data);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _data.length;

    return StreamAudioResponse(
      sourceLength: _data.length,
      contentLength: _data.length,
      offset: start,
      contentType: 'audio/mpeg',
      stream: Stream.value(_data.sublist(start, end)),
    );
  }
}