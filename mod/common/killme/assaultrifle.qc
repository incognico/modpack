#include "assaultrifle.qh"
#ifndef IMPLEMENTATION

AUTOCVAR(g_balance_assaultrifle_burst, float, 3, "");
AUTOCVAR(g_balance_assaultrifle_burst_ammo, float, 1, "");
AUTOCVAR(g_balance_assaultrifle_burst_animtime, float, 0.4, "");
AUTOCVAR(g_balance_assaultrifle_burst_damage, float, 16, "");
AUTOCVAR(g_balance_assaultrifle_burst_refire, float, 0.1, "");
AUTOCVAR(g_balance_assaultrifle_burst_refire2, float, 0.3, "");
AUTOCVAR(g_balance_assaultrifle_burst_speed, float, 0, "");
AUTOCVAR(g_balance_assaultrifle_first, float, 1, "");
AUTOCVAR(g_balance_assaultrifle_first_ammo, float, 1, "");
AUTOCVAR(g_balance_assaultrifle_first_damage, float, 14, "");
AUTOCVAR(g_balance_assaultrifle_first_force, float, 3, "");
AUTOCVAR(g_balance_assaultrifle_first_refire, float, 0.125, "");
AUTOCVAR(g_balance_assaultrifle_first_spread, float, 0.03, "");
AUTOCVAR(g_balance_assaultrifle_mode, float, 1, "");
AUTOCVAR(g_balance_assaultrifle_reload_ammo, float, 30, "");
AUTOCVAR(g_balance_assaultrifle_reload_time, float, 1.6, "");
AUTOCVAR(g_balance_assaultrifle_solidpenetration, float, 12, "");
AUTOCVAR(g_balance_assaultrifle_spread_add, float, 0.012, "");
AUTOCVAR(g_balance_assaultrifle_spread_max, float, 0.05, "");
AUTOCVAR(g_balance_assaultrifle_spread_min, float, 0.02, "");
AUTOCVAR(g_balance_assaultrifle_sustained_ammo, float, 1, "");
AUTOCVAR(g_balance_assaultrifle_sustained_damage, float, 12, "");
AUTOCVAR(g_balance_assaultrifle_sustained_force, float, 3, "");
AUTOCVAR(g_balance_assaultrifle_sustained_refire, float, 0.15, "");
AUTOCVAR(g_balance_assaultrifle_sustained_spread, float, 0.04, "");
AUTOCVAR(g_balance_assaultrifle_switchdelay_drop, float, 0.2, "");
AUTOCVAR(g_balance_assaultrifle_switchdelay_raise, float, 0.2, "");
AUTOCVAR(g_balance_assaultrifle_weaponreplace, string, "", "");
AUTOCVAR(g_balance_assaultrifle_weaponstart, float, 0, "");
AUTOCVAR(g_balance_assaultrifle_weaponstartoverride, float, -1, "");
AUTOCVAR(g_balance_assaultrifle_weaponthrowable, float, 1, "");

CLASS(AssaultRifle, Weapon)
/* spawnfunc */ ATTRIB(AssaultRifle, m_canonical_spawnfunc, string, "weapon_assaultrifle");
/* ammotype  */ ATTRIB(AssaultRifle, ammo_type, int, RESOURCE_BULLETS);
/* impulse   */ ATTRIB(AssaultRifle, impulse, int, 3);
/* flags     */ ATTRIB(AssaultRifle, spawnflags, int, WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN);
/* rating    */ ATTRIB(AssaultRifle, bot_pickupbasevalue, float, 7000);
/* color     */ ATTRIB(AssaultRifle, wpcolor, vector, '1 0.9 0.6');
/* modelname */ ATTRIB(AssaultRifle, mdl, string, "g3");
#ifdef GAMEQC
/* model     */ ATTRIB(AssaultRifle, m_model, Model, MDL_ASSAULTRIFLE_ITEM);
#endif
/* crosshair */ ATTRIB(AssaultRifle, w_crosshair, string, "gfx/crosshair61");
/* crosshair */ ATTRIB(AssaultRifle, w_crosshair_size, float, 0.6);
/* wepimg    */ ATTRIB(AssaultRifle, model2, string, "weaponassaultrifle");
/* refname   */ ATTRIB(AssaultRifle, netname, string, "assaultrifle");
/* wepname   */ ATTRIB(AssaultRifle, m_name, string, _("Assault Rifle"));

