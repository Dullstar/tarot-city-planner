module settings;

class Settings
{
public:
	static @safe @property int screen_size_x() nothrow
	{
		return m_screen_size_x;
	}
	static @safe @property int screen_size_y() nothrow
	{
		return m_screen_size_y;
	}
	static @safe @property int screen_scale() nothrow
	{
		return m_screen_scale;
	}
	static void set_screen_size(int new_size_x, int new_size_y) nothrow
	{
		m_screen_size_x = new_size_x;
		m_screen_size_y = new_size_y;
	}
	static void set_screen_scale(int new_scale) nothrow
	{
		m_screen_scale = new_scale;
	}
private:
	static int m_screen_size_x;
	static int m_screen_size_y;
	static int m_screen_scale;
}
