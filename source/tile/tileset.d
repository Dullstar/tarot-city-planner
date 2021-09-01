module tile.tileset;

import std.conv;
import std.stdio;
import allegro5.allegro;
import allegro5.allegro_image;

import graphics; 
import tile.tile;

class Tileset
{
	this(string filename)
	{
		intended_filename = filename;
		// For now, we just load a default...
		graphics.length = 2;
		graphics[tile_names.plains] = new StaticImage("resources/plains.png");
		graphics[tile_names.farmland] = new StaticImage("resources/farmland.png");
	}
	void draw_tile(int tile_graphics_index, int draw_x, int draw_y)
	{
		graphics[tile_graphics_index].draw(draw_x, draw_y);
	}
private:
	Graphic[] graphics;
	string intended_filename;
}
