shader_type spatial;
varying float intensity;

void vertex() {
	
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(1.0, 1.0, 1.0);
	//ALPHA = AO_LIGHT_AFFECT;
	// Called for every pixel the material is visible on.
}

void light() {
	//ALPHA = dot(NORMAL, SPECULAR_LIGHT) + dot(NORMAL, DIFFUSE_LIGHT);
	//Called for every pixel for every light affecting the material.
	//Uncomment to replace the default light processing function with this one.
}
