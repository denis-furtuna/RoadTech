document.addEventListener("DOMContentLoaded", () => {
    // Selectăm toate cardurile și imaginile
    const elementsToAnimate = document.querySelectorAll('.glass-card');

    // Setăm starea inițială (invizibil și puțin mai jos)
    elementsToAnimate.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
    });

    // Observer care verifică când elementele intră pe ecran
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
                // Nu mai observăm după ce a apărut o dată
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1 // Declanșează când 10% din element e vizibil
    });

    // Începem observarea
    elementsToAnimate.forEach(el => observer.observe(el));
});
