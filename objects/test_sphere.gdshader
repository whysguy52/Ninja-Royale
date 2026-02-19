shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;

// Allow tweaking transparency
uniform float alpha_scale : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    // Keep albedo (color) solid or set to a base color
    ALBEDO = vec3(1.0); 
}

void light() {
    // Calculate light intensity based on dot product and attenuation
    float light_intensity = length(LIGHT.rgb);
    light_intensity = max(light_intensity, 0.0); // No negative light
    
    // Attenuation accounts for distance and spotlight falloff
    light_intensity *= ATTENUATION; 
    
    // Multiply by light color
    vec3 light_color = LIGHT_COLOR * light_intensity;
    
    // Set alpha based on the intensity (max of RGB channels)
    ALPHA = max(light_color.r, max(light_color.g, light_color.b)) * alpha_scale;
}