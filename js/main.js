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
