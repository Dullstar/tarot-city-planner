module map_objects.forest;
import std.conv;
import map_objects;
import tile;

class Forest : MapObject
{
public:
	this(int x, int y)
	{
		super(x, y, tile_names.forest.to!int);
		quantity = m_max;
	}
	@property @safe int recovery()
	{
		return m_recovery;
	}
	int quantity;
	override void update_season()
	{
		quantity += m_recovery;
		if (quantity > 1000)
        {
            // recover burn status
            m_graphics_index = tile_names.forest;
            
        }
        if (quantity > m_max)
        {
            quantity = m_max;
        }
	}
	void burn()
	{
		m_recovery = 100;
        quantity = 0;
        m_graphics_index = tile_names.burnt_forest;
	}
private:
	int m_recovery = 500;
	int m_max = 2500;
}
