shader_type canvas_item;
render_mode world_vertex_coords;

group_uniforms Squiggle;
/**
 * Noise texture scale
 * By default, the noise texture's size in world coordinates is set by its resolution
*/
uniform vec2 scale = vec2(1.0);
uniform float strength = 1.0;
/**
 * Number of squiggle frames per second
*/
uniform float fps = 3.0;
uniform sampler2D noise : filter_linear, repeat_enable;
group_uniforms;

varying vec4 modulate;
varying vec2 noise_uv;

void vertex() {
	modulate = COLOR;
	noise_uv = (VERTEX - MODEL_MATRIX[3].xy) / (vec2(textureSize(noise, 0)) * scale);
}

// Use irrational constants for unique squiggles every frame
#define offset_multiplier vec2(PI, E)

uniform bool snap = false;

void fragment() {
	vec2 squiggle_block = TEXTURE_PIXEL_SIZE * 2.0;

	vec2 noise_uv_snapped;
	if (snap) {
		noise_uv_snapped = floor(noise_uv / squiggle_block) * squiggle_block;
	} else {
		noise_uv_snapped = noise_uv;
	}

	vec2 noise_offset = vec2(floor(TIME * fps)) * offset_multiplier;
	float noise_sample = texture(noise, noise_uv_snapped + noise_offset).r * 4.0 * PI;
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	vec2 displacement = direction * strength * 0.001;
	vec2 uv_snap;
	if (snap) {
		uv_snap = floor(UV / squiggle_block) * squiggle_block;
	} else {
		uv_snap = UV;
	}
	vec2 squiggle_uv = uv_snap + displacement;
	//vec2 snapped_squiggle = floor(squiggle_uv / squiggle_block) * squiggle_block;
    COLOR = texture(TEXTURE, squiggle_uv) * modulate;
}