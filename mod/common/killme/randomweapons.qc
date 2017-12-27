AUTOCVAR(g_random_weapons, bool, false, "Enable randomly placed weapons mutator");
AUTOCVAR(g_random_weapons_init, bool, true, "Place set items at map start rather than randomly during the match");
AUTOCVAR(g_random_weapons_keepspawns, bool, true, "Keep the regular weapon spawn points intact");
AUTOCVAR(g_random_weapons_count, int, 20, "Number of weapons to place around the map");
AUTOCVAR(g_random_weapons_tries, int, 20, "Try to place a weapon this many times before giving up");
AUTOCVAR(g_random_weapons_delay, float, 5, "Timer between spawning new weapons when init mode is off");
AUTOCVAR(g_random_weapons_droptofloor, bool, false, "Drop the weapons instantly so they don't appear to fall from the sky");
AUTOCVAR(g_random_weapons_lifetime, float, 15, "Lifespan of the spawned weapons when init mode is off");
AUTOCVAR(g_random_weapons_include_special, bool, true, "Include mutator blocked and hidden weapons");
AUTOCVAR(g_random_weapons_allow_weaponreplace, bool, false, "Allow weaponreplace settings to override the spawned weapons");

.bool rweps_item;
.bool rweps_seen;
float rweps_timer;

void random_weapons_DelayedInit(entity this);
void random_weapons_SpawnWeapons(int wcount, bool is_loot);
REGISTER_MUTATOR(random_weapons, autocvar_g_random_weapons)
{
	MUTATOR_ONADD
	{
		if(autocvar_g_random_weapons_init)
			InitializeEntity(NULL, random_weapons_DelayedInit, INITPRIO_GAMETYPE);
		else
			rweps_timer = time + autocvar_g_random_weapons_delay;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(random_weapons, FilterItem)
{
	entity item = M_ARGV(0, entity);

	if(item.weapon && !item.rweps_item && !autocvar_g_random_weapons_keepspawns)
		return true;

	return false;
}

MUTATOR_HOOKFUNCTION(random_weapons, SetWeaponreplace)
{
	if(autocvar_g_random_weapons_allow_weaponreplace)
		return false;

	entity wep = M_ARGV(0, entity);
	if(!wep.rweps_item)
		return false;

	entity e = M_ARGV(1, entity);
	M_ARGV(2, string) = e.netname;
}

MUTATOR_HOOKFUNCTION(random_weapons, SV_StartFrame)
{
	if(autocvar_g_random_weapons_init)
		return false;

	if(time < rweps_timer || !rweps_timer)
		return false;
	rweps_timer = time + autocvar_g_random_weapons_delay;

	// much easier to just count the active items than to make sure at every case that a counter is saved
	int rweps_count = 0;
	IL_EACH(g_items, it.rweps_item,
	{
		++rweps_count;
	});

	if(rweps_count >= autocvar_g_random_weapons_count)
		return false;

	random_weapons_SpawnWeapons(autocvar_g_random_weapons_count - rweps_count, true);
}

void random_weapons_SpawnWeapons(int wcount, bool is_loot)
{
	for(int j = 0; j < wcount; ++j)
	{
		entity e = spawn();
		if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, autocvar_g_random_weapons_tries, 1024, 256))
		{
			RandomSelection_Init();
			FOREACH(Weapons, it != WEP_Null && (!((it.spawnflags & WEP_FLAG_HIDDEN) || (it.spawnflags & WEP_FLAG_MUTATORBLOCKED)) || autocvar_g_random_weapons_include_special),
			{
				if((it.spawnflags & WEP_FLAG_HIDDEN) && (it.spawnflags & WEP_FLAG_MUTATORBLOCKED))
					continue; // never ever do the attacks
				RandomSelection_AddEnt(it, (((it.spawnflags & WEP_FLAG_SUPERWEAPON) || it.rweps_seen) ? 0.5 : 1), 1);
			});

			entity chosen = RandomSelection_chosen_ent;
			if(is_loot)
			{
				Item_SetLoot(e, true);
				e.pickup_anyway = true;
			}
			else
				chosen.rweps_seen = true; // don't bother, they'll despawn anyway
			if(autocvar_g_random_weapons_droptofloor)
				droptofloor(e);
			e.angles = '0 0 0';
			e.gravity = 1;
			e.rweps_item = true;
			e.spawnfunc_checked = true;
			weapon_defaultspawnfunc(e, chosen);

			if(is_loot && autocvar_g_random_weapons_lifetime > 0)
				SUB_SetFade(e, time + autocvar_g_random_weapons_lifetime, 1);
		}
		else
			delete(e); // RIP
	}
}

void random_weapons_DelayedInit(entity this)
{
	random_weapons_SpawnWeapons(autocvar_g_random_weapons_count, false);
}
