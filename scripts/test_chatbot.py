import requests
import json
import sys
import time
from typing import List, Dict, Any

# Configuration
RASA_URL = "http://localhost:5007/webhooks/rest/webhook"
SENDER_ID = "test_user"

# Test cases organized by categories
TEST_CASES = {
    "Greetings": [
        "hi",
        "hello",
        "hey there",
        "good morning",
        "howdy"
    ],
    "Mental Health Services": [
        "What mental health services are available?",
        "Can you tell me about counseling services?",
        "Where can I get mental health support?",
        "How do I access therapy at the university?",
        "Are there free counseling services for students?"
    ],
    "Emotional Expressions": [
        "I feel sad because of my grades",
        "I'm anxious about my future",
        "I feel overwhelmed with all my assignments",
        "I'm feeling lonely since moving to campus",
        "I'm stressed about deadlines for the past week"
    ],
    "Emergency Situations": [
        "I need emergency mental health support",
        "I'm having a mental health crisis",
        "I need immediate help for my mental health",
        "I'm having a serious mental health situation",
        "This is a mental health emergency"
    ],
    "Relationship and Study Balance": [
        "I can't balance my relationship with my studies",
        "My grades are suffering because of my relationship",
        "How do I manage my relationship and academic work?",
        "I'm spending too much time with my partner and not studying enough",
        "My partner complains I study too much"
    ],
    "Help Requests": [
        "I need help",
        "Can you help me?",
        "I'm looking for assistance",
        "I need support",
        "I need someone to talk to"
    ],
    "Assignment Problems": [
        "I'm struggling with my assignment",
        "My assignment is due soon and I haven't started",
        "I might miss my deadline",
        "I don't understand the assignment",
        "Help me with my assignment"
    ]
}

def send_message(message: str) -> Dict[Any, Any]:
    """Send a message to the Rasa server and return the response."""
    payload = {
        "sender": SENDER_ID,
        "message": message
    }
    
    try:
        response = requests.post(RASA_URL, json=payload)
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error sending message: {e}")
        return []
    except json.decoder.JSONDecodeError:
        print("Error decoding response from server")
        return []

def run_tests(categories: List[str] = None):
    """Run tests for specified categories or all if none are specified."""
    if not categories:
        categories = list(TEST_CASES.keys())
    
    results = {}
    
    for category in categories:
        if category not in TEST_CASES:
            print(f"Category '{category}' not found in test cases")
            continue
        
        print(f"\n===== Testing '{category}' =====")
        category_results = []
        
        for test_message in TEST_CASES[category]:
            print(f"\nMessage: '{test_message}'")
            response = send_message(test_message)
            
            if not response:
                print("No response received")
                category_results.append({
                    "message": test_message,
                    "response": None,
                    "status": "No response"
                })
                continue
            
            # Print the bot's response
            for resp in response:
                if "text" in resp:
                    print(f"Bot: '{resp['text']}'")
            
            category_results.append({
                "message": test_message,
                "response": response,
                "status": "Received response" if response else "No response"
            })
            
            # Short pause between messages
            time.sleep(0.5)
        
        results[category] = category_results
    
    return results

if __name__ == "__main__":
    # Parse command line arguments for specific categories to test
    categories = sys.argv[1:] if len(sys.argv) > 1 else None
    
    print("Starting chatbot test suite...")
    print(f"Using Rasa URL: {RASA_URL}")
    
    try:
        results = run_tests(categories)
        
        # Summarize results
        print("\n===== Test Summary =====")
        for category, category_results in results.items():
            responses_received = sum(1 for r in category_results if r["status"] == "Received response")
            print(f"{category}: {responses_received}/{len(category_results)} responses received")
        
    except Exception as e:
        print(f"Error during testing: {e}")
    
    print("\nTest suite completed.") 