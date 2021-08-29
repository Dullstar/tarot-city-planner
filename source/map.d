module map;
import allegro5.allegro;
import std.algorithm.comparison;
import tile;
import world;
import constants;
import settings;

class Map
{
public:
	this(int _size_x, int _size_y)
	{
		m_size_x = _size_x;
		m_size_y = _size_y;
		tileset = new Tileset("resources/tileset.txt");
		tiles = make_world(size_x, size_y);
	}
	void draw(int scroll_x, int scroll_y)
	{
		int start_tile_x = scroll_x / tile_size;
		int start_tile_y = scroll_y / tile_size;
		int end_tile_x = min((scroll_x + Settings.screen_size_x) / tile_size, size_x - 1);
		int end_tile_y = min((scroll_y + Settings.screen_size_y) / tile_size, size_y - 1);

		for (int y = start_tile_y; y <= end_tile_y; ++y)
		{
			for (int x = start_tile_x; x <= end_tile_x; ++x)
			{
				if (y >= m_size_y) {
					import std.stdio;
					writeln("The for loop got out of range in y!");
					writeln("    y = ", y);
				}
				try 
				{	tileset.draw_tile
						(
							tiles[get_tile_index(x, y)].graphics_index,
							x * tile_size - scroll_x,
							y * tile_size - scroll_y
						);
				}
				catch (Throwable)
				{
					import std.stdio;
					writeln("Tried to access element ", get_tile_index(x, y), " of array with length ", tiles.length);
				}
			}
		}	
		return;  // inserted to ease adding breakpoints.
	}
	@property @safe int size_x() const nothrow
	{
		return m_size_x;
	}
	@property @safe int size_y() const nothrow
	{
		return m_size_y;
	}
	int get_tile_index(int x, int y)
	in
	{
		assert(x < m_size_x);
		assert(y < m_size_y);
	}
	out (r)
	{
		assert(r < tiles.length);
	}
	do
	{
		return (y * m_size_x) + x;
	}
private:
	int m_size_x;
	int m_size_y;
	Tileset tileset;
	Tile[] tiles;

}
