class MediaState {
  final bool isPlaying;
  final String currentTrack;
  final String artist;
  final int volume; // 0-100
  final int position; // seconds
  final int duration; // seconds

  MediaState({
    this.isPlaying = false,
    this.currentTrack = 'Born to Run',
    this.artist = 'Bruce Springsteen',
    this.volume = 50,
    this.position = 145,
    this.duration = 223,
  });

  MediaState copyWith({
    bool? isPlaying,
    String? currentTrack,
    String? artist,
    int? volume,
    int? position,
    int? duration,
  }) {
    return MediaState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
      artist: artist ?? this.artist,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}
