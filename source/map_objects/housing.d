module map_objects.housing;
import map_objects.map_object;
import tile;

enum housing_type
{
	house,
	apartment
}

class Housing : MapObject
{
	this(int x, int y, housing_type type)
	{
		tile_names tile;
		type == housing_type.house ? tile = tile_names.house : tile_names.apartments;
		if (type == housing_type.house)
		{
			tile = tile_names.house;
			m_capacity = 4;
		}
		// Right now this is the only other one, but using else if in case of future expansion
		else if (type == housing_type.apartment)
		{
			tile = tile_names.apartments;
			m_capacity = 25;
		}
		super(x, y, tile);
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
