document.addEventListener('DOMContentLoaded', function() {
    const hero = document.querySelector('.hero');
    const features = document.querySelectorAll('.feature');

    // Add class to hero section when it comes into view
    const heroObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                hero.classList.add('visible');
            } else {
                hero.classList.remove('visible');
            }
        });
    }, { threshold: 0.1 });

    heroObserver.observe(hero);

    // Add class to feature sections when they come into view
    const featureObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            } else {
                entry.target.classList.remove('visible');
            }
        });
    }, { threshold: 0.1 });

    features.forEach(feature => {
        featureObserver.observe(feature);
    });
});

    document.querySelector('.login-btn').addEventListener('mouseleave', function() {
        this.classList.remove('active');
    });


    // typing effect
    const dynamicText = document.querySelector("#typing-effect");
    const name = "Ramesh Kanna";
    
    // Variables to track the position and deletion status of the text
    let charIndex = 0;
    let isDeleting = false;
    
    const typeEffect = () => {
        const currentChar = name.substring(0, charIndex);
        dynamicText.textContent = currentChar;
        dynamicText.classList.add("stop-blinking");
    
        if (!isDeleting && charIndex < name.length) {
            // Type the next character
            charIndex++;
            setTimeout(typeEffect, 200); // Adjust typing speed here
        } else if (isDeleting && charIndex > 0) {
            // Remove the previous character
            charIndex--;
            setTimeout(typeEffect, 100); // Adjust deleting speed here
        } else {
            // Switch to deleting if the current text is fully typed or deleted
            isDeleting = !isDeleting;
            dynamicText.classList.remove("stop-blinking");
            setTimeout(typeEffect, isDeleting ? 1200 : 1000); // Pause before deleting or next word
        }
    }
    
    typeEffect();
    