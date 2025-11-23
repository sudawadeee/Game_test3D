shader_type spatial;

uniform vec4 tint_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // เขียว

void fragment() {
	ALBEDO = tint_color.rgb;  // สีผิวโมเดล
	ALPHA  = tint_color.a;    // ความทึบ
}
