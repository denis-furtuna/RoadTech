import os
from dotenv import load_dotenv
from fastapi import FastAPI
import requests
import json
import uvicorn

# 1. ORDIN DE DESCHIDERE A SEIFULUI
load_dotenv()

app = FastAPI(title="Comandamentul Central ROAD TECH")

# 2. EXTRAGEREA MUNIȚIEI ÎN SIGURANȚĂ
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

# 3. VERIFICARE DE SECURITATE (Să nu plecăm la luptă cu arma goală)
if not GROQ_API_KEY:
    raise ValueError("ALARMĂ CRITICĂ: Cheia GROQ_API_KEY nu a fost găsită în fișierul .env!")

# ==========================================
# EXTRACTORUL WIKIPEDIA (MUNIȚIE GREA)
# ==========================================

def extrage_wikipedia(subiect: str):
    print(f"🕵️ Căutăm pe Wiki dosarul MASIV pentru: {subiect}")
    # AM MODIFICAT 'exsentences=25' CA SĂ ADUCĂ MULT MAI MULT TEXT!
    url = f"https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exsentences=25&explaintext=1&format=json&redirects=1&titles={subiect}"
    headers = {"User-Agent": "RoadTechGame/1.0 (contact@roadtech.com)"}
    try:
        raspuns = requests.get(url, headers=headers)
        if raspuns.status_code != 200: return None
        date = raspuns.json()
        pagini = date.get('query', {}).get('pages', {})
        id_pagina = list(pagini.keys())[0]
        if id_pagina == "-1": return None
        return pagini[id_pagina].get('extract', "Lipsă text.")
    except Exception as e:
        print(f"❌ Eroare Wikipedia: {e}")
        return None


def interogare_ai(prompt_text: str):
    print("🤖 Trimitem ordinele către satelitul Groq...")
    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    payload = {
        "model": "llama-3.1-8b-instant",
        "messages": [
            {
                # TRĂGACIUL SUPREM: Aici îi spălăm creierul!
                "role": "system",
                "content": """You are a strictly monolingual English data API. 
RULES YOU MUST OBEY OR DIE:
1. NEVER output Romanian. ENGLISH ONLY.
2. NEVER prefix questions! Do NOT use 'Q1.', '1.', 'Question:'. Write ONLY the pure question text.
3. NEVER prefix options! Do NOT use 'A)', 'A1.', '1-', 'Option A:'. Write ONLY the pure answer text.
4. Output clean, raw JSON only."""
            },
            {
                "role": "user",
                "content": prompt_text
            }
        ],
        "temperature": 0.1,  # Am redus temperatura la 0.1 ca să fie și mai ascultător și mai puțin "creativ"
        "response_format": {"type": "json_object"}
    }

    try:
        raspuns = requests.post(url, headers=headers, json=payload)
        if raspuns.status_code != 200:
            print(f"❌ Eroare AI: {raspuns.text}")
            return {"error": "AI-ul a picat pe front!"}

        text_ai = raspuns.json()['choices'][0]['message']['content']
        return json.loads(text_ai)
    except Exception as e:
        print(f"❌ Eroare la procesarea JSON-ului: {e}")
        return {"error": "JSON corupt de la AI!"}


# ==========================================
# RUTELE DE COMUNICAȚIE (ACUM CER ȘI VÂRSTA!)
# ==========================================

@app.get("/roadmap")
def cere_roadmap(subiect: str, varsta: str = "18-25 ani"):
    wiki_text = extrage_wikipedia(subiect)
    if not wiki_text:
        return {"capitole": [{"title": "Error 404", "content": "Subject doesn't exist!"}] * 6}

    prompt = f"""Read this text: [{wiki_text}]
Divide the information into EXACTLY 6 progressive subchapters.
TARGET AUDIENCE: {varsta} old. Adjust the complexity, vocabulary, and depth of the explanation to perfectly match this age group! Make the text long and detailed!
STRICT RULES:
1. Output strictly as JSON.
Format: {{"capitole": [{{"title": "Real Title", "content": "Detailed theory adjusted for age..."}}]}}"""
    return interogare_ai(prompt)


# MODIFICĂ DOAR RUTA /quiz ÎN server.py (SAU PUNE TOT CODUL DACĂ VREI SIGURANȚĂ)
@app.post("/quiz")
async def cere_quiz_strict(date: dict):
    subiect_text = date.get("text_capitol", "")
    varsta = date.get("varsta", "15-18 years old")

    if not subiect_text or len(subiect_text) < 10:
        return {"intrebari": [{"question_text": "Missing intel in this chapter!", "options": ["A", "B", "C", "D"],
                               "correct_answer": "A"}]}

    prompt = f"""SOURCE TEXT: [{subiect_text}]
TARGET AUDIENCE: {varsta}
MISSION: Generate EXACTLY 3 multiple-choice questions.

STRICT RULES:
1. EXCLUSIVELY use the SOURCE TEXT. 
2. ENGLISH ONLY.
3. NO PREFIXES! Do not write 'Q1:' or 'A)'. Just the raw text!
4. Output ONLY JSON.
Format: {{"intrebari": [{{"question_text": "What is the core color?", "options": ["Red", "Blue", "Green", "Yellow"], "correct_answer": "Red"}}]}}"""

    return interogare_ai(prompt)


@app.get("/boss")
def cere_boss(subiect: str, varsta: str = "18-25 ani"):
    prompt = f"""You are a final Boss testing a student on '{subiect}'. 
Generate EXACTLY 5 challenging multiple-choice questions. 
TARGET AUDIENCE: {varsta} old. Adjust the difficulty of the questions to match this age group!
STRICT RULES:
1. Output strictly as JSON. Use REAL ANSWERS.
Format: {{"intrebari": [{{"question_text": "Hard Q?", "options": ["R1", "R2", "R3", "R4"], "correct_answer": "R3"}}]}}"""
    return interogare_ai(prompt)


if __name__ == '__main__':
    print("🚀 SERVERUL TACTIC ESTE ONLINE!")
    uvicorn.run(app, host="127.0.0.1", port=5000)
