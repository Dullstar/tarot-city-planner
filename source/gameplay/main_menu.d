module gameplay.main_menu;
import allegro5.allegro;
import gameplay.game_state;
import app;

class MainMenu : GameState
{
public:
	this(ALLEGRO_BITMAP* main_buffer, MainWindow parent)
	{
		super(main_buffer, parent);
	}
	override void update()
	{
		parent.queue_state_change(game_state_type.main_game);
	}
	override void draw()
	{
		import std.stdio;
	}
}
