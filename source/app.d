import std.stdio;
import std.string;
import allegro5.allegro;

import controller;
import map_objects;

void initialize(bool test, string what)
{
	if (!test)
	{
		stderr.writeln("Error: failed to initialize " ~ what);
	}
}

class MainGame
{
public:
	this(int size_x, int size_y)
	{
		display = al_create_display(size_x, size_y);
		initialize((display !is null), "display");
		timer = al_create_timer(1 / 60.0);
		initialize((timer !is null), "timer");
		queue = al_create_event_queue();
		initialize((queue !is null), "event queue");

		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_timer_event_source(timer));

		main_buffer = al_create_bitmap(size_x, size_y);
		kb_controller = new KeyboardController("");
		al_start_timer(timer);
		// Font.create_fonts();
		// game_state = new GameState(main_buffer, &kb_controller);
	}
	~this()
	{
		al_destroy_display(display);
		al_destroy_timer(timer);
		al_destroy_event_queue(queue);
		// Font.destroy_fonts();
	}
	void run()
	{
		bool redraw = false;
		int ticks = 0;
		ALLEGRO_EVENT event;
		while (true)
		{
			al_wait_for_event(queue, &event);
			switch (event.type)
			{
			case ALLEGRO_EVENT_TIMER:
				++ticks;
				if (ticks == 1)
				{
					update();
					redraw = true;
				}
				break;
			case ALLEGRO_EVENT_KEY_DOWN:
				writeln("Key down event: ", event.keyboard.keycode);
				kb_controller.interpret_down(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_KEY_CHAR:
				writeln("Key char event: ", event.keyboard.keycode);
				kb_controller.interpret_char(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_KEY_UP:
				writeln("Key up event: ", event.keyboard.keycode);
				kb_controller.interpret_release(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
				return;
			default:
				// we can safely ignore any events we don't need to explicitly handle
				break;
			}
			if (redraw && al_is_event_queue_empty(queue))
			{
				draw();
				ticks = 0;
			}
		}
	}
private:
	ALLEGRO_TIMER* timer;
	ALLEGRO_EVENT_QUEUE* queue;
	ALLEGRO_DISPLAY* display;
	ALLEGRO_BITMAP* main_buffer;
	KeyboardController kb_controller;
	// GameState game_state;
	void update()
	{
		// TEMP
		foreach (i, key; kb_controller.pressed)
		{
			if (key) writeln("Pressed: ", i);
		}
		foreach (i, key; kb_controller.chars)
		{
			if (key) writeln("Char: ", i);
		}
		foreach (i, key; kb_controller.held)
		{
			if (key) writeln("Held: ", i);
		}
		foreach (i, key; kb_controller.released)
		{
			if (key) writeln("Released: ", i);
		}
		// END TEMP
		// game_state.update();
		kb_controller.prep_for_next_frame();
	}
	void draw()
	{
		al_set_target_bitmap(main_buffer);
		al_clear_to_color(al_map_rgb(0, 0, 0));
		// game_state.draw();
		al_set_target_bitmap(al_get_backbuffer(display));
		al_draw_bitmap(main_buffer, 0, 0, 0);
		al_flip_display();
	}
}

int main()
{
	return al_run_allegro({
		initialize(al_init(), "Allegro");
		initialize(al_install_keyboard(), "keyboard");
		auto main_game = new MainGame(640, 480);
		main_game.run();
		return 0;
	});
}
