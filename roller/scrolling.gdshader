shader_type canvas_item;

uniform bool is_manually_set_progress = true; // We need to dynamically speed up / slow down
uniform float scroll_speed :hint_range(0.0, 100.0) = 5.0;
uniform float scroll_progress = 0.0;
uniform sampler2D mask : filter_nearest;
varying vec2 sprite_scale;

void vertex() {
	// Called for every vertex the material is visible on.
	sprite_scale = vec2(MODEL_MATRIX[0][0], MODEL_MATRIX[1][1]);
}

void fragment() {
	float scroll_amount = is_manually_set_progress ? scroll_progress : TIME * scroll_speed;
	vec2 offset_uv = UV + (scroll_amount * vec2(0.0, 1.0));
	float aspect = sprite_scale.y / sprite_scale.x;
	offset_uv.y *= aspect;
	offset_uv.x += clamp(0.01 * scroll_speed, 0.01, 0.1) * sin(scroll_amount);
	vec2 blur_offset = vec2(0.0, TEXTURE_PIXEL_SIZE.y * 1.0);
	COLOR = mix(
		texture(TEXTURE, fract(offset_uv), 0.1),
		texture(TEXTURE, fract(offset_uv - blur_offset), 0.1),
		0.0
	);
	COLOR.a = texture(mask, UV).a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
