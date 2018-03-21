#include "crate_items.qc"

AUTOCVAR(g_random_crates, bool, false, "Enable randomly placed crates mutator");
AUTOCVAR(g_random_crates_count, int, 5, "Number of crates to place around the map");
AUTOCVAR(g_random_crates_tries, int, 20, "Try to place a crate this many times before giving up");
AUTOCVAR(g_random_crates_delay, float, 20, "Timer between spawning new crates");
AUTOCVAR(g_random_crates_scale, float, 1.4, "Size of the crates (doesn't affect hitbox)");
AUTOCVAR(g_random_crates_droptofloor, bool, true, "Drop the crates instantly so they don't appear to fall from the sky");
AUTOCVAR(g_random_crates_loot_count_min, int, 2, "Minimum number of items each crate can drop");
AUTOCVAR(g_random_crates_loot_count_max, int, 5, "Maximum number of items each crate can drop");
AUTOCVAR(g_random_crates_loot_lifetime, float, 5, "Lifespan of the spawned items");
AUTOCVAR(g_random_crates_loot_tuba_chance, float, 0.1, "Chance for tuba to spawn as opposed to most weapons");
AUTOCVAR(g_random_crates_loot_weapon_chance, float, 0.1, "Chance for a weapon to spawn from the crate");
AUTOCVAR(g_random_crates_loot_health_chance, float, 0.25, "Chance for a health or armor item to spawn from the crate");
AUTOCVAR(g_random_crates_loot_powerup_chance, float, 0.075, "Chance for a powerup to spawn from the crate");
AUTOCVAR(g_random_crates_loot_include_special, bool, true, "Include mutator blocked weapons");
AUTOCVAR(g_random_crates_loot_allow_weaponreplace, bool, false, "Allow weaponreplace settings to override the spawned loot");

float rcrates_timer;

void random_crates_SpawnCrates(int wcount);
REGISTER_MUTATOR(random_crates, autocvar_g_random_crates)
{
	MUTATOR_ONADD
	{
		rcrates_timer = time + autocvar_g_random_crates_delay;
	}
	return false;
}

MUTATOR_HOOKFUNCTION(random_crates, SetWeaponreplace)
{
	if(autocvar_g_random_crates_loot_allow_weaponreplace)
		return false;

	entity wep = M_ARGV(0, entity);
	if(!wep.rcrates_item)
		return false;

	entity e = M_ARGV(1, entity);
	M_ARGV(2, string) = e.netname;
}

MUTATOR_HOOKFUNCTION(random_crates, SV_StartFrame)
{
	if(time < rcrates_timer || !rcrates_timer)
		return false;
	rcrates_timer = time + autocvar_g_random_crates_delay;

	// much easier to just count the active crates than to make sure at every case that a counter is saved
	int rcrates_count = 0;
	IL_EACH(g_crates, it.health > 0,
	{
		++rcrates_count;
	});

	if(rcrates_count >= autocvar_g_random_crates_count)
		return false;

	random_crates_SpawnCrates(autocvar_g_random_crates_count - rcrates_count);
}

MUTATOR_HOOKFUNCTION(random_crates, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);
	player.rcrates_item = 0;
}

void random_crates_SpawnWeapon(entity ent, entity wep, vector org)
{
	Item_SetLoot(ent, true);
	ent.pickup_anyway = true;
	ent.angles = '0 0 0';
	ent.gravity = 1;
	setorigin(ent, org);
	ent.velocity = randomvec() * 150 + '0 0 325';
	ent.rcrates_item = true;
	ent.spawnfunc_checked = true;
	ent.glowmod = weaponentity_glowmod(wep, ent, 0, NULL);
	weapon_defaultspawnfunc(ent, wep);

	// fading handled globally
}

void crate_think(entity this)
{
	this.nextthink = time + 0.15; // don't need to update often, very unlikely for these to move
	CSQCMODEL_AUTOUPDATE(this);
}

void crate_dropweapon(entity e, vector org)
{
	RandomSelection_Init();
	FOREACH(Weapons, it != WEP_Null && (!(it.spawnflags & WEP_FLAG_MUTATORBLOCKED) || autocvar_g_random_crates_loot_include_special),
	{
		if((it.spawnflags & WEP_FLAG_HIDDEN) && (it.spawnflags & WEP_FLAG_MUTATORBLOCKED))
			continue; // never ever do the attacks
		if(it.spawnflags & WEP_FLAG_SUPERWEAPON)
			continue; // no power weapons thank you very much
		if(W_IsWeaponThrowable(e, it.m_id))
			RandomSelection_AddEnt(it, ((it == WEP_TUBA) ? autocvar_g_random_crates_loot_tuba_chance : 1), 1);
	});

	random_crates_SpawnWeapon(e, RandomSelection_chosen_ent, org);
}

void crate_dropregularitem(entity e, vector org, entity itm)
{
	Item_SetLoot(e, true);
	e.reset = SUB_Remove;
	e.noalign = true;
	StartItem(e, itm);
	e.gravity = 1;
	setorigin(e, org);
	e.velocity = randomvec() * 175 + '0 0 325';
	e.item_spawnshieldtime = time + 0.7;
	SUB_SetFade(e, time + autocvar_g_random_crates_loot_lifetime, 1);
}

void crate_drophealth(entity e, vector org)
{
	crate_dropregularitem(e, org, ((random() > 0.5) ? ITEM_HealthSmall : ITEM_ArmorSmall));
}

void crate_droppowerup(entity e, vector org)
{
	crate_dropregularitem(e, org, ((random() > 0.5) ? ITEM_Strength : ITEM_Shield));
}

