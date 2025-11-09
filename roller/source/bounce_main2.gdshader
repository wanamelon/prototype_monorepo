shader_type canvas_item;
render_mode world_vertex_coords; // We still use this for world-space noise

group_uniforms Squiggle;

// This controls the "blockiness" of the effect. 
// A value of 1.0 is 1x1 sprite pixels. 4.0 is 4x4 sprite pixels.
uniform float pixel_size : hint_range(1.0, 16.0) = 4.0;
// How "much" of the sprite gets wobbled. 1.0 is the full range.
uniform float strength : hint_range(0.0, 1.0) = 0.5;
// Number of pulses per second
uniform float fps = 8.0;
// Noise texture
uniform sampler2D noise : filter_linear, repeat_enable;
// Scale for the noise texture in world coordinates
uniform vec2 scale = vec2(1.0);

group_uniforms;

varying vec4 modulate;
varying vec2 noise_uv; // We get this from the vertex shader

void vertex() {
	modulate = COLOR;
	// Use world coordinates for scale-independent noise
	noise_uv = (VERTEX - MODEL_MATRIX[3].xy) / (vec2(textureSize(noise, 0)) * scale);
}

void fragment() {
	// --- Part 1: Pixelate the Sprite ---
	
	// Get the size of one "block" in UV space
	vec2 block_size = TEXTURE_PIXEL_SIZE * pixel_size;
	
	// Find the center of the block this screen-pixel is in
	vec2 block_center_uv = (floor(UV / block_size) + 0.5) * block_size;
	
	// Sample the *original* texture color from that block center
	vec4 color = texture(TEXTURE, block_center_uv);
	
	// If the original color is transparent, just discard.
	if (color.a < 0.1) {
		discard;
	}

	// --- Part 2: Pixelated Alpha Clip (The "Frog" Effect) ---
	
	// Snap the *noise_uv* to the *same* world-space grid size.
	// This ensures one block on-screen maps to one "noise" value.
	vec2 noise_uv_snapped = (floor(noise_uv / block_size) + 0.5) * block_size;
	
	// Sample the noise texture (value 0.0 to 1.0)
	float noise_sample = texture(noise, noise_uv_snapped).r;
	
	// --- Part 3: Animate the "Wobble" ---
	
	// Create a pulse that goes from 0.0 -> 1.0 -> 0.0
	float pulse = (sin(TIME * fps * PI) + 1.0) * 0.5; 
	
	// Map this pulse to the "strength". 
	// This gives us a threshold that animates from 0.0 up to `strength` and back.
	float threshold = pulse * strength;

	// --- Part 4: Final Check ---
	
	// If the noise value for this block is "weaker" than the current
	// pulse, discard the pixel.
	if (noise_sample < threshold) {
		discard;
	}
	
	// If it survives, draw the pixel.
	COLOR = color * modulate;
}