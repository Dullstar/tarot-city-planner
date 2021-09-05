module ui.button;
import allegro5.allegro_primitives;
import font;
import std.string;
import tile.tileset;
import constants;

enum button_state
{
	active,
	inactive,
	hidden
}
abstract class Button
{
public:
	this(int size_x, int size_y, int pos_x, int pos_y, void delegate() _on_click, button_state delegate() _on_update)
	{
		on_click = _on_click;
		on_update = _on_update;
		m_size_x = size_x;
		m_size_y = size_y;
		m_pos_x = pos_x;
		m_pos_y = pos_y;
		m_state = button_state.active;
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
	@property @safe button_state state() const nothrow
	{
		return m_state;
	}
	void draw();
	/*{
		if (m_state != button_state.hidden)
		{
			al_draw_bitmap(m_bitmap, m_pos_x, m_pos_y, 0);
		}
	}*/
	void delegate() on_click;
	button_state delegate() on_update;
	void update()
	{
		m_state = on_update();
	}
protected:
	button_state m_state;
	int m_pos_x;
	int m_pos_y;
	int m_size_x;
	int m_size_y;
}

class TextButton : Button
{
public:
	this(string text, int pos_x, int pos_y, void delegate() on_click, button_state delegate() on_update)
	{
		immutable auto c_text = text.toStringz;
		immutable int size_x = al_get_text_width(Font.font, c_text);
		immutable int size_y = al_get_font_line_height(Font.font);
		m_active = al_create_bitmap(size_x, size_y);
		m_inactive = al_create_bitmap(size_x, size_y);
		auto draw_target = al_get_target_bitmap();
		al_set_target_bitmap(m_active);
		al_draw_text(Font.font, al_map_rgb(255, 255, 255), 0, 0, 0, c_text);
		al_set_target_bitmap(m_inactive);
		al_draw_text(Font.font, al_map_rgb(150, 150, 150), 0, 0, 0, c_text);
		super(size_x, size_y, pos_x, pos_y, on_click, on_update);
		al_set_target_bitmap(draw_target);
	}
	~this()
	{
		al_destroy_bitmap(m_active);
		al_destroy_bitmap(m_inactive);
	}
	override void draw()
	{
		if (m_state == button_state.active)
		{
			al_draw_bitmap(m_active, pos_x, pos_y, 0);
		}
		else if (m_state == button_state.inactive)
		{
			al_draw_bitmap(m_inactive, pos_x, pos_y, 0);
		}
	}
private:
	ALLEGRO_BITMAP* m_active;
	ALLEGRO_BITMAP* m_inactive;
}

class TileButton : Button
{
public:
	this
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
		m_tileset = tileset;
		m_graphics_index = graphics_index;
		super(tile_size, tile_size, pos_x, pos_y, on_click, on_update);
		if (text.length > 0)
		{
			has_text = true;
			immutable auto c_text = text.toStringz;
			immutable int size_x = al_get_text_width(Font.font, c_text);
			immutable int size_y = al_get_font_line_height(Font.font);
			m_active_text = al_create_bitmap(size_x, size_y);
			m_inactive_text = al_create_bitmap(size_x, size_y);
			auto draw_target = al_get_target_bitmap();
			al_set_target_bitmap(m_active_text);
			al_draw_text(Font.font, al_map_rgb(255, 255, 255), 0, 0, 0, c_text);
			al_set_target_bitmap(m_inactive_text);
			al_draw_text(Font.font, al_map_rgb(150, 150, 150), 0, 0, 0, c_text);
			al_set_target_bitmap(draw_target);
			m_size_x += size_x;
			if (m_size_y < size_y) m_size_y = size_y;
		}
	}
	override void draw()
	{
		if (m_state != button_state.hidden)
		{
			m_tileset.draw_tile(m_graphics_index, pos_x, pos_y);

			if (m_state == button_state.inactive)
			{
				// not the prettiest but oh well
				al_draw_filled_rectangle(pos_x, pos_y, pos_x + tile_size, pos_y + tile_size, al_map_rgba(60, 60, 60, 127));
				if (has_text)
				{
					al_draw_bitmap(m_inactive_text, pos_x + tile_size, pos_y, 0);
				}
			}
			else if (has_text)
			{
				al_draw_bitmap(m_active_text, pos_x + tile_size, pos_y, 0);
			}
		}
	}
private:
	Tileset m_tileset;
	int m_graphics_index;
	ALLEGRO_BITMAP* m_active_text;
	ALLEGRO_BITMAP* m_inactive_text;
	bool has_text;
}