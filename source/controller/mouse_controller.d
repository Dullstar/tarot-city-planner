module controller.mouse_controller;
import allegro5.allegro;
import std.conv;
import std.stdio;
import settings;

// The controller interface was a generic idea created for controller support,
// as well as an idea for potential AI handling in other game types,
// but that aspect hasn't been used yet. But this project could actually really
// benefit from mouse support. This will likely mean further refinement of this
// idea. But that interface just largely doesn't make sense for the mouse, I don't
// think.
// This class's interface is based on the Controller interface, but it doesn't
// actually implement it. The interface may eventually be deprecated in future
// projects and/or future post-Jam development of this project depending on how
// it holds up once controller support as well as enemy AI in other game concepts
// plays out with it.

enum mouse_buttons
{
	M1 = 0,
	M2 = 1,
	left_click = M1,
	right_click = M2,
	none
}
class MouseController
{
public:
	@property @safe ref bool[mouse_buttons.max] pressed() nothrow
    {
        return m_downs;
    }
    @property @safe ref bool[mouse_buttons.max] released() nothrow
    {
        return m_released;
    }
	@property @safe int click_x() nothrow
	{
		return most_recent_click_x;
	}
	@property @safe int click_y() nothrow
	{
		return most_recent_click_y;
	}
	void interpret_down(ALLEGRO_EVENT* event)
	in(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_DOWN)
	{
		immutable int button = event.mouse.button.to!int - 1;
		if (button < mouse_buttons.max)
		{
			immutable mouse_buttons m = button.to!mouse_buttons;
			m_downs[m] = true;
			most_recent_click_x = event.mouse.x / Settings.screen_scale;
			most_recent_click_y = event.mouse.y / Settings.screen_scale;
		}
	}
	void interpret_release(ALLEGRO_EVENT* event)
	in(event.type == ALLEGRO_EVENT_MOUSE_BUTTON_UP)
	{
		immutable int button = event.mouse.button.to!int - 1;
		if (button < mouse_buttons.max)
		{
			immutable mouse_buttons m = button.to!mouse_buttons;
			m_released[m] = true;
			most_recent_click_x = event.mouse.x / Settings.screen_scale;
			most_recent_click_y = event.mouse.y / Settings.screen_scale;
		}
	}
	void prep_for_next_frame()
	{
		m_downs[] = false;
		m_released[] = false;
	}
private:
	bool[mouse_buttons.max] m_downs;
	bool[mouse_buttons.max] m_released;
	// The mouse handling for this game should be simple enough that this
	// should be sufficient, but I don't think this would work well for
    // clicking and dragging. But priorities! Let's not overengineer the
    // mouse input for now.
	int most_recent_click_x;
	int most_recent_click_y;
}
