module disaster;
import std.random;
import population;
import map_objects;

enum disasters
{
	plague
}
final class DisasterGenerator
{
public:
	this(Population population)
	{
		m_population = population;
		m_first_disaster = true;
		m_rng = Random(unpredictableSeed);
		m_seasons_until_first_disaster = 10;
		choose_disaster();
	}
	void choose_disaster()
	{
		disaster = new Plague(uniform!"[]"(1, 70, m_rng), m_population);
		seasons_until_next_disaster = uniform!"[]"(4, 12, m_rng);
		if (m_first_disaster)
		{
			seasons_until_next_disaster += m_seasons_until_first_disaster;
		}
	}
	void update_season()
	{
		if (disaster.active)
		{
			disaster.update_season();
			if (!disaster.active)
			{
				choose_disaster();
			}
		}
		else
		{
			seasons_until_next_disaster -= 1;
			if (seasons_until_next_disaster <= 0)
			{
				disaster.trigger();
			}		
		}
	}

	Disaster disaster;
	int seasons_until_next_disaster;
private:
	bool m_first_disaster;
	int m_seasons_until_first_disaster;
	Random m_rng;
	Population m_population;

}

abstract class Disaster
{
	this()
	{
		m_active = false;
	}
	void trigger();
	@property @safe bool active() const nothrow
	{
		return m_active;
	}
	void update_season();
	void predict();
	void alter();
protected:
	bool m_active;

}

class Plague : Disaster
{
	this(int victims_roll, Population population)
	{
		m_population = population;
		m_victims_roll = victims_roll;
	}

	override void update_season()
	{
		if (Hospital.total_capacity >= m_total_sick
			&& m_population.available_doctors >= m_required_doctors)
		{
			m_active = false;
		}
	}
	override void alter()
	{
		m_victims_roll /= 2;
		predict;
	}
	override void predict()
	{
		m_total_sick = population.total * m_victims_roll / 100;
		// the commented portion below was a bit buggy, but it was intended
		// to force roundup, so that, for example, 6 would require 2.
		m_required_doctors = m_total_sick / 5; // / + (m_total_sick % 5 == 0);
		m_sick_doctors = 0;
		m_sick_lumberjacks = 0;
		m_sick_firefighters = 0;
		m_sick_farmers = 0;
		m_sick_office_workers = 0;
		int sick = m_total_sick;
		assert (sick <= population.total);
		while (sick > 0)
		{
			// there are definitely better ways, but quick & dirty - less than 4 hr to go!
			if (population.lumberjacks > m_sick_lumberjacks)
			{
				m_sick_lumberjacks += 1;
				sick -= 1;
				if (sick == 0) break;
			}
			if (population.office_workers > m_sick_office_workers)
			{
				m_sick_office_workers += 1;
				sick -= 1;
				if (sick == 0) break;
			}
			/*if (population.firefighters > m_sick_firefighters)
			{
				m_sick_firefighters += 1;
				sick -= 1;
				if (sick == 0) break;
			}*/
			if (population.farmers > m_sick_farmers)
			{
				m_sick_farmers += 1;
				sick -= 1;
				if (sick == 0) break;
			}
			if (population.doctors > m_sick_doctors)
			{
				m_sick_doctors += 1;
				sick -= 1;
				if (sick == 0) break;
			}
		}
	}
	override void trigger()
	{
		m_active = true;
		// the prediction uses the same calculations.
		predict();
	}
	@property int sick_lumberjacks() {return m_sick_lumberjacks;}
	@property int sick_farmers() {return m_sick_farmers;}
	@property int sick_office_workers() {return m_sick_office_workers;}
	@property int sick_firefighters() {return m_sick_firefighters;}
	@property int sick_doctors() {return m_sick_doctors;}
	@property int total_sick() {return m_total_sick;}
	@property int required_doctors() {return m_required_doctors;}
private:
	// oops naming convention. Can't fix with this little time left.
	// correct during refactoring for sure!
	Population population;
	alias m_population = population;
	int m_victims_roll;
	int m_total_sick;
	int m_sick_lumberjacks;
	int m_sick_office_workers;
	int m_sick_doctors;
	int m_sick_firefighters;
	int m_sick_farmers;
	int m_required_doctors;
}
