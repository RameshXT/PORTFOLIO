window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});




// Function to show the notification after download completes
function showPopupNotification(message) {
const popup = document.getElementById('popupNotification');
const popupMessage = document.getElementById('popupMessage');

// Set the custom message
popupMessage.innerText = message;

// Add 'show' class to make the popup visible and animate it
popup.classList.add('show');

// Hide the popup after 3 seconds
setTimeout(() => {
popup.classList.remove('show');
}, 3000);
}

// Function to force download and show custom popup
function forceDownload(downloadLink, message) {
// Create a temporary anchor element to programmatically trigger download
const anchor = document.createElement('a');
anchor.href = downloadLink;
anchor.setAttribute('download', ''); // Set the download attribute
document.body.appendChild(anchor);
anchor.click(); // Simulate click to start the download
document.body.removeChild(anchor); // Clean up the DOM

// Show the popup with the custom message after the download starts
showPopupNotification(message);
}

// Add event listeners to the buttons with different messages
document.getElementById('sourceCodeBtn').addEventListener('click', function(e) {
e.preventDefault(); // Prevent default behavior (auto-download)
forceDownload('path/to/source-code.zip', 'Thank you, the source code has been downloaded.');
});

document.getElementById('pdfBtn').addEventListener('click', function(e) {
e.preventDefault(); // Prevent default behavior
forceDownload('path/to/document.pdf', 'Thank you, the PDF Document has been downloaded.');
});

document.getElementById('wordBtn').addEventListener('click', function(e) {
e.preventDefault(); // Prevent default behavior
forceDownload('path/to/document.docx', 'Thank you, the Word Document has been downloaded.');
});

document.getElementById('imageBtn').addEventListener('click', function(e) {
e.preventDefault(); // Prevent default behavior
forceDownload('/assets/screenshots/PortFolio-1.png', 'Thank you, the Image has been downloaded.');
}); 
