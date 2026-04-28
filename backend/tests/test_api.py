import unittest
import base64
import numpy as np
import cv2
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

class TestSignLanguageAPI(unittest.TestCase):
    
    def setUp(self):
        # Create a dummy image (black square)
        img = np.zeros((100, 100, 3), dtype=np.uint8)
        _, buffer = cv2.imencode('.jpg', img)
        self.dummy_base64 = base64.b64encode(buffer).decode('utf-8')
        
    def test_health_check(self):
        response = client.get("/health")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json(), {"status": "healthy"})

    def test_recognize_frame_no_hand(self):
        # Sending a black image should result in 'no_hand' status
        response = client.post("/api/v1/recognize/frame", json={"image_base64": self.dummy_base64})
        self.assertEqual(response.status_code, 200)
        
        data = response.json()
        self.assertIn("status", data)
        self.assertEqual(data["status"], "no_hand")
        self.assertIn("latency_ms", data)
        
    def test_recognize_frame_invalid_base64(self):
        # Send invalid base64 string
        response = client.post("/api/v1/recognize/frame", json={"image_base64": "invalid_base64++"})
        # The base64 decode might succeed with garbage or fail. CV2 decode will fail.
        self.assertEqual(response.status_code, 400)
        
    def test_text_to_sign(self):
        response = client.post("/api/v1/text-to-sign?text=hello%20world")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("sequence", data)
        
if __name__ == '__main__':
    unittest.main()
