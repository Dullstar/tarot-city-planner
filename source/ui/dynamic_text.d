module ui.dynamic_text;
import std.string;
import font;

class DynamicText
{
public:
	this(int pos_x, int pos_y, string delegate() on_update)
	{
		m_pos_x = pos_x;
		m_pos_y = pos_y;
		m_on_update = on_update;
		m_current_text = "";
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
		al_draw_text(Font.font, al_map_rgb(255, 255, 255), m_pos_x, m_pos_y, 0, m_current_text.toStringz);
	}
	void update()
	{
		m_current_text = m_on_update();
	}
	@property @safe string current_text() const nothrow
	{
		return current_text;
	}
private:
	int m_pos_x;
	int m_pos_y;
	string delegate() m_on_update;
	string m_current_text;
}
