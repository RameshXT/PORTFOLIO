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









document.addEventListener("DOMContentLoaded", function() {
    const elements = document.querySelectorAll('.scroll-trigger');

    if (!('IntersectionObserver' in window)) {
        console.warn('IntersectionObserver not supported');
        return;
    }

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            } else {
                entry.target.classList.remove('visible');
            }
        });
    }, { threshold: 0.1 });

    elements.forEach(element => {
        observer.observe(element);
    });
});

