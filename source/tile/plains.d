module tile.plains;
import tile.tile;
import tile.tileset;

deprecated class Plains : Tile
{
	this(int x, int y, int graphics_index = tile_names.plains)
	{
		super(x, y, graphics_index);
	}
}
