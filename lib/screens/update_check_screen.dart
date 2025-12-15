import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../widget_tree.dart';

class UpdateCheckScreen extends StatefulWidget {
  const UpdateCheckScreen({super.key});

  @override
  State<UpdateCheckScreen> createState() => _UpdateCheckScreenState();
}

class _UpdateCheckScreenState extends State<UpdateCheckScreen> {
  final UpdateService _service = UpdateService();
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _startCheck();
  }

  Future<void> _startCheck() async {
    final result = await _service.checkForUpdate();

    if (!mounted) return;

    setState(() => _checking = false);

    if (result != null) {
      _showDialog(result);
    } else {
      _goToApp();
    }
  }

  void _goToApp() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const WidgetTree(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showDialog(Map<String, dynamic> data) {
    final force = data['force_update'] ?? false;
    final version = data['version'] ?? 'Unknown';
    final notes = data['release_notes'] ?? 'No release notes available';
    final link = data['apk_url'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (_) => PopScope(
        canPop: !force,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.system_update, color: Colors.deepPurpleAccent),
              SizedBox(width: 8),
              Text(
                "Update Available",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Version: $version",
                style: const TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              Text(
                notes,
                style: const TextStyle(color: Colors.white70),
              ),
              if (force) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "This update is required to continue",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _goToApp();
                },
                child: const Text(
                  "Later",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (link.isNotEmpty) {
                  bool success = await _service.openDownloadLink(link);

                  if (!success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Could not open download link. Please try again or download manually.',
                        ),
                        backgroundColor: Colors.orangeAccent,
                        action: SnackBarAction(
                          label: 'Copy Link',
                          textColor: Colors.white,
                          onPressed: () {
                            // يمكن تضيف clipboard copy هنا
                            print("Link: $link");
                          },
                        ),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Download link not available'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text("Update Now"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _checking
            ? Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              color: Colors.deepPurpleAccent,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              "Checking for updates...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        )
            : const SizedBox.shrink(),
      ),
    );
  }
}