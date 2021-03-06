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
		graphics.length = tile_names.max + 1;
		graphics[tile_names.plains] = new StaticImage("resources/plains.png");
		graphics[tile_names.water] = new StaticImage("resources/water.png");
		graphics[tile_names.forest] = new StaticImage("resources/forest.png");
		graphics[tile_names.farmland] = new StaticImage("resources/farmland.png");
		graphics[tile_names.farmland_with_food] = new StaticImage("resources/farmland_with_food.png");
		graphics[tile_names.cursor] = new StaticImage("resources/cursor.png");
		graphics[tile_names.house] = new StaticImage("resources/house.png");
		graphics[tile_names.apartments] = new StaticImage("resources/apartments.png");
		graphics[tile_names.office] = new StaticImage("resources/office.png");
		graphics[tile_names.disaster_location] = new StaticImage("resources/disaster_location.png");
		graphics[tile_names.hospital] = new StaticImage("resources/hospital.png");
		graphics[tile_names.road] = new StaticImage("resources/road.png");
	}
	void draw_tile(int tile_graphics_index, int draw_x, int draw_y)
	{
		graphics[tile_graphics_index].draw(draw_x, draw_y);
	}
private:
	Graphic[] graphics;
	string intended_filename;
}
