# 🗡️ ROAD TECH: The Infinite Knowledge Engine 🧠

![Status](https://img.shields.io/badge/Status-Active_Deployment-00FF00?style=for-the-badge)
![Godot Engine](https://img.shields.io/badge/Godot_4.x-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)
![AI Powered](https://img.shields.io/badge/Groq_Llama_3.1-FF8800?style=for-the-badge)

> **"Read. Think. Survive. Master any subject in the universe through trial by fire."**

**Road Tech** is an infinitely scalable 16-bit educational RPG. Instead of hardcoding static questions, this engine pulls real-time, verified data from the **Wikipedia API**, processes it through an **AI Engine (Llama 3.1)**, and forges a unique, age-adapted quest on the spot.

Zero hallucinations. Pure facts. Brutal boss fights.

---

## 🚀 THE ARCHITECTURE (Two-Part System)

This project is split into a Front-End client (Godot/Web) and a custom Python API.

* **🎮 The Frontline (This Repository):** Contains the Godot 4 project, UI assets, HTML5 exports, and the pixel-art website. 
* **⚙️ The Command Center (Backend API):** The brain of the operation. A FastAPI server that handles Wikipedia scraping and AI prompt engineering.

---

## ⚔️ CORE FEATURES

* **Infinite Replayability:** Learn literally anything. If it's on Wikipedia, you can fight a dragon over it.
* **Adaptive Difficulty:** The AI adjusts vocabulary and quiz difficulty based on the player's selected age group.
* **Strict Source-Bound Quizzes:** Quizzes are generated EXCLUSIVELY from the text the player just read. No outside knowledge allowed.
* **Epic Boss Battles:** Face the Final Dragon in an arena where mathematical equations and historical facts are your only weapons.

---

## 🛠️ DEPLOYMENT INSTRUCTIONS

To run the complete Road Tech ecosystem locally, you must boot both the Backend and the Frontend.

### STEP 1: Boot the AI Backend
1. Clone the Backend Repository *(Link your backend repo here)*.
2. Install the required artillery:
   ```bash
   pip install -r requirements.txt

### STEP 2: Environment Setup
To keep your API keys secure and configure the environment:
1. In the `RoadTech-Backend` folder, create a new file named `.env`.
2. Open `.env` and add your Groq API key:
   ```env
   GROQ_API_KEY=your_actual_api_key_here

### STEP 4: Start the Command Center
Once the dependencies are installed and the environment is set up, initiate the server:

Run the following command in your terminal:
```bash
python server.py

The FastAPI backend will start running locally at http://127.0.0.1:5000. You can now connect the Godot frontend to this address to begin the quests.