#define X(BEGIN, P, END, class, prefix) \
	BEGIN(class) \
		P(class, prefix, burst, float, NONE) \
		P(class, prefix, burst_ammo, float, NONE) \
		P(class, prefix, burst_animtime, float, NONE) \
		P(class, prefix, burst_damage, float, NONE) \
		P(class, prefix, burst_refire2, float, NONE) \
		P(class, prefix, burst_refire, float, NONE) \
		P(class, prefix, burst_speed, float, NONE) \
		P(class, prefix, first, float, NONE) \
		P(class, prefix, first_ammo, float, NONE) \
		P(class, prefix, first_damage, float, NONE) \
		P(class, prefix, first_force, float, NONE) \
		P(class, prefix, first_refire, float, NONE) \
		P(class, prefix, first_spread, float, NONE) \
		P(class, prefix, mode, float, NONE) \
		P(class, prefix, reload_ammo, float, NONE) \
        P(class, prefix, reload_time, float, NONE) \
		P(class, prefix, solidpenetration, float, NONE) \
		P(class, prefix, spread_add, float, NONE) \
		P(class, prefix, spread_max, float, NONE) \
		P(class, prefix, spread_min, float, NONE) \
		P(class, prefix, sustained_ammo, float, NONE) \
		P(class, prefix, sustained_damage, float, NONE) \
		P(class, prefix, sustained_force, float, NONE) \
		P(class, prefix, sustained_refire, float, NONE) \
		P(class, prefix, sustained_spread, float, NONE) \
        P(class, prefix, switchdelay_drop, float, NONE) \
        P(class, prefix, switchdelay_raise, float, NONE) \
        P(class, prefix, weaponreplace, string,NONE) \
        P(class, prefix, weaponstartoverride, float, NONE) \
        P(class, prefix, weaponstart, float, NONE) \
        P(class, prefix, weaponthrowable, float, NONE) \
	END()
    W_MOD_PROPS(X, AssaultRifle, assaultrifle)
#undef X

ENDCLASS(AssaultRifle)
REGISTER_WEAPON(ASSAULTRIFLE, assaultrifle, NEW(AssaultRifle));

SPAWNFUNC_WEAPON(weapon_assaultrifle, WEP_ASSAULTRIFLE)

