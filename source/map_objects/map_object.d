module map_objects.map_object;

abstract class MapObject
{
public:
	abstract @safe @property size_t graphic_index();
	abstract @safe @property int required_workers();
	final @safe @property size_t x()
	{
		return m_x;
	}
	final @safe @property size_t y()
	{
		return m_y;
	}
	final @safe @property size_t tile_index()
	{
		return m_tile_index;
	}
	this(size_t x, size_t y, size_t map_width, size_t map_height)
	{
		move(x, y, map_width, map_height);
	}
	final @safe void move(size_t new_x, size_t new_y, size_t map_width, size_t map_height)
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
	size_t m_x;
	size_t m_y;
	size_t m_tile_index;
}
