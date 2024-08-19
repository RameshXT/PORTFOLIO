document.addEventListener('DOMContentLoaded', function() {
    const text = "Ramesh Kanna";
    const typingEffect = document.getElementById('typing-effect');
    let index = 0;

    function typeWriter() {
        if (index < text.length) {
            typingEffect.textContent += text.charAt(index);
            index++;
            setTimeout(typeWriter, 150); // Adjust typing speed here
        } else {
            typingEffect.style.borderRight = 'none'; // Optionally remove cursor after typing
        }
    }

    typeWriter();
});
