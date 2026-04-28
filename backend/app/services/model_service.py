import os
import time
import numpy as np
try:
    import tensorflow as tf
except ImportError:
    tf = None
from typing import List, Tuple, Dict
from collections import deque
import logging
from app.core.config import settings

logger = logging.getLogger(__name__)

class SignLanguageModelManager:
    def __init__(self):
        self.asl_model_path = settings.ASL_MODEL_PATH
        self.wlasl_model_path = settings.WLASL_MODEL_PATH
        
        self.asl_model = None
        self.wlasl_model = None
        
        # Vocabulary mapping
        self.asl_vocab = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["del", "space", "nothing"]
        self.wlasl_vocab = ["hello", "thank you", "please", "yes", "no", "help", "sorry"] 
        
        # Smoothing state
        self.history_queue = deque(maxlen=settings.SMOOTHING_WINDOW_SIZE)
        self.last_prediction = None
        self.last_confidence = 0.0

        self._load_models()

    def _load_models(self):
        """Load TensorFlow models if they exist, otherwise setup placeholders."""
        if tf is not None and os.path.exists(self.asl_model_path):
            self.asl_model = tf.keras.models.load_model(self.asl_model_path)
            logger.info("Loaded ASL Model.")
        else:
            if tf is None:
                logger.warning("TensorFlow not installed. Using placeholder simulated inference for ASL.")
            else:
                logger.warning(f"ASL Model not found at {self.asl_model_path}. Using placeholder simulated inference.")

        if tf is not None and os.path.exists(self.wlasl_model_path):
            self.wlasl_model = tf.keras.models.load_model(self.wlasl_model_path)
            logger.info("Loaded WLASL Model.")
        else:
            if tf is None:
                logger.warning("TensorFlow not installed. Using placeholder simulated inference for WLASL.")
            else:
                logger.warning(f"WLASL Model not found at {self.wlasl_model_path}. Using placeholder simulated inference.")

    def _simulate_asl_inference(self, landmarks) -> Tuple[str, float]:
        """Simulate inference if model is missing"""
        time.sleep(0.04) # Simulate 40ms inference latency
        # A simple deterministic heuristic based on wrist x coordinate for demo variety
        if len(landmarks) > 0:
             val = int(landmarks[0] * 100) % len(self.asl_vocab)
             return self.asl_vocab[val], 0.88
        return "A", 0.85

    def _simulate_wlasl_inference(self, sequence) -> Tuple[str, float]:
        """Simulate dynamic word inference"""
        time.sleep(0.1) # Simulate 100ms inference latency for LSTM
        return "hello", 0.90

    def predict_asl(self, hand_landmarks: List[List[float]]) -> Tuple[str, float]:
        """
        Predict static character (ASL Alphabet).
        Requires flattened relative landmarks.
        """
        flat_lms = np.array(hand_landmarks).flatten()
        
        if self.asl_model:
            pred = self.asl_model.predict(flat_lms.reshape(1, -1), verbose=0)[0]
            class_idx = np.argmax(pred)
            return self.asl_vocab[class_idx], float(pred[class_idx])
        else:
            return self._simulate_asl_inference(flat_lms)

    def process_frame(self, hand_landmarks: List[List[float]], mode: str = "auto") -> Dict:
        """
        The Priority Decision Layer.
        """
        if not hand_landmarks:
            # Clear history gracefully to not hold onto stale predictions
            self.history_queue.clear()
            self.last_prediction = None
            return {"text": "", "confidence": 0.0, "status": "no_hand"}

        pred_char, conf = self.predict_asl(hand_landmarks[0])

        # Confidence Smoothing (Max Voting)
        self.history_queue.append((pred_char, conf))
        
        votes = {}
        for char, c in self.history_queue:
            votes[char] = votes.get(char, 0) + c
        
        best_char = max(votes, key=votes.get)
        avg_conf = votes[best_char] / sum([1 for x, _ in self.history_queue if x == best_char])

        # Duplicate prediction suppression based on config threshold
        if avg_conf > settings.CONFIDENCE_THRESHOLD:
            if best_char != self.last_prediction:
                self.last_prediction = best_char
                self.last_confidence = avg_conf
                return {"text": best_char, "confidence": round(avg_conf, 2), "status": "new_prediction"}
            else:
                return {"text": best_char, "confidence": round(avg_conf, 2), "status": "duplicate"}
        
        return {"text": "", "confidence": round(avg_conf, 2), "status": "low_confidence"}
