shader_type spatial;
render_mode depth_prepass_alpha, blend_mix, depth_draw_always, cull_back;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//ALBEDO = vec3(1.0, 1.0, 1.0); //white
}

void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	
	//Light is the incoming light color * attenuation
	//We calculate intensity as the average of the RGB light components
	float intensity = length(LIGHT.rgb);
	
	// Set alpha equal to intensity, clamped between 0 and 1
	ALPHA = clamp(intensity, 0.0, 1.0);
	
	//Ensure the light is actually added to the surface
	DIFFUSE_LIGHT += LIGHT.rgb;
}
