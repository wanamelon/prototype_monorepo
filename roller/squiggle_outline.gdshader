shader_type canvas_item;
render_mode world_vertex_coords;

group_uniforms Squiggle;
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

uniform float timeDelay = 0.0; // use it if you don't want all the sprites to move at the same time
uniform float intensityX = 2.0; // X axis force of movement
uniform float intensityY = 2.0; // Y axis force of movement
uniform float seed = 42.0; // seed to randomize movement

void vertex() {
	float chunk = floor((TIME + timeDelay) * fps);
	float seedNum = VERTEX.x + VERTEX.y + chunk + seed;
	float offsetX = sin(seedNum * 12.9898) * 43758.5453;
	float offsetY = sin(seedNum * 32.9472) * 94726.0482;
	offsetX = fract(offsetX);
	offsetX = offsetX * 2.0 - 1.0;
	offsetY = fract(offsetY);
	offsetY = offsetY * 2.0 - 1.0;
	VERTEX += vec2(offsetX * intensityX, offsetY * intensityY);
	modulate = COLOR;
}

//void vertex() {
	//modulate = COLOR;
	//noise_uv = (VERTEX - MODEL_MATRIX[3].xy) / (vec2(textureSize(noise, 0)) * scale);
//}

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int thickness: hint_range(0, 3) = 1; // our filter's x and y ranges are [-width, width]
uniform int manhattan_max: hint_range(1, 6) = 1; // we'll only check a cell offset V if abs(V.x) + abs(V.y) <= manhattan

#define offset_multiplier vec2(PI, E)

uniform int pixel_snap_size: hint_range(0, 2) = 2;
uniform bool should_snap = true;

vec2 snap(vec2 uv, vec2 texture_pixel_size) {
	if (pixel_snap_size > 0) {
		vec2 block_size = texture_pixel_size * float(pixel_snap_size);
		return floor(((uv - 0.5) / block_size) + 0.5) * block_size + 0.5;
	} else {
		return uv;
	}
}

vec2 compute_displaced_uv(vec2 uv, vec2 texture_pixel_size) {
	vec2 noise_offset = vec2(floor(TIME * fps)) * offset_multiplier;
	vec2 uv_snapped_2 = snap(uv, texture_pixel_size);
	float noise_sample = texture(noise, uv_snapped_2 + noise_offset).r * 4.0 * PI;
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	vec2 displacement = direction * strength * 0.001;
	vec2 uv_snap = snap(uv, texture_pixel_size);
	return uv_snap + displacement;
}

float gtz(float input) { return max(0, sign(input)); }

float check(sampler2D tex, vec2 from, vec2 texture_pixel_size) {
	float result = 0.0;
	for (int i = -thickness; i <= thickness; i++) {
		for (int j = -thickness; j <= thickness; j++) {
			if (abs(i) + abs(j) <= manhattan_max) {
				vec2 offset_pos = from + vec2(float(i), float(j)) * texture_pixel_size;
				result += texture(tex, compute_displaced_uv(offset_pos, texture_pixel_size)).a;
			}
		}
	}
	return gtz(result);
}

void fragment() {
	vec2 squiggle_uv = compute_displaced_uv(UV, TEXTURE_PIXEL_SIZE);
    COLOR = texture(TEXTURE, squiggle_uv) * modulate;
	COLOR = mix(
		COLOR, outline_color,
		check(TEXTURE, UV, TEXTURE_PIXEL_SIZE) * (1.0 - gtz(COLOR.a)));
}