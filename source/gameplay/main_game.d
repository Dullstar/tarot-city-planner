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
		map = new Map(100, 100, Settings.screen_size_x - 128, Settings.screen_size_y - 8);
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
		topbar = new UI
		(
			map.buffer_size_x,
			8,
			0,
			0
		);
		auto starting_roads = [19, 119, 120, 121, 122, 123, 124, 125, 126, 127];
		foreach (road; starting_roads)
		{
			auto x = road % map.size_x;
			auto y = road / map.size_y;
			map.cursor.move(x, y);
			map.build_new_map_object(tile_names.road);
		}
		map.cursor.move(-1, -1);
		make_sidebar_layouts();
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
				if (parent.mouse_controller.click_y >= 8)
				{
					map.cursor.move(click_x / 16, (click_y - 8)/ 16);
					coords = "@(" ~ map.cursor.x.to!string ~ ", " ~ map.cursor.y.to!string ~ ")";
					tile_click_handling();
					road_proximity = map.check_road_proximity();
					road_adjacent = map.check_road_adjacent();
				}
				else
				{
					topbar.process_click(parent.mouse_controller.click_x, parent.mouse_controller.click_y);
				}
			}
			else
			{
				sidebar.process_click(parent.mouse_controller.click_x, parent.mouse_controller.click_y);
			}
		}
		if (parent.mouse_controller.pressed[mouse_buttons.M2])
		{
			map.cursor.move(-1, -1);
			sidebar.set_layout(sidebar_settings.none);
			tile_click_handling();
		}
		sidebar.update();
	}
	override void draw()
	{	
		map.draw(scroll_x, scroll_y);
		sidebar.draw();
		topbar.draw();
		string money_text = "$" ~ money.to!string;
		al_draw_text(Font.font, al_map_rgb(255, 255, 255), 0, 0, 0, money_text.toStringz);
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
	int money = 2500;
	UI sidebar;
	UI topbar;
	string label = "";
	string coords = "";
	int selected_index;
	bool road_adjacent;
	bool road_proximity;

	// UI controls
	enum sidebar_settings : int
	{
		none,
		build_submenu,
		plains_menu,
		build_bridge,
		forest,
		farm,
		housing,
		office,
		hospital
	}
	// I think the name of this function can be improved, but it needs
	// to be called *something* for now. But it is subject to change.
	// Reason: needs to be called with clicking on a tile, or the M2 unselect.
	void tile_click_handling()
	{
		// This branch can probably be refactored.
		MapObject obj = map.get_map_object_under_cursor();
		if (obj is null)
		{
			Tile tile = map.get_tile_under_cursor();
			if (tile is null) 
			{
				sidebar.set_layout(sidebar_settings.none);
			}
			else  // tile !is null
			{
				selected_index = tile.graphics_index;
				switch (tile.graphics_index)
				{
				case tile_names.plains:
					label = "Plains";
					sidebar.set_layout(sidebar_settings.plains_menu);
					break;
				case tile_names.water:
					label = "River";
					sidebar.set_layout(sidebar_settings.build_bridge);
					break;
				default:
					label = "???";
					sidebar.set_layout(sidebar_settings.none);
				}
			}
		}
		else // obj !is null
		{
			selected_index = obj.graphics_index;
			switch (obj.graphics_index)
			{
			case tile_names.forest:
				label = "Forest";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.burnt_forest:
				label = "Burnt Forest";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.farmland:
			case tile_names.farmland_with_food:
				label = "Farm";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.house:
				label = "House";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.apartments:
				label = "Apartment";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.hospital:
				label = "Hospital";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.office:
				label = "Office";
				sidebar.set_layout(sidebar_settings.none);
				break;
			case tile_names.road:
				label = "Road";
				sidebar.set_layout(sidebar_settings.none);
				break;
			default:
				label = "???";
				sidebar.set_layout(sidebar_settings.none);
				break;
			}
		}
	}

	// Sidebar layouts
	void make_sidebar_layouts()
	{
		sidebar.set_layout(sidebar_settings.plains_menu);
		sidebar.create_text_button
		(
			"Build...",
			sidebar.margains,
			sidebar.auto_button_y,
			//(sidebar.margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size),
			{sidebar.set_layout(sidebar_settings.build_submenu);},
			{
				if (road_proximity && money > price_house) return button_state.active;
				else return button_state.inactive;
			}
		);
		sidebar.create_text_button
		(
			"Build Road: " ~ price_road.to!string,
			sidebar.margains,
			sidebar.auto_button_y,
			{create_map_object(tile_names.road);},
			{return build_road_checks();}
		);
		sidebar.set_layout(sidebar_settings.build_bridge);
		sidebar.create_text_button
		(
			"Build Bridge: " ~ price_road.to!string,
			sidebar.margains,
			sidebar.auto_button_y,
			{create_map_object(tile_names.road);},
			{return build_road_checks();}
		);
		writeln("Check in 3");
		sidebar.set_layout(sidebar_settings.build_submenu);
		sidebar.create_text_button
		(
			"Build what?",
			sidebar.margains,
			(sidebar.margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size),
			{}, {return button_state.active;}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.farmland_with_food,
			"Farm: " ~ price_farm.to!string,
			sidebar.margains / 2,
			sidebar.auto_button_y,
			{create_map_object(tile_names.farmland);},
			// As long as farm's price = min price if we got to this menu we know we can afford it
			{return button_state.active;}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.house,
			"House: " ~ price_house.to!string,
			sidebar.margains / 2,
			sidebar.auto_button_y - sidebar.margains,
			{create_map_object(tile_names.house);},
			// See farm's comment
			{return button_state.active;}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.apartments,
			"Apt.: " ~ price_apartments.to!string,
			sidebar.margains / 2,
			sidebar.auto_button_y - sidebar.margains,
			{create_map_object(tile_names.apartments);},
			{
				if (money >= price_apartments) return button_state.active;
				else return button_state.inactive;
			}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.office,
			"Office: " ~ price_office.to!string,
			sidebar.margains / 2,
			sidebar.auto_button_y - sidebar.margains,
			{create_map_object(tile_names.office);},
			{
				if (money >= price_office) return button_state.active;
				else return button_state.inactive;
			}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.hospital,
			"Hospital: " ~ price_office.to!string,
			sidebar.margains / 2,
			sidebar.auto_button_y - sidebar.margains,
			{create_map_object(tile_names.hospital);},
			{
				if (money >= price_hospital) return button_state.active;
				else return button_state.inactive;
			}
		);

		sidebar.set_layout(sidebar_settings.none);
	}
	void create_map_object(tile_names object)
	{
		map.build_new_map_object(object);
		int cost = 0;
		switch (object)
		{
		case tile_names.farmland:
			cost = price_farm;
			break;
		case tile_names.house:
			cost = price_house;
			break;
		case tile_names.apartments:
			cost = price_apartments;
			break;
		case tile_names.hospital:
			cost = price_hospital;
			break;
		case tile_names.office:
			cost = price_office;
			break;
		case tile_names.road:
			cost = price_road;
			break;
		default:
			throw new Exception("Shouldn't be attempting to build object: " ~ object.to!string);
		}
		money -= cost;
		tile_click_handling();
		road_proximity = map.check_road_proximity();
		road_adjacent = map.check_road_adjacent();
	}

	button_state build_road_checks()
	{
		if (road_adjacent) return button_state.active;
		return button_state.inactive;
	}
}
