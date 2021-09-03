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
		max_scroll_x = (tile_size * map.size_x) - Settings.screen_size_x;
		max_scroll_y = (tile_size * map.size_y) - Settings.screen_size_y;
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
			// This could *definitely* get cached. The main reason for not doing that is that
			// we don't have any signal system for any of the many mostly-stable parameters
			// changing: while there aren't any currently, they'd be a potential problem later.
			// But certianly this (and the comparable code in x) are a missed optimization opportunity
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
		// This is probably safe to remove, but may be worth having lying around
		// if implementing resizing or something like that.
		// But if you're reading this in the future and that's been implemented,
		// go ahead and remove this if statement.
		/*if (parent.kb_controller.pressed[command.start])
		{
			import std.stdio.writeln;
			writeln("These tiles will be drawn:");
			for (int y = scroll_y / tile_size; y < (scroll_y + Settings.screen_size_y) / tile_size; ++y)
			{
				for (int x = scroll_x / tile_size; x < (scroll_x + Settings.screen_size_x) / tile_size; ++x)
				{
					writeln("    ", x, ", ", y, "    index: ", map.get_tile_index(x, y));

				}
			}
		}*/
		if (parent.mouse_controller.pressed[mouse_buttons.M1])
		{
			map.cursor = new Tile
			(
				(parent.mouse_controller.click_x + scroll_x) / 16,
				(parent.mouse_controller.click_y + scroll_y) / 16,
				tile_names.cursor
			); // long term maybe I should make it possible to move Tile.
		}
		if (parent.mouse_controller.pressed[mouse_buttons.M2])
		{
			map.cursor = new Tile(-1, -1, tile_names.cursor);
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
	int max_scroll_x;
	int max_scroll_y;
}
