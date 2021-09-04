module tile.tile;

enum tile_names : int
{
	plains = 0,
	water = 1,
	forest = 2,
	farmland = 3,
	cursor // should probably move this somewhere else later.
}

final class Tile
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
	void change_tile_type(int new_type)
	{
		m_graphics_index = new_type;
	}
	// Most tiles should not be moved! This function is intended
	// for special tiles like the cursor.
	void move(int new_x, int new_y)
	{
		m_x = new_x;
		m_y = new_y;
	}
private:
	int m_x;
	int m_y;
	int m_graphics_index;
	// int temperature;
	// int precipitation;
}
