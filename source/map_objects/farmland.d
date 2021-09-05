module map_objects.farmland;
import map_objects.map_object;
import tile;
import std.conv;

class Farmland : MapObject
{
public:
	this(int x, int y)
	{
		super(x, y, tile_names.farmland.to!int);
		m_recovery = 15;
		m_food = 0;  // doesn't hurt to be explicit about it.
	}
	@property @safe int food() const nothrow
	{
		return m_food;
	}
	override void update_season() nothrow
	{
		m_graphics_index = tile_names.farmland_with_food;
		m_food += m_recovery;
		if (m_food > m_max) m_food = m_max;
	}
	// Technically we could just use food and make this a void function, but convenience.
	@safe int harvest() nothrow
	{
		auto food = m_food;
		m_food = 0;
		m_graphics_index = tile_names.farmland;
		return food;
	}
private:
	int m_recovery = 15;
	int m_food;
	int m_max = 15 * 4;
}
