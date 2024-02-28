import 'package:socket_io_client/socket_io_client.dart' as IO;

class AudioControls {
  static IO.Socket? socket;

  static void play() {
    socket!.emit('play');
  }

  static void pause() {
    socket!.emit('pause');
  }

  static void resume() {
    socket!.emit('resume');
  }

  static void skip() {
    socket!.emit('skip');
  }

  static void previous() {
    socket!.emit('previous');
  }

  static void seek(int position) {
    socket!.emit('seek', position);
  }

}