MSG_INFO_NOTIF(WEAPON_ASSAULTRIFLE_MURDER_SNIPE,          1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",       "weaponassaultrifle",                _("^BG%s%s^K1 was semi-automatically nailed by ^BG%s^K1's Assault Rifle%s%s"), "")
MSG_INFO_NOTIF(WEAPON_ASSAULTRIFLE_MURDER_SPRAY,          1,  3, 2, "spree_inf s1 s2 s3loc spree_end", "s2 s1",       "weaponassaultrifle",                _("^BG%s%s^K1 was tactically shredded by ^BG%s^K1's Assault Rifle%s%s"), "")

MSG_MULTI_NOTIF(WEAPON_ASSAULTRIFLE_MURDER_SNIPE,     1,  NULL,           INFO_WEAPON_ASSAULTRIFLE_MURDER_SNIPE,    NULL)
MSG_MULTI_NOTIF(WEAPON_ASSAULTRIFLE_MURDER_SPRAY,     1,  NULL,           INFO_WEAPON_ASSAULTRIFLE_MURDER_SPRAY,    NULL)

#endif
#ifdef IMPLEMENTATION
#ifdef CSQC
.entity muzzle_flash;

void W_AssaultRifle_AttachToShotorg(entity wepent, entity flash, vector offset)
{
	flash.owner = wepent;
	flash.angles_z = random() * 360;

	if (gettagindex(wepent, "shot")) setattachment(flash, wepent, "shot");
	else setattachment(flash, wepent, "tag_shot");
	setorigin(flash, offset);
}
#endif

void W_AssaultRifle_MuzzleFlash_Think(entity this)
{
	this.frame += 2;
	this.scale *= 0.5;
	this.alpha -= 0.25;
	this.nextthink = time + 0.05;

	if(this.alpha <= 0)
	{
		setthink(this, SUB_Remove);
		this.nextthink = time;
		this.realowner.muzzle_flash = NULL;
		return;
	}

}

void W_AssaultRifle_MuzzleFlash(entity wepent)
{
	if(wepent.muzzle_flash == NULL)
		wepent.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(wepent.muzzle_flash, MDL_ASSAULTRIFLE_MUZZLEFLASH); // precision set below

	wepent.muzzle_flash.scale = 0.75;
	setthink(wepent.muzzle_flash, W_AssaultRifle_MuzzleFlash_Think);
	wepent.muzzle_flash.nextthink = time + 0.02;
	wepent.muzzle_flash.frame = 2;
	wepent.muzzle_flash.alpha = 0.75;
	wepent.muzzle_flash.angles_z = random() * 180;
	wepent.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT;
	wepent.muzzle_flash.owner = wepent.muzzle_flash.realowner = wepent;

#ifdef CSQC
	wepent.muzzle_flash.drawmask = MASK_NORMAL;
#endif
}

REGISTER_NET_TEMP(assaultrifle_muzzleflash)
#ifdef CSQC
NET_HANDLE(assaultrifle_muzzleflash, bool isNew)
{
	vector a = '5 0 0';
	//a.x = ReadCoord();
    //a.y = ReadCoord();
    //a.z = ReadCoord();
    int slot = ReadByte();
	entity wepent = viewmodels[slot];
	W_AssaultRifle_MuzzleFlash(wepent);
	W_AssaultRifle_AttachToShotorg(wepent, wepent.muzzle_flash, a);
	return true;
}
#endif
#ifdef SVQC
void assaultrifle_muzzleflash_send(entity actor, entity wepent)
{
	if (!IS_REAL_CLIENT(actor)) return;
	int channel = MSG_ONE;
	msg_entity = actor;
	WriteHeader(channel, assaultrifle_muzzleflash);
	//WriteCoord(channel, a.x);
	//WriteCoord(channel, a.y);
	//WriteCoord(channel, a.z);
	WriteByte(channel, weaponslot(wepent.weaponentity_fld));
}
#endif

#ifdef SVQC

void W_AssaultRifle_Attack(Weapon thiswep, int deathtype, entity actor, .entity weaponentity)
{
	W_SetupShot(actor, weaponentity, true, 0, SND_ASSAULTRIFLE_FIRE, CH_WEAPON_A, ((actor.(weaponentity).misc_bulletcounter == 1) ? WEP_CVAR(assaultrifle, first_damage) : WEP_CVAR(assaultrifle, sustained_damage)), deathtype);
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}
	int slot = weaponslot(weaponentity);
	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(actor, slot) = time + WEP_CVAR(assaultrifle, first_refire) * W_WeaponRateFactor(actor);

	if(actor.(weaponentity).misc_bulletcounter == 1)
		fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(assaultrifle, first_spread), WEP_CVAR(assaultrifle, solidpenetration), WEP_CVAR(assaultrifle, first_damage), WEP_CVAR(assaultrifle, first_force), deathtype, 0);
	else
		fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(assaultrifle, sustained_spread), WEP_CVAR(assaultrifle, solidpenetration), WEP_CVAR(assaultrifle, sustained_damage), WEP_CVAR(assaultrifle, sustained_force), deathtype, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	W_AssaultRifle_MuzzleFlash(actor.(weaponentity));
	actor.(weaponentity).muzzle_flash.nodrawtoclient = actor; // client side
	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	FOREACH_CLIENT(it == actor || (IS_SPEC(it) && it.enemy == actor),
	{
		muzzleflash_send(it, actor.(weaponentity));
	});

	// casing code
	if(autocvar_g_casings >= 2)
	{
		makevectors(actor.v_angle); // for some reason, this is lost
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);
	}

	if(actor.(weaponentity).misc_bulletcounter == 1)
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(assaultrifle, first_ammo), weaponentity);
	else
		W_DecreaseAmmo(thiswep, actor, WEP_CVAR(assaultrifle, sustained_ammo), weaponentity);
}

