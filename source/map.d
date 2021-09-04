module map;
import allegro5.allegro;
import std.algorithm.comparison;
import std.conv;
import tile;
import world;
import constants;
import settings;
import map_objects;

class Map
{
public:
	this(int _size_x, int _size_y, int buffer_x, int buffer_y)
	{
		map_buffer = al_create_bitmap(buffer_x, buffer_y);
		m_size_x = _size_x;
		m_size_y = _size_y;
		tileset = new Tileset("resources/tileset.txt");
		// tiles = make_world(size_x, size_y);
		tiles = load_preset_world("resources/map.txt", m_size_x, m_size_y);
		clean_preset_world();
		cursor = new Tile(-1, -1, tile_names.cursor);
	}
	~this()
	{
		al_destroy_bitmap(map_buffer);
	}
	void draw(int scroll_x, int scroll_y)
	{
		ALLEGRO_BITMAP* draw_target = al_get_target_bitmap();
		al_set_target_bitmap(map_buffer);
		al_clear_to_color(al_map_rgb(0,0,0));
		const int start_tile_x = scroll_x / tile_size;
		const int start_tile_y = scroll_y / tile_size;
		const int end_tile_x = min((scroll_x + Settings.screen_size_x) / tile_size, size_x - 1);
		const int end_tile_y = min((scroll_y + Settings.screen_size_y) / tile_size, size_y - 1);

		for (int y = start_tile_y; y <= end_tile_y; ++y)
		{
			for (int x = start_tile_x; x <= end_tile_x; ++x)
			{
				auto immutable index = get_tile_index(x, y);
				// Tiles
				tileset.draw_tile
						(
							tiles[index].graphics_index,
							x * tile_size - scroll_x,
							y * tile_size - scroll_y
						);
				// Map Objects
				if (objects[index] !is null)
				{
					tileset.draw_tile
						(
							objects[index].graphics_index,
							x * tile_size - scroll_x,
							y * tile_size - scroll_y
						);
				}
			}
		}	
		// We could technically check if this is on screen, but it probably
		// won't benefit the performance since it's just one object
		// so it's not worth the time given the strict time limit
		tileset.draw_tile(tile_names.cursor, cursor.x * tile_size - scroll_x, cursor.y * tile_size - scroll_y);
		al_set_target_bitmap(draw_target);
		al_draw_bitmap(map_buffer, 0, 0, 0);
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
	Tile get_tile_under_cursor()
	{
		// This relies on using the convention that if the cursor isn't on anything
		// it will be placed in negative coordinates. This should be -1, -1 usually.
		if (cursor.x < 0 || cursor.y < 0) return null;
		return tiles[get_tile_index(cursor.x, cursor.y)];
	}
	MapObject get_map_object_under_cursor()
	{
		if (cursor.x < 0 || cursor.y < 0) return null;
		return objects[get_tile_index(cursor.x, cursor.y)];
	}
	@property int buffer_size_x() nothrow
	{
		return al_get_bitmap_width(map_buffer);
	}
	@property int buffer_size_y() nothrow
	{
		return al_get_bitmap_height(map_buffer);
	}

	Tile cursor;
	Tileset tileset;
private:
	int m_size_x;
	int m_size_y;
	Tile[] tiles;
	MapObject[] objects;
	ALLEGRO_BITMAP* map_buffer;

	void clean_preset_world()
	{
		objects.length = tiles.length;
		foreach (i, tile; tiles)
		{
			if (tile.graphics_index == tile_names.forest)
			{
				tile.change_tile_type(tile_names.plains);
				objects[i] = new Forest(i.to!int % m_size_x, i.to!int % m_size_x);
			}
		}
	}
}
