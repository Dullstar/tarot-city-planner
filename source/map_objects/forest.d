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
        m_recovery = 500;
        quantity = m_max;
    }
    @property @safe int recovery()
    {
        return m_recovery;
    }
    int quantity;
private:
    int m_recovery;
    int m_max = 2500;
}