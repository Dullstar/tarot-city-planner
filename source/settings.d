module settings;

class Settings
{
public:
	static @safe @property int screen_size_x()
	{
		return m_screen_size_x;
	}
	static @safe @property int screen_size_y()
	{
		return m_screen_size_y;
	}
	static void set_screen_size(int new_size_x, int new_size_y)
	{
		m_screen_size_x = new_size_x;
		m_screen_size_y = new_size_y;
	}
private:
	static int m_screen_size_x;
	static int m_screen_size_y;
}
