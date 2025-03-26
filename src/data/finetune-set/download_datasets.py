#!/usr/bin/env python3
"""
Script to download specified datasets from Hugging Face and save them locally.
"""

import os
from datasets import load_dataset
import json

# Set output directory
OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

def save_dataset(dataset, name):
    """Save dataset to disk in JSON format."""
    print(f"Downloading {name}...")
    
    # Create dataset-specific directory
    dataset_dir = os.path.join(OUTPUT_DIR, name)
    os.makedirs(dataset_dir, exist_ok=True)
    
    # Save each split separately
    for split in dataset:
        print(f"  Saving {split} split with {len(dataset[split])} examples")
        output_file = os.path.join(dataset_dir, f"{split}.json")
        
        with open(output_file, 'w', encoding='utf-8') as f:
            # Convert dataset to list of dictionaries and save as JSON
            json.dump(dataset[split].to_dict(), f, ensure_ascii=False, indent=2)
            
    print(f"Dataset {name} saved to {dataset_dir}")
    print(f"Dataset structure: {list(dataset.keys())}")
    print(f"Example features: {dataset[list(dataset.keys())[0]].features}")
    print("-" * 40)

# Download and save the Personality dataset (train)
ds1 = load_dataset("Navya1602/Personality_dataset_train")
save_dataset(ds1, "personality_dataset_train")

# Download and save the Personalities dataset
ds2 = load_dataset("Denny-linguist/personalities")
save_dataset(ds2, "personalities")

# Download and save the Mental Health dataset
ds3 = load_dataset("TVRRaviteja/Mental-Health-Data")
save_dataset(ds3, "mental_health_data")

print("All datasets downloaded successfully!")
