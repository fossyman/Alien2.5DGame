shader_type spatial;
uniform vec4 Albedo:source_color = vec4(1.0);
uniform vec4 NoiseAlbedo:source_color = vec4(1.0);
uniform float Emission;
uniform sampler2D Noise:filter_nearest;
uniform sampler2D DisplayTexture:filter_nearest;

uniform vec2 ScrollSpeed;
uniform vec2 Scale = vec2(1.0);


void fragment() {
	
	vec4 noise = texture(Noise,(UV*Scale)+(TIME*ScrollSpeed));
	vec4 display = texture(DisplayTexture,UV) * Albedo;

	EMISSION = ((noise.rgb * NoiseAlbedo.rgb) * (display.rgb * Albedo.rgb)) * Emission;
}