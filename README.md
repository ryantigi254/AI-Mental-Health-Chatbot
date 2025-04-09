# AI Group Project - Mental Health Chatbot

This project is a Rasa-based conversational AI designed to provide mental health support and resource information, initially tailored for students at the University of Northampton. It is developed as part of the CSY2088 Group Project module.

## :bookmark_tabs: Table of Contents

*   [Overview](#rocket-overview)
*   [Key Features](#sparkles-key-features)
*   [Project Structure](#file_folder-project-structure)
*   [Setup and Installation](#gear-setup-and-installation)
*   [Training and Running](#robot-training-and-running)
*   [Hierarchical Intents](#books-hierarchical-intents)
*   [Development Status & Next Steps](#construction-development-status--next-steps)
*   [Resources](#scroll-resources)
*   [License](#memo-license)

## :rocket: Overview

The chatbot aims to understand user intents related to various mental health topics and provide appropriate, empathetic responses and resource referrals. The primary goal is to support student wellbeing by offering accessible, initial guidance and directing users to professional help when necessary.

This project leverages Rasa's NLU and Core components to manage dialogue flow and understand user input effectively.

## :sparkles: Key Features

*   **Broad Topic Coverage:** Handles intents related to mood, academic stress, relationships, identity, finances, social issues, substance use, and more.
*   **Hierarchical Intent Structure:** Utilizes a structured intent system (e.g., `mental_health/academic/stress`) for improved NLU accuracy and organization (See `src/data/README-HIERARCHY.md`).
*   **Entity Extraction:** Identifies key information like emotion types, triggers, duration, and severity to provide context-aware responses.
*   **Resource Provision:** Offers information and links to University of Northampton counselling services, mental health practitioners, self-help materials, and external support lines.
*   **Emergency/Crisis Handling:** Recognizes urgent situations (suicide, self-harm, panic) and directs users to immediate help (NHS, Samaritans, Campus Security).
*   **Contextual Dialogue:** Manages conversation context using slots and Rasa policies.

## :file_folder: Project Structure

The core Rasa project files are located within the `src/` directory:

```
src/
├── actions/          # Custom Python actions (if any)
├── data/             # NLU, Stories, Rules
│   ├── nlu/          # NLU training data (including hierarchical structure)
│   ├── rules/        # Conversation rules
│   └── stories/      # Example conversation stories
├── models/           # Trained Rasa models
├── tests/            # Test conversations
├── config.yml        # NLU pipeline and policy configuration
├── credentials.yml   # Connection details for external channels
├── domain.yml        # Intents, entities, slots, responses, actions
├── endpoints.yml     # Configuration for action server, tracker store etc.
└── requirements.txt  # Python package dependencies

.gitignore            # Specifies intentionally untracked files that Git should ignore
README.md             # This file
development_plan.md   # Document outlining steps for model improvement
progress_documentation.md # Tracks development progress
```

## :gear: Setup and Installation

1.  **Prerequisites**:
    *   Python (version 3.8 - 3.10 recommended for Rasa 3.x)
    *   `pip` (Python package installer)
    *   Git
    *   Virtual environment tool (e.g., `venv`)

2.  **Clone the Repository**:
    ```bash
    git clone git@github.com:ryantigi254/AI-Mental-Health-Chatbot.git
    cd AI-Mental-Health-Chatbot
    ```

3.  **Create and Activate Virtual Environment**:
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate  # On Windows use `.venv\Scripts\activate`
    ```

4.  **Install Dependencies**:
    *   Navigate to the `src` directory:
        ```bash
        cd src
        ```
    *   Install required packages:
        ```bash
        pip install -r requirements.txt
        ```

## :robot: Training and Running

*(Execute Rasa commands from within the `src/` directory)*

1.  **Train the Model**:
    ```bash
    rasa train
    ```
    This command trains the NLU and Core models using data in `src/data/`, configuration in `src/config.yml`, and the domain defined in `src/domain.yml`. Trained models are saved to `src/models/`.

2.  **Run the Chatbot (Interactive Shell)**:
    ```bash
    rasa shell
    ```
    Starts an interactive command-line interface to chat with the bot.

3.  **Run with Action Server (If using custom actions)**:
    *   *Terminal 1*: Start the action server:
        ```bash
        rasa run actions
        ```
    *   *Terminal 2*: Start the Rasa server (optionally enabling the API):
        ```bash
        rasa run --enable-api # Or rasa shell
        ```

## :books: Hierarchical Intents

This project uses a hierarchical structure for organizing NLU data, aiming for better clarity and performance. For example, an intent about academic stress is named `mental_health/academic/stress`. Refer to `src/data/README-HIERARCHY.md` for a detailed explanation of the structure and migration plan.

## :construction: Development Status & Next Steps

*(Based on `progress_documentation.md` and recent activity)*

*   **Current Status:** NLU data restructuring (hierarchical intents) is in progress. Core intents, entities, responses, and basic conversation flows are defined. Resource responses for UoN services have been added.
*   **Key Accomplishments:**
    *   Initial project setup and Rasa configuration.
    *   Definition of core mental health intents and entities.
    *   Implementation of emergency handling rules.
    *   Integration of UoN-specific resource information.
    *   Setup of `requirements.txt` and `.gitignore`.
*   **Next Steps (Planned):**
    *   Complete the migration to the hierarchical NLU structure.
    *   Expand test coverage (NLU and Core test stories).
    *   Implement custom actions for more dynamic behavior (if needed).
    *   Refine dialogue flows and error handling.
    *   Explore deployment options.
    *   User testing and feedback integration.

Refer to `development_plan.md` for more detailed improvement strategies.


## :scroll: Resources

*   **Project Specific:**
    *   `src/data/README-HIERARCHY.md`: NLU Structure Details
    *   `development_plan.md`: Improvement Plan
    *   `progress_documentation.md`: Development Log
*   **Rasa:**
    *   [Rasa Documentation](https://rasa.com/docs/rasa/)
*   **University of Northampton (UoN):**
    *   Student Hub: [Counselling & Mental Health](https://mynorthamptonac.sharepoint.com/sites/student/Pages/counselling-and-mental-health.aspx)
    *   Student Hub: [Self-Help Resources](https://mynorthamptonac.sharepoint.com/sites/student/Pages/self-help-resources.aspx)
*   **External Support:**
    *   NHS Urgent Mental Health Help: [NHFT Urgent Help](https://www.nhft.nhs.uk/help) or call 111.
    *   Samaritans: Call 116 123 (UK, free, 24/7)