// weapon frames
void W_AssaultRifle_Attack_Frame(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	if(actor.(weaponentity).m_weapon != actor.(weaponentity).m_switchweapon) // abort immediately if switching
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}
	if(PHYS_INPUT_BUTTON_ATCK(actor))
	{
		if(!thiswep.wr_checkammo2(thiswep, actor, weaponentity))
		if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
		{
			W_SwitchWeapon_Force(actor, w_getbestweapon(actor, weaponentity), weaponentity);
			w_ready(thiswep, actor, weaponentity, fire);
			return;
		}
		actor.(weaponentity).misc_bulletcounter = actor.(weaponentity).misc_bulletcounter + 1;
		W_AssaultRifle_Attack(WEP_ASSAULTRIFLE, WEP_ASSAULTRIFLE.m_id, actor, weaponentity);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(assaultrifle, sustained_refire), W_AssaultRifle_Attack_Frame);
	}
	else
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(assaultrifle, sustained_refire), w_ready);
}


void W_AssaultRifle_Attack_Auto(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	float assaultrifle_spread;

	if(!(fire & 2))
	{
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	if(!thiswep.wr_checkammo1(thiswep, actor, weaponentity))
	if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
	{
		W_SwitchWeapon_Force(actor, w_getbestweapon(actor, weaponentity), weaponentity);
		w_ready(thiswep, actor, weaponentity, fire);
		return;
	}

	W_DecreaseAmmo(WEP_ASSAULTRIFLE, actor, WEP_CVAR(assaultrifle, sustained_ammo), weaponentity);

	W_SetupShot(actor, weaponentity, true, 0, SND_ASSAULTRIFLE_FIRE, CH_WEAPON_A, WEP_CVAR(assaultrifle, sustained_damage), WEP_ASSAULTRIFLE.m_id);
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	assaultrifle_spread = bound(WEP_CVAR(assaultrifle, spread_min), WEP_CVAR(assaultrifle, spread_min) + (WEP_CVAR(assaultrifle, spread_add) * actor.(weaponentity).misc_bulletcounter), WEP_CVAR(assaultrifle, spread_max));
	fireBullet(actor, weaponentity, w_shotorg, w_shotdir, assaultrifle_spread, WEP_CVAR(assaultrifle, solidpenetration), WEP_CVAR(assaultrifle, sustained_damage), WEP_CVAR(assaultrifle, sustained_force), WEP_ASSAULTRIFLE.m_id, 0);

	actor.(weaponentity).misc_bulletcounter = actor.(weaponentity).misc_bulletcounter + 1;

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	W_AssaultRifle_MuzzleFlash(actor.(weaponentity));
	actor.(weaponentity).muzzle_flash.nodrawtoclient = actor; // client side
	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	FOREACH_CLIENT(it == actor || (IS_SPEC(it) && it.enemy == actor),
	{
		muzzleflash_send(it, actor.(weaponentity));
	});

	if(autocvar_g_casings >= 2) // casing code
	{
		makevectors(actor.v_angle); // for some reason, this is lost
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);
	}

	int slot = weaponslot(weaponentity);
	ATTACK_FINISHED(actor, slot) = time + WEP_CVAR(assaultrifle, first_refire) * W_WeaponRateFactor(actor);
	weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(assaultrifle, sustained_refire), W_AssaultRifle_Attack_Auto);
}

