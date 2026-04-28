import 'package:flutter/material.dart';
import '../recognition/recognition_screen.dart';
import '../text_to_sign/text_to_sign_screen.dart';
import '../../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to communicate today?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _buildActionCard(
                      context,
                      title: 'Live Recognition',
                      subtitle: 'Translate sign language to text and speech instantly using your camera.',
                      icon: Icons.camera_alt,
                      color: AppTheme.pinkAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RecognitionScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Text to Sign',
                      subtitle: 'Type or speak to see the corresponding sign language representation.',
                      icon: Icons.sign_language,
                      color: AppTheme.greenAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TextToSignScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      context,
                      title: 'Learning Mode',
                      subtitle: 'Practice your gestures and get real-time feedback.',
                      icon: Icons.school,
                      color: AppTheme.purpleAccent,
                      onTap: () {
                        // Navigate to Learning
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.neutralGray, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
