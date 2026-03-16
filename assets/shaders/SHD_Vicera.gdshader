shader_type spatial;

uniform sampler2D AlbedoTex:filter_nearest;

uniform vec2 ScrollSpeed;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec4 albedo = texture(AlbedoTex,UV+(TIME*ScrollSpeed));
	
	ALBEDO = albedo.rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
