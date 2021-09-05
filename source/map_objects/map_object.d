module map_objects.map_object;

abstract class MapObject
{
public:
	this(int x, int y, int graphics_index)
	{
		m_x = x;
		m_y = y;
		m_graphics_index = graphics_index;
	}
	final @safe @property int x() const nothrow
	{
		return m_x;
	}
	final @safe @property int y() const nothrow
	{
		return m_y;
	}
	@safe @property int graphics_index()
	{
		return m_graphics_index;
	}
	// update season doesn't need to do anything by default,
	// but of course can be overridden.
	void update_season() {}
protected:
	int m_x;
	int m_y;
	int m_graphics_index;
}
