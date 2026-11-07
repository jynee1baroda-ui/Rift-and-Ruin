shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 rock_color : source_color = vec4(0.155, 0.135, 0.135, 1.0);
uniform vec4 rock_dark : source_color = vec4(0.018, 0.014, 0.019, 1.0);
uniform vec4 seam_color : source_color = vec4(1.0, 0.36, 0.05, 1.0);
uniform float plate_scale = 0.33;
uniform float seam_width = 0.011;
uniform float glow_strength = 1.6;
uniform float detail_scale = 5.0;
uniform float seed = 3.7;
uniform float roughness_value = 0.82;
uniform float bump_strength = 2.2;

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

float fbm(vec2 p) {
	float value = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amp * noise2(p);
		p *= 2.03;
		amp *= 0.5;
	}
	return value;
}

float height_at(vec2 p) {
	return fbm(p * 1.1) * 0.6 + noise2(p * 3.0) * 0.2;
}

void fragment() {
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 p = world.xz * plate_scale + seed;
	vec2 cells = voronoi(p);
	float edge = cells.y - cells.x;
	float crack = 1.0 - smoothstep(seam_width, seam_width * 2.4, edge);
	float crack_halo = 1.0 - smoothstep(seam_width * 1.6, seam_width * 8.0, edge);

	vec2 fine_cells = voronoi(world.xz * plate_scale * 3.2 + seed * 3.0);
	float fine_edge = fine_cells.y - fine_cells.x;
	float fine_crack = 1.0 - smoothstep(seam_width * 1.1, seam_width * 3.0, fine_edge);

	float grain = fbm(world.xz * detail_scale * 0.45);
	float plate_shade = hash21(floor(p));
	vec3 col = mix(rock_dark.rgb * 2.2, rock_color.rgb, clamp(0.35 + plate_shade * 0.65, 0.0, 1.0));
	col *= 0.78 + grain * 0.45;
	col = mix(col, rock_dark.rgb * 1.8, pow(1.0 - grain, 3.0) * 0.35);
	float glow_chance = step(0.7, hash21(floor(p) + 3.1));
	float heat_zone = smoothstep(0.46, 0.8, fbm(world.xz * 0.05 + seed));
	col *= 1.0 - crack_halo * 0.55;
	col *= 1.0 - crack * 0.55;
	float lava_zone = heat_zone;
	float pulse = 0.66 + 0.34 * sin(TIME * 0.85 + hash21(floor(p)) * 6.283);
	float heat = crack * (0.015 + 0.6 * lava_zone * glow_chance) + fine_crack * (0.005 + 0.08 * lava_zone);
	ALBEDO = col * COLOR.rgb;
	EMISSION = seam_color.rgb * heat * glow_strength * pulse * COLOR.rgb;
	float e = 0.14;
	float h0 = height_at(world.xz);
	float hx = height_at(world.xz + vec2(e, 0.0));
	float hz = height_at(world.xz + vec2(0.0, e));
	vec3 world_normal = normalize(vec3((h0 - hx) * bump_strength, 1.0, (h0 - hz) * bump_strength));
	NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);
	ROUGHNESS = roughness_value - grain * 0.1;
	METALLIC = 0.05;
}
