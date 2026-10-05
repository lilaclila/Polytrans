#if defined(VERTEX) || __VERSION__ > 100 || defined(GL_FRAGMENT_PRECISION_HIGH)
	#define MY_HIGHP_OR_MEDIUMP highp
#else
	#define MY_HIGHP_OR_MEDIUMP mediump
#endif

extern MY_HIGHP_OR_MEDIUMP number polytrans_time; // G.TIMERS.REAL
extern MY_HIGHP_OR_MEDIUMP number unit_px;        // pixels per game unit, so the pattern scales with resolution

// tweakables
const number FIELD_SCALE = 24.0;   // field units per game unit (24 ~ same pattern scale as on a card)
const number BLUE_HUE    = 0.55;
const number PINK_HUE    = 0.95;

number hue(number s, number t, number h)
{
	number hs = mod(h, 1.)*6.;
	if (hs < 1.) return (t-s) * hs + s;
	if (hs < 3.) return t;
	if (hs < 4.) return (t-s) * (4.-hs) + s;
	return s;
}

vec4 RGB(vec4 c)
{
	if (c.y < 0.0001)
		return vec4(vec3(c.z), c.a);

	number t = (c.z < .5) ? c.y*c.z + c.z : -c.y*c.z + (c.y+c.z);
	number s = 2.0 * c.z - t;
	return vec4(hue(s,t,c.x + 1./3.), hue(s,t,c.x), hue(s,t,c.x - 1./3.), c.w);
}

vec4 effect( vec4 colour, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec2 p = (screen_coords / max(unit_px, 1.0)) * FIELD_SCALE;
	number t = polytrans_time * 3.221;

	vec2 field_part1 = p + 50.*vec2(sin(-t / 143.6340), cos(-t / 99.4324));
	vec2 field_part2 = p + 50.*vec2(cos( t / 53.1532),  cos( t / 61.4532));
	vec2 field_part3 = p + 50.*vec2(sin(-t / 87.53218), sin(-t / 49.0000));

	number field = (1.+ (
		cos(length(field_part1) / 19.483) + sin(length(field_part2) / 33.155) * cos(field_part2.y / 15.73) +
		cos(length(field_part3) / 27.193) * sin(field_part3.x / 21.92) ))/2.;

	number res = (.5 + .5* cos( (polytrans_time / 18.) * 2.612 + ( field + -.5 ) *3.14));

	number cycle = (res + polytrans_time*0.04) * 2.0;
	number band  = 0.5 - 0.5*cos(cycle*6.28318);
	number edge  = smoothstep(0.42, 0.58, band);

	// slightly darker/more saturated than the card shader so the white badge text stays readable
	vec4 hsl = vec4(mix(BLUE_HUE, PINK_HUE, edge), mix(0.75, 0.55, edge), mix(0.50, 0.64, edge), 1.0);

	return vec4(RGB(hsl).rgb * colour.rgb, colour.a);
}
