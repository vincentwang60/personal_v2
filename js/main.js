// Get canvas and WebGL context
const canvas = document.getElementById('webgl-canvas');
const gl = canvas.getContext('webgl');

// Mouse position - initialize to center
let mouseX = window.innerWidth / 2;
let mouseY = window.innerHeight / 2;

// Load shader from file
async function loadShader(url) {
    const response = await fetch(url);
    return await response.text();
}

// Create shader function
function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        console.error('Shader compilation error:', gl.getShaderInfoLog(shader));
        gl.deleteShader(shader);
        return null;
    }
    
    return shader;
}

// Create program function
function createProgram(gl, vertexShader, fragmentShader) {
    const program = gl.createProgram();
    gl.attachShader(program, vertexShader);
    gl.attachShader(program, fragmentShader);
    gl.linkProgram(program);
    
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
        console.error('Program linking error:', gl.getProgramInfoLog(program));
        gl.deleteProgram(program);
        return null;
    }
    
    return program;
}

// Initialize WebGL
async function init() {
    // Load shaders
    const vertexShaderSource = await loadShader('assets/vertex.glsl');
    const fragmentShaderSource = await loadShader('assets/fragment.glsl');
    
    // Create shaders and program
    const vertexShader = createShader(gl, gl.VERTEX_SHADER, vertexShaderSource);
    const fragmentShader = createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource);
    const program = createProgram(gl, vertexShader, fragmentShader);
    
    // Create a full-screen quad
    const positions = new Float32Array([
        -1, -1,
         1, -1,
        -1,  1,
        -1,  1,
         1, -1,
         1,  1,
    ]);

    // Create buffer
    const positionBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);

    // Get uniform locations
    const timeUniformLocation = gl.getUniformLocation(program, 'u_time');
    const resolutionUniformLocation = gl.getUniformLocation(program, 'u_resolution');
    const mouseUniformLocation = gl.getUniformLocation(program, 'u_mouse');
    
    // Render function
    function render() {
        gl.clearColor(0.0, 0.0, 0.0, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT);
        
        gl.useProgram(program);
        
        // Set uniforms
        gl.uniform1f(timeUniformLocation, performance.now() * 0.001);
        gl.uniform2f(resolutionUniformLocation, canvas.width, canvas.height);
        gl.uniform2f(mouseUniformLocation, mouseX, mouseY);
        
        // Debug: log mouse position every 60 frames (about once per second)
        if (Math.floor(performance.now() / 1000) % 1 === 0) {
            console.log('Setting mouse uniform:', mouseX, mouseY);
        }
        
        gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
        const positionAttributeLocation = gl.getAttribLocation(program, 'a_position');
        gl.enableVertexAttribArray(positionAttributeLocation);
        gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
        
        gl.drawArrays(gl.TRIANGLES, 0, 6);
    }

    // Animation loop
    function animate() {
        render();
        requestAnimationFrame(animate);
    }
    
    // Start animation
    animate();
}

// Set canvas size to full window
function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    gl.viewport(0, 0, canvas.width, canvas.height);
    
    // Update mouse position to stay centered if it was at center
    if (mouseX === (canvas.width / 2) && mouseY === (canvas.height / 2)) {
        mouseX = window.innerWidth / 2;
        mouseY = window.innerHeight / 2;
    }
}

// Initial resize
resizeCanvas();

// Handle window resize
window.addEventListener('resize', resizeCanvas);

// Handle mouse movement
canvas.addEventListener('mousemove', (event) => {
    const rect = canvas.getBoundingClientRect();
    mouseX = event.clientX - rect.left;
    mouseY = event.clientY - rect.top;
});

// Handle mouse leave (optional - keeps last position)
canvas.addEventListener('mouseleave', (event) => {
    // mouseX and mouseY keep their last values
});

// Start initialization
init();
