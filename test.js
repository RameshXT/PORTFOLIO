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