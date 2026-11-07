shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;

uniform vec4 crust_color : source_color = vec4(0.26, 0.07, 0.025, 1.0);
uniform vec4 hot_color : source_color = vec4(0.95, 0.26, 0.02, 1.0);
uniform vec4 core_color : source_color = vec4(0.98, 0.6, 0.14, 1.0);
uniform float flow_speed = 0.035;
uniform float plate_scale = 1.15;
uniform float glow_strength = 1.0;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
	float n = hash21(p);
	return vec2(n, hash21(p + n * 17.13));
}

vec2 voronoi(vec2 p) {
	vec2 base = floor(p);
	vec2 f = fract(p);
	float best = 8.0;
	float second = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 g = vec2(float(x), float(y));
			vec2 offset = hash22(base + g) * 0.84 + 0.08;
			vec2 r = g + offset - f;
			float d = dot(r, r);
			if (d < best) {
				second = best;
				best = d;
			} else if (d < second) {
				second = d;
			}
		}
	}
	return vec2(sqrt(best), sqrt(second));
}

float noise2(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), u.x),
			mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm_lava(vec2 p) {
	float value = 0.0;
	float amp = 0.55;
	for (int i = 0; i < 3; i++) {
		value += amp * noise2(p);
		p *= 2.1;
		amp *= 0.5;
	}
	return value;
}

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 flow = vec2(TIME * flow_speed, TIME * flow_speed * 0.6);
	vec2 p = (world.xz + flow) * plate_scale;
	vec2 warp = vec2(noise2(p * 0.28), noise2(p * 0.28 + 11.7)) * 1.5 + vec2(noise2(p * 0.9), noise2(p * 0.9 + 4.3)) * 0.4;
	vec2 cells = voronoi(p + warp);
	float edge = cells.y - cells.x;
	float seam = 1.0 - smoothstep(0.006, 0.042, edge);
	float wobble = noise2(world.xz * 1.7 + flow * 4.0);
	float molten = smoothstep(0.46, 0.82, fbm_lava(world.xz * 0.09 + flow * 2.0));
	float heat = smoothstep(0.22, 0.95, seam * 0.9 + wobble * 0.18 + molten * 0.55);
	float core = smoothstep(0.7, 1.0, heat);
	vec3 col = mix(crust_color.rgb, hot_color.rgb, clamp(0.1 + heat * 0.85, 0.0, 1.0));
	col = mix(col, core_color.rgb, core * 0.3);
	col += hot_color.rgb * molten * 0.22;
	float pulse = 0.78 + 0.22 * sin(TIME * 0.7 + hash21(floor(p)) * 6.283);
	ALBEDO = col * (0.7 + (heat * 0.75 + core * 0.25 + molten * 0.2) * glow_strength * pulse);
}
