import sys
import os
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from sklearn.model_selection import train_test_split

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from app.ml.data_loader import DataLoader

def train_static_model():
    dataset_path = "../ASL_Alphabet_dataset/asl_alphabet_train"
    if not os.path.exists(dataset_path):
        print(f"Dataset path {dataset_path} does not exist. Skipping training.")
        return

    print("Loading data...")
    loader = DataLoader(dataset_path)
    X, y, classes = loader.load_asl_dataset(max_samples_per_class=500)
    
    if len(X) == 0:
        print("No valid data loaded. Please check dataset.")
        return

    # Train/Test Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Build simple feedforward network for static landmarks
    model = Sequential([
        Dense(128, activation='relu', input_shape=(X.shape[1],)),
        Dropout(0.3),
        Dense(64, activation='relu'),
        Dropout(0.2),
        Dense(len(classes), activation='softmax')
    ])

    model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])

    print("Training model...")
    model.fit(X_train, y_train, epochs=20, batch_size=32, validation_data=(X_test, y_test))

    print("Saving model...")
    os.makedirs("../models", exist_ok=True)
    model.save("../models/asl_static.h5")
    print("Model saved to models/asl_static.h5")

if __name__ == "__main__":
    train_static_model()
