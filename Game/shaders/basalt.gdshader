shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform vec4 rock_color : source_color = vec4(0.155, 0.135, 0.135, 1.0);
uniform vec4 rock_dark : source_color = vec4(0.018, 0.014, 0.019, 1.0);
uniform vec4 seam_color : source_color = vec4(1.0, 0.36, 0.05, 1.0);
uniform sampler2D basalt_tex : source_color;
uniform float tex_mix = 0.42;
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
	float broad = fbm(world.xz * 0.075 + seed * 0.7);
	vec3 tex_big = texture(basalt_tex, UV).rgb;
	vec3 tex_fine = texture(basalt_tex, UV * 2.6 + vec2(0.37, 0.19)).rgb;
	vec3 tex_macro = texture(basalt_tex, UV * 0.23 + vec2(0.11, 0.67)).rgb;
	float mottle = texture(basalt_tex, UV * 0.15 + vec2(0.63, 0.29)).r;
	vec3 rock_tex = mix(mix(tex_big, tex_fine, 0.34), tex_macro, 0.38);
	float tex_lum = dot(tex_big, vec3(0.299, 0.587, 0.114));
	float fine_lum = dot(tex_fine, vec3(0.299, 0.587, 0.114));
	float tex_heat = smoothstep(0.30, 0.75, rock_tex.r);
	float plate_shade = hash21(floor(p));
	vec3 col = mix(rock_dark.rgb * 2.4, rock_color.rgb, clamp(0.30 + plate_shade * 0.70, 0.0, 1.0));
	float t_detail = clamp((tex_lum - 0.035) * 6.8, 0.0, 1.0);
	float t_fine = clamp((fine_lum - 0.035) * 8.5, 0.0, 1.0);
	col *= 0.62 + t_detail * 0.62 + t_fine * 0.16;
	col *= 0.82 + broad * 0.30 + grain * 0.14;
	col += rock_tex * (0.35 + broad * 0.40) * tex_mix;
	col *= 0.78 + mottle * 2.2;
	col *= 0.90 + t_fine * 0.22;
	float tex_seam = 1.0 - smoothstep(0.035, 0.085, tex_lum);
	col *= 1.0 - tex_seam * 0.42;
	float glow_chance = 0.35 + 0.65 * hash21(floor(p) + 3.1);
	float heat_zone = smoothstep(0.52, 0.78, fbm(world.xz * 0.09 + seed * 1.7));
	float lava_zone = smoothstep(0.5, 0.85, heat_zone * 0.6 + fbm(world.xz * 0.11 + seed) * 0.4);
	col *= 1.0 - crack_halo * 0.55;
	vec3 seam_dark = mix(rock_dark.rgb, rock_color.rgb * 0.55, t_detail);
	col = mix(col, seam_dark, crack * 0.72 + fine_crack * 0.3);
	float pulse = 0.70 + 0.30 * sin(TIME * 0.85 + hash21(floor(p)) * 6.283);
	float heat = crack * heat_zone * glow_chance * (0.35 + 0.65 * lava_zone) * 0.30;
	heat += fine_crack * lava_zone * 0.03;
	heat += tex_seam * tex_heat * lava_zone * 0.06;
	heat += tex_heat * tex_mix * (0.008 + 0.05 * lava_zone);
	ALBEDO = col * COLOR.rgb;
	EMISSION = seam_color.rgb * heat * glow_strength * pulse * COLOR.rgb * COLOR.a;
	// Side walls share this material with the floor: give them their true
	// normal and a darker albedo so the arena edge reads as a cliff.
	vec3 world_in = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float flatness = smoothstep(0.35, 0.85, abs(world_in.y));
	ALBEDO *= mix(0.34, 1.0, flatness);
	EMISSION *= mix(0.15, 1.0, flatness);
	float e = 0.11;
	float h0 = height_at(world.xz) + t_detail * 0.34;
	float hx = height_at(world.xz + vec2(e, 0.0)) + clamp((texture(basalt_tex, UV + vec2(0.031, 0.0)).r - 0.035) * 6.8, 0.0, 1.0) * 0.34;
	float hz = height_at(world.xz + vec2(0.0, e)) + clamp((texture(basalt_tex, UV + vec2(0.0, 0.031)).r - 0.035) * 6.8, 0.0, 1.0) * 0.34;
	if (flatness > 0.4) {
		vec3 world_normal = normalize(vec3((h0 - hx) * bump_strength, 1.0, (h0 - hz) * bump_strength));
		NORMAL = normalize((VIEW_MATRIX * vec4(world_normal, 0.0)).xyz);
	}
	ROUGHNESS = clamp(roughness_value - grain * 0.10 + t_detail * 0.10, 0.0, 1.0);
	METALLIC = 0.05;
}
