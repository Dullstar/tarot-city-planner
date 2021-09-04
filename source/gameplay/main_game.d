module gameplay.main_game;
import allegro5.allegro;
import std.stdio;
import gameplay.game_state;
import map;
import settings;
import constants;
import app;
import controller;
import tile;
import ui;

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
			if (click_x < map.buffer_size_x)
			{
				map.cursor.move(click_x / 16, click_y / 16);
			}
			else
			{
				// For now do nothing. This will change.
			}
		}
		if (parent.mouse_controller.pressed[mouse_buttons.M2])
		{
			map.cursor.move(-1, -1);
		}
	}
	override void draw()
	{	
		map.draw(scroll_x, scroll_y);
		sidebar.draw();
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

	void create_house()
	{

	}
}
