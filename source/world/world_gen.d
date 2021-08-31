module world.world_gen;
import tile;

Tile[] make_world(int size_x, int size_y)
out (r)
{
	foreach (tile; r)
	{
		assert(tile !is null);
	}
}
do
{
	Tile[] tiles;
	tiles.length = size_x * size_y;
	// Early on, we just want a map that exists and don't really care what's in it.
	for (int y = 0; y < size_y; ++y)
	{
		for (int x = 0; x < size_x; ++x)
		{
			if (x == 0 || x == size_x - 1 || y == 0 || y == size_y - 1) 
			{
				tiles[y * size_x + x] = new Tile(x, y, tile_names.farmland);
			}
			else
			{
				tiles[y * size_x + x] = new Tile(x, y, tile_names.plains);
			}
		}
	}
	return tiles;
}
