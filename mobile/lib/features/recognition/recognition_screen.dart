import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/recognition_provider.dart';
import '../../services/accessibility_service.dart';
import '../../core/theme.dart';

class RecognitionScreen extends ConsumerStatefulWidget {
  const RecognitionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends ConsumerState<RecognitionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.low, // Optimized payload size
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    }
  }

  DateTime? _lastFrameTime;

  void _startStreaming() {
    ref.read(recognitionProvider.notifier).startDetection();
    _cameraController?.startImageStream((CameraImage image) {
      final state = ref.read(recognitionProvider);
      if (!state.isDetecting) return;

      final now = DateTime.now();
      // Throttle to max 3 FPS (~333ms per frame)
      if (_lastFrameTime != null && now.difference(_lastFrameTime!).inMilliseconds < 333) {
        return;
      }
      _lastFrameTime = now;

      // Simulated base64 conversion (In real app, convert YUV420 to JPEG Base64)
      String dummyBase64 = base64Encode([0,1,2]); 
      ref.read(recognitionProvider.notifier).processFrame(dummyBase64);
    });
  }

  void _stopStreaming() {
    ref.read(recognitionProvider.notifier).stopDetection();
    _cameraController?.stopImageStream();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recognitionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Recognition'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Camera View
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: state.isDetecting ? AppTheme.pinkAccent : AppTheme.mutedBlueGray,
                  width: 3,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),

          // Output Panel
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Output', style: Theme.of(context).textTheme.titleLarge),
                      _buildStatusChip(state.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.mutedBlueGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Text(
                          state.currentText.isEmpty ? 'Waiting for gestures...' : state.currentText,
                          key: ValueKey<String>(state.currentText),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: state.currentText.isEmpty ? AppTheme.neutralGray : AppTheme.whiteText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.backspace),
                        onPressed: () => ref.read(recognitionProvider.notifier).deleteLastWord(),
                        color: AppTheme.neutralGray,
                        tooltip: 'Delete last word',
                      ),
                      FloatingActionButton(
                        backgroundColor: state.isDetecting ? AppTheme.errorRed : AppTheme.pinkAccent,
                        onPressed: () {
                          if (state.isDetecting) {
                            _stopStreaming();
                          } else {
                            _startStreaming();
                          }
                        },
                        child: Icon(state.isDetecting ? Icons.stop : Icons.play_arrow),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          ref.read(accessibilityServiceProvider).speak(state.currentText);
                        },
                        color: AppTheme.greenAccent,
                        tooltip: 'Speak Text',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'detecting':
        color = AppTheme.pinkAccent;
        label = 'Detecting...';
        break;
      case 'recognized':
        color = AppTheme.greenAccent;
        label = 'Recognized';
        break;
      case 'error':
        color = AppTheme.errorRed;
        label = 'Error';
        break;
      default:
        color = AppTheme.neutralGray;
        label = 'Idle';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
