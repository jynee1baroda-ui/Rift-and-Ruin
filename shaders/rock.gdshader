shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 rock_color : source_color = vec4(0.13, 0.125, 0.135, 1.0);
uniform vec4 rock_dark : source_color = vec4(0.025, 0.023, 0.03, 1.0);
uniform vec4 seam_color : source_color = vec4(1.0, 0.3, 0.04, 1.0);
uniform float plate_scale = 1.6;
uniform float glow_strength = 1.1;
uniform float seed = 7.3;

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
			vec2 offset = hash22(base + g) * 0.86 + 0.07;
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

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz * plate_scale + world.y * 0.35 + seed;
	vec2 cells = voronoi(p);
	float edge = cells.y - cells.x;
	float crack = 1.0 - smoothstep(0.01, 0.07, edge);
	float grain = noise2(world.xz * 6.0 + world.y * 6.0);
	float shade = hash21(floor(p)) * 0.5 + 0.5;
	vec3 col = mix(rock_dark.rgb, rock_color.rgb, clamp(shade * (0.7 + grain * 0.8), 0.0, 1.0));
	ALBEDO = mix(col, col * 0.4, crack * 0.8);
	EMISSION = seam_color.rgb * pow(crack, 2.5) * glow_strength * 0.35;
	ROUGHNESS = 0.88;
	METALLIC = 0.04;
}
