# 🗡️ ROAD TECH: The Infinite Knowledge Engine 🧠

![Road Tech Banner](https://img.shields.io/badge/Status-Active_Deployment-00FF00?style=for-the-badge)
![Godot Engine](https://img.shields.io/badge/Godot_4.x-478CBF?style=for-the-badge&logo=godotengine&logoColor=white)
![Python Backend](https://img.shields.io/badge/Python_FastAPI-009688?style=for-the-badge&logo=python&logoColor=white)
![AI Powered](https://img.shields.io/badge/Groq_Llama_3.1-FF8800?style=for-the-badge)

> **"Read. Think. Survive. Master any subject in the universe through trial by fire."**

**Road Tech** is not just a game; it is an infinitely scalable 16-bit educational RPG. Instead of hardcoding boring questions, this engine uses a custom Python backend to pull real-time, verified data from the **Wikipedia API**, processes it through an **AI Engine (Llama 3.1)**, and forges a unique, age-adapted quest on the spot.

Zero hallucinations. Pure facts. Brutal boss fights.

---

## 🚀 THE PIPELINE (How it works)

1. **The Request:** The player inputs ANY topic (e.g., "Quantum Physics", "Ancient Rome") and their age group.
2. **The Extraction:** Our Python API raids Wikipedia for 100% factual, verified text. 
3. **The AI Forge:** The AI structures the raw text into EXACTLY 6 interactive chapters and generates strict, context-bound multiple-choice quizzes.
4. **The Execution:** The player explores the Godot frontend, reads the generated chapters from chests, and proves their knowledge to survive.

---

## ⚔️ CORE FEATURES

* **Infinite Replayability:** Learn literally anything. If it's on Wikipedia, you can fight a dragon over it.
* **Adaptive Difficulty:** The AI adjusts vocabulary, complexity, and quiz difficulty based on the player's selected age group (from 7-10 years old to University Level).
* **Strict Source-Bound Quizzes:** The AI is strictly ordered to *never* use outside knowledge. Quizzes are generated EXCLUSIVELY from the text the player just read. No trick questions.
* **Epic Boss Battles:** Face the Final Dragon in an arena where mathematical equations and historical facts are your only weapons. Answer correctly to deal critical damage; answer wrongly and get atomized.
* **Premium 16-Bit Aesthetic:** CRT scanlines, custom sprite sheets, and high-octane pixel art animations.

---

## 🛠️ TECH STACK

### 🎮 Frontend (The Frontline)
* **Engine:** Godot 4.x
* **Language:** GDScript
* **UI/UX:** Custom pixel-art sprite sheets, animated via CSS/Godot AnimationPlayers.

### ⚙️ Backend (The Command Center)
* **Framework:** Python + FastAPI
* **Data Source:** Wikipedia API
* **AI Provider:** Groq API (Llama-3.1-8b-instant)
* **Architecture:** Strictly prompt-engineered to enforce JSON-only outputs, zero prefixes, and English-only generation via System Roles.

---

## ⚙️ DEPLOYMENT INSTRUCTIONS

Want to run the base on your local machine? Follow these orders:

### 1. Boot up the Backend (Python)
1. Navigate to the backend directory.
2. Install the heavy artillery:
   ```bash
   pip install fastapi uvicorn requests python-dotenv
