# Cooking AI

## Description
Cooking AI is a mobile app that lets you get the best recipes based on the products you have and the preferences you set. Upload a photo of your fridge (or any product spread) and the AI will analyze it and return 3–4 matching recipes.

## History of development
Many students and other people can't even cook a simple dish without someone's help. This app lets them become the real kings of cooking. Set up your dietary restrictions, cooking skill level, favourite cuisines, and how much time you have to get perfect detailed recipes.

## Stack
- **iOS App:** Swift  
- **Backend:** Python, Django (DRF), OpenAI API

## How to deploy?

### Backend
```bash
# 1) setup
git clone <repo>.git && cd <repo>/api/backend
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# 2) config
echo "OPENAI_API_KEY=sk-xxxx" > .env
mkdir -p api/images

# 3) db
python manage.py migrate

# 4) run (no nginx)
python manage.py runserver 0.0.0.0:<PORT>

### iOS App (super short)

1. Open the Xcode project.
2. Set backend base URL:

   ```swift
   let BASE = URL(string: "http://<SERVER_IP>:<PORT>")!
   ```
3. Build & Run. Pick a photo → send → receive recipes.
