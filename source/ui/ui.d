module ui.ui;
import allegro5.allegro;
import ui.button;
import ui.dynamic_text;
import controller.mouse_controller;
import std.stdio;
import std.conv;
import tile.tileset;
import constants;
import font;

// There's a null check to make sure things won't crash if you don't,
// but that's about all it does after construction.
class UI
{
public:
	this(int size_x, int size_y, int pos_x, int pos_y)
	{
		m_size_x = size_x;
		m_size_y = size_y;
		m_pos_x = pos_x;
		m_pos_y = pos_y;
		m_bitmap = al_create_bitmap(size_x, size_y);
		m_layout = 0;
		m_buttons.length = 1;
		m_text.length = 1;
	}
	~this()
	{
		al_destroy_bitmap(m_bitmap);
	}
	void process_click(int click_x, int click_y)
	{
		immutable int adj_x = click_x - m_pos_x;
		immutable int adj_y = click_y - m_pos_y;
		foreach(button; m_buttons[m_layout])
		{
			if (button.state == button_state.active
				&& adj_x >= button.pos_x 
				&& adj_x < button.pos_x + button.size_x
				&& adj_y >= button.pos_y
				&& adj_y < button.pos_y + button.size_y)
			{
				button.on_click();
			}
		}
	}
	void create_text_button(string text, int pos_x, int pos_y, void delegate() on_click, button_state delegate() on_update)
	{
		m_buttons[m_layout] ~= new TextButton(text, pos_x, pos_y, on_click, on_update);
	}
	void create_tile_button
	(
		Tileset tileset, 
		int graphics_index, 
		string text,
		int pos_x, 
		int pos_y, 
		void delegate() on_click, 
		button_state delegate() on_update
	)
	{
		m_buttons[m_layout] ~= new TileButton(tileset, graphics_index, text, pos_x, pos_y, on_click, on_update);
	}
	void create_dynamic_text(int pos_x, int pos_y, string delegate() on_update)
	{
		m_text[m_layout] ~= new DynamicText(pos_x, pos_y, on_update);
	}
	int auto_button_y()
	{
		if (m_buttons[m_layout].length == 0)
		{
			return (margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size);
		}
		return m_buttons[m_layout][$ - 1].pos_y + m_buttons[m_layout][$ - 1].size_y + m_margains;
	}
	int auto_button_x()
	{
		return m_margains;
	}
	int auto_dynamic_text_y()
	{
		if (m_text[m_layout].length == 0)
		{
			return (margains * 2) + al_get_font_line_height(Font.font) + (2 * tile_size);
		}
		return m_text[m_layout][$ - 1].pos_y + al_get_font_line_height(Font.font);
	}
	void draw()
	{
		auto target = al_get_target_bitmap();
		al_set_target_bitmap(m_bitmap);
		al_clear_to_color(al_map_rgb(127, 127, 127));
		// writeln(m_layout, ": ", m_buttons[m_layout]);
		foreach (button; m_buttons[m_layout])
		{
			button.draw();
		}
		foreach (text; m_text[m_layout])
		{
			text.draw();
		}
		al_set_target_bitmap(target);
		al_draw_bitmap(m_bitmap, m_pos_x, m_pos_y, 0);
	}
	void update()
	{
		// Button update functions are for hiding/inactivating/showing
		// buttons, so no need to run them on the inactive layouts.
		foreach (button; m_buttons[m_layout])
		{
			button.update();
		}	
		foreach (text; m_text[m_layout])
		{
			text.update();
		}
	}
	// Creates the layout if it doesn't exist.
	void set_layout(int layout)
	{
		// writeln(m_buttons.length, " == ", m_text.length);
		assert(m_buttons.length == m_text.length);
		if (layout >= m_buttons.length)
		{
			m_buttons.length = layout + 1;
			m_text.length = layout + 1;
		}
		m_layout = layout;
	}
	@property @safe int margains() const nothrow
	{
		return m_margains;
	}
	@property @safe int size_x() const nothrow
	{
		return m_size_x;
	}
	@property @safe int size_y() const nothrow
	{
		return m_size_y;
	}
	@property @safe int pos_x() const nothrow
	{
		return m_pos_x;
	}
	@property @safe int pos_y() const nothrow
	{
		return m_pos_y;
	}
	@property @safe int layout() const nothrow
	{
		return m_layout;
	}

	void debug_contents()
	{
		writeln("Layout: ", m_layout);
		writeln("Text: ", m_text);
		writeln("Buttons: ", m_buttons);
	}
private:
	int m_size_x;
	int m_size_y;
	int m_pos_x;
	int m_pos_y;
	int m_layout;
	int m_margains = 8;
	ALLEGRO_BITMAP* m_bitmap;
	Button[][] m_buttons;
	DynamicText[][] m_text;
}
