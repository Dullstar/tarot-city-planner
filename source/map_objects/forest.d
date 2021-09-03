module map_objects.forest;
import std.conv;
import map_objects;
import tile;

class Forest : MapObject
{
    this(int x, int y)
    {
        super(x, y, tile_names.forest.to!int);
    }
}