# Mental Health Chatbot with Rasa

This repository contains a mental health chatbot built using the Rasa framework. The chatbot is designed to provide support and resources for mental health concerns.

## Project Structure

```
src/
├── actions/
│   └── actions.py          # Custom actions for complex behaviors
├── data/
│   ├── nlu/
│   │   └── nlu.yml         # Training data for natural language understanding
│   ├── rules/
│   │   └── rules.yml       # Definitive conversation patterns
│   └── stories/
│       └── stories.yml     # Example conversation paths
├── models/                 # Trained model files will be stored here
├── tests/                  # Test files for the chatbot
│   └── conversation_tests/ # Test conversation files
├── config.yml              # Pipeline and policy configuration
├── credentials.yml         # Channel connection credentials
├── domain.yml              # Chatbot domain (intents, entities, slots, responses)
├── endpoints.yml           # Webhook configurations for the bot
└── README.md               # Project documentation
```

## Setup and Installation

1. **Install Python** (3.8+ recommended)

2. **Install Rasa**:
   ```bash
   pip install rasa
   ```

3. **Install dependencies for custom actions**:
   ```bash
   pip install rasa-sdk
   ```

## Running the Chatbot

1. **Train the model**:
   From the `src` directory, run:
   ```bash
   rasa train
   ```

2. **Start the action server** (in a separate terminal):
   ```bash
   rasa run actions
   ```

3. **Start the chatbot** (in another terminal):
   ```bash
   rasa shell
   ```
   
   Or to run with an API:
   ```bash
   rasa run --enable-api --cors "*"
   ```

## Development

### Custom Actions

The `actions.py` file contains custom actions that the bot can perform:
- `ActionSuggestCopingStrategy`: Provides tailored coping strategies based on the user's symptoms
- `ActionCheckSeverity`: Monitors conversations for concerning content and provides crisis resources
- `ActionProvideResources`: Offers a comprehensive list of mental health resources

### Extending the Chatbot

To add new capabilities:

1. Add new intents in `data/nlu/nlu.yml`
2. Add example utterances for those intents
3. Update `domain.yml` with new intents, entities, slots, and responses
4. Create stories in `data/stories/stories.yml` to define conversation flows
5. Add rules in `data/rules/rules.yml` for definitive patterns
6. Implement custom actions in `actions/actions.py` if needed
7. Retrain the model with `rasa train`

## Testing

Run tests using:
```bash
rasa test
```

This will test both NLU and core components.

## Deployment

For production deployment, consider using:
- Docker containers
- Rasa X for conversation monitoring and improvement
- Cloud hosting services (AWS, Google Cloud, etc.)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Specify your license here]