void W_AssaultRifle_Attack_Burst(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	W_SetupShot(actor, weaponentity, true, 0, SND_ASSAULTRIFLE_FIRE, CH_WEAPON_A, WEP_CVAR(assaultrifle, sustained_damage), WEP_ASSAULTRIFLE.m_id);
	if(!autocvar_g_norecoil)
	{
		actor.punchangle_x = random() - 0.5;
		actor.punchangle_y = random() - 0.5;
	}

	fireBullet(actor, weaponentity, w_shotorg, w_shotdir, WEP_CVAR(assaultrifle, burst_speed), WEP_CVAR(assaultrifle, solidpenetration), WEP_CVAR(assaultrifle, burst_damage), WEP_CVAR(assaultrifle, sustained_force), WEP_ASSAULTRIFLE.m_id, 0);

	Send_Effect(EFFECT_MACHINEGUN_MUZZLEFLASH, w_shotorg, w_shotdir * 1000, 1);

	W_AssaultRifle_MuzzleFlash(actor.(weaponentity));
	actor.(weaponentity).muzzle_flash.nodrawtoclient = actor; // client side
	W_AttachToShotorg(actor, weaponentity, actor.(weaponentity).muzzle_flash, '5 0 0');

	FOREACH_CLIENT(it == actor || (IS_SPEC(it) && it.enemy == actor),
	{
		muzzleflash_send(it, actor.(weaponentity));
	});

	if(autocvar_g_casings >= 2) // casing code
	{
		makevectors(actor.v_angle); // for some reason, this is lost
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);
	}

	actor.(weaponentity).misc_bulletcounter = actor.(weaponentity).misc_bulletcounter + 1;
	if(actor.(weaponentity).misc_bulletcounter == 0)
	{
		int slot = weaponslot(weaponentity);
		ATTACK_FINISHED(actor, slot) = time + WEP_CVAR(assaultrifle, burst_refire2) * W_WeaponRateFactor(actor);
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(assaultrifle, burst_animtime), w_ready);
	}
	else
	{
		weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(assaultrifle, burst_refire), W_AssaultRifle_Attack_Burst);
	}

}

