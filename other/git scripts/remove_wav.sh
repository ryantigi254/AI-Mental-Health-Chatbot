
#!/bin/bash

git filter-branch --force --index-filter \

  "git rm --cached --ignore-unmatch \

  'Research/General Research/NotebookLM/Podcast 1/Mental Health Chatbot.wav' \

  'Research/General Research/NotebookLM/Podcast 2/Mental Health Chatbot 2.wav' \

  'Research/General Research/NotebookLM/Podcast 3/Mental Health Chatbot 3.wav' \

  'Research/General Research/NotebookLM/Podcast 4/Mental Health Chatbot 4.wav' \

  'Research/General Research/NotebookLM/podcast 5/Mental Health Chatbot 5.wav'" \

  --prune-empty -- --all

