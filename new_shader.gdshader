shader_type canvas_item;

// Uniforms
uniform vec4 outline_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 0.05) = 0.01;

void fragment() {
    vec4 col = texture(TEXTURE, SCREEN_UV);

    float alpha = col.a;

    float alpha_outline = texture(TEXTURE, SCREEN_UV + vec2(outline_width, 0) * SCREEN_PIXEL_SIZE).a;
    alpha_outline = max(alpha_outline, texture(TEXTURE, SCREEN_UV + vec2(-outline_width, 0) * SCREEN_PIXEL_SIZE).a);
    alpha_outline = max(alpha_outline, texture(TEXTURE, SCREEN_UV + vec2(0, outline_width) * SCREEN_PIXEL_SIZE).a);
    alpha_outline = max(alpha_outline, texture(TEXTURE, SCREEN_UV + vec2(0, -outline_width) * SCREEN_PIXEL_SIZE).a);

    if (alpha_outline > 0 && alpha < 1.0) {
        COLOR = outline_color;
    } else {
        COLOR = col;
    }
}
