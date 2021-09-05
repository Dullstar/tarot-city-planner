module map_objects.office;
import map_objects.map_object;
import tile;

class Office : MapObject
{
	this(int x, int y)
	{
		super(x, y, tile_names.office);
		m_capacity = 25;
		m_total_capacity += m_capacity;	
	}
	@property @safe int capacity() const nothrow
	{
		return m_capacity;
	}
	static @property @safe int total_capacity() nothrow
	{
		return m_total_capacity;
	}
	@safe void burn() nothrow
	{
		m_total_capacity -= m_capacity;
	}
private:
	static int m_total_capacity;
	int m_capacity;
}
