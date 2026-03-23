shader_type spatial;
render_mode unshaded;
uniform vec4 Albedo:source_color;
uniform sampler2D AlbedoTex:filter_nearest;

uniform vec2 ScrollSpeed;
uniform vec2 Scale = vec2(1.0);


void fragment() {
	
	vec4 albedo = texture(AlbedoTex,(UV*Scale)+(TIME*ScrollSpeed));
	
	ALBEDO = albedo.rgb * Albedo.rgb;
	ALPHA = Albedo.a;
}