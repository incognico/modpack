#ifndef SCRAG_H
#define SCRAG_H

#ifdef GAMEQC
MODEL(MON_SCRAG, M_Model("scrag.mdl"));

SOUND(SCRAG_FIRESPIKE, W_Sound("electro_fire"));
#endif

CLASS(Scrag, Monster)
    ATTRIB(Scrag, spawnflags, int, MONSTER_SIZE_QUAKE | MON_FLAG_HIDDEN | MONSTER_TYPE_FLY | MON_FLAG_RANGED);
    ATTRIB(Scrag, m_mins, vector, '-16 -16 -24');
    ATTRIB(Scrag, m_maxs, vector, '16 16 40');
#ifdef GAMEQC
    ATTRIB(Scrag, m_model, Model, MDL_MON_SCRAG);
#endif
    ATTRIB(Scrag, netname, string, "scrag");
    ATTRIB(Scrag, monster_name, string, "Scrag");
ENDCLASS(Scrag)

REGISTER_MONSTER(SCRAG, NEW(Scrag));

CLASS(ScragAttack, PortoLaunch)
/* flags     */ ATTRIB(ScragAttack, spawnflags, int, WEP_FLAG_SPECIALATTACK);
/* impulse   */ ATTRIB(ScragAttack, impulse, int, 9);
/* refname   */ ATTRIB(ScragAttack, netname, string, "scrag");
/* wepname   */ ATTRIB(ScragAttack, message, string, "Scrag attack");
ENDCLASS(ScragAttack)
REGISTER_WEAPON(SCRAG_ATTACK, NEW(ScragAttack));

#endif

#ifdef IMPLEMENTATION

#ifdef SVQC

AUTOCVAR(g_monster_scrag_attack_spike_damage, float, 10, "");
AUTOCVAR(g_monster_scrag_attack_spike_edgedamage, float, 4, "");
AUTOCVAR(g_monster_scrag_attack_spike_force, float, 10, "");
AUTOCVAR(g_monster_scrag_attack_spike_radius, float, 10, "");
AUTOCVAR(g_monster_scrag_attack_spike_speed, float, 600, "");

void M_Scrag_Attack_Spike_Explode_think(entity this);
void M_Scrag_Attack_Spike_Touch(entity this, entity toucher);

METHOD(ScragAttack, wr_think, void(ScragAttack thiswep, entity actor, .entity weaponentity, int fire))
{
	TC(ScragAttack, thiswep);
    if (fire & 1)
    if (time > actor.attack_finished_single[0] || weapon_prepareattack(thiswep, actor, weaponentity, false, 1.2)) {
        if (IS_PLAYER(actor)) W_SetupShot_Dir(actor, weaponentity, v_forward, false, 0, SND_SCRAG_FIRESPIKE, CH_WEAPON_B, 0, DEATH_MONSTER_WYVERN.m_id);
		if (IS_MONSTER(actor)) {
			actor.anim_finished = time + 1.2;
		}

		actor.attack_finished_single[0] = time + 1.2;

		entity missile = spawn();
		missile.owner = missile.realowner = actor;
		missile.solid = SOLID_TRIGGER;
		set_movetype(missile, MOVETYPE_FLYMISSILE);
		missile.projectiledeathtype = DEATH_MONSTER_WYVERN.m_id;
		setsize(missile, '-6 -6 -6', '6 6 6');
		setorigin(missile, actor.origin + actor.view_ofs + v_forward * 14);
		missile.flags = FL_PROJECTILE;
		IL_PUSH(g_projectiles, missile);
		IL_PUSH(g_bot_dodge, missile);
		missile.velocity = w_shotdir * (autocvar_g_monster_scrag_attack_spike_speed);
		missile.avelocity = '300 300 300';
		missile.nextthink = time + 5;
		setthink(missile, M_Scrag_Attack_Spike_Explode_think);
		settouch(missile, M_Scrag_Attack_Spike_Touch);
		CSQCProjectile(missile, true, PROJECTILE_CRYLINK, true);

        weapon_thinkf(actor, weaponentity, WFRAME_FIRE1, 0, w_ready);
    }
}

METHOD(ScragAttack, wr_checkammo1, bool(ScragAttack thiswep, entity actor, .entity weaponentity)) {
	TC(ScragAttack, this);
	return true;
}

AUTOCVAR(g_monster_scrag_health, float, 110, "");
AUTOCVAR(g_monster_scrag_damageforcescale, float, 0.55, "");
AUTOCVAR(g_monster_scrag_speed_stop, float, 50, "");
AUTOCVAR(g_monster_scrag_speed_run, float, 120, "");
AUTOCVAR(g_monster_scrag_speed_walk, float, 80, "");

