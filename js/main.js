/*
======================================
        [ SCRIPT INFORMATION ]
======================================

    File:           main.js
    Script Name:    Main Script | Ramesh
    Category:       Portfolio
    Author:         Ramesh
    Version:        1.0

    Description:    Contains the main JavaScript functionality for the portfolio project.

    Design and Developed by: Ramesh

======================================
        [ END SCRIPT INFORMATION ]
======================================
*/

/*
======================================
    [ JAVASCRIPT TABLE OF CONTENTS ]
======================================

    [ Table of Contents ]

    1. Menu Toggle
    2. Typing Effect
    3. Scroll Visibility Styles
    4. Nav bar smooth naviagte

======================================
    [ END JAVASCRIPT TABLE OF CONTENTS ]
======================================
*/


/*
 ======================================
    [ JAVASCRIPT STYLES START ]
 ======================================
 */


/* -------[ MENU TOGGLE ]------- */

document.addEventListener('DOMContentLoaded', function() {
    const menuToggle = document.querySelector('.menu-toggle');
    const nav = document.querySelector('header nav');

    menuToggle.addEventListener('click', function() {
        menuToggle.classList.toggle('active');
        nav.classList.toggle('active');
    });
});


/* -------[ TYPING EFFECT ]------- */

const typedElement = document.getElementById("typing-text");

const textsToType = [
    "Ramesh Kanna",
    "A DevOps Engineer",
    "A Creative Technologist",
    "A Newcomer to the IT Industry from a non-IT Background"
];

const typingDelay = 100;
const erasingDelay = 75;
const newTextDelay = 300;
const initialDelay = 2000;

let textIndex = 0; 
let charIndex = 0; 

function typeText() {
    if (charIndex < textsToType[textIndex].length) {
        typedElement.textContent += textsToType[textIndex].charAt(charIndex);
        charIndex++;
        setTimeout(typeText, typingDelay);
    } else {
        setTimeout(eraseText, newTextDelay);
    }
}

function eraseText() {
    if (charIndex > 0) {
        typedElement.textContent = textsToType[textIndex].substring(0, charIndex - 1);
        charIndex--;
        setTimeout(eraseText, erasingDelay);
    } else {
        textIndex++;
        if (textIndex >= textsToType.length) textIndex = 0;
        setTimeout(typeText, newTextDelay);
    }
}

window.onload = function() {
    if (textsToType.length) {
        setTimeout(typeText, initialDelay);
    }
};

/* -------[ SCROLL VISIBILITY STYLES ]------- */

document.addEventListener('DOMContentLoaded', function() {
    const heroContent = document.querySelector('.hero-content');
    const animatedText = document.querySelector('.animated-text');
    const elementsToShow = document.querySelectorAll('.hidden-content');

    function checkVisibility() {
        const rectHero = heroContent.getBoundingClientRect();
        const rectText = animatedText.getBoundingClientRect();
        const windowHeight = window.innerHeight;

        if (rectHero.top <= windowHeight && rectHero.bottom >= 0) {
            heroContent.classList.add('visible');
        }

        if (rectText.top <= windowHeight && rectText.bottom >= 0) {
            animatedText.classList.add('visible');
        }

        elementsToShow.forEach(element => {
            const rectElement = element.getBoundingClientRect();
            if (rectElement.top <= windowHeight && rectElement.bottom >= 0) {
                element.classList.add('visible');
            } else {
                element.classList.remove('visible');
            }
        });
    }

    window.addEventListener('scroll', checkVisibility);
    window.addEventListener('resize', checkVisibility);
    checkVisibility(); 
});


/* -------[ SCROLL VISIBILITY STYLES & LOTTIE PLAYER VISIBILITY ]------- */

document.addEventListener('DOMContentLoaded', function() {
    const lottiePlayerContainer = document.querySelector('.lottie-player-container');
    
    function checkVisibility() {
        const rect = lottiePlayerContainer.getBoundingClientRect();
        const windowHeight = window.innerHeight;

        if (rect.top <= windowHeight && rect.bottom >= 0) {
            lottiePlayerContainer.style.opacity = '1'; // Make visible
            lottiePlayerContainer.style.transform = 'translateY(0)'; // Slide into view
        } else {
            lottiePlayerContainer.style.opacity = '0'; // Hide
            lottiePlayerContainer.style.transform = 'translateY(20px)'; // Slide out of view
        }
    }

    window.addEventListener('scroll', checkVisibility);
    checkVisibility(); // Check visibility on page load
});



/* -------[ NAV BAR SMOOTH NAVIGATE ]------- */

document.addEventListener('DOMContentLoaded', function() {
    const navLinks = document.querySelectorAll('nav ul li a');

    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault(); // Prevent default anchor click behavior

            const targetId = this.getAttribute('href'); // Get the target section ID
            const targetSection = document.querySelector(targetId);

            if (targetSection) {
                const startPosition = window.pageYOffset;
                const targetPosition = targetSection.getBoundingClientRect().top + window.pageYOffset;
                const distance = targetPosition - startPosition;
                const duration = 1200; // Duration in milliseconds
                let start = null;

                function smoothScroll(timestamp) {
                    if (!start) start = timestamp;
                    const progress = timestamp - start;
                    const scrollProgress = Math.min(progress / duration, 1);
                    window.scrollTo(0, startPosition + distance * easeInOutQuad(scrollProgress));

                    if (progress < duration) {
                        requestAnimationFrame(smoothScroll);
                    }
                }

                function easeInOutQuad(t) {
                    return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
                }

                requestAnimationFrame(smoothScroll);
            }
        });
    });
});

/* -------[ FOOTER ]------- */
const currentYear = new Date().getFullYear();
          
            const startYear = 2024;
            const copyrightText = (currentYear > startYear) ? `${startYear} - ${currentYear}` : startYear;
          
            document.getElementById('copyright').textContent = copyrightText;

/* -------[  ]------- */


/* -------[  ]------- */


/* -------[  ]------- */


/*
======================================
    [ END JAVASCRIPT STYLES START ]
======================================
*/