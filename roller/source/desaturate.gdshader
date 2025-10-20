shader_type canvas_item;

uniform float saturation : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);
	float luminance = dot(original_color.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 desaturated_color = mix(vec3(luminance), original_color.rgb, saturation);
	COLOR.rgb = desaturated_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
