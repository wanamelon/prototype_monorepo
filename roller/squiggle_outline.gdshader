shader_type canvas_item;
render_mode world_vertex_coords;

group_uniforms Squiggle;
uniform vec2 scale = vec2(1.0);
uniform float strength = 1.0;
uniform float random_offset = 0.0;
uniform float fps = 3.0;
uniform sampler2D noise : filter_linear, repeat_enable;
group_uniforms;

varying vec4 modulate;
varying vec2 noise_uv;

void vertex() {
	modulate = COLOR;
}

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

vec2 compute_displaced_uv(vec2 uv, vec2 texture_pixel_size, vec2 global_uv) {
	vec2 noise_offset = vec2(random_offset + floor(TIME * fps)) * offset_multiplier;
	float noise_sample = texture(noise, snap(uv, texture_pixel_size) + noise_offset).r * 4.0 * PI;
	vec2 direction = vec2(cos(noise_sample), sin(noise_sample));
	vec2 displacement = direction * strength * 0.001;
	vec2 uv_snap = snap(uv, texture_pixel_size);
	return uv_snap + displacement;
}

float gtz(float input) { return max(0, sign(input)); }

float check(sampler2D tex, vec2 from, vec2 texture_pixel_size, vec2 global_uv) {
	float result = 0.0;
	for (int i = -thickness; i <= thickness; i++) {
		for (int j = -thickness; j <= thickness; j++) {
			if (abs(i) + abs(j) <= manhattan_max) {
				vec2 offset_pos = from + vec2(float(i), float(j)) * texture_pixel_size;
				result += texture(tex, compute_displaced_uv(offset_pos, texture_pixel_size, global_uv)).a;
			}
		}
	}
	return gtz(result);
}

void fragment() {
	vec2 global_uv = SCREEN_UV;
	vec2 squiggle_uv = compute_displaced_uv(UV, TEXTURE_PIXEL_SIZE, global_uv);
    COLOR = texture(TEXTURE, squiggle_uv) * modulate;
	COLOR = mix(
		COLOR, outline_color,
		check(TEXTURE, UV, TEXTURE_PIXEL_SIZE, global_uv) * (1.0 - gtz(COLOR.a)));
}