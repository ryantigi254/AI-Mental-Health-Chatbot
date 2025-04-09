### **Development Document for Model Improvement**

#### **Objective**: 
This document outlines a detailed plan for improving the performance of the Rasa-based chatbot. The goal is to address low performance metrics, data issues, and random question handling, especially focusing on inference scenarios where users may ask known or random questions.

---

### **Overview of Current Issues**

1. **Performance Metrics**:
   - **Intent accuracy**: 5.24% (Low, indicating poor intent classification).
   - **Entity F1-score**: 74.9% (Good, but room for improvement in rare or complex entities).
   - **TEDPolicy Accuracy**: 11.9% (Struggling with dialogue management and long-term context).
   - **UnexpecTEDIntentPolicy Accuracy**: 88% (High, but this reflects fallback actions, not meaningful responses).

2. **Training Data Issues**:
   - **Missing Intents**: Some defined intents are not represented in the training data.
   - **Low Entity Examples**: For example, the entity `mental_health_severity` has only one example, which is insufficient.
   - **Duplicate Examples**: Conflicting examples like "I'm fine" labeled both as `mood_neutral` and `mood_positive`.

3. **Test Results**:
   - **F1-Score**: Most intents have 0% F1-score, indicating misclassification.
   - **Confusion Between Intents**: High confusion between related intents such as `emergency_natural_disaster`, `relationship_identity`, `relationship_abuse`.
   - **Random Question Handling**: Poor performance on random or out-of-scope questions (e.g., weather, president).

---

### **Steps for Improvement**

#### **1. Review and Clean the Training Data**

##### **Files to Update**:
- **NLU Training Data**: 
  - `data/nlu/*.yml` (e.g., `simple_nlu.yml`)
  - Remove conflicting or overlapping examples. Example: “I’m fine” should not be labeled with both `mood_neutral` and `mood_positive`. 
  - Add more diverse examples for each intent, especially those with low F1-scores.
  - Provide more examples for underrepresented entities, like `mental_health_severity`.

##### **Tasks**:
- **Remove Duplicates**: Go through training examples and eliminate any conflicting or duplicate entries.
- **Increase Examples**: Add 100+ examples for each intent. Focus on covering different variations of how users might express each intent (e.g., for `mood_negative`, ensure examples include different ways people might express sadness, anger, etc.).
- **Clarify Intent Boundaries**: Where confusion exists between similar intents (e.g., `relationship_abuse` and `relationship_identity`), clearly define the intent boundaries in the training data and domain file.

#### **2. Consolidate Similar Intents**

##### **Files to Update**:
- **Domain File**:
  - `domain.yml` (update to reflect merged or redefined intents).
  - Merge related intents such as emergency-related intents or relationship-related intents to simplify the decision-making space.
  
##### **Tasks**:
- **Review Intents**: Identify any intents that are too similar and consolidate them. For instance, merge the intents `relationship_identity` and `relationship_abuse` if they overlap in meaning.
- **Simplify the Decision Space**: For intents that are too granular (e.g., specific emotional states), consider grouping them into broader categories (e.g., mood-related intents).

#### **3. Enhance the NLU Pipeline and Model Hyperparameters**

##### **Files to Update**:
- **Pipeline Configuration**:
  - `config.yml` (Update the pipeline configuration to tune hyperparameters or try different components).
  - Review and potentially experiment with different NLU components in the pipeline, such as using a different entity extractor (CRF) or modifying the `DIETClassifier` settings.
  
##### **Tasks**:
- **Tuning Hyperparameters**:
  - Increase the size of embeddings, adjust the `epochs`, `batch_size`, and other parameters of the `DIETClassifier`.
  - Test different `hidden_layer_sizes` and `embedding_dimensions` to help the model generalize better.
- **Evaluate and Enhance Entity Recognition**: Add diverse examples for entities, and consider using more advanced entity extraction models if needed.

#### **4. Add More Training Data for Underperforming Intents**

##### **Files to Update**:
- **NLU Training Data**:
  - `data/nlu/*.yml`
  - Add more examples for intents that are underperforming, such as `express_emotion`, `emergency_mental_health`, etc. Aim for 100+ examples per intent.

