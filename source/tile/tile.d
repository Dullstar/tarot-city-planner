module tile.tile;

abstract class Tile
{
public:
	@safe @property int x()
	{
		return m_x;
	}
	@safe @property int y()
	{
		return m_y;
	}
	@safe @property size_t graphics_index()
	{
		return m_graphics_index;
	}
private:
	int m_x;
	int m_y;
	size_t m_graphics_index;
	// int temperature;
	// int precipitation;
}
