shader_type spatial;

uniform sampler2D Albedo;

void fragment() {
	ALBEDO = texture(Albedo,UV+(TIME*1.0)).rgb;
	ROUGHNESS = 0.1;
	SPECULAR = 1.0;
	METALLIC = 0.5;
	EMISSION = texture(Albedo,UV+(TIME*0.2)).rgb * pow(sin(TIME - (SCREEN_UV.r * 2.0)),4.0) * 0.0; 
}
