shader_type canvas_item;

uniform sampler2D noise : filter_linear, repeat_enable;

uniform float speed = 3.0;
uniform float freq = 0.1;
uniform float amp = 0.01;
uniform float noise_factor = 4.0;
uniform bool should_snap = true;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int thickness: hint_range(0, 3) = 1; // our filter's x and y ranges are [-width, width]
uniform int manhattan_max: hint_range(1, 6) = 1; // we'll only check a cell offset V if abs(V.x) + abs(V.y) <= manhattan

vec2 snap(vec2 uv, vec2 texture_pixel_size) {
	return floor(((uv - 0.5) / texture_pixel_size) + 0.5) * texture_pixel_size + 0.5;
}

float gtz(float input) { return max(0, sign(input)); }

vec2 compute_displaced_coordinate(vec2 uv, vec2 block_size) {
	vec2 wave_uv = snap(uv, block_size);
	float noise_sample = texture(noise, wave_uv).r * noise_factor * PI;
	vec2 snapped_sample = snap(uv, block_size);
	vec2 displacement = vec2(
		amp * sin((snapped_sample.x / freq) + floor(TIME * speed) + noise_sample),
		amp * cos((snapped_sample.y / freq) + floor(TIME * speed) + noise_sample)
	);
	wave_uv += displacement;
	return snap(wave_uv, block_size);
}

float check(sampler2D tex, vec2 from, vec2 texture_pixel_size, vec2 size) {
	float result = 0.0;
	for (int i = -thickness; i <= thickness; i++) {
		for (int j = -thickness; j <= thickness; j++) {
			if (abs(i) + abs(j) <= manhattan_max) {
				vec2 offset_pos = from + vec2(float(i), float(j)) * texture_pixel_size;
				result += texture(tex, compute_displaced_coordinate(offset_pos, size)).a;
			}
		}
	}
	return gtz(result);
}

void fragment() {
	vec2 block_size = should_snap? TEXTURE_PIXEL_SIZE * 2.0 : vec2(0.0001);
	vec2 snapped = compute_displaced_coordinate(UV, block_size);
	COLOR = texture(TEXTURE, snapped);
	if (sin(TIME * 4.0) > -10.0) {
		COLOR = mix(
			COLOR, outline_color,
			check(TEXTURE, UV, TEXTURE_PIXEL_SIZE, block_size) * (1.0 - gtz(COLOR.a))); // * (1.0 - gtz(COLOR.a))
	}
}
