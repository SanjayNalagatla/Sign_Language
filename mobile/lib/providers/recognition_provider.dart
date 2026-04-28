import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'dart:async';

final recognitionProvider = StateNotifierProvider<RecognitionNotifier, RecognitionState>((ref) {
  return RecognitionNotifier(ref.read(apiServiceProvider));
});

class RecognitionState {
  final String currentText;
  final bool isDetecting;
  final double confidence;
  final String status; // idle, detecting, recognized, error

  RecognitionState({
    this.currentText = '',
    this.isDetecting = false,
    this.confidence = 0.0,
    this.status = 'idle',
  });

  RecognitionState copyWith({
    String? currentText,
    bool? isDetecting,
    double? confidence,
    String? status,
  }) {
    return RecognitionState(
      currentText: currentText ?? this.currentText,
      isDetecting: isDetecting ?? this.isDetecting,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
    );
  }
}

class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final ApiService _apiService;
  bool _isProcessingFrame = false;

  RecognitionNotifier(this._apiService) : super(RecognitionState());

  void startDetection() {
    state = state.copyWith(isDetecting: true, status: 'detecting');
  }

  void stopDetection() {
    state = state.copyWith(isDetecting: false, status: 'idle');
  }

  void clearText() {
    state = state.copyWith(currentText: '', confidence: 0.0);
  }

  void deleteLastWord() {
    if (state.currentText.isNotEmpty) {
      List<String> words = state.currentText.trim().split(' ');
      if (words.isNotEmpty) {
        words.removeLast();
        state = state.copyWith(currentText: words.join(' ') + (words.isNotEmpty ? ' ' : ''));
      }
    }
  }

  Future<void> processFrame(String base64Image) async {
    if (!state.isDetecting || _isProcessingFrame) return;

    _isProcessingFrame = true;
    try {
      final result = await _apiService.recognizeFrame(base64Image);
      if (result != null) {
        final text = result['text'] ?? '';
        final confidence = result['confidence'] ?? 0.0;
        final status = result['status'] ?? 'low_confidence';

        if (status == 'new_prediction' && text.isNotEmpty) {
          // Append with space if it's a word, or just append for ASL spelling
          // Basic heuristic: if length > 1 it's a word, else character
          String newText = state.currentText;
          if (text.length > 1 || text == 'space') {
             if (text == 'space') {
                 newText += ' ';
             } else if (text == 'del') {
                 // handle delete
                 if (newText.isNotEmpty) {
                     newText = newText.substring(0, newText.length - 1);
                 }
             } else {
                newText += ' $text ';
             }
          } else {
            newText += text;
          }

          state = state.copyWith(
            currentText: newText,
            confidence: confidence,
            status: 'recognized',
          );
          
          // Revert status to detecting after short delay
          Future.delayed(const Duration(milliseconds: 500), () {
             if (state.isDetecting && state.status == 'recognized') {
                 state = state.copyWith(status: 'detecting');
             }
          });
        }
      }
    } catch (e) {
      state = state.copyWith(status: 'error');
    } finally {
      _isProcessingFrame = false;
    }
  }
}
