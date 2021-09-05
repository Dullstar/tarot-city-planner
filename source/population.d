module population;
import map_objects.housing;
import disaster;
import std.stdio;

class Population
{
public:
	this(Disaster disaster_ref)
	{
		m_lumberjacks = 0;
		m_farmers = 0;
		m_doctors = 0;
		m_office_workers = 0;
		m_firefighters = 0;
		m_total = 0;
	}
	@property @safe int lumberjacks() const nothrow
	{
		return m_lumberjacks;
	}
	@safe void add_lumberjacks(int delta) nothrow
	{
		m_lumberjacks += delta;
		a_lumberjacks += delta;
		m_total += delta;
	}
	@property @safe int farmers() const nothrow
	{
		return m_farmers;
	}
	@safe void add_farmers(int delta) nothrow
	{
		m_farmers += delta;
		a_farmers += delta;
		m_total += delta;
	}
	@property @safe int doctors() const nothrow
	{
		return m_doctors;
	}
	@safe void add_doctors(int delta) nothrow
	{
		m_doctors += delta;
		a_doctors += delta;
		m_total += delta;
	}
	@property @safe int office_workers() const nothrow
	{
		return m_office_workers;
	}
	@safe void add_office_workers(int delta) nothrow
	{
		m_office_workers += delta;
		a_office_workers += delta;
		m_total += delta;
	}
	@property @safe int firefighters() const nothrow
	{
		return m_firefighters;
	}
	@safe void add_firefighters(int delta) nothrow
	{
		m_firefighters += delta;
		a_firefighters += delta;
		m_total += delta;
	}
	@property @safe total() const nothrow
	out(r; r == m_lumberjacks + m_farmers + m_doctors + m_office_workers + m_firefighters)
	{
		return m_total;
	}
	@property @safe available_lumberjacks() nothrow {return a_lumberjacks;}
	@property @safe available_farmers() nothrow {return a_farmers;}
	@property @safe available_firefighters() nothrow {return a_firefighters;}
	@property @safe available_office_workers() nothrow {return a_office_workers;}
	@property @safe available_doctors() nothrow {return a_doctors;}
	void use_lumberjack()
	{
		a_lumberjacks -= 1;
	}
	void use_farmer()
	{
		a_farmers -= 1;
	}
	void use_firefighter()
	{
		a_firefighters -= 1;
	}
	void update_season()
	{
		a_lumberjacks = m_lumberjacks;
		a_farmers = m_farmers;
		a_doctors = m_doctors;
		a_firefighters = m_firefighters;
		a_office_workers = m_office_workers;
		if (m_disaster !is null && m_disaster.active && cast(Plague) m_disaster)
		{
			auto plague = cast(Plague) m_disaster;
			a_lumberjacks -= plague.sick_lumberjacks;
			a_office_workers -= plague.sick_office_workers;
			a_firefighters -= plague.sick_firefighters;
			a_doctors -= plague.sick_doctors;
			a_farmers -= plague.sick_farmers;
		}
	}
	void register_disaster_handle(Disaster disaster)
	{
		m_disaster = disaster;
	}
private:
	int m_lumberjacks;
	int m_farmers;
	int m_doctors;
	int m_office_workers;
	int m_firefighters;
	int m_total;
	// a = available
	int a_lumberjacks;
	int a_farmers;
	int a_doctors;
	int a_office_workers;
	int a_firefighters;

	Disaster m_disaster;
}
