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


class ActionProvideResourcesByCategory(Action):
    def name(self) -> Text:
        return "action_provide_resources_by_category"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get the latest intent
        latest_intent = tracker.latest_message.get("intent", {}).get("name", "")
        
        # Determine category based on intent prefix
        if latest_intent.startswith("mental_health"):
            self._provide_mental_health_resources(dispatcher)
        elif latest_intent.startswith("relationship"):
            self._provide_relationship_resources(dispatcher)
        elif latest_intent.startswith("support_services"):
            self._provide_support_services_resources(dispatcher)
        elif latest_intent.startswith("social_connection"):
            self._provide_social_connection_resources(dispatcher)
        elif latest_intent.startswith("special_conditions"):
            self._provide_special_conditions_resources(dispatcher, latest_intent)
        elif latest_intent.startswith("identity"):
            self._provide_identity_resources(dispatcher, latest_intent)
        elif latest_intent.startswith("financial"):
            self._provide_financial_resources(dispatcher, latest_intent)
        elif latest_intent.startswith("emergency"):
            self._provide_emergency_resources(dispatcher, latest_intent)
        else:
            # Default to general resources
            self._provide_general_resources(dispatcher)
        
        return []
    
    def _provide_mental_health_resources(self, dispatcher: CollectingDispatcher):
        dispatcher.utter_message(text="Here are helpful mental health resources:\n\n"
                                     "🏥 Campus Resources:\n"
                                     "- Counseling Center: [Contact details]\n"
                                     "- Student Health Services: [Contact details]\n"
                                     "- After-hours crisis line: [Contact details]\n\n"
                                     "📱 Apps & Online Resources:\n"
                                     "- Headspace (meditation)\n"
                                     "- Calm (sleep, meditation)\n"
                                     "- Student Wellness Portal: [Website]\n\n"
                                     "🌐 External Resources:\n"
                                     "- National Crisis Line: 988\n"
                                     "- Crisis Text Line: Text HOME to 741741")
    
    def _provide_relationship_resources(self, dispatcher: CollectingDispatcher):
        dispatcher.utter_message(text="Here are helpful relationship resources:\n\n"
                                     "🏥 Campus Resources:\n"
                                     "- Student Counseling Center: [Contact details]\n"
                                     "- Peer Support Program: [Contact details]\n"
                                     "- Relationship Workshops: [Schedule link]\n\n"
                                     "📚 Online Resources:\n"
                                     "- Relationship Skills Modules: [Website]\n"
                                     "- Healthy Relationships Guide: [Website]\n\n"
                                     "🌐 External Resources:\n"
                                     "- Relationship Helpline: [Contact details]\n"
                                     "- LoveIsRespect.org: Information on healthy relationships")
    
    def _provide_support_services_resources(self, dispatcher: CollectingDispatcher):
        dispatcher.utter_message(text="Here are campus support services resources:\n\n"
                                     "🏥 Academic Support:\n"
                                     "- Academic Advising: [Contact details]\n"
                                     "- Tutoring Center: [Contact details]\n"
                                     "- Writing Center: [Contact details]\n\n"
                                     "🛠️ Student Services:\n"
                                     "- One-Stop Student Services: [Contact details]\n"
                                     "- Disability Resources: [Contact details]\n"
                                     "- International Student Office: [Contact details]\n\n"
                                     "💼 Career Services:\n"
                                     "- Career Center: [Contact details]\n"
                                     "- Internship Office: [Contact details]\n"
                                     "- Alumni Network: [Website]")
    
    def _provide_social_connection_resources(self, dispatcher: CollectingDispatcher):
        dispatcher.utter_message(text="Here are resources for making social connections:\n\n"
                                     "🏫 Campus Organizations:\n"
                                     "- Student Union Website: [Website]\n"
                                     "- Club Directory: [Website]\n"
                                     "- Student Activities Office: [Contact details]\n\n"
                                     "🏆 Sports & Recreation:\n"
                                     "- Intramural Sports: [Website]\n"
                                     "- Recreation Center: [Contact details]\n"
                                     "- Fitness Classes: [Schedule]\n\n"
                                     "🎭 Events & Activities:\n"
                                     "- Campus Events Calendar: [Website]\n"
                                     "- Welcome Week Activities: [Schedule]\n"
                                     "- Residence Hall Programs: [Information]")
    
    def _provide_special_conditions_resources(self, dispatcher: CollectingDispatcher, intent: str):
        # Extract the condition from the intent name (after "special_conditions_")
        condition = intent.replace("special_conditions_", "")
        
        if condition == "adhd" or condition == "learning":
            dispatcher.utter_message(text="Here are resources for ADHD and learning disabilities:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Disability Resources Center: [Contact details]\n"
                                         "- Academic Accommodations: [Information]\n"
                                         "- Learning Strategies Center: [Contact details]\n\n"
                                         "📚 Learning Support:\n"
                                         "- ADHD Coaching: [Information]\n"
                                         "- Study Skills Workshops: [Schedule]\n"
                                         "- Assistive Technology: [Resources]")
        elif condition in ["anxiety", "depression", "bipolar", "ocd", "ptsd", "mental_health"]:
            dispatcher.utter_message(text="Here are resources for mental health conditions:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Counseling Center: [Contact details]\n"
                                         "- Psychiatric Services: [Contact details]\n"
                                         "- Mental Health Peer Support: [Information]\n\n"
                                         "🧠 Treatment Options:\n"
                                         "- Therapy Services: [Information]\n"
                                         "- Medication Management: [Information]\n"
                                         "- Support Groups: [Schedule]")
        elif condition in ["physical_disability", "mobility", "visual_impairment", "hearing_impairment", "chronic_pain"]:
            dispatcher.utter_message(text="Here are resources for physical disabilities:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Disability Resources Center: [Contact details]\n"
                                         "- Accessible Transportation: [Information]\n"
                                         "- Adaptive Technology Center: [Contact details]\n\n"
                                         "🛠️ Accommodations:\n"
                                         "- Classroom Accommodations: [Information]\n"
                                         "- Housing Accommodations: [Information]\n"
                                         "- Exam Accommodations: [Procedures]")
        else:
            dispatcher.utter_message(text="Here are resources for your specific condition:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Disability Resources Center: [Contact details]\n"
                                         "- Student Health Center: [Contact details]\n"
                                         "- Counseling Services: [Contact details]\n\n"
                                         "🛠️ Support Options:\n"
                                         "- Personalized Accommodations: [Information]\n"
                                         "- Peer Support Groups: [Schedule]\n"
                                         "- Academic Adjustments: [Information]")
    
    def _provide_identity_resources(self, dispatcher: CollectingDispatcher, intent: str):
        # Extract the identity aspect from the intent name (after "identity_")
        identity_aspect = intent.replace("identity_", "")
        
        if identity_aspect in ["sexual_orientation", "gender"]:
            dispatcher.utter_message(text="Here are LGBTQ+ resources:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- LGBTQ+ Resource Center: [Contact details]\n"
                                         "- Gender Inclusive Housing: [Information]\n"
                                         "- Pride Alliance: [Contact details]\n\n"
                                         "🧠 Support Services:\n"
                                         "- Coming Out Support: [Information]\n"
                                         "- Gender Affirming Services: [Information]\n"
                                         "- LGBTQ+ Mentoring: [Information]")
        elif identity_aspect in ["race_ethnicity", "culture", "international", "immigrant", "refugee"]:
            dispatcher.utter_message(text="Here are cultural and identity resources:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Multicultural Center: [Contact details]\n"
                                         "- International Student Services: [Contact details]\n"
                                         "- Cultural Student Organizations: [Directory]\n\n"
                                         "🌍 Support Services:\n"
                                         "- Cultural Adjustment Support: [Information]\n"
                                         "- Intercultural Programs: [Schedule]\n"
                                         "- Language Support: [Resources]")
        else:
            dispatcher.utter_message(text="Here are identity-related resources:\n\n"
                                         "🏥 Campus Resources:\n"
                                         "- Diversity & Inclusion Office: [Contact details]\n"
                                         "- Student Support Services: [Contact details]\n"
                                         "- Identity-Based Organizations: [Directory]\n\n"
                                         "🧠 Support Services:\n"
                                         "- Identity Development Programs: [Information]\n"
                                         "- Peer Support Networks: [Information]\n"
                                         "- Community Building Events: [Schedule]")
    
    def _provide_financial_resources(self, dispatcher: CollectingDispatcher, intent: str):
        # Extract the financial aspect from the intent name (after "financial_")
        financial_aspect = intent.replace("financial_", "")
        
        if financial_aspect in ["loans", "scholarships", "aid"]:
            dispatcher.utter_message(text="Here are financial aid resources:\n\n"
                                         "💰 Campus Resources:\n"
                                         "- Financial Aid Office: [Contact details]\n"
                                         "- Scholarship Office: [Contact details]\n"
                                         "- Student Loan Services: [Contact details]\n\n"
                                         "📝 Application Support:\n"
                                         "- FAFSA Assistance: [Information]\n"
                                         "- Scholarship Application Help: [Schedule]\n"
                                         "- Loan Counseling: [Resources]")
        elif financial_aspect in ["budgeting", "planning", "savings"]:
            dispatcher.utter_message(text="Here are financial planning resources:\n\n"
                                         "💰 Campus Resources:\n"
                                         "- Financial Wellness Center: [Contact details]\n"
                                         "- Money Management Workshops: [Schedule]\n"
                                         "- Personal Finance Coaching: [Information]\n\n"
                                         "📊 Budgeting Tools:\n"
                                         "- Student Budget Templates: [Download]\n"
                                         "- Financial Planning Tools: [Resources]\n"
                                         "- Expense Tracking Apps: [Recommendations]")
        elif financial_aspect in ["emergency", "crisis"]:
            dispatcher.utter_message(text="Here are emergency financial resources:\n\n"
                                         "💰 Campus Resources:\n"
                                         "- Emergency Aid Fund: [Contact details]\n"
                                         "- Crisis Support Services: [Contact details]\n"
                                         "- Food Pantry: [Location and hours]\n\n"
                                         "🆘 Immediate Assistance:\n"
                                         "- Emergency Loans: [Application process]\n"
                                         "- Hardship Funding: [Information]\n"
                                         "- Basic Needs Support: [Resources]")
        else:
            dispatcher.utter_message(text="Here are general financial resources:\n\n"
                                         "💰 Campus Resources:\n"
                                         "- Financial Services Office: [Contact details]\n"
                                         "- Student Money Management: [Contact details]\n"
                                         "- Financial Counseling: [Appointment scheduling]\n\n"
                                         "💼 Financial Education:\n"
                                         "- Financial Literacy Workshops: [Schedule]\n"
                                         "- Money Management Resources: [Website]\n"
                                         "- Student Discounts Program: [Information]")
    
    def _provide_emergency_resources(self, dispatcher: CollectingDispatcher, intent: str):
        # Extract the emergency type from the intent name (after "emergency_")
        emergency_type = intent.replace("emergency_", "")
        
        # Critical emergency resources should be provided for all emergency types
        dispatcher.utter_message(text="⚠️ EMERGENCY RESOURCES ⚠️\n\n"
                                     "🚨 Immediate Help:\n"
                                     "- Emergency Services: 911\n"
                                     "- Campus Police: [Emergency number]\n"
                                     "- Crisis Text Line: Text HOME to 741741\n\n"
                                     "🏥 24/7 Support:\n"
                                     "- National Suicide Prevention Lifeline: 988\n"
                                     "- Campus Crisis Line: [Phone number]\n"
                                     "- Emergency Mental Health Services: [Contact details]\n\n"
                                     "🆘 Additional Resources:\n"
                                     "- Student Emergency Services: [Contact details]\n"
                                     "- After-hours Health Services: [Contact details]\n"
                                     "- Emergency Notification System: [Website]")
        
        # Add more specific resources based on emergency type
        if emergency_type == "mental_health" or emergency_type == "suicide":
            dispatcher.utter_message(text="🧠 Mental Health Crisis Resources:\n"
                                         "- Campus Counseling Center (24/7): [Phone number]\n"
                                         "- Mental Health Crisis Team: [Contact details]\n"
                                         "- Suicide Prevention Resources: [Website]\n"
                                         "- Crisis Stabilization Services: [Information]")
    
    def _provide_general_resources(self, dispatcher: CollectingDispatcher):
        dispatcher.utter_message(text="Here are general campus resources:\n\n"
                                     "🏥 Student Services:\n"
                                     "- Student Services Hub: [Contact details]\n"
                                     "- Academic Advising: [Contact details]\n"
                                     "- Counseling Center: [Contact details]\n\n"
                                     "🛠️ Support Options:\n"
                                     "- Dean of Students Office: [Contact details]\n"
                                     "- Financial Aid: [Contact details]\n"
                                     "- Student Health Center: [Contact details]\n\n"
                                     "🌐 Online Resources:\n"
                                     "- Student Portal: [Website]\n"
                                     "- Campus App: [Download information]\n"
                                     "- Student Success Resources: [Website]")

