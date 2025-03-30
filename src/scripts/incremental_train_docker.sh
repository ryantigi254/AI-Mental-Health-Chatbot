#!/bin/bash

# Incremental Training Script for Rasa via Docker
# Usage: ./incremental_train_docker.sh [mode] [--finetune model_path]
# Modes: dev, nlu, core, all

MODE=$1
FINETUNE_FLAG=""
MODEL_PATH=""
CURRENT_DIR="$(pwd)"

# Check if finetune flag is provided
if [[ "$2" == "--finetune" ]]; then
  FINETUNE_FLAG="--finetune"
  if [ -n "$3" ]; then
    MODEL_PATH="$3"
  fi
fi

# Create directory structure if it doesn't exist
mkdir -p src/data/dev

# Function to train in development mode (fewer intents, reduced epochs)
dev_train() {
  echo "Training in development mode with reduced dataset..."
  
  if [ -n "$FINETUNE_FLAG" ]; then
    if [ -n "$MODEL_PATH" ]; then
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data/dev --config /app/src/data/dev/config.yml $FINETUNE_FLAG $MODEL_PATH --epoch-fraction 0.5
    else
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data/dev --config /app/src/data/dev/config.yml $FINETUNE_FLAG --epoch-fraction 0.5
    fi
  else
    docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data/dev --config /app/src/data/dev/config.yml
  fi
}

# Function to train NLU only
nlu_train() {
  echo "Training NLU only..."
  
  if [ -n "$FINETUNE_FLAG" ]; then
    if [ -n "$MODEL_PATH" ]; then
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train nlu --nlu /app/src/data/nlu.yml --config /app/src/config.yml $FINETUNE_FLAG $MODEL_PATH --epoch-fraction 0.2
    else
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train nlu --nlu /app/src/data/nlu.yml --config /app/src/config.yml $FINETUNE_FLAG --epoch-fraction 0.2
    fi
  else
    docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train nlu --nlu /app/src/data/nlu.yml --config /app/src/config.yml
  fi
}

# Function to train Core only with reduced augmentation
core_train() {
  echo "Training Core only with reduced augmentation..."
  
  if [ -n "$FINETUNE_FLAG" ]; then
    if [ -n "$MODEL_PATH" ]; then
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train core --stories /app/src/data/stories --config /app/src/config.yml --augmentation 20 $FINETUNE_FLAG $MODEL_PATH --epoch-fraction 0.2
    else
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train core --stories /app/src/data/stories --config /app/src/config.yml --augmentation 20 $FINETUNE_FLAG --epoch-fraction 0.2
    fi
  else
    docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train core --stories /app/src/data/stories --config /app/src/config.yml --augmentation 20
  fi
}

# Function to train both NLU and Core
all_train() {
  echo "Training both NLU and Core..."
  
  if [ -n "$FINETUNE_FLAG" ]; then
    if [ -n "$MODEL_PATH" ]; then
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data --config /app/src/config.yml --augmentation 20 $FINETUNE_FLAG $MODEL_PATH --epoch-fraction 0.2
    else
      docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data --config /app/src/config.yml --augmentation 20 $FINETUNE_FLAG --epoch-fraction 0.2
    fi
  else
    docker run -v "$CURRENT_DIR:/app" rasa/rasa:3.6.20-full train --data /app/src/data --config /app/src/config.yml --augmentation 20
  fi
}

# Main execution based on selected mode
case $MODE in
  "dev")
    dev_train
    ;;
  "nlu")
    nlu_train
    ;;
  "core")
    core_train
    ;;
  "all")
    all_train
    ;;
  *)
    echo "Usage: ./incremental_train_docker.sh [mode] [--finetune model_path]"
    echo "Modes: dev, nlu, core, all"
    exit 1
    ;;
esac

echo "Training complete!"
