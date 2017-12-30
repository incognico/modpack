#include "explosives.qh"
#ifndef IMPLEMENTATION

AUTOCVAR(g_balance_explosives_ammo, float, 80, "");
AUTOCVAR(g_balance_explosives_animtime, float, 0.4, "");
AUTOCVAR(g_balance_explosives_damage, float, 800, "");
AUTOCVAR(g_balance_explosives_edgedamage, float, 400, "");
AUTOCVAR(g_balance_explosives_force, float, 500, "");
AUTOCVAR(g_balance_explosives_radius, float, 350, "");
AUTOCVAR(g_balance_explosives_refire, float, 5, "");
AUTOCVAR(g_balance_explosives_load_abort, bool, true, "");
AUTOCVAR(g_balance_explosives_load_animtime, float, 0.2, "");
AUTOCVAR(g_balance_explosives_load_hold, float, 4, "");
AUTOCVAR(g_balance_explosives_load_speed, float, 0.5, "");
AUTOCVAR(g_balance_explosives_reload_ammo, float, 0, "");
AUTOCVAR(g_balance_explosives_reload_time, float, 1.6, "");
AUTOCVAR(g_balance_explosives_switchdelay_drop, float, 0.2, "");
AUTOCVAR(g_balance_explosives_switchdelay_raise, float, 0.2, "");
AUTOCVAR(g_balance_explosives_weaponreplace, string, "", "");
AUTOCVAR(g_balance_explosives_weaponstart, float, 0, "");
AUTOCVAR(g_balance_explosives_weaponstartoverride, float, -1, "");
AUTOCVAR(g_balance_explosives_weaponthrowable, float, 0, "");

CLASS(Explosives, Weapon)
/* spawnfunc */ ATTRIB(Explosives, m_canonical_spawnfunc, string, "weapon_explosives");
/* ammotype  */ ATTRIB(Explosives, ammo_type, int, RESOURCE_ROCKETS);
/* impulse   */ ATTRIB(Explosives, impulse, int, 4);
/* flags     */ ATTRIB(Explosives, spawnflags, int, WEP_TYPE_SPLASH | WEP_FLAG_NODUAL);
/* rating    */ ATTRIB(Explosives, bot_pickupbasevalue, float, 12000);
/* color     */ ATTRIB(Explosives, wpcolor, vector, '0.6 1 0.1');
/* modelname */ ATTRIB(Explosives, mdl, string, "explosives");
#ifdef GAMEQC
/* model     */ ATTRIB(Explosives, m_model, Model, MDL_EXPLOSIVES_ITEM);
#endif
/* crosshair */ ATTRIB(Explosives, w_crosshair, string, "gfx/crosshair34");
/* crosshair */ ATTRIB(Explosives, w_crosshair_size, float, 0.6);
/* wepimg    */ ATTRIB(Explosives, model2, string, "weaponexplosives");
/* refname   */ ATTRIB(Explosives, netname, string, "explosives");
/* wepname   */ ATTRIB(Explosives, m_name, string, _("Explosives"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, ammo, float, NONE) \
		P(class, prefix, animtime, float, NONE) \
		P(class, prefix, damage, float, NONE) \
		P(class, prefix, edgedamage, float, NONE) \
		P(class, prefix, force, float, NONE) \
		P(class, prefix, radius, float, NONE) \
		P(class, prefix, refire, float, NONE) \
        P(class, prefix, load_abort, float, NONE) \
        P(class, prefix, load_animtime, float, NONE) \
        P(class, prefix, load_hold, float, NONE) \
        P(class, prefix, load_speed, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, weaponreplace, string,NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, Explosives, explosives)
#undef X

ENDCLASS(Explosives)
REGISTER_WEAPON(EXPLOSIVES, explosives, NEW(Explosives));

SPAWNFUNC_WEAPON(weapon_explosives, WEP_EXPLOSIVES)

#endif
#ifdef IMPLEMENTATION

#ifdef SVQC

.float explosives_loadstep, explosives_loadblock, explosives_loadbeep, explosives_warning;
.float explosives_load;
void W_Explosives_Attack_Load_Release(entity actor, .entity weaponentity)
{
	if(!actor.(weaponentity).explosives_load)
		return;

	W_SetupShot(actor, weaponentity, false, 2, SND_ROCKET_IMPACT, CH_WEAPON_A, WEP_CVAR(explosives, damage));

	if(actor.weapons & WEPSET(EXPLOSIVES))
		actor.weapons &= ~WEPSET(EXPLOSIVES); // take it away before doing the damage?

	entity dmgent = spawn();
	dmgent.owner = dmgent.realowner = actor;
	setorigin(dmgent, actor.origin);
	RadiusDamage (dmgent, actor, WEP_CVAR(explosives, damage), WEP_CVAR(explosives, edgedamage), WEP_CVAR(explosives, radius), NULL, NULL, WEP_CVAR(explosives, force), WEP_EXPLOSIVES.m_id, actor);
	delete(dmgent);

	weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(explosives, load_animtime), w_ready);
	actor.(weaponentity).explosives_loadstep = time + WEP_CVAR(explosives, refire) * W_WeaponRateFactor(actor);
	actor.(weaponentity).explosives_load = 0;
}

