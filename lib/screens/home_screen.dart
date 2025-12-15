import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';
import '../services/music_api_service.dart';
import 'developers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  ConcatenatingAudioSource? _playlist;

  List<Song> _songs = [];
  int? _currentIndex;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _loadSongs();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _player.currentIndexStream.listen((index) {
      setState(() => _currentIndex = index);
    });

    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _animController.repeat(reverse: true);
      } else {
        _animController.stop();
        _animController.reset();
      }
    });
  }

  Future<void> _loadSongs() async {
    _songs = await MusicApiService.fetchSongs();

    _playlist = ConcatenatingAudioSource(
      children:
      _songs.map((s) => AudioSource.uri(Uri.parse(s.url))).toList(),
    );

    await _player.setAudioSource(_playlist!);
    await _player.setLoopMode(LoopMode.all);

    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _player.playing ? _player.pause() : _player.play();
  }

  Future<void> _playAt(int index) async {
    try {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load audio. Check internet or source.'),
        ),
      );
    }
  }


  Future<void> _seekForward() async {
    final d = _player.duration ?? Duration.zero;
    final p = _player.position + const Duration(seconds: 10);
    await _player.seek(p < d ? p : d);
  }

  Future<void> _seekBackward() async {
    final p = _player.position - const Duration(seconds: 10);
    await _player.seek(p > Duration.zero ? p : Duration.zero);
  }

  Future<void> _onRefresh() async => _loadSongs();

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'Guest';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Music',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Hi, $email',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DevelopersScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),

      body: _songs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          /// 🎵 SONG LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              color: Colors.deepPurpleAccent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _songs.length,
                itemBuilder: (context, index) {
                  final song = _songs[index];

                  return GestureDetector(
                    onTap: () => _playAt(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? Colors.deepPurpleAccent.withOpacity(0.25)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _currentIndex == index
                                ? _scaleAnim
                                : const AlwaysStoppedAnimation(1),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                song.image,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<PlayerState>(
                            stream:
                            _player.playerStateStream,
                            builder: (context, snapshot) {
                              final playing =
                                  snapshot.data?.playing ??
                                      false;
                              final isPlaying =
                                  _currentIndex == index &&
                                      playing;

                              return Icon(
                                isPlaying
                                    ? Icons.equalizer
                                    : Icons.play_arrow,
                                color:
                                Colors.deepPurpleAccent,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          /// 🎧 MINI PLAYER (Synced)
          if (_currentIndex != null)
            _miniPlayer(),
        ],
      ),
    );
  }

  Widget _miniPlayer() {
    final song = _songs[_currentIndex!];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ⏱ SEEK
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snap) {
              final pos = snap.data ?? Duration.zero;
              final dur = _player.duration ?? Duration.zero;

              return Slider(
                min: 0,
                max: dur.inSeconds.toDouble(),
                value: pos.inSeconds
                    .clamp(0, dur.inSeconds)
                    .toDouble(),
                activeColor: Colors.deepPurpleAccent,
                inactiveColor: Colors.grey[700],
                onChanged: (v) {
                  _player.seek(Duration(seconds: v.toInt()));
                },
              );
            },
          ),

          Row(
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.image,
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(song.artist,
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12)),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(Icons.replay_10,
                    color: Colors.white),
                onPressed: _seekBackward,
              ),

              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing =
                      snapshot.data?.playing ?? false;

                  return IconButton(
                    iconSize: 38,
                    icon: Icon(
                      playing
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlayPause,
                  );
                },
              ),

              IconButton(
                icon: const Icon(Icons.forward_10,
                    color: Colors.white),
                onPressed: _seekForward,
              ),

              IconButton(
                icon: const Icon(Icons.skip_next,
                    color: Colors.white),
                onPressed:
                _player.hasNext ? _player.seekToNext : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
