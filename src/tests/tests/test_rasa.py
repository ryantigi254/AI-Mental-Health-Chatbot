from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from typing import Any, Text, Dict, List

class TestActionSelectPersonality(Action):
    def name(self) -> Text:
        return "action_select_personality"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Test the personality selection
        personality = next(tracker.get_latest_entity_values("personality_type"), None)
        
        if personality:
            dispatcher.utter_message(text=f"Selected personality: {personality}")
            return [SlotSet("personality_type", personality)]
        else:
            dispatcher.utter_message(text="Please select a personality type")
            return []

class TestActionGenerateResponse(Action):
    def name(self) -> Text:
        return "action_generate_response"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Test the response generation
        personality = tracker.get_slot("personality_type")
        intent = tracker.latest_message.get("intent", {}).get("name")
        
        response = f"Testing response for intent: {intent} with personality: {personality}"
        dispatcher.utter_message(text=response)
        return []
