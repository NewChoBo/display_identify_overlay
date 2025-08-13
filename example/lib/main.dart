import 'package:display_identify_overlay/display_identify_overlay.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Display Identify Overlay Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _working = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _show() async {
    setState(() {
      _working = true;
      _status = 'Showing overlay...';
    });
    try {
      await DisplayIdentifyOverlay.show();
      setState(() => _status = 'Overlay requested');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _working = false);
    }
  }

  Future<void> _hide() async {
    setState(() {
      _working = true;
      _status = 'Hiding overlay...';
    });
    try {
      await DisplayIdentifyOverlay.hide();
      setState(() => _status = 'Overlay hidden');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    } finally {
      setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overlay Test (Windows)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: _working ? null : _show,
              child: const Text('Show overlay (3s)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _working ? null : _hide,
              child: const Text('Hide overlay'),
            ),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
