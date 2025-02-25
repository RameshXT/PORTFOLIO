/* -------[ HANDLE FORM SUBMISSION ]------- */
function handleSubmit(event) {
    event.preventDefault();
    
    const form = document.getElementById('myForm');
    const formData = new FormData(form);

    fetch(form.action, {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (response.ok) {
            window.location.href = '/home/index.html';
        } else {
            alert('There was a problem with your submission.');
        }
    })
    .catch(error => {
        alert('There was an error: ' + error);
    });
}

/* -------[ SMOOTH ENTRY ]------- */
window.addEventListener('load', () => {
    document.body.classList.add('loaded');
});