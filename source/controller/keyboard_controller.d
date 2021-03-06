module controller.keyboard_controller;
import allegro5.allegro;
import std.conv;
import std.stdio;
import std.string;
import std.file;
import controller.controller_interface;

class KeyboardController : Controller
{
public:
	this(string config)
	{
		if (config != "")
	   	{
			try
			{
				load_config(config);
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
	@property ref bool[ALLEGRO_KEY_MAX] raw_held()
	{
		return raw_key_held;
	}
	@property ref bool[ALLEGRO_KEY_MAX] raw_pressed()
	{
		return raw_key_downs;
	}
	@property ref bool[ALLEGRO_KEY_MAX] raw_released()
	{
		return raw_key_released;
	}
	@property ref bool[ALLEGRO_KEY_MAX] raw_chars()
	{
		return raw_key_chars;
	}
	void interpret_down(int keycode)
	{
		// Under certain conditions, extra keydown events can be generated
		// (modifier keys in particular seem to cause this soemtimes),
		// so throw them out if that happens.
		if (raw_key_held[keycode]) 
		{	
			// writeln("Tossed a duplicate key down event.");
			return;
		}
		raw_key_downs[keycode] = true;
		raw_key_held[keycode] = true;
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
		raw_key_chars[keycode] = true;
		command translated = translation_table[keycode];
		if (translated == command.none) return;
		translated_key_chars[translated] = true;
	}
	void interpret_release(int keycode)
	{
		raw_key_released[keycode] = true;
		command translated = translation_table[keycode];
		if (translated == command.none) return;
		number_keys_held[translated] -= 1;
		if (number_keys_held[translated] < 0)
		{
			// Intended to prevent switch out problems... doesn't need to be perfect,
			// just needs to prevent any sort of input lockup. An else if is used for
			// zero as I don't want to generate new released events if we've already
			// assumed the key was released.
			// This may need some additional work, but right now no actions are based
			// on key release, so idk if it feels right. If it feels wrong we can always
			// fix it later.
			number_keys_held[translated] = 0;
		}
		else if (number_keys_held[translated] == 0)
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
			if (!raw_key_downs[keycode])
			{
				raw_key_held[keycode] = false;
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
		for (int i = 0; i < ALLEGRO_KEY_MAX; ++i)
		{
			if (raw_key_released[i])
			{
				raw_key_held[i] = false;
			}
		}
		raw_key_downs[] = false;
		raw_key_released[] = false;
		raw_key_chars[] = false;
		translated_key_downs[] = false;
		translated_key_released[] = false;
		translated_key_chars[] = false;
	}
	void handle_switch_out()
	{
		// Release all keys when this happens.
		for (int i = 0; i < ALLEGRO_KEY_MAX; ++i)
		{
			interpret_release(i);
		}
	}
private:
	bool[command.max] translated_key_downs;
	bool[command.max] translated_key_released;
	bool[command.max] translated_key_held;
	bool[command.max] translated_key_chars;
	int[command.max] number_keys_held;
	bool[ALLEGRO_KEY_MAX] raw_key_downs;
	bool[ALLEGRO_KEY_MAX] raw_key_released;
	bool[ALLEGRO_KEY_MAX] raw_key_held;
	bool[ALLEGRO_KEY_MAX] raw_key_chars;
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
		translation_table[ALLEGRO_KEY_LSHIFT] = command.speed_up;
		translation_table[ALLEGRO_KEY_RSHIFT] = command.speed_up;
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
		// Load/parse the file if it exists, else create it using the defaults.
		if (exists(filename))
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
		else
		{
			init_default_controls();
			write_config(filename);
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