void crate_item_touch(entity this, entity toucher)
{
	if(game_stopped) { return; }

	if(ITEM_TOUCH_NEEDKILL())
	{
		delete(this);
		return;
	}

	if((this.team && DIFF_TEAM(toucher, this))
	|| (STAT(FROZEN, toucher))
	|| (toucher.vehicle)
	|| (!IS_PLAYER(toucher))
	|| (time < this.item_spawnshieldtime)
	)
	{
		// can't touch this
		return;
	}

	int handled = crate_item_handletouch(this, toucher);
	if(handled != -1)
	if(!(toucher.rcrates_item & BIT(this.rcrates_item)) || handled == 1)
		centerprint(toucher, crate_item_getmessage(this.rcrates_item));

	toucher.rcrates_item |= BIT(this.rcrates_item);
	//Send_Notification(NOTIF_ONE, toucher, MSG_MULTI, CRATE_ITEM, get_crate_item_name(this.rcrates_item));

	Send_Effect(EFFECT_ITEM_PICKUP, CENTER_OR_VIEWOFS(this), '0 0 0', 1);
	sound(this, CH_TRIGGER, SND_ITEMPICKUP, VOL_BASE, ATTEN_NORM);
	delete(this);
}

void crate_dropitem(entity e, vector org)
{
	// TODO: csqc networking?
	e.flags = FL_ITEM;
	e.bot_pickup = true;
	e.bot_pickupevalfunc = ammo_pickupevalfunc;
	e.bot_pickupbasevalue = 500;
	IL_PUSH(g_items, e);
	e.reset = SUB_Remove;
	e.solid = SOLID_TRIGGER;
	set_movetype(e, MOVETYPE_TOSS);
	e.gravity = 1;
	setorigin(e, org);
	e.velocity = randomvec() * 175 + '0 0 325';
	e.item_spawnshieldtime = time + 0.7;
	SUB_SetFade(e, time + autocvar_g_random_crates_loot_lifetime, 1);
	// now that we have our item, let's do the setup elsewhere

	settouch(e, crate_item_touch);

	e.rcrates_item = floor(random() * CRATE_LOOT_LAST);
	setmodel(e, MDL_CRATE_LOOT(e.rcrates_item));
	setsize(e, '-16 -16 0', '16 16 32');
}

void crate_dropitems(vector org)
{
	int lootcount = bound(autocvar_g_random_crates_loot_count_min, floor(random() * autocvar_g_random_crates_loot_count_max) + 1, autocvar_g_random_crates_loot_count_max);
	for(int j = 0; j < lootcount; ++j)
	{
		entity e = spawn();
		e.spawnfunc_checked = true;
		if(random() < autocvar_g_random_crates_loot_weapon_chance)
			crate_dropweapon(e, org);
		else if(random() < autocvar_g_random_crates_loot_health_chance)
			crate_drophealth(e, org);
		else if(random() < autocvar_g_random_crates_loot_powerup_chance)
			crate_droppowerup(e, org);
		else
			crate_dropitem(e, org);
	}
}

void crate_die(entity this)
{
	crate_dropitems(this.origin);

	Send_Effect(EFFECT_CRATE_BREAK, this.origin, randomvec() * 300, 5);
	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	sound(this, CH_SHOTS, SND_CRATE_BREAK_RANDOM(), VOL_BASEVOICE, ATTEN_NORM);

	this.health = 0;
	this.takedamage = DAMAGE_NO;
	this.event_damage = func_null;
	setthink(this, SUB_Remove);
	this.nextthink = time;
}

void crate_damage(entity this, entity inflictor, entity attacker, float damage, int deathtype, .entity weaponentity, vector hitloc, vector force)
{
	if(this.health <= 0 || damage <= 0)
		return;

	this.health -= damage;

	if(this.health <= 0)
	{
		crate_die(this);
		return;
	}

	Send_Effect(EFFECT_SPARKS, hitloc, force * -1, 1);

	//sound on every hit
	if (random() < 0.5)
		sound(this, CH_TRIGGER, SND_ONS_HIT1, VOL_MUFFLED, ATTEN_NORM);
	else
		sound(this, CH_TRIGGER, SND_ONS_HIT2, VOL_MUFFLED, ATTEN_NORM);
}

void crate_setup(entity crate)
{
	setmodel(crate, MDL_CRATE);
	setsize(crate, '-16 -16 0', '16 16 16');
	setthink(crate, crate_think);
	crate.nextthink = time + 0.25;
	CSQCMODEL_AUTOINIT(crate);

	if(!crate.bot_attack)
		IL_PUSH(g_bot_targets, crate);
	crate.bot_attack = true;

	crate.scale = autocvar_g_random_crates_scale;
	crate.angles_y = floor(random() * 180);
	crate.takedamage = DAMAGE_AIM;
	crate.health = 50;
	crate.solid = SOLID_BBOX;
	crate.event_damage = crate_damage;
	crate.reset = SUB_Remove;
	set_movetype(crate, MOVETYPE_TOSS);

	IL_PUSH(g_crates, crate);
}

void random_crates_SpawnCrates(int wcount)
{
	for(int j = 0; j < wcount; ++j)
	{
		entity e = spawn();
		setsize(e, '-16 -16 0', '16 16 16');
		if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, autocvar_g_random_crates_tries, 1024, 256))
		{
			if(autocvar_g_random_crates_droptofloor)
				droptofloor(e);
			e.angles = '0 0 0';
			e.gravity = 1;
			e.spawnfunc_checked = true;

			crate_setup(e);
		}
		else
			delete(e); // RIP
	}
}
