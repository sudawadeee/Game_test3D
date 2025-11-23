shader_type spatial;
render_mode cull_back, specular_schlick_ggx;

uniform float wave_speed     = 1.5;
uniform float wave_amplitude = 0.15;   // คลื่นใหญ่
uniform float wave_frequency = 3.0;

uniform float small_wave_amplitude = 0.03;  // คลื่นเล็ก
uniform float small_wave_frequency = 1.0;

uniform vec4 water_color      : source_color = vec4(0.0, 0.35, 0.8, 0.7);
uniform vec3 reflection_color : source_color = vec3(0.4, 0.6, 0.9);

uniform float shininess        = 0.9;
uniform float fresnel_power    = 3.0;
uniform float fresnel_strength = 0.45;

void vertex() {
	float t = TIME * wave_speed;

	// คลื่นชุดใหญ่
	float wave_x1 = sin((VERTEX.x + t) * wave_frequency);
	float wave_z1 = cos((VERTEX.z + t * 0.8) * wave_frequency * 0.7);

	// คลื่นชุดเล็ก ความถี่สูงกว่าหน่อย
	float wave_x2 = sin((VERTEX.x * 1.7 - t * 1.3) * small_wave_frequency);
	float wave_z2 = cos((VERTEX.z * 1.4 + t * 1.1) * small_wave_frequency);

	float big_wave   = (wave_x1 + wave_z1) * 0.5 * wave_amplitude;
	float small_wave = (wave_x2 + wave_z2) * 0.5 * small_wave_amplitude;

	float height = big_wave + small_wave;

	// ดัน vertex ขึ้นลงตามคลื่น
	VERTEX.y += height;

	// ปรับ normal ให้รับแสงดีขึ้น
	vec3 n = NORMAL;
	n.y += height * 4.0;
	NORMAL = normalize(n);
}

void fragment() {
	// สีหลักของน้ำ
	vec3 base_color = water_color.rgb;

	// pseudo Fresnel ใช้เทียบกับทิศขึ้น (ไม่ต้องใช้ตำแหน่งกล้อง)
	vec3 up = vec3(0.0, 1.0, 0.0);
	float ndotu = clamp(dot(normalize(NORMAL), up), 0.0, 1.0);
	float fresnel = pow(1.0 - ndotu, fresnel_power) * fresnel_strength;

	// ผสมสีสะท้อนท้องฟ้า / ขอบน้ำ
	vec3 color = base_color + reflection_color * fresnel;

	ALBEDO = color;
	ALPHA  = water_color.a;

	METALLIC = 0.1;
	ROUGHNESS = 1.0 - shininess;
	SPECULAR = 0.8;
}
