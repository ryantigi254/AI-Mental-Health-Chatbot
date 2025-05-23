# Mental Health Chatbot Hierarchical Intent Structure

This document explains the new hierarchical intent structure implemented for the mental health chatbot.

## Overview

We've restructured the NLU data to use a hierarchical intent format. This approach:

1. Improves classification accuracy by organizing intents into logical categories
2. Reduces confusion between similar intents 
3. Makes it easier to add new intents in the future
4. Supports better entity extraction for specialized responses

## Hierarchy Structure

```
mental_health/
  ├── mood/
  │   ├── positive
  │   ├── negative
  │   └── neutral
  ├── academic/
  │   ├── stress
  │   ├── performance
  │   └── accommodations
  ├── crisis/
  │   ├── suicide
  │   ├── self_harm
  │   └── panic
  └── resources/
      ├── campus
      ├── online
      └── emergency
```

## Implementation Details

### Directory Structure

The NLU data is now organized in subdirectories that match the hierarchical structure:

```
src/data/nlu/mental_health/
├── mood/
│   ├── positive.yml
│   ├── negative.yml
│   └── neutral.yml
├── academic/
│   ├── stress.yml
│   ├── performance.yml
│   └── accommodations.yml
├── crisis/
│   ├── suicide.yml
│   ├── self_harm.yml
│   └── panic.yml
└── resources/
    ├── campus.yml
    ├── online.yml
    └── emergency.yml
```

### Intent Format

Intents use the hierarchical naming convention:

```yaml
- intent: mental_health/mood/positive
  examples: |
    - I feel great today
    - I am happy
    ...
```

### Entity Extraction

Each category uses specific entities for better response targeting:

1. Academic category uses:
   - `academic_trigger`: Specific cause (exams, assignments)
   - `severity`: Level of stress (low, medium, high)
   - `duration`: How long the issue has persisted

2. Crisis category has high detection priority with:
   - Direct pattern matching for urgent responses

3. Resources category organizes by location/type:
   - Campus, online, and emergency resources

## Migration Plan

1. **Current Status**: Hierarchical structure has been implemented in parallel with existing intents
2. **Short Term**: Test and verify the new structure works correctly
3. **Medium Term**: Gradually transition to using only hierarchical intents
4. **Long Term**: Completely replace old intent structure

## Examples

### Example 1: Academic Stress Intent

```yaml
- intent: mental_health/academic/stress
  examples: |
    - I'm stressed about [exams](academic_trigger)
    - My [coursework](academic_trigger) is overwhelming me
    - I can't handle the [deadlines](academic_trigger)
    - I'm stressed at a [high](severity) level about [exams](academic_trigger)
```

### Example 2: Crisis Suicidal Intent

```yaml
- intent: mental_health/crisis/suicide
  examples: |
    - I'm having thoughts of suicide
    - I want to kill myself
    - I don't want to live anymore
```

## References

- [Rasa Documentation on Avoiding Intent Confusion](https://rasa.com/docs/rasa/generating-nlu-data)
- [Hierarchical Intent Classification Techniques](https://dev.to/vonagedev/how-to-build-an-intent-classification-hierarchy-d4) 