module controller.controller_interface;

enum command 
{
	up = 0,
	down = 1,
	left = 2,
	right = 3,
	start = 4,
	left_click = 5,
	right_click = 6,
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


