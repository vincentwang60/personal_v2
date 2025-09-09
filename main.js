// Get canvas and WebGL context
const canvas = document.getElementById('webgl-canvas');
const gl = canvas.getContext('webgl');

// Set canvas size to full window
function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);
}

// Initial resize
resizeCanvas();

// Handle window resize
window.addEventListener('resize', resizeCanvas);

// Set clear color to blue
gl.clearColor(0.0, 0.0, 1.0, 1.0);

// Clear the canvas
gl.clear(gl.COLOR_BUFFER_BIT);
