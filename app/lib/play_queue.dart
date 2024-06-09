import 'package:app/interfaces/song.dart';

class PlayQueue {
  List<Song> _songs = [];
  int _currentIndex = 0;

  PlayQueue(this._songs);

  List<Song> get songs => _songs;

  int get currentIndex => _currentIndex;

  Song get currentSong => _songs[_currentIndex];

  void next() {
    if (_currentIndex < _songs.length - 1) {
      _currentIndex++;
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
    }
  }
}