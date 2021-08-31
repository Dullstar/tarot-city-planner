module controller;
import allegro5.allegro;
import std.conv;
import std.stdio;
import std.string;

enum command 
{
	up = 0,
	down = 1,
	left = 2,
	right = 3,
	start = 4,
	none
}

interface Controller
{
public:
	@property ref bool[command.max] released();
	@property ref bool[command.max] held();
	@property ref bool[command.max] pressed();
	@property ref bool[command.max] chars();
}

class KeyboardController : Controller
{
public:
	this(string config)
	{
		if (config != "")
	   	{
			try
			{
				auto config2 = config.strip().split("\n");
				foreach(line; config2)
				{
					auto line_contents = line.strip().split(", ");
					int keycode = line_contents[0].to!int;
				}
			}
			catch(Exception e)
			{
				stderr.writeln("Error reading control configuration:\n    ", e);
				stderr.writeln("    The default controls will be used.");
				clear_translation_table();
				init_default_controls();
			}
		}
		else {
			init_default_controls();
		}
	}
	@property override ref bool[command.max] held()
	{
		return translated_key_held;
	}
	@property override ref bool[command.max] pressed()
	{
		return translated_key_downs;
	}
	@property override ref bool[command.max] released()
	{
		return translated_key_released;
	}
	@property override ref bool[command.max] chars()
	{
		return translated_key_chars;
	}
	void interpret_down(int keycode)
	{
		command translated = translation_table[keycode];
		if (translated == command.none) return;
		if (number_keys_held[translated] == 0)
		{
			// The condition prevents extra key downs from being generated
			// if the user has multiple keybinds. Guarantees that no matter
			// how we interpret the keypress data later, there won't be any
			// unexpected behavior resulting from users binding multiple
			// keys to the same function.
			translated_key_downs[translated] = true;
		}
		number_keys_held[translated] += 1;
		translated_key_held[translated] = true;
	}
	void interpret_char(int keycode)
	{
		command translated = translation_table[keycode];
		if (translated == command.none) return;
		translated_key_chars[translated] = true;
	}
	void interpret_release(int keycode)
	{
		command translated = translation_table[keycode];
		if (translated == command.none) return;
		number_keys_held[translated] -= 1;
		if (number_keys_held[translated] == 0)
		{
			translated_key_released[translated] = true;
			// Why such complication regarding released keys?
			// This check, along with the processing in prep_for_next_frame(),
			// ensures that the key isn't regarded as being held on the frame
			// that it is released, except if it is necessary to guarantee all
			// key presses are registered as held for at least one frame.
			
			// If it somehow becomes a performance issue, then we could have a
			// simpler input system that simply assumes that a keypress will
			// last more than one frame, as this is a solution to a mostly
			// theoretical problem: I wasn't able to produce sufficiently short
			// keypresses to be missed without slowing the framerate down.
			if (!translated_key_downs[translated])
			{
				translated_key_held[translated] = false;
			}
		}
	}
	void prep_for_next_frame()
	{
		for (int i = 0; i < translated_key_held.length; ++i)
		{
			if (translated_key_released[i])
		   	{
				translated_key_held[i] = false;
			}
		}
		translated_key_downs[] = false;
		translated_key_released[] = false;
		translated_key_chars[] = false;
	}
private:
	bool[command.max] translated_key_downs;
	bool[command.max] translated_key_released;
	bool[command.max] translated_key_held;
	bool[command.max] translated_key_chars;
	int[command.max] number_keys_held;
	command[ALLEGRO_KEY_MAX] translation_table = command.none;

	void init_default_controls()
	{
		translation_table[ALLEGRO_KEY_W] = command.up;
		translation_table[ALLEGRO_KEY_UP] = command.up;
		translation_table[ALLEGRO_KEY_A] = command.left;
		translation_table[ALLEGRO_KEY_LEFT] = command.left;
		translation_table[ALLEGRO_KEY_S] = command.down;
		translation_table[ALLEGRO_KEY_DOWN] = command.down;
		translation_table[ALLEGRO_KEY_D] = command.right;
		translation_table[ALLEGRO_KEY_RIGHT] = command.right;
		translation_table[ALLEGRO_KEY_ENTER] = command.start;
	}
	void clear_translation_table()
	{
		translation_table[] = command.none;
	}
	void write_config(string filename)
	{
		auto file = File(filename);
		foreach(keycode, command; translation_table)
		{
			file.writeln(keycode, ": ", command);
		}
	}
	void load_config(string filename, bool ignore_invalid = true)
	{
		auto file = File(filename);
		foreach(line; file.byLine())
		{
			try
			{
				const auto tmp = line.split(": ");
				translation_table[tmp[0].to!int] = tmp[1].to!command;
			}
			catch (Exception e)
			{
				// No, there isn't any missing behavior here: if the line is
				// Either we want to ignore the invalid entry, in which case
				// just throw out the line and keep going, or we want to rethrow
				// Might be able to improve with specific exceptions: I believe
				// we can get ConvException, ConvOverflowException, and whatever
				// out of bounds array access is.
				// Out of bounds handling would ideally be improved, but realistically
				// the inputs are probably valid anyway unless the user has been
				// tampering with them.
				if (!ignore_invalid)
				{
					throw e;
				}
			}
		}
	}
	command interpret_command_string(string cmd, bool ignore_invalid = true)
	{
		try
		{
			return cmd.to!command;
		}
		catch(ConvException e)
		{
			if (ignore_invalid)
			{
				stderr.writeln("Warning: Invalid command ignored: " ~ cmd);
				return command.none;
			}
			else throw new Exception("Invalid command: " ~ cmd);
		}
	}
}
