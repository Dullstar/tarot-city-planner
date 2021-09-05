module map_objects.road;
import map_objects.map_object;
import tile;

class Road : MapObject
{
public:
	this(int x, int y)
	{
		super(x, y, tile_names.road);	
	}
	static @safe @property max_dist() nothrow
	{
		return 2;
	}
}