class ActionEmergencyResources(Action):
    def name(self) -> Text:
        return "action_emergency_resources"

    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Critical emergency resources should be provided
        dispatcher.utter_message(text="⚠️ EMERGENCY RESOURCES ⚠️\n\n"
                                 "🚨 Immediate Help:\n"
                                 "- Emergency Services: 911\n"
                                 "- Campus Police: [Emergency number]\n"
                                 "- Crisis Text Line: Text HOME to 741741\n\n"
                                 "🏥 24/7 Support:\n"
                                 "- National Suicide Prevention Lifeline: 988\n"
                                 "- Campus Crisis Line: [Phone number]\n"
                                 "- Emergency Mental Health Services: [Contact details]\n\n"
                                 "🆘 Additional Resources:\n"
                                 "- Student Emergency Services: [Contact details]\n"
                                 "- After-hours Health Services: [Contact details]\n"
                                 "- Emergency Notification System: [Website]")
        
        # Get the intent to check for specific emergency types
        intent = tracker.latest_message.get("intent", {}).get("name", "")
        
        # Add more specific resources based on emergency type
        if "suicide" in intent or "mental_health" in intent:
            dispatcher.utter_message(text="🧠 Mental Health Crisis Resources:\n"
                                     "- Campus Counseling Center (24/7): [Phone number]\n"
                                     "- Mental Health Crisis Team: [Contact details]\n"
                                     "- Suicide Prevention Resources: [Website]\n"
                                     "- Crisis Stabilization Services: [Information]")
        elif "physical" in intent or "medical" in intent:
            dispatcher.utter_message(text="🏥 Medical Emergency Resources:\n"
                                     "- Campus Health Center: [Phone number]\n"
                                     "- Nearest Hospital: [Address and directions]\n"
                                     "- Urgent Care Centers: [Locations]\n"
                                     "- Transportation to Medical Facilities: [Information]")
        elif "safety" in intent or "violence" in intent:
            dispatcher.utter_message(text="🛡️ Safety Emergency Resources:\n"
                                     "- Campus Safety Escort: [Phone number]\n"
                                     "- Safe Zones on Campus: [Locations]\n"
                                     "- Violence Prevention Office: [Contact details]\n"
                                     "- Restraining Order Information: [Resources]")
        elif "sexual_assault" in intent:
            dispatcher.utter_message(text="🛡️ Sexual Assault Resources:\n"
                                     "- Sexual Assault Response Team: [Phone number]\n"
                                     "- Confidential Advocacy: [Contact details]\n"
                                     "- Medical Forensic Exams: [Information]\n"
                                     "- Reporting Options: [Resources]")
        
        return []
