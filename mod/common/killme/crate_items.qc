#include "crates.qh"

enum
{
	CRATE_LOOT_POTION,
	CRATE_LOOT_HEART,
	CRATE_LOOT_MAGNET,
	CRATE_LOOT_DRINK,
	CRATE_LOOT_AMMO,
	CRATE_LOOT_SPEED,
	CRATE_LOOT_SKULL,
	CRATE_LOOT_GASMASK,
	CRATE_LOOT_SCUBAGEAR,
	CRATE_LOOT_SHIELD,
	CRATE_LOOT_ARSENAL,
	CRATE_LOOT_LAST
};

MODEL(CRATE_LOOT_POTION, "models/crate_items/potion.iqm");
MODEL(CRATE_LOOT_HEART, "models/crate_items/heart.iqm");
MODEL(CRATE_LOOT_MAGNET, "models/crate_items/magnet.iqm");
MODEL(CRATE_LOOT_DRINK, "models/crate_items/drink.iqm");
MODEL(CRATE_LOOT_AMMO, "models/crate_items/ammo.iqm");
MODEL(CRATE_LOOT_SPEED, "models/crate_items/speed.iqm");
MODEL(CRATE_LOOT_SKULL, "models/crate_items/skull.iqm");
MODEL(CRATE_LOOT_GASMASK, "models/crate_items/gasmask.iqm");
MODEL(CRATE_LOOT_SCUBAGEAR, "models/crate_items/scubagear.iqm");
MODEL(CRATE_LOOT_SHIELD, "models/crate_items/shield.iqm");
MODEL(CRATE_LOOT_ARSENAL, "models/crate_items/arsenal.iqm");
Model MDL_CRATE_LOOT(int id) {
    return Models_from(MDL_CRATE_LOOT_POTION.m_id + id);
}

string crate_item_getmessage(int id)
{
	switch(id)
	{
		case CRATE_LOOT_POTION: return "Health refilled!";
		case CRATE_LOOT_HEART: return "Health limit doubled!";
		case CRATE_LOOT_MAGNET: return "Items magnetise towards you!";
		case CRATE_LOOT_DRINK: return "Moaning Lescue!";
		case CRATE_LOOT_AMMO: return "Ammo refilled!";
		case CRATE_LOOT_SPEED: return "Gotta go fast!";
		case CRATE_LOOT_SKULL: return "Mistakes were made.";
		case CRATE_LOOT_GASMASK: return "You can swim in slime!";
		case CRATE_LOOT_SCUBAGEAR: return "No more drowning!";
		case CRATE_LOOT_SHIELD: return "Paladin's shield grants you armor!";
		case CRATE_LOOT_ARSENAL: return "Double vortex? Why not!";
	}

	return "You got nothing, sucker!";
}

// below here is the implementation of the loot items we registered above

AUTOCVAR(g_random_crates_loot_magnet_range, float, 100, "Pickup range of the magnet item");
AUTOCVAR(g_random_crates_loot_drink_dontsue, bool, false, "Please");
AUTOCVAR(g_random_crates_loot_drink_sue_chance, float, 0.1, "Hehehe");
AUTOCVAR(g_random_crates_loot_speed_speed, float, 2, "Movement speed while holding speed item");
AUTOCVAR(g_random_crates_loot_speed_weaponspeed, float, 2, "Weapon action speed");
AUTOCVAR(g_random_crates_loot_speed_rate, float, 0.5, "Weapon attack rate speed (lower is faster)");
AUTOCVAR(g_random_crates_loot_skull_time, float, 10, "Rough time between pain");
AUTOCVAR(g_random_crates_loot_skull_damage, float, 20, "Pain");


REGISTER_MUTATOR(crate_items, true); // always enabled!

MUTATOR_HOOKFUNCTION(crate_items, PlayerRegen)
{
	entity player = M_ARGV(0, entity);

	if(player.rcrates_item & BIT(CRATE_LOOT_HEART))
	{
		M_ARGV(1, float) *= 2; // max_mod
		M_ARGV(4, float) *= 2; // limit_mod
	}
}

MUTATOR_HOOKFUNCTION(crate_items, GetResourceLimit)
{
	entity player = M_ARGV(0, entity);
	int rtype = M_ARGV(1, int);

	if(player.rcrates_item & BIT(CRATE_LOOT_HEART))
	{
		if(rtype == RESOURCE_HEALTH)
			M_ARGV(2, float) *= 2; // limit
	}
}

MUTATOR_HOOKFUNCTION(crate_items, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	if(game_stopped || IS_DEAD(player) || frametime || !IS_PLAYER(player)) return;

	if(player.rcrates_item & BIT(CRATE_LOOT_SKULL))
	{
		if(time >= player.bloodloss_timer) // we can safely reuse the field, if bloodloss is in effect they don't need to stack!
		{
			if(player.event_damage)
				player.event_damage(player, player, player, autocvar_g_random_crates_loot_skull_damage, DEATH_ROT.m_id, DMG_NOWEP, player.origin, '0 0 0');
			player.bloodloss_timer = time + 5 + random() * autocvar_g_random_crates_loot_skull_time;
		}
	}

	if(player.rcrates_item & BIT(CRATE_LOOT_MAGNET))
	{
		vector pickup_size = '1 1 1' * autocvar_g_random_crates_loot_magnet_range;
		IL_EACH(g_items, it.itemdef,
		{
			if(boxesoverlap(player.absmin - pickup_size, player.absmax + pickup_size, it.absmin, it.absmax))
			{
				if(gettouch(it))
					gettouch(it)(it, player);
			}
		});
	}
}

