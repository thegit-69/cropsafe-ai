# train_soil_model.py

import numpy as np
import pandas as pd
import joblib
import os
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import accuracy_score, classification_report
from sklearn.preprocessing import LabelEncoder

# ── Paths ──────────────────────────────────────────────────────
DATA_PATH    = "datasets/fertilizer_data.csv"
MODEL_PATH   = "trained_models/soil_model.pkl"
ENCODER_PATH = "trained_models/fertilizer_encoder.pkl"

# ── Only these 4 features match our Flutter input ─────────────
FEATURE_COLUMNS = ["Nitrogen", "Phosphorous", "Potassium", "Moisture"]
TARGET_COLUMN   = "Fertilizer Name"


def load_and_prepare():
    print("Loading dataset...")
    df = pd.read_csv(DATA_PATH)

    print(f"Rows         : {len(df)}")
    print(f"Columns      : {df.columns.tolist()}")
    print(f"Classes      : {df[TARGET_COLUMN].unique().tolist()}")
    print(f"\nClass distribution:\n{df[TARGET_COLUMN].value_counts()}\n")

    X = df[FEATURE_COLUMNS].values
    y = df[TARGET_COLUMN].values
    return X, y


def train():
    print("\nAgro AI — Soil Fertilizer Model Training")
    print("=" * 45)

    # ── Load ───────────────────────────────────────────────────
    X, y = load_and_prepare()

    # ── Encode labels ──────────────────────────────────────────
    encoder = LabelEncoder()
    y_encoded = encoder.fit_transform(y)
    print(f"Encoded classes: {list(encoder.classes_)}\n")

    # ── Cross validation first ─────────────────────────────────
    print("Running 5-fold cross validation...")
    model_cv = RandomForestClassifier(
        n_estimators=200,
        max_depth=15,
        random_state=42,
        n_jobs=-1
    )
    cv_scores = cross_val_score(model_cv, X, y_encoded, cv=5)
    print(f"CV Accuracy   : {cv_scores.mean()*100:.2f}% (+/- {cv_scores.std()*100:.2f}%)\n")

    # ── Train final model on full data ─────────────────────────
    # Since dataset is small (99 rows) we train on full data
    # after validating with cross validation above
    print("Training final model on full dataset...")
    model = RandomForestClassifier(
        n_estimators=200,
        max_depth=15,
        random_state=42,
        n_jobs=-1
    )
    model.fit(X, y_encoded)
    print("Training complete.\n")

    # ── Evaluate on a holdout split for report ─────────────────
    X_train, X_test, y_train, y_test = train_test_split(
        X, y_encoded,
        test_size=0.2,
        random_state=42,
        stratify=y_encoded
    )
    model_eval = RandomForestClassifier(
        n_estimators=200,
        max_depth=15,
        random_state=42,
        n_jobs=-1
    )
    model_eval.fit(X_train, y_train)
    y_pred = model_eval.predict(X_test)

    print(f"Holdout Accuracy: {accuracy_score(y_test, y_pred)*100:.2f}%")
    print("\nClassification Report:")
    print(classification_report(
        y_test,
        y_pred,
        target_names=encoder.classes_
    ))

    # ── Feature importance ─────────────────────────────────────
    print("Feature Importance:")
    for name, imp in zip(FEATURE_COLUMNS, model.feature_importances_):
        print(f"  {name:15} : {imp:.4f}")

    # ── Save ───────────────────────────────────────────────────
    os.makedirs("trained_models", exist_ok=True)
    joblib.dump(model,   MODEL_PATH)
    joblib.dump(encoder, ENCODER_PATH)

    print(f"\nModel saved   -> {MODEL_PATH}")
    print(f"Encoder saved -> {ENCODER_PATH}")
    print("\nSoil model ready for the backend.")


if __name__ == "__main__":
    train()