import 'package:flutter/material.dart';
import 'package:display_identify_overlay/display_identify_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  int _displayCount = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    int displayCount;

    try {
      platformVersion =
          await DisplayIdentifyOverlay.platformVersion ??
          'Unknown platform version';
      displayCount = await DisplayIdentifyOverlay.getDisplayCount();
    } catch (e) {
      platformVersion = 'Failed to get platform version: $e';
      displayCount = 0;
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _displayCount = displayCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Display Identify Overlay Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Display count: $_displayCount'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Future implementation: show overlays
                },
                child: const Text('Show Display Overlays'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