void W_Explosives_Attack_Load(Weapon thiswep, entity actor, .entity weaponentity)
{
	// loadable explosives secondary attack, must always run each frame
	if(round_handler_IsActive() && !round_handler_IsRoundStarted())
		return;
	if(time < game_starttime)
		return;

	bool loaded = actor.(weaponentity).explosives_load;

	// this is different than WR_CHECKAMMO when it comes to reloading
	bool enough_ammo;
	if(actor.items & IT_UNLIMITED_WEAPON_AMMO)
		enough_ammo = true;
	else if(WEP_CVAR(explosives, reload_ammo))
		enough_ammo = actor.(weaponentity).(weapon_load[WEP_EXPLOSIVES.m_id]) >= WEP_CVAR(explosives, ammo);
	else
		enough_ammo = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(explosives, ammo);

	bool stopped = loaded || !enough_ammo;

	if(PHYS_INPUT_BUTTON_ATCK(actor))
	{
		if(PHYS_INPUT_BUTTON_ATCK2(actor) && WEP_CVAR(explosives, load_abort))
		{
			if(actor.(weaponentity).explosives_load)
			{
				// if we pressed primary fire while loading, unload and abort
				actor.(weaponentity).state = WS_READY;
				W_DecreaseAmmo(thiswep, actor, WEP_CVAR(explosives, ammo) * -1, weaponentity); // give back ammo
				actor.(weaponentity).explosives_load = 0;
				sound(actor, CH_WEAPON_A, SND_HAGAR_BEEP, VOL_BASE, ATTN_NORM);

				// pause until we can load rockets again, once we re-press the alt fire button
				actor.(weaponentity).explosives_loadstep = time + WEP_CVAR(explosives, load_speed) * W_WeaponRateFactor(actor);

				// require letting go of the alt fire button before we can load again
				actor.(weaponentity).explosives_loadblock = true;
			}
		}
		else
		{
			// check if we can attempt to load another rocket
			if(!stopped)
			{
				if(!actor.(weaponentity).explosives_loadblock && actor.(weaponentity).explosives_loadstep < time)
				{
					W_DecreaseAmmo(thiswep, actor, WEP_CVAR(explosives, ammo), weaponentity);
					actor.(weaponentity).state = WS_INUSE;
					actor.(weaponentity).explosives_load += 1;
					//sound(actor, CH_WEAPON_B, SND_HAGAR_LOAD, VOL_BASE * 0.8, ATTN_NORM); // sound is too loud according to most

					if(actor.(weaponentity).explosives_load)
						stopped = true;
					else
						actor.(weaponentity).explosives_loadstep = time + WEP_CVAR(explosives, load_speed) * W_WeaponRateFactor(actor);
				}
			}
			if(stopped && !actor.(weaponentity).explosives_loadbeep && actor.(weaponentity).explosives_load) // prevents the beep from playing each frame
			{
				// if this is the last rocket we can load, play a beep sound to notify the player
				sound(actor, CH_WEAPON_A, SND_HAGAR_BEEP, VOL_BASE, ATTN_NORM);
				actor.(weaponentity).explosives_loadbeep = true;
				actor.(weaponentity).explosives_loadstep = time + WEP_CVAR(explosives, load_hold) * W_WeaponRateFactor(actor);
			}
		}
	}
	else if(actor.(weaponentity).explosives_loadblock)
	{
		// the alt fire button has been released, so re-enable loading if blocked
		actor.(weaponentity).explosives_loadblock = false;
	}

	if(actor.(weaponentity).explosives_load)
	{
		// play warning sound if we're about to release
		if(stopped && actor.(weaponentity).explosives_loadstep - 0.5 < time && WEP_CVAR(explosives, load_hold) >= 0)
		{
			if(!actor.(weaponentity).explosives_warning) // prevents the beep from playing each frame
			{
				// we're about to automatically release after holding time, play a beep sound to notify the player
				sound(actor, CH_WEAPON_A, SND_MINE_TRIGGER, VOL_BASE, ATTN_NORM);
				actor.(weaponentity).explosives_warning = true;
			}
		}

		// release if player let go of button or if they've held it in too long
		if(!PHYS_INPUT_BUTTON_ATCK(actor) || (stopped && actor.(weaponentity).explosives_loadstep < time && WEP_CVAR(explosives, load_hold) >= 0))
		{
			actor.(weaponentity).state = WS_READY;
			W_Explosives_Attack_Load_Release(actor, weaponentity);
		}
	}
	else
	{
		actor.(weaponentity).explosives_loadbeep = false;
		actor.(weaponentity).explosives_warning = false;

		// we aren't checking ammo during an attack, so we must do it here
		if(!(thiswep.wr_checkammo1(thiswep, actor, weaponentity) + thiswep.wr_checkammo2(thiswep, actor, weaponentity)))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			// note: this doesn't force the switch
			W_SwitchToOtherWeapon(actor, weaponentity);
			return;
		}
	}
}

