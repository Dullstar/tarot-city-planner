module ui.button;
import font;
import std.string;

enum button_state
{
	active,
	inactive,
	hidden
}
abstract class Button
{
public:
	this(ALLEGRO_BITMAP* bitmap, int pos_x, int pos_y, void delegate() _on_click, void delegate() _on_update)
	{
		m_bitmap = bitmap;
		on_click = _on_click;
		on_update = _on_update;
		m_size_x = al_get_bitmap_width(m_bitmap);
		m_size_y = al_get_bitmap_height(m_bitmap);
		m_pos_x = pos_x;
		m_pos_y = pos_y;
		m_state = button_state.active;
	}
	~this()
	{
		al_destroy_bitmap(m_bitmap);
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
	void draw()
	{
		if (m_state != button_state.hidden)
		{
			al_draw_bitmap(m_bitmap, m_pos_x, m_pos_y, 0);
		}
	}
	void delegate() on_click;
	void delegate() on_update;
private:
	button_state m_state;
	ALLEGRO_BITMAP* m_bitmap;
	int m_pos_x;
	int m_pos_y;
	// I'd have to remove the const and @safe if I didn't just cache these,
	// but I doubt there'd be any perf difference if I didn't store these.
	int m_size_x;
	int m_size_y;
}

class TextButton : Button
{
public:
	this(string text, int pos_x, int pos_y, void delegate() on_click, void delegate() on_update)
	{
		auto immutable c_text = text.toStringz;
		immutable int size_x = al_get_text_width(Font.font, c_text);
		immutable int size_y = al_get_font_line_height(Font.font);
		auto bitmap = al_create_bitmap(size_x, size_y);
		auto draw_target = al_get_target_bitmap();
		al_set_target_bitmap(bitmap);
		al_draw_text(Font.font, al_map_rgb(255, 255, 255), 0, 0, 0, c_text);
		super(bitmap, pos_x, pos_y, on_click, on_update);
		al_set_target_bitmap(draw_target);
	}
}

/*class GraphicButton : Button
{

}*/