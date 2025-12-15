class Song {
  final String title;
  final String artist;
  final String url;
  final String image;

  Song({
    required this.title,
    required this.artist,
    required this.url,
    required this.image,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      artist: json['artist'],
      url: json['url'],
      image: json['image'],
    );
  }
}
