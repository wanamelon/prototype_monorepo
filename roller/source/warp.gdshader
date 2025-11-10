shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float warp_amount :hint_range(0.0, 5.0) = 1.0;

vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;

	vec2 warped = uv + delta * delta_offset;
	return (warped - 0.5) / mix(1.0,1.2,warp_amount/5.0) + 0.5;
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, warp(SCREEN_UV));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
