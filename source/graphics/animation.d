module graphics.animation;
import graphics.graphic;
import allegro5.allegro;

class Animation : Graphic
{
public:
	this(string animation_filename)
	{
		// we would need to import some stuff, but we don't have
		// enough to do it.
		super(animation_filename);  // NEEDS CHANGED LATER
	}
	final override void draw(int draw_x, int draw_y)
	{
		// TODO: Finish this.
	}
}
