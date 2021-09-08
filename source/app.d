module app;

import std.stdio;
import std.string;
import allegro5.allegro;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import allegro5.allegro_font;

import controller;
import settings;
import gameplay;
import font;

void initialize(bool test, string what)
{
	if (!test)
	{
		stderr.writeln("Error: failed to initialize " ~ what);
	}
}

class MainWindow
{
public:
	this(int size_x, int size_y)
	{
		display = al_create_display(size_x * Settings.screen_scale, size_y * Settings.screen_scale);
		initialize((display !is null), "display");
		timer = al_create_timer(1 / 60.0);
		initialize((timer !is null), "timer");
		queue = al_create_event_queue();
		initialize((queue !is null), "event queue");
		Font.font = al_create_builtin_font();

		al_register_event_source(queue, al_get_keyboard_event_source());
		al_register_event_source(queue, al_get_display_event_source(display));
		al_register_event_source(queue, al_get_timer_event_source(timer));
		al_register_event_source(queue, al_get_mouse_event_source());

		main_buffer = al_create_bitmap(size_x, size_y);
		kb_controller = new KeyboardController("");
		mouse_controller = new MouseController();
		al_start_timer(timer);
		// al_grab_mouse(display);
		// Font.create_fonts();
		current_state = new MainMenu(main_buffer, this);
	}
	~this()
	{
		al_destroy_display(display);
		al_destroy_timer(timer);
		al_destroy_event_queue(queue);
		al_destroy_font(Font.font);
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
				// writeln("Key down event: ", event.keyboard.keycode);
				kb_controller.interpret_down(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_KEY_CHAR:
				// writeln("Key char event: ", event.keyboard.keycode);
				kb_controller.interpret_char(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_KEY_UP:
				// writeln("Key up event: ", event.keyboard.keycode);
				kb_controller.interpret_release(event.keyboard.keycode);
				break;
			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
				mouse_controller.interpret_down(&event);
				break;
			case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
				mouse_controller.interpret_release(&event);
				break;
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
				return;
			case ALLEGRO_EVENT_DISPLAY_SWITCH_OUT:
				kb_controller.handle_switch_out();
				al_ungrab_mouse();
				break;
			case ALLEGRO_EVENT_DISPLAY_SWITCH_IN:
				// al_grab_mouse(display);
				break;
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
	void queue_state_change(game_state_type new_state)
	{
		next_state = new_state;
		state_change_queued = true;
	}
	// This could be encapsulated a little better, but this will do
	// for now. It shouldn't be too problematic to change with later
	// refactoring; the main problem is that we can't make the compiler
	// enforce using it correctly, but I'm the only one working on this
	// for now anyway, so it should be okay.
	KeyboardController kb_controller;
	MouseController mouse_controller;
private:
	ALLEGRO_TIMER* timer;
	ALLEGRO_EVENT_QUEUE* queue;
	ALLEGRO_DISPLAY* display;
	ALLEGRO_BITMAP* main_buffer;
	void update()
	{
		/*// TEMP
		foreach (i, key; kb_controller.pressed)
		{
			if (key) writeln("Pressed: ", i);
		}
		//foreach (i, key; kb_controller.held)
		//{
		//	if (key) writeln("Held: ", i);
		//}
		foreach (i, key; kb_controller.released)
		{
			if (key) writeln("Released: ", i);
		}
		// END TEMP*/
		current_state.update();
		kb_controller.prep_for_next_frame();
		mouse_controller.prep_for_next_frame();
		if (state_change_queued)
		{
			// writeln("Processing state change...");
			final switch (next_state)
			{
			case game_state_type.main_menu:
				current_state = new MainMenu(main_buffer, this);
				break;
			case game_state_type.main_game:
				current_state = new MainGame(main_buffer, this);
				break;
			}
			state_change_queued = false;
		}
	}
	void draw()
	{
		al_set_target_bitmap(main_buffer);
		al_clear_to_color(al_map_rgb(0, 0, 0));
		current_state.draw();
		al_set_target_bitmap(al_get_backbuffer(display));
		al_draw_bitmap(main_buffer, 0, 0, 0);
		al_draw_scaled_bitmap
			(
				main_buffer,
				0, 
				0, 
				al_get_bitmap_width(main_buffer), 
				al_get_bitmap_height(main_buffer), 
				0, 
				0, 
				al_get_display_width(display),
				al_get_display_height(display),
				0
			);
		al_flip_display();
	}

	// Used for controlling states
	GameState current_state;
	game_state_type next_state;
	bool state_change_queued = false;
}

int main()
{
	return al_run_allegro({
		initialize(al_init(), "Allegro");
		initialize(al_init_image_addon(), "Allegro image addon.");
		initialize(al_init_primitives_addon(), "Allegro primitives addon.");
		initialize(al_install_keyboard(), "keyboard");
		initialize(al_install_mouse(), "mouse");
		initialize(al_init_font_addon(), "Allegro font addon.");
		Settings.set_screen_size(480, 270);  // 480 x 256 is best tile-aligned that fits in 16:9
		Settings.set_screen_scale(2);
		auto main_game = new MainWindow(Settings.screen_size_x, Settings.screen_size_y);
		main_game.run();
		return 0;
	});
}
