module world.world_io;
import std.stdio;
import std.random;
import std.container.dlist;
import std.typecons;
import std.string;
import std.conv;

import tile;

// THIS FUNCTION SUCKS and is okay ONLY BECAUSE THIS IS A CODE JAM PROJECT
// it makes way too many assumptions
Tile[] load_preset_world(string filename, int size_x, int size_y)
{
   auto file = File(filename);
    int[] tiles;
    foreach(line; file.byLine())
    {
        auto partial_tiles = line.strip.split(" ");
        foreach(tile; partial_tiles)
        {
            try
            {
                tiles ~= tile.to!int;
            }
            catch (Exception e)
            {
                writeln("Exception thrown in load_preset_world by tiles ~= tile.to!int;");
                writeln("    tile = ", tile);
                writeln("    Current contents of tiles array: ", tiles);
                throw e;
            }
        }
    }

    // expand out the 2s
    // This section seems slower than expected. I suspect there's a lot of redundant
    // checks going on, but since this is a jam we're going to just pick numbers
    // that don't get out of hand fast enough.
    auto rng = Random(100);
    alias TreeSpawn = Tuple!(int, "index", int, "p_spread");
    auto queue = new DList!TreeSpawn;
    int to_index(int X, int Y)
    {
        return Y * size_x + X;
    }
    void insert_if_RNG(int x, int y, int threshold = 48)
    {
        // writeln("Current threshold = ", threshold);
        auto index = to_index(x, y);
        if (index < 0 || index >= tiles.length) return;
        if (tiles[index] == 0) 
        {
            immutable int tmp = uniform!"[]"(1, 100, rng);
            if (tmp < threshold)
            {
                // No need to worry about the possibility of the threshold
                // going negative - if that happens at all, it'll just act
                // like the value is zero and should stop further spawns.
                queue.insertBack(TreeSpawn(index, threshold - 3));
            }
        }
    }
    void spread_tree(TreeSpawn spawn)
    {
        immutable int x = spawn.index % size_y;
        immutable int y = spawn.index / size_y;
        tiles[spawn.index] = 2;
        insert_if_RNG(x - 1, y, spawn.p_spread);
        insert_if_RNG(x + 1, y, spawn.p_spread);
        insert_if_RNG(x, y - 1, spawn.p_spread);
        insert_if_RNG(x, y + 1, spawn.p_spread);

    }
    foreach(i, tile; tiles)
    {
        if (tile == 2)
        {
            spread_tree(TreeSpawn(i.to!int, 90));
        }
    }
    while (!queue.empty)
    {
        spread_tree(queue.front);
        queue.removeFront;
    }

    // Clean up a bit. The outer loop's purpose is entirely to do 2 passes,
    // with the first pass cleaning up tiles w/ 3+ neighbors and the second
    // ensuring the first pass didn't leave behind any gaps with 4 neighbors.
    for (int j = 0; j < 2; ++j)
    {
        foreach(i, tile; tiles)
        {
            if (tile != 0) continue;
            immutable int x = i.to!int % size_y;
            immutable int y = i.to!int / size_y;

            immutable int[4] indices = 
            [
                to_index(x - 1, y),
                to_index(x + 1, y),
                to_index(x, y - 1),
                to_index(x, y + 1)
            ];
            int neighbors = 0;
            foreach(index; indices)
            {
                if (index < 0 || index >= tiles.length || tiles[index] == 2)
                {
                    neighbors += 1;
                }
            }
            if (neighbors >= 3 + j)
            {
                tiles[i] = 2;
            }
        }
    }

    // Finally do the tile creation
    Tile[] final_tiles;
    foreach(i, tile; tiles)
    {
        auto j = i.to!int;
        final_tiles ~= new Tile(j % size_y, j / size_y, tile.to!tile_names);
    }
    return final_tiles;
}