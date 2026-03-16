document.addEventListener("DOMContentLoaded", () => {
    const dragonContainer = document.getElementById("dragon-container");
    const playerDeathContainer = document.getElementById("player-death-container");
    const btnCorrect = document.getElementById("btn-correct");
    const btnWrong = document.getElementById("btn-wrong");
    const combatText = document.querySelector(".combat-text");

    let isAnimating = false;

    // --- ATAC CORECT ---
    btnCorrect.addEventListener("click", () => {
        if (isAnimating) return;
        isAnimating = true;

        combatText.innerText = "CRITICAL HIT! ALGORITHM EXECUTED!";
        combatText.style.color = "#00FF00";

        // Schimbăm clasa Dragonului pentru a porni animația de Damage
        dragonContainer.classList.remove("dragon-idle");
        dragonContainer.classList.add("dragon-hurt");

        // Revenim la normal după 1 secundă
        setTimeout(() => {
            dragonContainer.classList.remove("dragon-hurt");
            dragonContainer.classList.add("dragon-idle");
            combatText.innerText = "ARE YOU READY TO FACE THE FIRE?";
            combatText.style.color = "#FFF";
            isAnimating = false;
        }, 1000);
    });

    // --- ATAC GREȘIT ---
    btnWrong.addEventListener("click", () => {
        if (isAnimating) return;
        isAnimating = true;

        combatText.innerText = "FATAL ERROR! YOU HAVE BEEN ATOMIZED!";
        combatText.style.color = "#FF0000";

        // Afișăm player-ul făcut scrum
        playerDeathContainer.classList.remove("hidden");

        // Dragonul poate rămâne pe idle sau îl putem face mai agresiv
        
        // Revenim la normal după 2 secunde
        setTimeout(() => {
            playerDeathContainer.classList.add("hidden");
            combatText.innerText = "ARE YOU READY TO FACE THE FIRE?";
            combatText.style.color = "#FFF";
            isAnimating = false;
        }, 2000);
    });
});
