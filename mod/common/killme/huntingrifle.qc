#include "huntingrifle.qh"

#ifdef SVQC
void W_HuntingRifle_FireBullet(Weapon thiswep, .entity weaponentity, float pSpread, float pDamage, float pForce, float pSolidPenetration, float pAmmo, int deathtype, float pTracer, float pShots, Sound pSound, entity actor)
{
	W_DecreaseAmmo(thiswep, actor, pAmmo, weaponentity);

	W_SetupShot(actor, weaponentity, true, 2, pSound, CH_WEAPON_A, pDamage * pShots, deathtype);

	Send_Effect(EFFECT_RIFLE_MUZZLEFLASH, w_shotorg, w_shotdir * 2000, 1);

	if(PHYS_INPUT_BUTTON_ZOOM(actor) | PHYS_INPUT_BUTTON_ZOOMSCRIPT(actor)) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = actor.origin + actor.view_ofs + ((w_shotorg - actor.origin - actor.view_ofs) * v_forward) * v_forward;
	}

	for(int j = 0; j < pShots; ++j)
		fireBullet(actor, weaponentity, w_shotorg, w_shotdir, pSpread, pSolidPenetration, pDamage, pForce, deathtype, (pTracer ? EF_RED : EF_BLUE));

	if(autocvar_g_casings >= 2)
    {
        makevectors(actor.v_angle); // for some reason, this is lost
		SpawnCasing(((random() * 50 + 50) * v_right) - (v_forward * (random() * 25 + 25)) - ((random() * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 3, actor, weaponentity);
    }
}

void W_HuntingRifle_Attack(entity actor, .entity weaponentity)
{
	W_HuntingRifle_FireBullet(WEP_HUNTINGRIFLE, weaponentity, WEP_CVAR_PRI(huntingrifle, spread), WEP_CVAR_PRI(huntingrifle, damage), WEP_CVAR_PRI(huntingrifle, force), WEP_CVAR_PRI(huntingrifle, solidpenetration), 
		WEP_CVAR_PRI(huntingrifle, ammo), WEP_HUNTINGRIFLE.m_id, WEP_CVAR_PRI(huntingrifle, tracer), WEP_CVAR_PRI(huntingrifle, shots), SND_HUNTINGRIFLE_FIRE, actor);
}

void W_HuntingRifle_Attack2(entity actor, .entity weaponentity)
{
	W_HuntingRifle_FireBullet(WEP_HUNTINGRIFLE, weaponentity, WEP_CVAR_SEC(huntingrifle, spread), WEP_CVAR_SEC(huntingrifle, damage), WEP_CVAR_SEC(huntingrifle, force), WEP_CVAR_SEC(huntingrifle, solidpenetration), 
		WEP_CVAR_SEC(huntingrifle, ammo), WEP_HUNTINGRIFLE.m_id | HITTYPE_SECONDARY, WEP_CVAR_SEC(huntingrifle, tracer), WEP_CVAR_SEC(huntingrifle, shots), SND_HUNTINGRIFLE_FIRE2, actor);
}

.void(entity actor, .entity weaponentity) huntingrifle_bullethail_attackfunc;
.WFRAME huntingrifle_bullethail_frame;
.float huntingrifle_bullethail_animtime;
.float huntingrifle_bullethail_refire;
void W_HuntingRifle_BulletHail_Continue(Weapon thiswep, entity actor, .entity weaponentity, int fire)
{
	float r, af;

	Weapon sw = actor.(weaponentity).m_switchweapon; // make it not detect weapon changes as reason to abort firing
	int slot = weaponslot(weaponentity);
	af = ATTACK_FINISHED(actor, slot);
	actor.(weaponentity).m_switchweapon = actor.(weaponentity).m_weapon;
	ATTACK_FINISHED(actor, slot) = time;
	r = weapon_prepareattack(thiswep, actor, weaponentity, actor.huntingrifle_bullethail_frame == WFRAME_FIRE2, actor.huntingrifle_bullethail_refire);
	if(actor.(weaponentity).m_switchweapon == actor.(weaponentity).m_weapon)
		actor.(weaponentity).m_switchweapon = sw;
	if(r)
	{
		actor.huntingrifle_bullethail_attackfunc(actor, weaponentity);
		weapon_thinkf(actor, weaponentity, actor.huntingrifle_bullethail_frame, actor.huntingrifle_bullethail_animtime, W_HuntingRifle_BulletHail_Continue);
	}
	else
	{
		ATTACK_FINISHED(actor, slot) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
	}
}

void W_HuntingRifle_BulletHail(entity actor, .entity weaponentity, float mode, void(entity actor, .entity weaponentity) AttackFunc, WFRAME fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc(actor, weaponentity);
	if(mode)
	{
		// continue hail
		actor.huntingrifle_bullethail_attackfunc = AttackFunc;
		actor.huntingrifle_bullethail_frame = fr;
		actor.huntingrifle_bullethail_animtime = animtime;
		actor.huntingrifle_bullethail_refire = refire;
		weapon_thinkf(actor, weaponentity, fr, animtime, W_HuntingRifle_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(actor, weaponentity, fr, animtime, w_ready);
	}
}

.float bot_secondary_riflemooth;

METHOD(HuntingRifle, wr_aim, void(entity thiswep, entity actor, .entity weaponentity))
{
    PHYS_INPUT_BUTTON_ATCK(actor) = false;
    PHYS_INPUT_BUTTON_ATCK2(actor) = false;
    if(vdist(actor.origin - actor.enemy.origin, >, 1000))
        actor.bot_secondary_riflemooth = 0;
    if(actor.bot_secondary_riflemooth == 0)
    {
        if(bot_aim(actor, weaponentity, 1000000, 0, 0.001, false))
        {
            PHYS_INPUT_BUTTON_ATCK(actor) = true;
            if(random() < 0.01) actor.bot_secondary_riflemooth = 1;
        }
    }
    else
    {
        if(bot_aim(actor, weaponentity, 1000000, 0, 0.001, false))
        {
            PHYS_INPUT_BUTTON_ATCK2(actor) = true;
            if(random() < 0.03) actor.bot_secondary_riflemooth = 0;
        }
    }
}
METHOD(HuntingRifle, wr_think, void(entity thiswep, entity actor, .entity weaponentity, int fire))
{
    if(autocvar_g_balance_rifle_reload_ammo && actor.(weaponentity).clip_load < min(WEP_CVAR_PRI(huntingrifle, ammo), WEP_CVAR_SEC(huntingrifle, ammo))) { // forced reload
        thiswep.wr_reload(thiswep, actor, weaponentity);
    } else
    {
        actor.(weaponentity).huntingrifle_accumulator = bound(time - WEP_CVAR(huntingrifle, bursttime), actor.(weaponentity).huntingrifle_accumulator, time);
        if(fire & 1)
        if(weapon_prepareattack_check(thiswep, actor, weaponentity, false, WEP_CVAR_PRI(huntingrifle, refire)))
        if(time >= actor.(weaponentity).huntingrifle_accumulator + WEP_CVAR_PRI(huntingrifle, burstcost))
        {
            weapon_prepareattack_do(actor, weaponentity, false, WEP_CVAR_PRI(huntingrifle, refire));
            W_HuntingRifle_BulletHail(actor, weaponentity, WEP_CVAR_PRI(huntingrifle, bullethail), W_HuntingRifle_Attack, WFRAME_FIRE1, WEP_CVAR_PRI(huntingrifle, animtime), WEP_CVAR_PRI(huntingrifle, refire));
            actor.(weaponentity).huntingrifle_accumulator += WEP_CVAR_PRI(huntingrifle, burstcost);
        }
        if(fire & 2)
        {
            if(WEP_CVAR(huntingrifle, secondary))
            {
                if(WEP_CVAR_SEC(huntingrifle, reload)) {
                    thiswep.wr_reload(thiswep, actor, weaponentity);
                } else
                {
                    if(weapon_prepareattack_check(thiswep, actor, weaponentity, true, WEP_CVAR_SEC(huntingrifle, refire)))
                    if(time >= actor.(weaponentity).huntingrifle_accumulator + WEP_CVAR_SEC(huntingrifle, burstcost))
                    {
                        weapon_prepareattack_do(actor, weaponentity, true, WEP_CVAR_SEC(huntingrifle, refire));
                        W_HuntingRifle_BulletHail(actor, weaponentity, WEP_CVAR_SEC(huntingrifle, bullethail), W_HuntingRifle_Attack2, WFRAME_FIRE2, WEP_CVAR_SEC(huntingrifle, animtime), WEP_CVAR_PRI(huntingrifle, refire));
                        actor.(weaponentity).huntingrifle_accumulator += WEP_CVAR_SEC(huntingrifle, burstcost);
                    }
                }
            }
        }
    }
}
METHOD(HuntingRifle, wr_checkammo1, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR_PRI(huntingrifle, ammo);
    ammo_amount += actor.(weaponentity).(weapon_load[WEP_HUNTINGRIFLE.m_id]) >= WEP_CVAR_PRI(huntingrifle, ammo);
    return ammo_amount;
}
METHOD(HuntingRifle, wr_checkammo2, bool(entity thiswep, entity actor, .entity weaponentity))
{
    float ammo_amount = GetResourceAmount(actor, thiswep.ammo_type) >= WEP_CVAR_SEC(huntingrifle, ammo);
    ammo_amount += actor.(weaponentity).(weapon_load[WEP_HUNTINGRIFLE.m_id]) >= WEP_CVAR_SEC(huntingrifle, ammo);
    return ammo_amount;
}
METHOD(HuntingRifle, wr_resetplayer, void(entity thiswep, entity actor))
{
    actor.huntingrifle_accumulator = time - WEP_CVAR(huntingrifle, bursttime);
}
METHOD(HuntingRifle, wr_reload, void(entity thiswep, entity actor, .entity weaponentity))
{
    W_Reload(actor, weaponentity, min(WEP_CVAR_PRI(huntingrifle, ammo), WEP_CVAR_SEC(huntingrifle, ammo)), SND_RELOAD);
}
METHOD(HuntingRifle, wr_suicidemessage, Notification(entity thiswep))
{
    return WEAPON_THINKING_WITH_PORTALS;
}
METHOD(HuntingRifle, wr_killmessage, Notification(entity thiswep))
{
    if(w_deathtype & HITTYPE_SECONDARY)
    {
        if(w_deathtype & HITTYPE_BOUNCE)
            return WEAPON_HUNTINGRIFLE_MURDER_HAIL_PIERCING;
        else
            return WEAPON_HUNTINGRIFLE_MURDER_HAIL;
    }
    else
    {
        if(w_deathtype & HITTYPE_BOUNCE)
            return WEAPON_HUNTINGRIFLE_MURDER_PIERCING;
        else
            return WEAPON_HUNTINGRIFLE_MURDER;
    }
}
METHOD(HuntingRifle, wr_zoom, bool(entity thiswep, entity actor))
{
    return PHYS_INPUT_BUTTON_ATCK2(actor) && WEP_CVAR(huntingrifle, secondary) == 0;
}

REGISTER_MUTATOR(hrifletag, true);

MUTATOR_HOOKFUNCTION(hrifletag, FireBullet_Hit)
{
    entity attacker = M_ARGV(0, entity);
    entity targ = M_ARGV(1, entity);
    entity wep_ent = M_ARGV(5, entity);

	if(IS_DEAD(targ) || wep_ent.m_weapon != WEP_HUNTINGRIFLE || STAT(FROZEN, targ) || !targ.takedamage || attacker.vehicle)
		return;

	if(!targ.huntingrifle_tagged)
		IL_PUSH(g_huntingrifle_tagged, targ);
	targ.huntingrifle_tagged = time + WEP_CVAR(huntingrifle, tag_time);
}

MUTATOR_HOOKFUNCTION(hrifletag, PlayerPowerups)
{
	entity player = M_ARGV(0, entity);

	if(player.huntingrifle_tagged && time < player.huntingrifle_tagged)
		player.effects |= (EF_NODEPTHTEST | EF_ADDITIVE); // make double sure
}

MUTATOR_HOOKFUNCTION(hrifletag, SV_StartFrame)
{
	IL_EACH(g_huntingrifle_tagged, it.huntingrifle_tagged,
	{
		if(time > it.huntingrifle_tagged || IS_DEAD(it) || !it.takedamage || STAT(FROZEN, it))
		{
			it.huntingrifle_tagged = 0;
			it.effects &= ~EF_NODEPTHTEST;
			it.effects &= ~EF_ADDITIVE; // not removed on all entities!
			IL_REMOVE(g_huntingrifle_tagged, it); // dangerous to do from within the loop!
		}
		else
			it.effects |= (EF_ADDITIVE | EF_NODEPTHTEST);
	});
}

#endif
#ifdef CSQC

STATIC_INIT(huntingrifle_weaponpriority)
{
	string curprio = cvar_string("cl_weaponpriority");

	bool have_huntingrifle = strhasword(curprio, "huntingrifle");

	// to save on rebuilding, only loop through if one of these is indeed missing
	if(!have_huntingrifle)
	{
		string newprio = "";
		FOREACH_WORD(curprio, true,
		{
			newprio = cons(newprio, it);

			if(it == "rifle" && !have_huntingrifle)
				newprio = cons(newprio, "huntingrifle");
		});

		cvar_set("cl_weaponpriority", newprio);
	}
}

METHOD(HuntingRifle, wr_impacteffect, void(entity thiswep, entity actor))
{
    vector org2;
    org2 = w_org + w_backoff * 2;
    pointparticles(EFFECT_RIFLE_IMPACT, org2, w_backoff * 1000, 1);
    if(!w_issilent)
    {
        sound(actor, CH_SHOTS, SND_RIC_RANDOM(), VOL_BASE, ATTN_NORM);
    }
}
METHOD(HuntingRifle, wr_init, void(entity thiswep))
{
    if(autocvar_cl_reticle && autocvar_cl_reticle_weapon)
    {
        precache_pic("gfx/reticle_nex");
    }
}
METHOD(HuntingRifle, wr_zoom, bool(entity thiswep, entity actor))
{
    if(button_zoom || zoomscript_caught)
    {
        return true;
    }
    else
    {
        // no weapon specific image for this weapon
        return false;
    }
}

#endif
