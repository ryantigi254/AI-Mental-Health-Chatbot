from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet
import random

class ActionSuggestCopingStrategy(Action):
    def name(self) -> Text:
        return "action_suggest_coping_strategy"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the symptom slot value
        symptom = tracker.get_slot("symptom")
        
        # Suggest specific coping strategies based on the symptom
        if symptom == "anxiety":
            dispatcher.utter_message(text="Here are some anxiety coping strategies:\n"
                                         "1. Deep breathing: Inhale for 4 counts, hold for 4, exhale for 6\n"
                                         "2. Progressive muscle relaxation: Tense and release each muscle group\n"
                                         "3. Grounding techniques: Focus on your 5 senses\n"
                                         "4. Challenge negative thoughts with evidence\n"
                                         "5. Limit caffeine and alcohol intake")
        
        elif symptom == "depression":
            dispatcher.utter_message(text="Here are some depression coping strategies:\n"
                                         "1. Set small, achievable daily goals\n"
                                         "2. Practice self-compassion and challenge negative self-talk\n"
                                         "3. Maintain social connections, even when it's difficult\n"
                                         "4. Establish a regular sleep schedule\n"
                                         "5. Consider speaking with a mental health professional")
        
        elif symptom == "stress":
            dispatcher.utter_message(text="Here are some stress management strategies:\n"
                                         "1. Practice time management and prioritization\n"
                                         "2. Set healthy boundaries with work and others\n"
                                         "3. Engage in regular physical activity\n"
                                         "4. Use mindfulness meditation techniques\n"
                                         "5. Take short breaks throughout the day")
        
        else:
            dispatcher.utter_message(text="Here are some general mental wellness strategies:\n"
                                         "1. Maintain a regular sleep schedule\n"
                                         "2. Eat nutritious foods and stay hydrated\n"
                                         "3. Exercise regularly\n"
                                         "4. Practice mindfulness\n"
                                         "5. Connect with supportive people\n"
                                         "6. Limit social media use\n"
                                         "7. Spend time in nature")
        
        return []


class ActionCheckSeverity(Action):
    def name(self) -> Text:
        return "action_check_severity"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Check for severe symptoms in the conversation history
        severe_keywords = [
            "suicide", "kill myself", "end my life", "hurt myself", 
            "self-harm", "cutting", "harming myself", "die"
        ]
        
        # Get the user's last message
        last_message = tracker.latest_message.get("text", "")
        
        # Check if any severe keywords are in the message
        for keyword in severe_keywords:
            if keyword in last_message.lower():
                dispatcher.utter_message(text="I've noticed you mentioned something concerning. "
                                             "If you're having thoughts of harming yourself, please reach out for immediate help:\n\n"
                                             "- National Suicide Prevention Lifeline: 1-800-273-8255\n"
                                             "- Crisis Text Line: Text HOME to 741741\n"
                                             "- Or go to your nearest emergency room\n\n"
                                             "Remember, you're not alone, and help is available.")
                return [SlotSet("severity", "high")]
        
        return [SlotSet("severity", "normal")]


class ActionProvideResources(Action):
    def name(self) -> Text:
        return "action_provide_resources"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(text="Here are some mental health resources that might be helpful:\n\n"
                                     "🏥 Professional Help:\n"
                                     "- Talk to your primary care doctor\n"
                                     "- Find a therapist: Psychology Today Therapist Directory\n"
                                     "- Online therapy services: BetterHelp, Talkspace\n\n"
                                     "📱 Mental Health Apps:\n"
                                     "- Headspace (meditation)\n"
                                     "- Calm (sleep, meditation)\n"
                                     "- Woebot (CBT-based chatbot)\n"
                                     "- MoodMission (mood improvement strategies)\n\n"
                                     "📚 Self-Help Resources:\n"
                                     "- NAMI (National Alliance on Mental Illness): nami.org\n"
                                     "- Mental Health America: mhanational.org\n\n"
                                     "Would you like information on any specific resource?")
        
        return []


class ActionSelectPersonality(Action):
    def name(self) -> Text:
        return "action_select_personality"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the personality preference from the user's message
        personality = next(tracker.get_latest_entity_values("personality_type"), None)
        
        if personality:
            # Set the personality slot
            return [SlotSet("personality_type", personality)]
        else:
            # Ask for personality preference if not specified
            dispatcher.utter_message(response="utter_ask_personality")
            return []


