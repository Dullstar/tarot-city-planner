module tile.tile;

class Tile
{
public:
	this(int x, int y, int graphics_index)
	{
		m_x = x;
		m_y = y;
		m_graphics_index = graphics_index;
	}
	@safe @property int x() const nothrow
	{
		return m_x;
	}
	@safe @property int y() const nothrow
	{
		return m_y;
	}
	@safe @property int graphics_index()
	{
		return m_graphics_index;
	}
private:
	int m_x;
	int m_y;
	int m_graphics_index;
	// int temperature;
	// int precipitation;
}
