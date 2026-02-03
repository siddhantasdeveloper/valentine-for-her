import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Provides ImageFilter

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:html' as html;

void main() => runApp(const MaterialApp(home: PremiumValentine(), debugShowCheckedModeBanner: false));

class PremiumValentine extends StatefulWidget {
  const PremiumValentine({super.key});

  @override
  State<PremiumValentine> createState() => _PremiumValentineState();
}

class _PremiumValentineState extends State<PremiumValentine> with TickerProviderStateMixin {
  bool isAccepted = false;
  double noTop = 0, noLeft = 0;
  double yesScale = 1.0;
  String name = "Sweetheart";
  int hoverCount = 0;

  // Inside your State class
  final player = AudioPlayer();

  late AnimationController _rainController;
  final List<HeartPath> _heartRain = List.generate(40, (i) => HeartPath());

  final List<String> guiltTexts = ["No", "Are you sure?", "Pookie please...", "Don't be mean!", "I'm crying..", "Broken heart :(", "Click the big YES!", "Give up!"];

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    // High-compatibility URL parser
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fullUrl = Uri.base.toString(); // Gets the entire string including hashes
      if (fullUrl.contains("name=")) {
        setState(() {
          // Simple manual split to bypass Hash/Path strategy issues
          name = fullUrl.split("name=").last.split("&").first;
          // Decode URL encoding (e.g., %20 to space)
          name = Uri.decodeComponent(name);
        });
      }
    });
  }

  FutureOr<void> _onYes() async {
    setState(() => isAccepted = true);
    _rainController.repeat();

    await player.setAsset('assets/audio/my_valentine_song.mpeg');
    player.play();
    Future.delayed(const Duration(seconds: 20), () => _launchWhatsApp());
  }

  void _launchWhatsApp() {
    String phoneNumber = "9826469628"; // Put your number with country code here
    String message = "Yes! I'd love to be your Valentine! ❤️";

    // Encodes the message for a URL
    String url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    // Uses Flutter's base Uri to open the link
    html.window.open(url, "_blank");
  }

  void _moveNo() {
    final s = MediaQuery.of(context).size;
    setState(() {
      noTop = Random().nextDouble() * (s.height - 60).clamp(0, s.height);
      noLeft = Random().nextDouble() * (s.width - 120).clamp(0, s.width);
      yesScale += 0.25;
      hoverCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    // Set initial button position
    if (noTop == 0) {
      noTop = s.height * 0.7;
      noLeft = s.width * 0.5 + 40;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Heart Rain Layer
          if (isAccepted)
            AnimatedBuilder(
              animation: _rainController,
              builder: (context, _) => Stack(
                children: _heartRain.map((h) => h.draw(s, _rainController.value)).toList(),
              ),
            ),

          // Main UI Card
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // This requires dart:ui
                child: Container(
                  width: (s.width * 0.85).clamp(300, 450),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeartIcon(),
                      const SizedBox(height: 20),
                      Text("Hi $name,", style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 10),
                      Text(
                        isAccepted ? "LOVE YOU FOREVER! ❤️" : "Will you be my Valentine?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),
                      if (!isAccepted) _buildYesButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Runaway No Button
          if (!isAccepted)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 150),
              top: noTop,
              left: noLeft,
              child: MouseRegion(
                onEnter: (_) => _moveNo(),
                child: ElevatedButton(
                  onPressed: _moveNo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  child: Text(guiltTexts[hoverCount % guiltTexts.length]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeartIcon() {
    return AnimatedScale(
      scale: isAccepted ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Icon(
        isAccepted ? Icons.favorite : Icons.favorite_border,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildYesButton() {
    return AnimatedScale(
      scale: yesScale,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: _onYes,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: const StadiumBorder(),
          elevation: 10,
        ),
        child: const Text("YES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  @override
  void dispose() {
    _rainController.dispose();
    super.dispose();
  }
}

class HeartPath {
  final double xPercent = Random().nextDouble();
  final double size = Random().nextDouble() * 20 + 15;
  final double speed = Random().nextDouble() * 1.5 + 0.5;

  Widget draw(Size screen, double t) {
    double y = (t * screen.height * speed) % screen.height;
    return Positioned(
      top: y,
      left: xPercent * screen.width,
      child: Icon(Icons.favorite, color: Colors.white.withOpacity(0.5), size: size),
    );
  }
}