METHOD(AssaultRifle, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    if(vdist(actor.origin - actor.enemy.origin, <, 3000 - bound(0, skill, 10) * 200))
        PHYS_INPUT_BUTTON_ATCK(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
    else
        PHYS_INPUT_BUTTON_ATCK2(actor) = bot_aim(actor, weaponentity, 1000000, 0, 0.001, false);
}
METHOD(AssaultRifle, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    if(WEP_CVAR(assaultrifle, reload_ammo) && actor.(weaponentity).clip_load < min(max(WEP_CVAR(assaultrifle, sustained_ammo), WEP_CVAR(assaultrifle, first_ammo)), WEP_CVAR(assaultrifle, burst_ammo))) { // forced reload
        thiswep.wr_reload(thiswep, actor, weaponentity);
    } else
    if(WEP_CVAR(assaultrifle, mode) == 1)
    {
    	if(fire & 1)
        if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
        {
            if(!thiswep.wr_checkammo2(thiswep, actor, weaponentity))
            if(!(actor.items & IT_UNLIMITED_WEAPON_AMMO))
            {
                W_SwitchWeapon_Force(actor, w_getbestweapon(actor, weaponentity), weaponentity);
                w_ready(thiswep, actor, weaponentity, fire);
                return;
            }

            W_DecreaseAmmo(thiswep, actor, WEP_CVAR(assaultrifle, burst_ammo), weaponentity);

            actor.(weaponentity).misc_bulletcounter = WEP_CVAR(assaultrifle, burst) * -1;
            W_AssaultRifle_Attack_Burst(thiswep, actor, weaponentity, fire);
        }

        if(fire & 2)
        if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
        {
            actor.(weaponentity).misc_bulletcounter = 0;
            W_AssaultRifle_Attack_Auto(thiswep, actor, weaponentity, fire);
        }
    }
    else
    {
    	if((fire & 1) && WEP_CVAR(assaultrifle, first))
        if(weapon_prepareattack(thiswep, actor, weaponentity, true, 0))
        {
            actor.(weaponentity).misc_bulletcounter = 1;
            W_AssaultRifle_Attack(WEP_ASSAULTRIFLE, WEP_ASSAULTRIFLE.m_id | HITTYPE_SECONDARY, actor, weaponentity); // sets attack_finished
            weapon_thinkf(actor, weaponentity, WFRAME_FIRE2, WEP_CVAR(assaultrifle, first_refire), w_ready);
        }

        if(fire & 2)
        if(weapon_prepareattack(thiswep, actor, weaponentity, false, 0))
        {
            actor.(weaponentity).misc_bulletcounter = 1;
            W_AssaultRifle_Attack(WEP_ASSAULTRIFLE, WEP_ASSAULTRIFLE.m_id, actor, weaponentity); // sets attack_finished
            weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, WEP_CVAR(assaultrifle, sustained_refire), W_AssaultRifle_Attack_Frame);
        }
    }
}
METHOD(AssaultRifle, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount;
    if(WEP_CVAR(assaultrifle, mode) == 1)
        ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(assaultrifle, burst_ammo);
    else
        ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(assaultrifle, first_ammo);

    if(WEP_CVAR(assaultrifle, reload_ammo))
    {
        if(WEP_CVAR(assaultrifle, mode) == 1)
            ammo_amount += actor.(weaponentity).(weapon_load[WEP_ASSAULTRIFLE.m_id]) >= WEP_CVAR(assaultrifle, burst_ammo);
        else
            ammo_amount += actor.(weaponentity).(weapon_load[WEP_ASSAULTRIFLE.m_id]) >= WEP_CVAR(assaultrifle, first_ammo);
    }
    return ammo_amount;
}
METHOD(AssaultRifle, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount;
    if(WEP_CVAR(assaultrifle, mode) == 1)
        ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(assaultrifle, sustained_ammo);
    else
        ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR(assaultrifle, first_ammo);

    if(WEP_CVAR(assaultrifle, reload_ammo))
    {
        if(WEP_CVAR(assaultrifle, mode) == 1)
            ammo_amount += actor.(weaponentity).(weapon_load[WEP_ASSAULTRIFLE.m_id]) >= WEP_CVAR(assaultrifle, sustained_ammo);
        else
            ammo_amount += actor.(weaponentity).(weapon_load[WEP_ASSAULTRIFLE.m_id]) >= WEP_CVAR(assaultrifle, first_ammo);
    }
    return ammo_amount;
}
METHOD(AssaultRifle, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
{
    W_Reload(actor, weaponentity, min(max(WEP_CVAR(assaultrifle, sustained_ammo), WEP_CVAR(assaultrifle, first_ammo)), WEP_CVAR(assaultrifle, burst_ammo)), SND_RELOAD);
}
METHOD(AssaultRifle, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(AssaultRifle, wr_killmessage, Notification(entity thiswep))
{
    if(w_deathtype & HITTYPE_SECONDARY)
        return WEAPON_ASSAULTRIFLE_MURDER_SNIPE;
    else
        return WEAPON_ASSAULTRIFLE_MURDER_SPRAY;
}

#endif
#ifdef CSQC

STATIC_INIT(assaultrifle_weaponpriority)
{
	string curprio = cvar_string("cl_weaponpriority");

	bool have_assaultrifle = strhasword(curprio, "assaultrifle");

	// to save on rebuilding, only loop through if one of these is indeed missing
	if(!have_assaultrifle)
	{
		string newprio = "";
		FOREACH_WORD(curprio, true,
		{
			newprio = cons(newprio, it);

			if(it == "machinegun" && !have_assaultrifle)
				newprio = cons(newprio, "assaultrifle");
		});

		cvar_set("cl_weaponpriority", newprio);
	}
}

METHOD(AssaultRifle, wr_impacteffect, void(entity thiswep, entity actor))
{
    vector org2;
    org2 = w_org + w_backoff * 2;
    pointparticles(EFFECT_MACHINEGUN_IMPACT, org2, w_backoff * 1000, 1);
    if(!w_issilent)
        sound(actor, CH_SHOTS, SND_RIC_RANDOM(), VOL_BASE, ATTN_NORM);
}

#endif
#endif
