# train_crop_model.py

import os
import time
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision.transforms as transforms
import torchvision.datasets as datasets
import torchvision.models as models
from torch.utils.data import DataLoader, random_split

# ── Paths ──────────────────────────────────────────────────────
DATA_DIR   = "datasets/crop_disease"
MODEL_PATH = "trained_models/crop_model.pth"

# ── Hyperparameters ────────────────────────────────────────────
# RTX 4060/4070/4080/4090 can handle batch size 64 comfortably
BATCH_SIZE  = 64
EPOCHS      = 10
LR          = 0.001
IMAGE_SIZE  = 224
NUM_CLASSES = 5

# ── Device ─────────────────────────────────────────────────────
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def get_transforms():
    """
    Training transforms include augmentation to prevent overfitting.
    Validation transforms only resize and normalize — no augmentation.
    """
    train_transform = transforms.Compose([
        transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
        transforms.RandomHorizontalFlip(),
        transforms.RandomVerticalFlip(),
        transforms.RandomRotation(15),
        transforms.ColorJitter(
            brightness=0.3,
            contrast=0.3,
            saturation=0.3
        ),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])

    val_transform = transforms.Compose([
        transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])

    return train_transform, val_transform


def load_data(train_transform, val_transform):
    """
    Loads images from datasets/crop_disease/ folder.
    Splits 80% for training and 20% for validation.
    """
    print("Loading dataset...")

    full_dataset = datasets.ImageFolder(
        root=DATA_DIR,
        transform=train_transform
    )

    # Class names detected from folder names
    class_names = full_dataset.classes
    print(f"Classes detected : {class_names}")
    print(f"Total images     : {len(full_dataset)}")

    # 80/20 split
    train_size = int(0.8 * len(full_dataset))
    val_size   = len(full_dataset) - train_size

    train_dataset, val_dataset = random_split(
        full_dataset,
        [train_size, val_size],
        generator=torch.Generator().manual_seed(42)
    )

    # Apply validation transform to val set
    val_dataset.dataset.transform = val_transform

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True,
        num_workers=4,
        pin_memory=True     # faster GPU transfer
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=4,
        pin_memory=True
    )

    print(f"Train samples    : {train_size}")
    print(f"Val samples      : {val_size}\n")

    return train_loader, val_loader, class_names


def build_model(num_classes: int):
    """
    Loads pretrained MobileNetV2 and replaces the
    final classifier layer to match our 5 disease classes.
    Using pretrained weights means we start with good
    feature extraction already learned from ImageNet.
    """
    model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)

    # Freeze early layers — only train the classifier
    for param in model.features.parameters():
        param.requires_grad = False

    # Replace final layer for our classes
    model.classifier[1] = nn.Linear(
        model.last_channel,
        num_classes
    )

    return model.to(device)


def train_one_epoch(model, loader, optimizer, criterion, epoch):
    """
    Runs one full pass through the training data.
    Returns average loss and accuracy for this epoch.
    """
    model.train()
    running_loss     = 0.0
    correct          = 0
    total            = 0

    for batch_idx, (images, labels) in enumerate(loader):
        images = images.to(device, non_blocking=True)
        labels = labels.to(device, non_blocking=True)

        optimizer.zero_grad()
        outputs = model(images)
        loss    = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        running_loss += loss.item()
        _, predicted  = outputs.max(1)
        total        += labels.size(0)
        correct      += predicted.eq(labels).sum().item()

        # Print progress every 20 batches
        if (batch_idx + 1) % 20 == 0:
            print(
                f"  Epoch {epoch} | "
                f"Batch {batch_idx+1}/{len(loader)} | "
                f"Loss: {running_loss/(batch_idx+1):.4f} | "
                f"Acc: {100.*correct/total:.2f}%"
            )

    epoch_loss = running_loss / len(loader)
    epoch_acc  = 100. * correct / total
    return epoch_loss, epoch_acc


def validate(model, loader, criterion):
    """
    Evaluates the model on the validation set.
    No gradient computation — faster and uses less memory.
    """
    model.eval()
    running_loss = 0.0
    correct      = 0
    total        = 0

    with torch.no_grad():
        for images, labels in loader:
            images  = images.to(device, non_blocking=True)
            labels  = labels.to(device, non_blocking=True)
            outputs = model(images)
            loss    = criterion(outputs, labels)

            running_loss += loss.item()
            _, predicted  = outputs.max(1)
            total        += labels.size(0)
            correct      += predicted.eq(labels).sum().item()

    val_loss = running_loss / len(loader)
    val_acc  = 100. * correct / total
    return val_loss, val_acc


def train():
    print("\nAgro AI — Crop Disease Model Training")
    print("=" * 45)
    print(f"Device           : {device}")

    if torch.cuda.is_available():
        print(f"GPU              : {torch.cuda.get_device_name(0)}")
        print(f"VRAM             : {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f} GB")

    print()

    # ── Data ───────────────────────────────────────────────────
    train_transform, val_transform = get_transforms()
    train_loader, val_loader, class_names = load_data(
        train_transform, val_transform
    )

    # ── Model ──────────────────────────────────────────────────
    print("Building MobileNetV2 model...")
    model     = build_model(NUM_CLASSES)
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(
        filter(lambda p: p.requires_grad, model.parameters()),
        lr=LR
    )

    # Reduce LR if validation accuracy plateaus
    scheduler = optim.lr_scheduler.ReduceLROnPlateau(
        optimizer,
        mode="max",
        patience=2,
        factor=0.5,
    )

    print(f"Model ready — starting training for {EPOCHS} epochs\n")

    # ── Training loop ──────────────────────────────────────────
    best_val_acc  = 0.0
    best_model_path = MODEL_PATH
    start_time    = time.time()

    for epoch in range(1, EPOCHS + 1):
        epoch_start = time.time()

        train_loss, train_acc = train_one_epoch(
            model, train_loader, optimizer, criterion, epoch
        )
        val_loss, val_acc = validate(
            model, val_loader, criterion
        )

        scheduler.step(val_acc)
        epoch_time = time.time() - epoch_start

        print(
            f"\nEpoch {epoch}/{EPOCHS} Summary | "
            f"Train Loss: {train_loss:.4f} | "
            f"Train Acc: {train_acc:.2f}% | "
            f"Val Loss: {val_loss:.4f} | "
            f"Val Acc: {val_acc:.2f}% | "
            f"Time: {epoch_time:.1f}s"
        )

        # Save best model
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            os.makedirs("trained_models", exist_ok=True)
            torch.save(model.state_dict(), best_model_path)
            print(f"  Best model saved — Val Acc: {best_val_acc:.2f}%")

        print()

    total_time = time.time() - start_time
    print("=" * 45)
    print(f"Training complete in {total_time/60:.1f} minutes")
    print(f"Best Val Accuracy : {best_val_acc:.2f}%")
    print(f"Model saved       -> {MODEL_PATH}")
    print(f"Classes           : {class_names}")
    print("\nCrop model ready for the backend.")


if __name__ == "__main__":
    train()