##### **Tasks**:
- **Diverse Scenarios**: Add examples for edge cases and outlier scenarios to improve generalization. These could include nuanced ways of expressing emotions or complex relationship dynamics.
- **Balance Data**: Ensure that all intents are well-balanced in the dataset. Underperforming intents should have a higher number of examples compared to well-performing ones.

#### **5. Review and Improve Stories and Rules**

##### **Files to Update**:
- **Stories**:
  - `data/stories/*.yml`
  - Update the stories to ensure that all intents are represented in the conversation flow. Add stories for intents that are not currently included.
  
##### **Tasks**:
- **Add Missing Stories**: Make sure all intents have at least one story that triggers them. Create new stories for intents like `mental_health_severity`, `relationship_work_study`, etc.
- **Improve Dialogue Management**: If TEDPolicy is not working well, experiment with different policies. Try using **MemoizationPolicy** or **RulePolicy** in combination with **TEDPolicy** for better control of dialogue management.

#### **6. Improve Random Question Handling**

##### **Files to Update**:
- **Custom Actions**:
  - `actions.py` (Create a custom action to handle out-of-scope queries).
  - `domain.yml` (Add fallback actions or intents).

##### **Tasks**:
- **Implement Out-of-Scope Handling**: Add a fallback action to catch random or irrelevant questions. A possible fallback could be a response like “I am not equipped to answer this question” or redirecting the user to a human agent.
- **Custom Action for Random Queries**: Implement a **custom action** to detect and respond to queries unrelated to mental health, ensuring the bot doesn’t misclassify these under existing intents.

#### **7. Implement Custom Actions**

##### **Files to Update**:
- **Custom Actions**:
  - `actions.py` (Create or modify actions to handle dynamic responses based on user context).
  
##### **Tasks**:
- **Dynamic Responses**: For intents related to mental health severity, implement actions that ask clarifying questions or provide more personalized responses based on the context.
- **Custom Action Examples**: A custom action could trigger based on the user's mood or context, e.g., a more empathetic response if the user mentions anxiety or depression.

#### **8. Testing and Model Evaluation**

##### **Files to Update**:
- **Test Data**:
  - `data/test/test_stories.yml`, `data/test/test_nlu.yml`, `data/test/test_inputs.yml`.
  - Update and expand the test set to include more diverse and edge case scenarios.

##### **Tasks**:
- **Use `rasa test nlu` and `rasa test core` Regularly**: Test the model after every major change to ensure improvements are reflected.
- **Generate Confusion Matrix**: Review the confusion matrix to identify which intents are still misclassified and why.
- **Cross-validation**: Use cross-validation to evaluate model performance and ensure that the model generalizes well across different datasets.

---

### **Action Plan with Deadlines**

1. **Immediate Tasks** (1-2 days):
   - Clean and organize the **NLU training data** by removing duplicates and adding more diverse examples.
   - Consolidate similar intents in the **domain.yml** file.
   
2. **Mid-term Tasks** (3-4 days):
   - Implement improvements in the **NLU pipeline** by adjusting hyperparameters.
   - Add missing **stories** and **rules** in `data/stories/*.yml`.
   - Implement **custom actions** to handle out-of-scope queries and improve dynamic responses.

3. **Long-term Tasks** (5-7 days):
   - Continue testing with updated **test data** (test stories, test NLU).
   - Perform **cross-validation** and fine-tune the model based on feedback.

4. **Final Testing** (1-2 days):
   - Use `rasa test nlu` and `rasa test core` to evaluate the final model performance.
   - Ensure that improvements are reflected in intent classification, entity extraction, and dialogue management.

---

### **Testing Enhancements**

- **Unit Tests**: Implement unit tests for custom actions and stories to ensure the model behaves as expected in different scenarios.
- **Test Edge Cases**: Ensure edge cases (e.g., random questions, complex emotional expressions) are covered in both the training data and testing phases.

By following this development plan, the model’s performance should significantly improve, especially in handling both known and random questions.x