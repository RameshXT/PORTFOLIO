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
    2. Visibility
    3. Typing Effect
    4. Scroll Visibility Styles

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
    "DevOps Engineer",
    "Creative Technologist",
    "AWS Specialist"
];

const typingDelay = 100; // Delay between typing characters (in milliseconds)
const erasingDelay = 75; // Delay between erasing characters (in milliseconds)
const newTextDelay = 300; // Delay before starting to type new text (in milliseconds)
const initialDelay = 2000; // Initial delay

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
    const elementsToShow = document.querySelectorAll('.hidden-content'); // Added

    function checkVisibility() {
        const rectHero = heroContent.getBoundingClientRect();
        const rectText = animatedText.getBoundingClientRect();
        const windowHeight = window.innerHeight;

        // Check visibility for heroContent
        if (rectHero.top <= windowHeight && rectHero.bottom >= 0) {
            heroContent.classList.add('visible');
        }

        // Check visibility for animatedText
        if (rectText.top <= windowHeight && rectText.bottom >= 0) {
            animatedText.classList.add('visible');
        }

        // Check visibility for elementsToShow
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





/* -------[  ]------- */


/* -------[  ]------- */


/* -------[  ]------- */


/* -------[  ]------- */


/* -------[  ]------- */


/*
======================================
    [ END JAVASCRIPT STYLES START ]
======================================
*/