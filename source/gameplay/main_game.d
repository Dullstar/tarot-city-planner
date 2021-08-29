module gameplay.main_game;
import allegro5.allegro;
import gameplay.game_state;
import map;
import settings;
import constants;
import app;
import controller;

class MainGame : GameState
{
public:
	this(ALLEGRO_BITMAP* main_buffer, MainWindow parent)
	{
		super(main_buffer, parent);
		map = new Map(100, 100);
		scroll_x = 0;
		scroll_y = 0;
		scroll_speed = 4;
	}
	override void update()
	{
		if (parent.kb_controller.held[command.up])
		{
			scroll_y -= scroll_speed;
			if (scroll_y < 0)
				scroll_y = 0;
		}
		if (parent.kb_controller.held[command.down])
		{
			scroll_y += scroll_speed;
			int max_scroll_y = (tile_size * map.size_y) - Settings.screen_size_y;
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
			int max_scroll_x = (tile_size * map.size_x) - Settings.screen_size_x;
			if (scroll_x > max_scroll_x)
				scroll_x = max_scroll_x;
		}
		if (parent.kb_controller.pressed[command.start])
		{
			import std.stdio;
			writeln("These tiles will be drawn:");
			for (int y = scroll_y / tile_size; y < (scroll_y + Settings.screen_size_y) / tile_size; ++y)
			{
				for (int x = scroll_x / tile_size; x < (scroll_x + Settings.screen_size_x) / tile_size; ++x)
				{
					import std.stdio;
					writeln("    ", x, ", ", y, "    index: ", map.get_tile_index(x, y));

				}
			}
		}
			
	}
	override void draw()
	{
		map.draw(scroll_x, scroll_y);
	}
private:
	Map map;
	int scroll_x;
	int scroll_y;
	int scroll_speed;
}
