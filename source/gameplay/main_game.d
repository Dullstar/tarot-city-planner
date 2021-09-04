module gameplay.main_game;
import allegro5.allegro;
import std.stdio;
import std.string;
import std.conv;
import gameplay.game_state;
import map;
import settings;
import constants;
import app;
import controller;
import tile;
import ui;
import map_objects;
import font;

class MainGame : GameState
{
public:
	this(ALLEGRO_BITMAP* main_buffer, MainWindow parent)
	{
		super(main_buffer, parent);
		map = new Map(100, 100, Settings.screen_size_x - 100, Settings.screen_size_y);
		scroll_x = 0;
		scroll_y = 0;
		scroll_speed = 4;
		regular_scroll_speed = scroll_speed;
		speed_up_scroll_speed = 10;
		max_scroll_x = (tile_size * map.size_x) - map.buffer_size_x;
		max_scroll_y = (tile_size * map.size_y) - map.buffer_size_y;
		sidebar = new UI
		(
			Settings.screen_size_x - map.buffer_size_x,
			Settings.screen_size_y,
			map.buffer_size_x,
			0
		);
	}
	override void update()
	{
		if (parent.kb_controller.held[command.speed_up])
		{
			scroll_speed = speed_up_scroll_speed;
		}
		if (parent.kb_controller.held[command.up])
		{
			scroll_y -= scroll_speed;
			if (scroll_y < 0)
				scroll_y = 0;
		}
		if (parent.kb_controller.held[command.down])
		{
			scroll_y += scroll_speed;
			if (scroll_y > max_scroll_y)
				scroll_y = max_scroll_y;	
		}
		if (parent.kb_controller.held[command.left])
		{
			scroll_x -= scroll_speed;
			if (scroll_x < 0)
				scroll_x = 0;
		}
		if (parent.kb_controller.held[command.right])
		{
			scroll_x += scroll_speed;
			if (scroll_x > max_scroll_x)
				scroll_x = max_scroll_x;
		}
		// now that we're done with the scrolling, put the scroll speed back in case it changed
		scroll_speed = regular_scroll_speed;
		if (parent.mouse_controller.pressed[mouse_buttons.M1])
		{
			immutable int click_x = parent.mouse_controller.click_x + scroll_x;
			immutable int click_y = parent.mouse_controller.click_y + scroll_y;
			if (parent.mouse_controller.click_x < map.buffer_size_x)
			{
				map.cursor.move(click_x / 16, click_y / 16);
				coords = "@(" ~ map.cursor.x.to!string ~ ", " ~ map.cursor.y.to!string ~ ")";
				tile_click_handling();
			}
			else
			{
				// For now do nothing. This will change.
			}
		}
		if (parent.mouse_controller.pressed[mouse_buttons.M2])
		{
			map.cursor.move(-1, -1);
			sidebar.set_layout(sidebar_settings.none);
			tile_click_handling();
		}
	}
	override void draw()
	{	
		map.draw(scroll_x, scroll_y);
		sidebar.draw();
		if (map.cursor.x > 0)
		{
			al_draw_text
			(
				Font.font, 
				al_map_rgb(255, 255, 255),
				sidebar.pos_x + sidebar.margains,
				sidebar.margains,
				0,
				label.toStringz
			);
			al_draw_text
			(
				Font.font,
				al_map_rgb(255, 255, 255),
				sidebar.pos_x + sidebar.margains,
				sidebar.margains + al_get_font_line_height(Font.font) + tile_size,
				0,
				coords.toStringz
			);
			map.tileset.draw_tile
			(
				selected_index,
				sidebar.pos_x + sidebar.margains,
				sidebar.margains + al_get_font_line_height(Font.font)
			);
		}
	}
private:
	Map map;
	int scroll_x;
	int scroll_y;
	int scroll_speed;
	int speed_up_scroll_speed;
	int regular_scroll_speed;
	int max_scroll_x;
	int max_scroll_y;
	UI sidebar;
	string label = "";
	string coords = "";
	int selected_index;

	// UI controls
	enum sidebar_settings : int
	{
		none = 0,
		build_submenu = 1,
		plains_menu = 2
	}
	// I think the name of this function can be improved, but it needs
	// to be called *something* for now. But it is subject to change.
	// Reason: needs to be called with clicking on a tile, or the M2 unselect.
	void tile_click_handling()
	{
		MapObject obj = map.get_map_object_under_cursor();
		if (obj is null)
		{
			Tile tile = map.get_tile_under_cursor();
			if (tile is null) 
			{
				// sidebar.set_layout(sidebar_settings.none);
			}
			else if (tile.graphics_index == tile_names.plains)
			{
				label = "Plains";
				selected_index = tile_names.plains;
				// sidebar.set_layout(sidebar_settings.plains_menu);
			}
			else if (tile.graphics_index == tile_names.water)
			{
				label = "River";
				selected_index = tile_names.water;
			}
			else
			{
				label = "???";
				selected_index = tile.graphics_index;
				// sidebar.set_layout(sidebar_settings.none);
			}
		}
		else if (obj.graphics_index == tile_names.forest)
		{
			label = "Forest";
			selected_index = tile_names.forest;
		}
		else
		{
			label = "???";
			selected_index = obj.graphics_index;
			// sidebar.set_layout(sidebar_settings.none);
		}
	}

	// Sidebar layouts
	void make_sidebar_layouts()
	{
		sidebar.set_layout(sidebar_settings.plains_menu);
	}

	// Ye Olde Sections of functions that are to be used as delegates later.
	void build_submenu()
	{
		sidebar.set_layout(sidebar_settings.build_submenu);
	}
	void create_house()
	{

	}

}
