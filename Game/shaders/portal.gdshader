shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 inner_color : source_color = vec4(1.0, 0.46, 0.08, 1.0);
uniform vec4 outer_color : source_color = vec4(0.22, 0.02, 0.46, 1.0);
uniform float intensity = 1.4;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 3; i++) {
		value += amp * noise(p);
		p = p * 2.1 + vec2(5.2, 1.3);
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float r = length(uv) * 2.0;
	float ang = atan(uv.y, uv.x);
	float swirl = fbm(vec2(ang * 1.4 + r * 4.0 - TIME * 0.9, r * 3.0 - TIME * 0.5));
	float mask = smoothstep(1.0, 0.55, r);
	float ring = smoothstep(0.15, 0.0, abs(r - 0.92));
	float core = smoothstep(0.6, 0.0, r);
	vec3 col = mix(outer_color.rgb, inner_color.rgb, clamp(swirl * 0.85 + core * 0.5, 0.0, 1.0));
	col += inner_color.rgb * ring * 0.55;
	ALBEDO = col * intensity * (0.65 + swirl * 1.35);
	ALPHA = mask;
}
