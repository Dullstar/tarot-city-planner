module gameplay.game_state;
import allegro5.allegro;
import app;

enum game_state_type
{
	main_menu,
	main_game
}

abstract class GameState
{
public:
	this(ALLEGRO_BITMAP* _main_buffer, MainWindow _parent)
	{
		main_buffer = _main_buffer;
		parent = _parent;
		assert(parent !is null);
	}
	abstract void update();
	abstract void draw();
protected:
	// This pointer is non-owning,
	// so this class does not need a destructor.
	ALLEGRO_BITMAP* main_buffer;
	MainWindow parent;
}
