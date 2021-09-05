module gameplay.main_game;
import allegro5.allegro;
import std.stdio;
import std.string;
import std.conv;
import std.format;
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
import population;
import disaster;

class MainGame : GameState
{
public:
	this(ALLEGRO_BITMAP* main_buffer, MainWindow parent)
	{
		super(main_buffer, parent);
		map = new Map(100, 100, Settings.screen_size_x - 152, Settings.screen_size_y - 8);
		scroll_x = 0;
		scroll_y = 0;
		scroll_speed = 4;
		regular_scroll_speed = scroll_speed;
		speed_up_scroll_speed = 10;
		max_scroll_x = (tile_size * map.size_x) - map.buffer_size_x;
		max_scroll_y = (tile_size * map.size_y) - map.buffer_size_y;
		food = 50;
		money = 2500;
		population = new Population(null);
		disaster_gen = new DisasterGenerator(population);
		population.register_disaster_handle(disaster_gen.disaster);
		sidebar = new UI
		(
			Settings.screen_size_x - map.buffer_size_x,
			Settings.screen_size_y,
			map.buffer_size_x,
			0
		);
		topbar = new UI(map.buffer_size_x, 8, 0, 0);
		population_menu = new UI(Settings.screen_size_x, Settings.screen_size_y, 0, 0);
		prediction_menu = new UI(Settings.screen_size_x, Settings.screen_size_y, 0, 0);
		game_over_menu = new UI(Settings.screen_size_x, Settings.screen_size_y, 0, 0);
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
		make_topbar_layout();
		make_pop_menu_layout();
		make_game_over_layout();
		make_prediction_layout();
		string ns = "[Next Season]";
		next_season_button = new TextButton
		(
			ns,
			Settings.screen_size_x - al_get_text_width(Font.font, ns.toStringz),
			Settings.screen_size_y - al_get_font_line_height(Font.font),
			&next_season,
			{return button_state.active;}
		);
	}
	override void update()
	{
		if (ui_state == active_state.map)
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
			// cheats for debugging
			if (parent.kb_controller.raw_pressed[ALLEGRO_KEY_0])
			{
				money += 10_000;
				food += 100;
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
				else if (parent.mouse_controller.click_x > Settings.screen_size_x - next_season_button.size_x
					&& parent.mouse_controller.click_y > Settings.screen_size_y - next_season_button.size_y)
				{
					next_season_button.on_click();
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
			topbar.update();
		}
		else if (ui_state == active_state.pop_menu)
		{
			population_menu.update();
			if (parent.mouse_controller.pressed[mouse_buttons.M1])
			{
				population_menu.process_click(parent.mouse_controller.click_x, parent.mouse_controller.click_y);
			}
		}
		else if (ui_state == active_state.game_over)
		{
			game_over_menu.update();
		}
		else if (ui_state == active_state.prediction_menu)
		{
			prediction_menu.update();
			if (parent.mouse_controller.pressed[mouse_buttons.M1])
			{
				prediction_menu.process_click(parent.mouse_controller.click_x, parent.mouse_controller.click_y);
			}
		}
	}
	override void draw()
	{	
		if (ui_state == active_state.map)
		{
			map.draw(scroll_x, scroll_y);
			sidebar.draw();
			next_season_button.draw();
			topbar.draw();
			/*string money_text = format!"$%d  %d food"(money, food);
			al_draw_text(Font.font, al_map_rgb(255, 255, 255), 0, 0, 0, money_text.toStringz);*/
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
		else if (ui_state == active_state.pop_menu)
		{
			population_menu.draw();
		}
		else if (ui_state == active_state.game_over)
		{
			game_over_menu.draw();
		}
		else if (ui_state == active_state.prediction_menu)
		{
			prediction_menu.draw();
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
	int money;
	int food;
	int current_season;
	UI sidebar;
	UI topbar;
	UI population_menu;
	UI prediction_menu;
	UI game_over_menu;
	string label = "";
	string coords = "";
	int selected_index;
	bool road_adjacent;
	bool road_proximity;
	int season;
	Population population;
	TextButton next_season_button;
	DisasterGenerator disaster_gen;
	int farm_count;

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
	enum active_state : int
	{
		map,
		pop_menu,
		prediction_menu,
		game_over
	}
	active_state ui_state = active_state.map;

	void next_season()
	{
		season += 1;
		food -= population.total;
		int food_up = population.available_farmers < farm_count ?
			population.available_farmers : farm_count;
		food_up *= 10;
		food += food_up;
		int money_up_of = population.available_office_workers < Office.total_capacity ?
			population.available_office_workers : Office.total_capacity;
		money_up_of *= 250;
		int money_up_wood = population.available_lumberjacks * 200;
		money += money_up_of + money_up_wood;
		money -= population.total * 100;
		if (food < 0 || money < 0 || population.total > Housing.total_capacity)
		{
			ui_state = active_state.game_over;
		}
		map.update_season();
		disaster_gen.update_season();
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
				sidebar.set_layout(sidebar_settings.housing);
				break;
			case tile_names.apartments:
				label = "Apartment";
				sidebar.set_layout(sidebar_settings.housing);
				break;
			case tile_names.hospital:
				label = "Hospital";
				sidebar.set_layout(sidebar_settings.hospital);
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
			"[Build]",
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
			"[Build Road: " ~ price_road.to!string ~ "]",
			sidebar.margains,
			sidebar.auto_button_y,
			{create_map_object(tile_names.road);},
			{return build_road_checks();}
		);
		sidebar.set_layout(sidebar_settings.build_bridge);
		sidebar.create_text_button
		(
			"[Build Bridge: " ~ price_road.to!string ~ "]",
			sidebar.margains,
			sidebar.auto_button_y,
			{create_map_object(tile_names.road);},
			{return build_road_checks();}
		);
		sidebar.set_layout(sidebar_settings.build_submenu);
		/*sidebar.create_text_button
		(
			"Build what?",
			sidebar.margains,
			(sidebar.margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size),
			{}, {return button_state.active;}
		);*/
		sidebar.create_dynamic_text
		(
			sidebar.margains,
			(sidebar.margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size),
			{return "Build what?";}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.farmland_with_food,
			"[Farm: " ~ price_farm.to!string ~ "]",
			sidebar.margains / 2,
			sidebar.auto_button_y + al_get_font_line_height(Font.font) * 2,
			{farm_count++; create_map_object(tile_names.farmland);},
			// As long as farm's price = min price if we got to this menu we know we can afford it
			{return button_state.active;}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.house,
			"[House: " ~ price_house.to!string ~ "]",
			sidebar.margains / 2,
			sidebar.auto_button_y,
			{create_map_object(tile_names.house);},
			// See farm's comment
			{return button_state.active;}
		);
		sidebar.create_tile_button
		(
			map.tileset,
			tile_names.apartments,
			"[Apt.: " ~ price_apartments.to!string ~ "]",
			sidebar.margains / 2,
			sidebar.auto_button_y,
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
			"[Office: " ~ price_office.to!string ~ "]",
			sidebar.margains / 2,
			sidebar.auto_button_y,
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
			"[Hospital: " ~ price_office.to!string ~ "]",
			sidebar.margains / 2,
			sidebar.auto_button_y,
			{create_map_object(tile_names.hospital);},
			{
				if (money >= price_hospital) return button_state.active;
				else return button_state.inactive;
			}
		);
		sidebar.set_layout(sidebar_settings.housing);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y,
			{
				auto housing = cast(Housing)map.get_map_object_under_cursor();
				return format!"Capacity: %d"(housing.capacity);
			}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y * 2,
			{return "Population:";}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y,
			{
				auto housing = cast(Housing)map.get_map_object_under_cursor();
				return format!"%d / %d"(population.total, Housing.total_capacity);
			}
		);
		sidebar.set_layout(sidebar_settings.hospital);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y,
			{
				auto hospital = cast(Hospital)map.get_map_object_under_cursor();
				return format!"Capacity: %d"(hospital.capacity);
			}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y + al_get_font_line_height(Font.font),
			{return "Total use:";}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains /2,
			sidebar.auto_dynamic_text_y,
			{
				int i;
				if (disaster_gen.disaster.active && cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					i = plague.total_sick;
				}
				else i = 0;
				return format!"%d / %d"(i, Hospital.total_capacity);
			}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y + al_get_font_line_height(Font.font),
			{return "Doctors for: ";}
		);
		sidebar.create_dynamic_text
		(
			sidebar.margains / 2,
			sidebar.auto_dynamic_text_y,
			{return format!"%d patients"(population.available_doctors * 5);}
		);
		sidebar.set_layout(sidebar_settings.none);
	}
	void make_pop_menu_layout()
	{
		population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains,
			{return format!"Current Population: %d / %d"(population.total, Housing.total_capacity);}
		);
		immutable int padding = population_menu.margains + (8 * 24);
		immutable int line = al_get_font_line_height(Font.font);
		population_menu.create_dynamic_text(
			population_menu.margains,
			population_menu.margains + line,
			{return format!"Seasonal cost: %d food ; %d population * $100 = $%d"
			(
				population.total, 
				population.total,
				population.total * 100
			);
			}
		);
		population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains + (4 * line),
			{return format!"Farmers: %d"(population.farmers);}
		);
		population_menu.create_text_button
		(
			"[Hire Farmer]",
			padding,
			population_menu.margains + (4 * line),
			{population.add_farmers(1);},
			&population_check
		);
		population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains + (6 * line),
			{return format!"Lumberjacks: %d"(population.lumberjacks);}
		);
		population_menu.create_text_button
		(
			"[Hire Lumberjack]",
			padding,
			population_menu.margains + (6 * line),
			{population.add_lumberjacks(1);},
			&population_check
		);
		population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains + (8 * line),
			{return format!"Office Workers: %d"(population.office_workers);}
		);
		population_menu.create_text_button
		(
			"[Hire Office Worker]",
			padding,
			population_menu.margains + (8 * line),
			{population.add_office_workers(1);},
			&population_check
		);
		/*population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains + (12 * line),
			{return format!"Firefighters: %d"(population.firefighters);}
		);
		population_menu.create_text_button
		(
			"[Hire Firefighter]",
			padding,
			population_menu.margains + (12 * line),
			{population.add_firefighters(1);},
			&population_check
		);*/
		population_menu.create_dynamic_text
		(
			population_menu.margains,
			population_menu.margains + (10 * line),
			{return format!"Doctors: %d"(population.doctors);}
		);
		population_menu.create_text_button
		(
			"[Hire Doctor]",
			padding,
			population_menu.margains + (10 * line),
			{population.add_doctors(1);},
			&population_check
		);
		population_menu.create_text_button
		(
			"[Back to Map]",
			population_menu.margains,
			population_menu.margains + (14 * line),
			{ui_state = ui_state.map;},
			{return button_state.active;}
		);
	}
	void make_topbar_layout()
	{
		topbar.create_dynamic_text
		(
			0,
			0,
			{return format!"%d  %d food"(money, food);}
		);
		topbar.create_text_button
		(
			"[Population]",
			8 * 20,
			0,
			{ui_state = active_state.pop_menu;},
			{return button_state.active;}
		);
		topbar.create_text_button
		(
			"[Predict]",
			8 * 32,
			0,
			{
				if (!disaster_gen.disaster.active)
				{
					disaster_gen.disaster.predict();
				}
				ui_state = active_state.prediction_menu;
			},
			{return button_state.active;}
		);
	}
	void make_game_over_layout()
	{
		game_over_menu.create_dynamic_text(
			game_over_menu.margains,
			game_over_menu.margains,
			{return "GAME OVER!";}
		);
		game_over_menu.create_dynamic_text(
			game_over_menu.margains,
			game_over_menu.margains + (3 * al_get_font_line_height(Font.font) / 2),
			{return "Your food, money, or excess housing went negative.";}
		);
	}
	void make_prediction_layout()
	{
		prediction_menu.create_dynamic_text(
			prediction_menu.margains,
			prediction_menu.margains,
			{
				string disaster_type;
				if (cast(Plague) disaster_gen.disaster) 
				{
					disaster_type = "a PLAGUE";
				}
				return "The cards predict " ~ disaster_type ~ " in "
					~ disaster_gen.seasons_until_next_disaster.to!string
					~ (disaster_gen.seasons_until_next_disaster == 1 ? " season!" : " seasons!");
			}
		);
		auto line = al_get_font_line_height(Font.font);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains,
			prediction_menu.margains + 2 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					return "Assuming no population increases:";
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains,
			prediction_menu.margains + 4 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"%d patients will become sick,"(plague.total_sick);
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains,
			prediction_menu.margains + 5 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"including %d farmers,"(plague.sick_farmers);
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains + 4 * 8,
			prediction_menu.margains + 6 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"%d lumberjacks,"(plague.sick_lumberjacks);
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains + 4 * 8,
			prediction_menu.margains + 7 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"%d office workers,"(plague.sick_office_workers);
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains + 4 * 8,
			prediction_menu.margains + 8 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"and %d doctors,"(plague.sick_doctors);
				}
				return "";
			}
		);
		prediction_menu.create_dynamic_text
		(
			prediction_menu.margains,
			prediction_menu.margains + 10 * line,
			{
				if (cast(Plague) disaster_gen.disaster)
				{
					auto plague = cast(Plague) disaster_gen.disaster;
					return format!"requiring %d hospital beds and %d available doctors to treat."
						(plague.total_sick, plague.required_doctors);
				}
				return "";
			}
		);
		// For now this button can work for any disaster type, but
		// may need several different ones later depending on the layouts and effects.
		prediction_menu.create_text_button
		(
			"[Alter cards for $20k (lessens severity)]",
			prediction_menu.margains,
			prediction_menu.margains + 12 * line,
			{
				money -= 20_000;
				disaster_gen.disaster.alter();
			},
			{
				if (money >= 20_000) return button_state.active;
				return button_state.inactive;
			}
		);
		prediction_menu.create_text_button
		(
			"[Back to Map]",
			prediction_menu.margains,
			prediction_menu.margains + (14 * line),
			{ui_state = ui_state.map;},
			{return button_state.active;}
		);
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

	button_state population_check()
	{
		if (population.total < Housing.total_capacity) return button_state.active;
		return button_state.inactive;
	}

	button_state hide_if_not_plague()
	{
		if (!cast(Plague) disaster_gen.disaster) return button_state.hidden;
		return button_state.active;
	}
}