MUTATOR_HOOKFUNCTION(crate_items, WeaponRateFactor)
{
	entity player = M_ARGV(1, entity);

	if(player.rcrates_item & BIT(CRATE_LOOT_SPEED))
		M_ARGV(0, float) *= autocvar_g_random_crates_loot_speed_rate;
}

MUTATOR_HOOKFUNCTION(crate_items, WeaponSpeedFactor)
{
	entity player = M_ARGV(1, entity);

	if(player.rcrates_item & BIT(CRATE_LOOT_SPEED))
		M_ARGV(0, float) *= autocvar_g_random_crates_loot_speed_weaponspeed;
}

MUTATOR_HOOKFUNCTION(crate_items, PlayerPhysics_UpdateStats)
{
	entity player = M_ARGV(0, entity);
	// these automatically reset, no need to worry

	if(player.rcrates_item & BIT(CRATE_LOOT_SPEED))
		STAT(MOVEVARS_HIGHSPEED, player) *= autocvar_g_random_crates_loot_speed_speed;
}

MUTATOR_HOOKFUNCTION(crate_items, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);

	if((frag_target.rcrates_item & BIT(CRATE_LOOT_GASMASK)) && DEATH_ENT(frag_deathtype) == DEATH_SLIME)
		M_ARGV(4, float) = 0; // damage

	if((frag_target.rcrates_item & BIT(CRATE_LOOT_SCUBAGEAR)) && DEATH_ENT(frag_deathtype) == DEATH_DROWN)
		M_ARGV(4, float) = 0; // damage

	if((frag_target.rcrates_item & BIT(CRATE_LOOT_SHIELD)) && IS_PLAYER(frag_target) && frag_target != frag_attacker && frag_attacker && M_ARGV(4, float) > 0)
		SetResourceAmount(frag_target, RESOURCE_ARMOR, GetResourceAmount(frag_target, RESOURCE_ARMOR) + M_ARGV(4, float));
}

MUTATOR_HOOKFUNCTION(crate_items, ItemTouch)
{
	// duplicate of the akimbo function, even allows this outside of akimbo!
	if(g_nexball || autocvar_g_weaponswitch_debug != 2)
		return false; // at least try to remain compatible
	if(MUTATOR_RETURNVALUE == MUT_ITEMTOUCH_RETURN)
		return false; // already handled, probably didn't pick it up

	entity item = M_ARGV(0, entity);
	entity player = M_ARGV(1, entity);

	if(Item_IsLoot(item) && item.weapon && (player.weapons & item.itemdef.m_weapon.m_wepset) && item.owner != player && (player.rcrates_item & BIT(CRATE_LOOT_ARSENAL)))
		PS(player).dual_weapons |= item.itemdef.m_weapon.m_wepset; // dual it up!
}

bool crate_item_ammo_set(entity player, int resource)
{
	float resamount = GetResourceAmount(player, resource);
	float reslimit = GetResourceLimit(player, resource);
	if(resamount > 0 && resamount < reslimit)
	{
		SetResourceAmount(player, resource, reslimit);
		return true;
	}
	return false;
}

void MorningRescue(entity e); // TODO
// return true to force print the message or -1 to override the regular message
// return false to use regular handling, which checks if the player has the item already
int crate_item_handletouch(entity this, entity toucher)
{
	switch(this.rcrates_item)
	{
		case CRATE_LOOT_POTION:
		{
			// refill health
			float hp = GetResourceAmount(toucher, RESOURCE_HEALTH);
			if(hp < start_health)
			{
				SetResourceAmount(toucher, RESOURCE_HEALTH, start_health);
				return true;
			}
			return -1; // didn't refill health, so don't print a message
		}
		case CRATE_LOOT_DRINK:
		{
			// hehe
			if(!autocvar_g_random_crates_loot_drink_dontsue && random() < autocvar_g_random_crates_loot_drink_sue_chance)
			{
				MorningRescue(toucher);
				toucher.rcrates_item &= ~BIT(CRATE_LOOT_SKULL);
				return -1; // no message, it has its own ;)
			}
			toucher.rcrates_item &= ~BIT(CRATE_LOOT_SKULL);
		}
		case CRATE_LOOT_AMMO:
		{
			// refill ammo if we can
			bool filled = false;
			filled |= crate_item_ammo_set(toucher, RESOURCE_SHELLS);
			filled |= crate_item_ammo_set(toucher, RESOURCE_BULLETS);
			filled |= crate_item_ammo_set(toucher, RESOURCE_ROCKETS);
			filled |= crate_item_ammo_set(toucher, RESOURCE_CELLS);
			filled |= crate_item_ammo_set(toucher, RESOURCE_PLASMA);
			filled |= crate_item_ammo_set(toucher, RESOURCE_FUEL);

			if(filled)
				return true;
			return -1; // didn't refill ammo, so don't print a message
		}
	}

	return false;
}
