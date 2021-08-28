module graphics.static_image;
import allegro5.allegro;
import graphics.graphic;

class StaticImage : Graphic
{
	this(string image_filename)
	{
		super(image_filename);
	}
	final override void draw(int draw_x, int draw_y)
	{
		al_draw_bitmap(bitmap, draw_x, draw_y, 0);
	}
}
