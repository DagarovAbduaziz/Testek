import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeVideoPage extends StatefulWidget {
  @override
  _YouTubeVideoPageState createState() => _YouTubeVideoPageState();
}

class _YouTubeVideoPageState extends State<YouTubeVideoPage> {
  bool _isVideoVisible = false;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _youtubeController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://youtu.be/5J_pnqFnV1E?si=dpIMBRTr6mpESxYa',
      )!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ilovadan foydalanish'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isVideoVisible = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // YouTube red color
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill, size: 28, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Video',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            if (_isVideoVisible)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _youtubeController,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text(
                  'Tugmani bosing va videoni ko\'ring!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  ),
  home: YouTubeVideoPage(),
));
