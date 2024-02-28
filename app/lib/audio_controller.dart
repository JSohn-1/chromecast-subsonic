import 'package:audio_service/audio_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'audio_local.dart';

class SystemAudioHandler extends BaseAudioHandler with SeekHandler {
  // Override the play method to send a resume signal to the socket
  @override
  Future<void> play() async {
    AudioControls.resume();
  }

  @override
  Future<void> pause() async {
    AudioControls.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    AudioControls.seek(position.inMilliseconds);
  }

  @override
  Future<void> skipToNext() async {
    AudioControls.skip();
  }

  @override
  Future<void> skipToPrevious() async {
    AudioControls.previous();
  }
}
