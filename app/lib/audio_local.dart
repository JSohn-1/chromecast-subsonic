import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:audio_service/audio_service.dart';

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

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}

// class MediaItem {
//   final String id;
//   final String title;
//   final String artist;
//   final String imageUrl;
//   final Duration duration;

//   MediaItem(this.id, this.title, this.artist, this.imageUrl, this.duration);
// }