METHOD(Explosives, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    if(vdist(actor.origin - actor.enemy.origin, <, 3000 - bound(0, skill, 10) * 200))
        PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
    else
        PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
}
METHOD(Explosives, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    W_Explosives_Attack_Load(thiswep, actor, weaponentity); // must always run each frame (even when reloading, apparently)
    if(WEP_CVAR(explosives, reload_ammo) && actor.(weaponentity).clip_load < WEP_CVAR(explosives, ammo)) { // forced reload
        thiswep.wr_reload(thiswep, actor, weaponentity);
    }
}
METHOD(Explosives, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(explosives, ammo);
    ammo_amount += actor.(weaponentity).(weapon_load[WEP_EXPLOSIVES.m_id]) >= WEP_CVAR(explosives, ammo);
    return ammo_amount;
}
METHOD(Explosives, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    return false; // false? it doesn't technically have ammo
}
METHOD(Explosives, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
{
    if(!actor.(weaponentity).explosives_load) // require releasing loaded explosive first
        W_Reload(actor, weaponentity, WEP_CVAR(explosives, ammo), SND_RELOAD);
}
METHOD(Explosives, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_EXPLOSIVES_SUICIDE;
}
METHOD(Explosives, wr_killmessage, Notification(entity thiswep))
{
    return WEAPON_EXPLOSIVES_MURDER;
}

#endif
#ifdef CSQC

STATIC_INIT(explosives_weaponpriority)
{
	string curprio = cvar_string("cl_weaponpriority");

	bool have_explosives = strhasword(curprio, "explosives");

	// to save on rebuilding, only loop through if one of these is indeed missing
	if(!have_explosives)
	{
		string newprio = "";
		FOREACH_WORD(curprio, true,
		{
			newprio = cons(newprio, it);

			if(it == "mortar" && !have_explosives)
				newprio = cons(newprio, "explosives");
		});

		cvar_set("cl_weaponpriority", newprio);
	}
}

METHOD(Explosives, wr_impacteffect, void(entity thiswep, entity actor))
{
    vector org2;
    org2 = w_org + w_backoff * 12;
    pointparticles(EFFECT_EXPLOSION_MEDIUM, org2, '0 0 0', 1);
    if(!w_issilent)
        sound(actor, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
}

#endif
#endif
