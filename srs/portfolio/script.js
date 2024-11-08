// JavaScript to reveal workflow steps one-by-one as the user scrolls down
document.addEventListener("DOMContentLoaded", () => {
    const steps = document.querySelectorAll(".workflow-step");

    // Function to check which steps are visible and reveal them
    const revealSteps = () => {
        steps.forEach((step, index) => {
            const rect = step.getBoundingClientRect();
            // Check if the step is visible in the viewport (80% of the window height)
            if (rect.top < window.innerHeight * 0.8 && rect.bottom > 0) {
                setTimeout(() => {
                    step.classList.add("active"); // Add the "active" class to reveal the step
                }, index * 200); // Stagger the reveal for each step
            }
        });
    };

    // Add an event listener to trigger reveal when scrolling
    window.addEventListener("scroll", revealSteps);
    revealSteps(); // Initially check visibility when the page loads
});

// JavaScript for the Copy Button functionality
function copyCode(button) {
    const codeText = button.previousElementSibling.querySelector("code").textContent; // Get code text from the specific code block
    // Copy the code text to the clipboard
    navigator.clipboard.writeText(codeText).then(() => {
        // Change the button text to 'Copied!' when successful
        button.textContent = 'Copied!';
        setTimeout(() => {
            button.textContent = 'Copy code'; // Reset button text after 2 seconds
        }, 2000);
    });
}
