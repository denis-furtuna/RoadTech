document.addEventListener("DOMContentLoaded", () => {
    const dragonContainer = document.getElementById("dragon-container");
    const playerDeathContainer = document.getElementById("player-death-container");
    const btnCorrect = document.getElementById("btn-correct");
    const btnWrong = document.getElementById("btn-wrong");
    const btnKill = document.getElementById("btn-kill"); // Noul buton!
    const combatText = document.querySelector(".combat-text");

    let isAnimating = false;
    let isDragonDead = false;

    // --- ATAC CORECT (Damage) ---
    btnCorrect.addEventListener("click", () => {
        if (isAnimating || isDragonDead) return;
        isAnimating = true;

        combatText.innerText = "CRITICAL HIT! ALGORITHM EXECUTED!";
        combatText.style.color = "#00FF00";

        // Dragonul ia damage
        dragonContainer.className = "sprite-anim dragon-hurt";

        // Revine la flăcări după 1.2 secunde
        setTimeout(() => {
            dragonContainer.className = "sprite-anim dragon-idle";
            combatText.innerText = "ARE YOU READY TO FACE THE FIRE?";
            combatText.style.color = "#FFF";
            isAnimating = false;
        }, 1200);
    });

    // --- ATAC GREȘIT (Player moare) ---
    btnWrong.addEventListener("click", () => {
        if (isAnimating || isDragonDead) return;
        isAnimating = true;

        combatText.innerText = "FATAL ERROR! YOU HAVE BEEN ATOMIZED!";
        combatText.style.color = "#FF0000";

        // Afișăm player-ul făcut scrum
        playerDeathContainer.classList.remove("hidden");
        
        // Revine la normal după 2 secunde
        setTimeout(() => {
            playerDeathContainer.classList.add("hidden");
            combatText.innerText = "ARE YOU READY TO FACE THE FIRE?";
            combatText.style.color = "#FFF";
            isAnimating = false;
        }, 2000);
    });

    // --- LOVITURA FINALĂ (Dragonul Moare) ---
    btnKill.addEventListener("click", () => {
        if (isAnimating || isDragonDead) return;
        isAnimating = true;
        isDragonDead = true; // Blocăm celelalte butoane pentru totdeauna!

        combatText.innerText = "SUPREME VICTORY! DRAGON DEFEATED!";
        combatText.style.color = "#FFFF00"; // Galben victorios

        // Schimbăm clasa la animația de moarte
        dragonContainer.className = "sprite-anim dragon-death";

        // Ascundem butoanele ca să fie un final curat
        btnCorrect.style.display = "none";
        btnWrong.style.display = "none";
        btnKill.style.display = "none";
    });
});