/*
const float scrag_anim_hover	= 0;
const float scrag_anim_fly		= 1;
const float scrag_anim_magic	= 2;
const float scrag_anim_pain	= 3;
const float scrag_anim_death	= 4;
*/

void M_Scrag_Attack_Spike_Explode(entity this, entity directhitentity)
{
	//Send_Effect(EFFECT_FIREBALL_EXPLODE, this.origin, '0 0 0', 1);
	__pointparticles(_particleeffectnum("TE_WIZSPIKE"), this.origin, '0 0 0', 1);

	entity own = this.realowner;

	RadiusDamage(this, own, autocvar_g_monster_scrag_attack_spike_damage, autocvar_g_monster_scrag_attack_spike_edgedamage, autocvar_g_monster_scrag_attack_spike_force, 
		NULL, NULL, autocvar_g_monster_scrag_attack_spike_radius, this.projectiledeathtype, DMG_NOWEP, directhitentity);

	delete(this);
}

void M_Scrag_Attack_Spike_Explode_think(entity this)
{
	M_Scrag_Attack_Spike_Explode(this, NULL);
}

void M_Scrag_Attack_Spike_Touch(entity this, entity toucher)
{
	PROJECTILE_TOUCH(this, toucher);
	if(toucher == this.owner) { return; }

	M_Scrag_Attack_Spike_Explode(this, toucher);
}

bool M_Scrag_Attack(int attack_type, entity actor, entity targ, .entity weaponentity)
{
	switch(attack_type)
	{
		case MONSTER_ATTACK_MELEE:
		case MONSTER_ATTACK_RANGED:
		{
			w_shotdir = normalize((actor.enemy.origin + '0 0 10') - actor.origin);
			Weapon wep = WEP_SCRAG_ATTACK;
			wep.wr_think(wep, actor, weaponentity, 1);

			if(random() <= 0.1 || actor.monster_moveto)
			{
				vector forward, right, up;
				MAKE_VECTORS(actor.angles, forward, right, up);
				actor.monster_moveto = actor.origin + '1 1 0' * (random() >= 0.5) ? (right * 300) : (right * -300);
				actor.monster_face = actor.enemy.origin; // but still look at enemy
				if(random() <= 0.4)
					actor.monster_moveto = actor.monster_face = '0 0 0';
			}
			return true;
		}
	}

	return false;
}

spawnfunc(monster_scrag) { Monster_Spawn(this, true, MON_SCRAG.monsterid); }
#endif // SVQC

		#ifdef SVQC
		METHOD(Scrag, mr_think, bool(Scrag thismon, entity actor))
		{
			return true;
		}
		METHOD(Scrag, mr_pain, float(Scrag thismon, entity actor, float damage_take, entity attacker, float deathtype))
		{
			actor.pain_finished = time + 0.5;
			setanim(actor, actor.anim_pain1, true, true, false);
			return damage_take;
		}
		METHOD(Scrag, mr_death, bool(Scrag thismon, entity actor))
		{
			setanim(actor, actor.anim_die1, false, true, true);
			actor.velocity_x = -200 + 400 * random();
			actor.velocity_y = -200 + 400 * random();
			actor.velocity_z = 100 + 100 * random();
			return true;
		}
		#endif
		#ifdef GAMEQC
		METHOD(Scrag, mr_anim, bool(Scrag thismon, entity actor))
		{
			vector none = '0 0 0';
			actor.anim_die1 = animfixfps(actor, '4 1 0.5', none); // 2 seconds
			actor.anim_walk = animfixfps(actor, '1 1 1', none);
			actor.anim_idle = animfixfps(actor, '0 1 1', none);
			actor.anim_pain1 = animfixfps(actor, '3 1 2', none); // 0.5 seconds
			actor.anim_shoot = animfixfps(actor, '2 1 5', none); // analyze models and set framerate
			actor.anim_run = animfixfps(actor, '1 1 1', none);
			return true;
		}
		#endif
		#ifdef SVQC
		METHOD(Scrag, mr_setup, bool(Scrag thismon, entity actor))
		{
			if(!GetResource(actor, RES_HEALTH)) SetResourceExplicit(actor, RES_HEALTH, autocvar_g_monster_scrag_health);
			if(!actor.speed) { actor.speed = (autocvar_g_monster_scrag_speed_walk); }
			if(!actor.speed2) { actor.speed2 = (autocvar_g_monster_scrag_speed_run); }
			if(!actor.stopspeed) { actor.stopspeed = (autocvar_g_monster_scrag_speed_stop); }
			if(!actor.damageforcescale) { actor.damageforcescale = (autocvar_g_monster_scrag_damageforcescale); }

			//actor.monster_loot = ITEM_Cells;
			actor.monster_attackfunc = M_Scrag_Attack;

			return true;
		}
		#endif

#endif
