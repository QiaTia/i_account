import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  bool isPlaying = false;
  double currentProgress = 0.3; // 示例进度值
  int currentLyricIndex = 1; // 当前歌词行索引
  final Duration totalDuration = const Duration(minutes: 4, seconds: 59);
  
  final List<String> lyrics = [
    "When the night falls silent",
    "And the stars lose their way",
    "I'll be here waiting",
    "For the dawn of new day",
    "Fade before the dawn",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey!, Colors.black],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 专辑封面
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: NetworkImage(
                        "https://img.alicdn.com/imgextra/i3/O1CN01HKF8IE21NglxmBjwj_!!6000000006973-2-tps-456-502.png",
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 歌曲信息
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "fade before the dawn",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "joyful supplyment",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // 进度条
                LinearProgressIndicator(
                  value: currentProgress,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
                const SizedBox(height: 8),
                
                // 时间显示
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(totalDuration * currentProgress),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 歌词显示
                Expanded(
                  child: ListView.builder(
                    itemCount: lyrics.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          lyrics[index],
                          style: TextStyle(
                            color: index == currentLyricIndex 
                                ? Colors.white 
                                : Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                
                // 控制按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(FontAwesomeIcons.shuffle),
                    _buildControlButton(FontAwesomeIcons.backwardStep),
                    _buildPlayPauseButton(),
                    _buildControlButton(FontAwesomeIcons.forwardStep),
                    _buildControlButton(FontAwesomeIcons.repeat),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return IconButton(
      icon: FaIcon(icon),
      color: Colors.grey,
      iconSize: 24,
      onPressed: () {},
    );
  }

  Widget _buildPlayPauseButton() {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isPlaying
            ? const FaIcon(FontAwesomeIcons.pause, key: ValueKey('pause'))
            : const FaIcon(FontAwesomeIcons.play, key: ValueKey('play')),
      ),
      color: Colors.white,
      iconSize: 32,
      onPressed: () {
        setState(() {
          isPlaying = !isPlaying;
        });
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
