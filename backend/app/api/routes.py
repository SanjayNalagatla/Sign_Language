import base64
import cv2
import time
import uuid
import logging
import numpy as np
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel
from app.services.vision_service import VisionService
from app.services.model_service import SignLanguageModelManager

# Setup basic logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

router = APIRouter()

# Initialize services
vision_service = VisionService()
model_manager = SignLanguageModelManager()

class FrameRequest(BaseModel):
    image_base64: str

@router.post("/recognize/frame")
async def recognize_frame(request: FrameRequest):
    """
    Process a single frame for static ASL alphabet recognition.
    """
    req_id = str(uuid.uuid4())[:8]
    start_time = time.time()
    
    try:
        # Decode base64 image
        img_data = base64.b64decode(request.image_base64)
        np_arr = np.frombuffer(img_data, np.uint8)
        img_np = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
        
        if img_np is None:
            logger.warning(f"[{req_id}] Invalid image format.")
            raise HTTPException(status_code=400, detail="Invalid image format.")

        # Extract landmarks
        hand_landmarks = vision_service.process_frame_for_hands(img_np)
        
        # Process through Priority Model Layer (ASL first)
        result = model_manager.process_frame(hand_landmarks)
        
        latency_ms = round((time.time() - start_time) * 1000, 2)
        logger.info(f"[{req_id}] Frame processed in {latency_ms}ms | Status: {result['status']} | Output: {result.get('text', '')}")
        
        result["latency_ms"] = latency_ms
        return result

    except HTTPException as he:
        raise he
    except Exception as e:
        logger.error(f"[{req_id}] Server error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/text-to-sign")
async def text_to_sign(text: str):
    """
    Convert text to a sequence of sign identifiers.
    """
    req_id = str(uuid.uuid4())[:8]
    logger.info(f"[{req_id}] Text-to-sign requested for: '{text}'")
    
    words = text.lower().split()
    sequence = []
    
    for word in words:
        if word in model_manager.wlasl_vocab:
            sequence.append({"type": "word", "value": word})
        else:
            # Fallback to spelling
            for char in word:
                if char.upper() in model_manager.asl_vocab:
                    sequence.append({"type": "char", "value": char.upper()})
    
    return {"sequence": sequence}

# Cleanup on shutdown
@router.on_event("shutdown")
def shutdown_event():
    vision_service.close()
