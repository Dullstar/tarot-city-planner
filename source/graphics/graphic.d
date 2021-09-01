module graphics.graphic;
import allegro5.allegro;
import allegro5.allegro_image;
import std.string;

abstract class Graphic
{
public:
	this(string image_filename)
	{
		bitmap = al_load_bitmap(image_filename.toStringz);
		assert(bitmap !is null);
	}
	~this()
	{
		al_destroy_bitmap(bitmap);
	}
	abstract void draw(int draw_x, int draw_y);
protected:
	ALLEGRO_BITMAP* bitmap;
}
