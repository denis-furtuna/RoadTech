// Salvăm rutele către fișierele tale GIF (va trebui să pui tu numele corecte ale fișierelor tale)
const animDragonFire = "path/to/dragon_fire.gif";        // Boss idle/atac
const animDragonHurt = "path/to/dragon_hurt.gif";        // Boss ia damage
const animPlayerAtomed = "path/to/player_atomed.gif";    // Player moare
const animPlayerThinking = "path/to/player_thinking.gif";// Player idle

const dragonImageElement = document.getElementById('dragon-anim');
const btnCorrect = document.getElementById('btn-correct');
const btnWrong = document.getElementById('btn-wrong');

let isAnimating = false;

// Ce se întâmplă când dai click pe RĂSPUNS CORECT
btnCorrect.addEventListener('click', () => {
    if(isAnimating) return;
    isAnimating = true;
    
    // Dragonul își ia damage (dă din cap)
    dragonImageElement.src = animDragonHurt;
    
    // După 1.5 secunde, revine la animația de flăcări
    setTimeout(() => {
        dragonImageElement.src = animDragonFire;
        isAnimating = false;
    }, 1500); 
});

// Ce se întâmplă când dai click pe RĂSPUNS GREȘIT
btnWrong.addEventListener('click', () => {
    if(isAnimating) return;
    isAnimating = true;
    
    // Jucătorul își ia damage (se transformă în atomed baby)
    // Înlocuim dragonul cu animația jucătorului pe ecran pentru efect
    dragonImageElement.src = animPlayerAtomed;
    
    // După 2 secunde, revine dragonul
    setTimeout(() => {
        dragonImageElement.src = animDragonFire;
        isAnimating = false;
    }, 2000);
});