class ActionGenerateResponse(Action):
    def name(self) -> Text:
        return "action_generate_response"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the current personality
        personality = tracker.get_slot("personality_type")
        
        # Get the latest user message
        user_message = tracker.latest_message.get("text")
        
        # Get the intent of the latest message
        intent = tracker.latest_message.get("intent", {}).get("name")
        
        # Generate response based on personality
        if personality == "empathetic":
            response = self._generate_empathetic_response(intent, user_message)
        elif personality == "direct":
            response = self._generate_direct_response(intent, user_message)
        elif personality == "motivational":
            response = self._generate_motivational_response(intent, user_message)
        elif personality == "analytical":
            response = self._generate_analytical_response(intent, user_message)
        else:  # balanced
            response = self._generate_balanced_response(intent, user_message)
        
        dispatcher.utter_message(text=response)
        return []
    
    def _generate_empathetic_response(self, intent: str, message: str) -> str:
        """Generate an empathetic response."""
        responses = {
            "academic_stress": "I understand how overwhelming academic stress can be. It's completely normal to feel this way. Let's explore some strategies together to make it more manageable.",
            "social_isolation": "I hear you're feeling isolated. It's okay to feel this way, and you're not alone. Let's talk about ways to connect with others and build a support network.",
            "feeling_anxious": "I can see you're feeling anxious. That's a valid emotion, and it's okay to feel this way. Let's explore some techniques to help you feel more grounded.",
            "default": "I'm here to listen and support you. How can I help you today?"
        }
        
        return responses.get(intent, responses["default"])
    
    def _generate_direct_response(self, intent: str, message: str) -> str:
        """Generate a direct, practical response."""
        responses = {
            "academic_stress": "Here are three practical steps to manage your workload: 1) Prioritize assignments, 2) Create a study schedule, 3) Break tasks into smaller chunks.",
            "social_isolation": "Here are some concrete steps: 1) Join a student club, 2) Attend campus events, 3) Use the buddy system for classes.",
            "feeling_anxious": "Try these techniques: 1) Deep breathing, 2) Progressive muscle relaxation, 3) Grounding exercises.",
            "default": "What specific issue would you like to address? I can provide practical solutions."
        }
        
        return responses.get(intent, responses["default"])
    
    def _generate_motivational_response(self, intent: str, message: str) -> str:
        """Generate a motivational response."""
        responses = {
            "academic_stress": "You're capable of handling this! Let's break down your goals and create a plan that works for you. Remember, progress is more important than perfection.",
            "social_isolation": "You have so much to offer! Let's explore ways to connect with others and build meaningful relationships. Your unique perspective is valuable.",
            "feeling_anxious": "You're stronger than you think! Let's work on strategies to help you manage anxiety and build confidence. You can overcome this.",
            "default": "I believe in you and your ability to overcome challenges. What would you like to focus on?"
        }
        
        return responses.get(intent, responses["default"])
    
    def _generate_analytical_response(self, intent: str, message: str) -> str:
        """Generate an analytical, structured response."""
        responses = {
            "academic_stress": "Let's break this down: 1) Identify stress triggers, 2) Analyze time management patterns, 3) Create a structured plan with measurable goals.",
            "social_isolation": "Let's examine the factors: 1) Social preferences, 2) Campus resources, 3) Available opportunities for connection.",
            "feeling_anxious": "Let's analyze: 1) Anxiety triggers, 2) Coping mechanisms, 3) Long-term management strategies.",
            "default": "Let's approach this systematically. First, let's identify the core issue, then explore potential solutions, and finally create an action plan."
        }
        
        return responses.get(intent, responses["default"])
    
    def _generate_balanced_response(self, intent: str, message: str) -> str:
        """Generate a balanced response combining different styles."""
        responses = {
            "academic_stress": "I understand this is challenging, but you're not alone. Here are three practical steps you can take: 1) Break down your workload, 2) Create a realistic schedule, 3) Set achievable goals. Would you like to explore any of these in more detail?",
            "social_isolation": "It's completely normal to feel isolated at times. Here are some concrete steps you can take: 1) Join a student club that interests you, 2) Attend campus events, 3) Consider finding a study buddy. Which of these sounds most appealing to you?",
            "feeling_anxious": "I understand you're feeling anxious. Here are some techniques that might help: 1) Deep breathing exercises, 2) Progressive muscle relaxation, 3) Grounding techniques. Would you like to try any of these?",
            "default": "I'm here to support you. Let's explore practical solutions together. What's on your mind?"
        }
        
        return responses.get(intent, responses["default"])
