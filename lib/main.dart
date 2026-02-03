import 'dart:async';
import 'dart:math';
import 'dart:ui';
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

  final player = AudioPlayer();
  late AnimationController _rainController;
  final List<HeartPath> _heartRain = List.generate(50, (i) => HeartPath());

  final List<String> guiltTexts = [
    "No", "Are you sure?", "Pookie please...", "Don't be mean!",
    "I'm crying..", "Broken heart :(", "Click the big YES!", "Give up!"
  ];

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(vsync: this, duration: const Duration(seconds: 3));

    // Improved URL Parameter Logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fullUrl = Uri.base.toString();
      if (fullUrl.contains("name=")) {
        setState(() {
          name = Uri.decodeComponent(fullUrl.split("name=").last.split("&").first);
        });
      }
    });
  }

  FutureOr<void> _onYes() async {
    setState(() => isAccepted = true);
    _rainController.repeat();

    try {
      // Loading asset
      await player.setAsset('assets/audio/my_valentine_song.mpeg');
      player.play();
    } catch (e) {
      debugPrint("Audio Error: $e");
    }

    // Corrected Future.delayed syntax
    Future.delayed(const Duration(seconds: 5), () {
      _launchWhatsApp();
    });
  }

  void _launchWhatsApp() {
    String phoneNumber = "9826469628";
    String message = "Yes! I'd love to be your Valentine! ❤️";
    String url = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";
    html.window.open(url, "_blank");
  }

  void _moveNo() {
    final s = MediaQuery.of(context).size;
    setState(() {
      noTop = Random().nextDouble() * (s.height - 100).clamp(50, s.height - 100);
      noLeft = Random().nextDouble() * (s.width - 150).clamp(50, s.width - 150);
      yesScale += 0.15; // Growing 'Yes' button
      hoverCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    if (noTop == 0) {
      noTop = s.height * 0.7;
      noLeft = s.width * 0.5 + 40;
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
                center: Alignment.center,
                radius: 1.0,
              ),
            ),
          ),

          // 2. Heart Rain
          if (isAccepted)
            AnimatedBuilder(
              animation: _rainController,
              builder: (context, _) => Stack(
                children: _heartRain.map((h) => h.draw(s, _rainController.value)).toList(),
              ),
            ),

          // 3. Central Interactive Card
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(40),
              width: (s.width * 0.85).clamp(320, 480),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeartIcon(),
                      const SizedBox(height: 20),
                      Text("Hi $name,", style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.2)),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(seconds: 1),
                        child: Text(
                          isAccepted ? "I KNEW IT! ❤️\nLocked for Feb 14th" : "Will you be my Valentine?",
                          key: ValueKey(isAccepted),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (!isAccepted) _buildYesButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. The Runaway No Button
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
                    elevation: 0,
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
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutSine,
      builder: (context, scale, child) => Transform.scale(scale: isAccepted ? 1.2 : scale, child: child),
      onEnd: () => setState(() {}),
      child: const Icon(Icons.favorite, size: 80, color: Colors.white),
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
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
          shape: const StadiumBorder(),
          elevation: 15,
        ),
        child: const Text("YES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
  }

  @override
  void dispose() {
    _rainController.dispose();
    player.dispose();
    super.dispose();
  }
}

class HeartPath {
  final double xPercent = Random().nextDouble();
  final double size = Random().nextDouble() * 25 + 10;
  final double speed = Random().nextDouble() * 1.5 + 0.8;
  final double rotation = Random().nextDouble() * 360;

  Widget draw(Size screen, double t) {
    double y = (t * screen.height * speed) % screen.height;
    return Positioned(
      top: y,
      left: xPercent * screen.width + (sin(t * 10) * 20), // Swaying effect
      child: Transform.rotate(
        angle: rotation * (pi / 180),
        child: Icon(Icons.favorite, color: Colors.white.withOpacity(0.4), size: size),
      ),
    );
  }
}