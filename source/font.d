module font;
// These imports are public here because this module is useless without those.
public import allegro5.allegro;
public import allegro5.allegro_font;

// Basically just a convenience way of having a global font
// so we don't have to pass around 500 different identical fonts.
class Font
{
	static ALLEGRO_FONT* font;
}
