module tile.tileset;

import std.stdio;
import allegro5.allegro;
import allegro5.allegro_image;

import graphics;
import tile.tile;

enum tile_names : size_t
{
	plains = 0,
	farmland = 1
}

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
	void draw_tile(Tile tile, int scroll_x, int scroll_y)
	{
		graphics[tile.graphics_index].draw(tile.x - scroll_x, tile.y - scroll_y);
	}
private:
	Graphic[] graphics;
	string intended_filename;
}
