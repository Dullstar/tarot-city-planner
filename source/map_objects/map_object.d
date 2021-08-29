module map_objects.map_object;

abstract class MapObject
{
public:
	abstract @safe @property int graphic_index();
	abstract @safe @property int required_workers();
	final @safe @property int x()
	{
		return m_x;
	}
	final @safe @property int y()
	{
		return m_y;
	}
	final @safe @property int tile_index()
	{
		return m_tile_index;
	}
	this(int x, int y, int map_width, int map_height)
	{
		move(x, y, map_width, map_height);
	}
	final @safe void move(int new_x, int new_y, int map_width, int map_height)
	in
	{
		assert(x < map_width);
		assert(y < map_height);
	}
	do
	{
		m_x = x;
		m_y = y;
		m_tile_index = map_width * y + x;
	}
private:
	int m_x;
	int m_y;
	int m_tile_index;
}
