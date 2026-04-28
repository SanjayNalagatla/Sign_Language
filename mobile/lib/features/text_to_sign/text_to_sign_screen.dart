import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../services/accessibility_service.dart';
import '../../core/theme.dart';

class TextToSignScreen extends ConsumerStatefulWidget {
  const TextToSignScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TextToSignScreen> createState() => _TextToSignScreenState();
}

class _TextToSignScreenState extends ConsumerState<TextToSignScreen> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic> _signSequence = [];
  bool _isLoading = false;
  bool _isListening = false;
  int _currentSignIndex = 0;

  void _convertTextToSign() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _signSequence = [];
      _currentSignIndex = 0;
    });

    final api = ref.read(apiServiceProvider);
    final sequence = await api.textToSign(text);

    setState(() {
      _signSequence = sequence;
      _isLoading = false;
    });
  }

  void _toggleListening() {
    final stt = ref.read(accessibilityServiceProvider);
    if (_isListening) {
      stt.stopListening();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      stt.startListening((text) {
        _textController.text = text;
        _convertTextToSign();
        setState(() => _isListening = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Sign'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Input Area
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter text to convert...',
                    ),
                    onSubmitted: (_) => _convertTextToSign(),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: _isListening ? AppTheme.errorRed : AppTheme.pinkAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    color: AppTheme.whiteText,
                    onPressed: _toggleListening,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.greenAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: AppTheme.whiteText,
                    onPressed: _convertTextToSign,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Display Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _signSequence.isEmpty
                      ? Center(
                          child: Text(
                            'Enter text to see signs',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : Column(
                          children: [
                            // Main Sign Display (Placeholder for actual image/animation)
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.mutedBlueGray.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sign_language,
                                      size: 120,
                                      color: AppTheme.pinkAccent.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _signSequence[_currentSignIndex]['value'].toString().toUpperCase(),
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        color: AppTheme.greenAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _signSequence[_currentSignIndex]['type'] == 'word' ? 'Word Sign' : 'Alphabet Sign',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Sequence Timeline
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _signSequence.length,
                                itemBuilder: (context, index) {
                                  final isCurrent = index == _currentSignIndex;
                                  return GestureDetector(
                                    onTap: () => setState(() => _currentSignIndex = index),
                                    child: Container(
                                      width: 60,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: isCurrent ? AppTheme.pinkAccent : AppTheme.mutedBlueGray.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _signSequence[index]['value'].toString().toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent ? AppTheme.whiteText : AppTheme.neutralGray,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
