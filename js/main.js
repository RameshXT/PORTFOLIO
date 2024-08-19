// Start of script for handling DOM events and animations
document.addEventListener('DOMContentLoaded', function() {
    // Start of section for observing the hero section visibility
    const hero = document.querySelector('.hero');
    const heroObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                hero.classList.add('visible'); // Add 'visible' class when hero is in view
            } else {
                hero.classList.remove('visible'); // Remove 'visible' class when hero is out of view
            }
        });
    }, { threshold: 0.1 }); // Trigger when 10% of the hero section is visible

    heroObserver.observe(hero); // Start observing the hero section
    // End of section for observing the hero section visibility

    // Start of section for observing feature sections visibility
    const features = document.querySelectorAll('.feature');
    const featureObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible'); // Add 'visible' class when feature is in view
            } else {
                entry.target.classList.remove('visible'); // Remove 'visible' class when feature is out of view
            }
        });
    }, { threshold: 0.1 }); // Trigger when 10% of the feature section is visible

    features.forEach(feature => {
        featureObserver.observe(feature); // Start observing each feature section
    });
    // End of section for observing feature sections visibility
});

// Start of section for handling the login button hover effect
document.querySelector('.login-btn').addEventListener('mouseleave', function() {
    this.classList.remove('active'); // Remove 'active' class when mouse leaves the button
});
// End of section for handling the login button hover effect

// Start of section for typing effect
const dynamicText = document.querySelector("#typing-effect");
const name = "Ramesh Kanna";

// Variables to track the position and deletion status of the text
let charIndex = 0;
let isDeleting = false;

const typeEffect = () => {
    const currentChar = name.substring(0, charIndex); // Get the current text to display
    dynamicText.textContent = currentChar; // Update text content
    dynamicText.classList.add("stop-blinking"); // Stop the blinking cursor effect

    if (!isDeleting && charIndex < name.length) {
        charIndex++; // Move to the next character
        setTimeout(typeEffect, 200); // Adjust typing speed here
    } else if (isDeleting && charIndex > 0) {
        charIndex--; // Move to the previous character
        setTimeout(typeEffect, 100); // Adjust deleting speed here
    } else {
        isDeleting = !isDeleting; // Toggle between typing and deleting
        dynamicText.classList.remove("stop-blinking"); // Start blinking cursor effect
        setTimeout(typeEffect, isDeleting ? 1200 : 1000); // Pause before starting to delete or type again
    }
}

typeEffect(); // Start the typing effect
// End of section for typing effect
