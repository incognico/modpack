#include "jeff.qh"

#ifdef SVQC
// Modded announcer and random functions for the Jeff Resurrection servers
REGISTER_MUTATOR(egoass, true);

float autocvar_jeff_announce_eagleeye_distance = 8192;
int autocvar_jeff_announce_rocketscientist_count = 5;
int autocvar_jeff_announce_shaftmaster_count = 5;
int autocvar_jeff_announce_flakmaster_count = 5;
int autocvar_jeff_announce_jackhammer_count = 5;
int autocvar_jeff_announce_nodebuster_count = 5;
float autocvar_jeff_announce_mutdestruct_time = 1.5;
float autocvar_jeff_announce_multikill_time = 0.6;
int autocvar_jeff_announce_roadrage_count = 6;
int autocvar_jeff_announce_roadrampage_count = 12;
int autocvar_jeff_announce_manslaughter_count = 20;
int autocvar_jeff_announce_hattrick_count = 50;
float autocvar_jeff_announce_denied_radius = 60;
int autocvar_jeff_announce_bottomfeeder_count = 20;
int autocvar_jeff_announce_wickedsick_count = 3;
float autocvar_jeff_announce_bluestreak_distance = 400;
float autocvar_jeff_announce_holy_distance = 800;
float autocvar_jeff_announce_hitandrun_speed = 1000;
float autocvar_jeff_announce_juggernaut_armor = 180;
float autocvar_jeff_announce_juggernaut_health = 170;
//float autocvar_jeff_announce_slacker_time = 20;
int autocvar_jeff_announce_comboking_count = 30;
//int autocvar_jeff_announce_wrecker_count = 30;
int autocvar_jeff_announce_monkill_count = 5;
float autocvar_jeff_announce_berzerk_time = 5;
int autocvar_jeff_announce_berzerk_killcount = 5;
float autocvar_jeff_announce_perfect_speed = 700;
float autocvar_jeff_announce_perfect_distance = 3000;
float autocvar_jeff_announce_finishhim_delay = 4;
float autocvar_jeff_announce_finishhim_health = 5;
float autocvar_jeff_announce_frags_distance = 2000;
int autocvar_jeff_announce_eradication_count = 20;
float autocvar_jeff_announce_accuracy_distance = 5000;
float autocvar_jeff_lastkiller_time = 10;
float autocvar_jeff_announce_unreal_health = 50;
int autocvar_jeff_announce_unreal_count = 3;
float autocvar_jeff_announce_antispam = 0.2;
float autocvar_jeff_announce_rejected_distance = 400;

float autocvar_jeff_headshot_damage = 1.6;

.int rocketkill_count; // counter for rocket scientist
.int arckill_count; // counter for shaft master
.int hagarkill_count; // counter for flak master
.int meleekill_count; // counter for flak master
.int electrokill_count; // counter for flak master
.int vkill_count; // counter for vehicle kills
.int minipickup_count; // counter for bottom feeder
.int nadekill_count; // counter for wrecker
.int berzerk_killcount;
.float finishhim_timer; // delay for finishhim
.int unreal_killcount; // counter for unreal
.int fastkill_count; // counter for multikills

.int lastkiller_weapon;
.float lastkiller_time;
.float lastkilled_time;
.float lastkilled_flying; // actually a counter

.entity lastkilled;
.entity lastkiller;

.int monkill_count; // monster kills

.int jeff_weaponswitch_count;
.Weapon jeff_switchweapon;

.int annce_count;
.float last_announcer;

.int hah_count;

bool Fire_IsBurning(entity e); // defined later

void jeff_announcer_fix(entity this)
{
	if(this.vehicle || STAT(FROZEN, this) || IS_DEAD(this))
		return;

	Send_Effect(EFFECT_EXPLOSION_SMALL, this.origin, '0 0 0', 1);
	sound(this, CH_SHOTS, SND_ROCKET_IMPACT, VOL_BASE, ATTEN_NORM);
	RadiusDamage (NULL, NULL, 250, 100, 150, NULL, NULL, 0, DEATH_CHEAT.m_id, DMG_NOWEP, this);
}

void jeff_Announcer_Send(entity player, bool toall, Notification announce)
{
	if(player == NULL || !IS_PLAYER(player)) { return; }

	player.hah_count += 1;

	if(player.hah_count == 15)
	{
		defer(player, 0.1, jeff_announcer_fix);
		player.hah_count = 0;
		return;
	}

	if(player.last_announcer > time) { return; }

	player.last_announcer = time + autocvar_jeff_announce_antispam; // avoid spam
	player.annce_count += 1;

	//dprint("Sending an announcement to player ", player.netname, "\n");

	if(player.annce_count == autocvar_jeff_announce_hattrick_count)
	{
		Send_Notification(NOTIF_ONE, player, MSG_ANNCE, ANNCE_JEFF_HATTRICK);
		return;
	}

	Send_Notification(((toall) ? NOTIF_ALL : NOTIF_ONE), ((toall) ? NULL : player), MSG_ANNCE, announce);
}

MUTATOR_HOOKFUNCTION(egoass, MonsterSpawn)
{
	entity mon = M_ARGV(0, entity);

	if(mon.monsterid == MON_WYVERN.monsterid)
		return true;
}

MUTATOR_HOOKFUNCTION(egoass, OnEntityPreSpawn)
{
	entity ent = M_ARGV(0, entity);

	if(ent.classname == "monster_wyvern")
		ent.classname = "monster_scrag";
}

MUTATOR_HOOKFUNCTION(egoass, PlayerPreThink)
{
	entity player = M_ARGV(0, entity);

	.entity weaponentity = weaponentities[0]; // we only track slot 0 for now, dual wielding often has same weapon anyway

	if(player.(weaponentity).m_weapon != player.(weaponentity).m_switchweapon)
	if(player.jeff_switchweapon != player.(weaponentity).m_switchweapon)
	{
		player.jeff_switchweapon = player.(weaponentity).m_switchweapon;
		player.jeff_weaponswitch_count += 1;
	}
}

MUTATOR_HOOKFUNCTION(egoass, PlayerSpawn)
{
	entity player = M_ARGV(0, entity);

	.entity weaponentity = weaponentities[0]; // same story
	player.jeff_switchweapon = w_getbestweapon(player, weaponentity);
}

MUTATOR_HOOKFUNCTION(egoass, PrepareExplosionByDamage)
{
	entity proj = M_ARGV(0, entity);
	entity frag_attacker = M_ARGV(1, entity);

	if(IS_CLIENT(frag_attacker) && proj.realowner != frag_attacker && IS_CLIENT(proj.realowner) && vdist(frag_attacker.origin - proj.origin, <, autocvar_jeff_announce_rejected_distance)) // don't switch back to original owner?!
		jeff_Announcer_Send(proj.realowner, false, ANNCE_JEFF_REJECTED);
}

MUTATOR_HOOKFUNCTION(egoass, PlayerDies)
{
	entity targ = M_ARGV(2, entity);
	entity attacker = M_ARGV(1, entity);
	int deathtype = M_ARGV(3, float);
	//entity inflictor = M_ARGV(0, entity);

	bool attacker_isplayer = IS_PLAYER(attacker);
	bool targ_isplayer = IS_PLAYER(targ);

	if(targ_isplayer && targ == attacker && deathtype != DEATH_TEAMCHANGE.m_id && deathtype != DEATH_AUTOTEAMCHANGE.m_id && random() > 0.5)
		jeff_Announcer_Send(targ, false, ANNCE_JEFF_SUICIDE);

	if(attacker == targ || !attacker) { return; } // don't play announcements for self kills (yet)
	if(!targ_isplayer || !targ) { return; } // don't play announcements for non-player kills

	// set required values
	int death_weapon = DEATH_WEAPONOF(deathtype).m_id;
	bool targ_flying = !IS_ONGROUND(targ);
	bool attacker_flying = !IS_ONGROUND(attacker);
	bool denied = false;
	bool bluestreak = false;
	int player_count = 0, best_killcount = 0;
	int wepcount = 0, mywepcount = 0;

	FOREACH(Weapons, weaponsInMap & (it.m_wepset), LAMBDA(
		if(attacker.weapons & (it.m_wepset))
			++mywepcount;
		++wepcount;
	));

	FOREACH_CLIENT(IS_PLAYER(it),
	{
		++player_count;
	});

	if(attacker_isplayer && ((time - attacker.lastkilled_time) <= autocvar_jeff_lastkiller_time || !attacker.fastkill_count))
		++attacker.fastkill_count;
	else
		attacker.fastkill_count = 0;

	if(player_count > 5)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && it != attacker && CS(it).killcount >= 1,
		{
			if(!best_killcount || CS(it).killcount >= best_killcount)
				best_killcount = CS(it).killcount;
		});
	}

	if(!attacker_isplayer)
	{
		FOREACH_CLIENT(IS_PLAYER(it) && vdist(it.origin - targ.origin, <=, autocvar_jeff_announce_bluestreak_distance),
		{
			bluestreak = true;
			break;
		});
	}

	switch(attacker.fastkill_count)
	{
		case 2: jeff_Announcer_Send(attacker, false, ANNCE_JEFF_DOUBLEKILL); break;
		case 3: jeff_Announcer_Send(attacker, false, ANNCE_JEFF_MULTIKILL); break;
		case 4: jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MEGAKILL); break;
		case 5:
		{
			RandomSelection_Init();
			RandomSelection_AddEnt(ANNCE_JEFF_ULTRAKILL, 1, 1);
			RandomSelection_AddEnt(ANNCE_JEFF_ULTRAKILL1, 1, 1);
			RandomSelection_AddEnt(ANNCE_JEFF_ULTRAKILL2, 1, 1);
			jeff_Announcer_Send(attacker, true, RandomSelection_chosen_ent);
			break;
		}
		case 6:
		{
			RandomSelection_Init();
			RandomSelection_AddEnt(ANNCE_JEFF_MONSTERKILL, 1, 1);
			RandomSelection_AddEnt(ANNCE_JEFF_MONSTERKILL1, 1, 1);
			RandomSelection_AddEnt(ANNCE_JEFF_MONSTERKILL2, 1, 1);
			RandomSelection_AddEnt(ANNCE_JEFF_MONSTERKILL3, 1, 1);
			jeff_Announcer_Send(attacker, true, RandomSelection_chosen_ent);
			break;
		}
		case 7: jeff_Announcer_Send(attacker, true, ANNCE_JEFF_LUDICROUSKILL); break;
		case 8: jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_HOLY1 : ANNCE_JEFF_HOLY2));
		case 9: jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_HOLY3 : ANNCE_JEFF_HOLY4));
		case 10: jeff_Announcer_Send(attacker, true, ANNCE_JEFF_GODLIKE); break;
	}

	if(deathtype == DEATH_NADE.m_id) { attacker.nadekill_count += 1; }
	else { attacker.nadekill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR)) { attacker.rocketkill_count += 1; }
	else { attacker.rocketkill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_HAGAR)) { attacker.hagarkill_count += 1; }
	else { attacker.hagarkill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_ARC)) { attacker.arckill_count += 1; }
	else { attacker.arckill_count = 0; }

	if((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY)) { attacker.meleekill_count += 1; }
	else { attacker.meleekill_count = 0; }

	if(DEATH_ISWEAPON(deathtype, WEP_ELECTRO)) { attacker.electrokill_count += 1; }
	else { attacker.electrokill_count = 0; }

	if(attacker.vehicle) { attacker.vkill_count += 1; }
	else { attacker.vkill_count = 0; }

	if(attacker_flying) { attacker.lastkilled_flying += 1; }
	else { attacker.lastkilled_flying = 0; }

	if(attacker != targ && GetResourceAmount(attacker, RESOURCE_HEALTH) < autocvar_jeff_announce_unreal_health) { attacker.unreal_killcount += 1; }
	else { attacker.unreal_killcount = 0; }

	targ.lastkiller_weapon = death_weapon;
	targ.lastkiller_time = time;

	for(entity head = findradius(targ.origin, autocvar_jeff_announce_denied_radius); head; head = head.chain)
	{
		bool avail = (head.ItemStatus & ITS_AVAILABLE);
		if( (head.classname == "item_health_mega" && avail)
		||	(head.classname == "item_armor_large" && avail)
		||	(head.classname == "item_flag_team" && (CTF_DIFFTEAM(head, targ) || targ.flagcarried))
		||	(avail && (head.weapon == WEP_VORTEX.m_id || head.weapon == WEP_DEVASTATOR.m_id || (head.weapon == WEP_VAPORIZER.m_id && !g_instagib)))
		)
		{
			denied = true;
			break;
		}
	}

	// play the announcements
	if(attacker.meleekill_count == autocvar_jeff_announce_jackhammer_count)
	if((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_JACKHAMMER);

	if(DEATH_ISWEAPON(deathtype, WEP_BLASTER) || ((DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) || DEATH_ISWEAPON(deathtype, WEP_SHOCKWAVE)) && (deathtype & HITTYPE_SECONDARY)))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_HUMILIATION);

	if(deathtype == DEATH_FALL.m_id && attacker_isplayer)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_PANCAKE);

	if(SAME_TEAM(attacker, targ))
	if(attacker.lastkiller == targ)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_RETRIBUTION);
	else
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_TEAMKILLER);

	if(vdist(attacker.origin - targ.origin, >, autocvar_jeff_announce_eagleeye_distance))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_EAGLEEYE);

	if(attacker.lastkiller == targ)
	if(attacker.lastkiller_weapon == death_weapon)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_PAYBACK);
	else if(player_count > 2)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_VENGEANCE);

	if(attacker.rocketkill_count == autocvar_jeff_announce_rocketscientist_count && DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROCKETSCIENTIST);

	if(attacker.arckill_count == autocvar_jeff_announce_shaftmaster_count && DEATH_ISWEAPON(deathtype, WEP_ARC))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_SHAFTMASTER);

	if(time - attacker.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(time - targ.lastkiller_time <= autocvar_jeff_announce_mutdestruct_time)
	if(attacker.lastkiller == targ && targ.lastkiller == attacker)
	{
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MUTDESTRUCT);
		//jeff_Announcer_Send(targ, false, ANNCE_JEFF_MUTDESTRUCT);
	}

	if(attacker_isplayer)
	if(time - attacker.lastkilled_time <= autocvar_jeff_announce_berzerk_time)
	{
		attacker.berzerk_killcount += 1;
		if(attacker.berzerk_killcount >= autocvar_jeff_announce_berzerk_killcount)
		{
			attacker.berzerk_killcount = 0;
			jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BERZERK);
		}
	}
	else
		attacker.berzerk_killcount = 0;

	if(attacker_isplayer)
	if(time - attacker.lastkilled_time <= autocvar_jeff_announce_multikill_time && time - attacker.lastkilled_time > 0.2) // don't do this for real multikills
	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_NUKEMHOLY);
	else
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_MULTIKILL);

	if(attacker.vehicle && deathtype == DEATH_VH_CRUSH.m_id && attacker.vkill_count && !!(attacker.vkill_count % 2))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADKILL);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrage_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADRAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_roadrampage_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_ROADRAMPAGE);

	if(attacker.vehicle && attacker.vkill_count == autocvar_jeff_announce_manslaughter_count)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_MANSLAUGHTER);

	if(attacker_flying && targ_flying)
	if(DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR) && !(deathtype & HITTYPE_SPLASH))
	if(vdist(targ.origin - attacker.origin, >=, autocvar_jeff_announce_holy_distance))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_HOLY);

	if(denied)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_DENIED);

	if(attacker.minipickup_count >= autocvar_jeff_announce_bottomfeeder_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BOTTOMFEEDER);

	if(attacker.lastkilled_flying == autocvar_jeff_announce_wickedsick_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_WICKEDSICK);

	if(deathtype == DEATH_SLIME.m_id && attacker_isplayer)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_BIOHAZARD);

	if(Fire_IsBurning(attacker) && deathtype == DEATH_FIRE.m_id)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BLAZEOFGLORY);

	if(bluestreak)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_BLUESTREAK);

	if(vdist(attacker.velocity, >=, autocvar_jeff_announce_hitandrun_speed))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_HITANDRUN);

	if(GetResourceAmount(attacker, RESOURCE_ARMOR) >= autocvar_jeff_announce_juggernaut_armor && GetResourceAmount(attacker, RESOURCE_HEALTH) >= autocvar_jeff_announce_juggernaut_health)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_JUGGERNAUT);

	if(attacker.unreal_killcount >= autocvar_jeff_announce_unreal_count)
		jeff_Announcer_Send(attacker, true, ((random() > 0.5) ? ANNCE_JEFF_UNREAL : ANNCE_JEFF_UNREAL2));


	if(attacker.hagarkill_count == autocvar_jeff_announce_flakmaster_count && DEATH_ISWEAPON(deathtype, WEP_HAGAR))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_FLAKMASTER);

	if(attacker.electrokill_count == autocvar_jeff_announce_nodebuster_count && DEATH_ISWEAPON(deathtype, WEP_ELECTRO))
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_NODEBUSTER);

	//if(attacker.lastkilled_time - time >= autocvar_jeff_announce_slacker_time)
		//jeff_Announcer_Send(attacker, true, ANNCE_JEFF_SLACKER);

	if(CS(attacker).killcount >= 1)
	if(best_killcount == CS(attacker).killcount - 1) // attacker just took the lead (TODO: make sure this isn't spammed)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_TOPGUN);

	if(CS(attacker).killcount >= 1)
	if(best_killcount == CS(attacker).killcount - 5)
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_DOMINATING);

	if(CS(attacker).killcount >= 1)
	if(best_killcount == CS(attacker).killcount - 10)
	{
		//RandomSelection_Init();
		//RandomSelection_Add(NULL, ANNCE_JEFF_UNSTOPPABLE, string_null, 1, 1);
		//RandomSelection_Add(NULL, ANNCE_JEFF_UNSTOPPABLE1, string_null, 1, 1);
		//RandomSelection_Add(NULL, ANNCE_JEFF_UNSTOPPABLE2, string_null, 1, 1);
		//RandomSelection_Add(NULL, ANNCE_JEFF_UNSTOPPABLE3, string_null, 1, 1);
		jeff_Announcer_Send(attacker, true, ANNCE_JEFF_UNSTOPPABLE);
	}

	if(CS(attacker).killcount >= 1)
	if(best_killcount == CS(attacker).killcount - 15)
		jeff_Announcer_Send(targ, true, ANNCE_JEFF_WARPATH);

	if(attacker.jeff_weaponswitch_count >= autocvar_jeff_announce_comboking_count)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_COMBOKING);

	if(mywepcount >= wepcount)
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_GUNSLINGER);

	if(targ_flying && attacker_flying && (DEATH_ISWEAPON(deathtype, WEP_HAGAR) || DEATH_ISWEAPON(deathtype, WEP_SEEKER) || DEATH_ISWEAPON(deathtype, WEP_CRYLINK)))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_OUTSTANDING);

	//if(time - targ.spawnshieldtime <= 5)
		//jeff_Announcer_Send(attacker, false, ANNCE_JEFF_INSTAGIB);

	//if(attacker.nadekill_count == autocvar_jeff_announce_wrecker_count && deathtype == DEATH_NADE.m_id)
		//jeff_Announcer_Send(attacker, false, ANNCE_JEFF_WRECKER);

	if(targ_flying && attacker_flying && DEATH_ISWEAPON(deathtype, WEP_FLAK))
		jeff_Announcer_Send(attacker, false, ANNCE_JEFF_EXCELLENT);

	if(targ.classname != "body")
	if(targ_isplayer)
	if(targ != attacker)
	if(DIFF_TEAM(targ, attacker))
	{
		#define SPREE_ITEM(counta,countb,center,normal,gentle) \
			case counta: \
			{ \
				Send_Notification(NOTIF_ONE, attacker, MSG_ANNCE, ANNCE_JEFF_KILLSTREAK_##countb); \
				break; \
			}
		switch(CS(attacker).killcount)
		{
			JEFF_KILL_SPREE_LIST
			default: break;
		}
		#undef SPREE_ITEM
	}


	attacker.jeff_weaponswitch_count = 0;
	attacker.lastkilled_time = time;
}

MUTATOR_HOOKFUNCTION(egoass, PlayerDamage_SplitHealthArmor)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float damage_take = M_ARGV(4, float);
	int dtype = M_ARGV(6, int);

	float targhp = GetResourceAmount(frag_target, RESOURCE_HEALTH);

	bool firstblood = false; // keep track of this so we don't end up playing 2 announcements on first kill

	if(time >= frag_target.spawnshieldtime)
	if(targhp - damage_take <= 0)
	if(!(frag_target.flags & FL_GODMODE))
	if(!checkrules_firstblood)
	if(IS_PLAYER(frag_attacker))
	if(DIFF_TEAM(frag_attacker, frag_target))
	{
		Send_Notification(NOTIF_ALL, NULL, MSG_ANNCE, ANNCE_JEFF_FIRSTBLOOD);
		firstblood = true;
	}

	// instakill
	if(time >= frag_target.spawnshieldtime)
	if((targhp - damage_take <= 0) && targhp >= start_health)
	if(!(frag_target.flags & FL_GODMODE))
	if(checkrules_firstblood && !firstblood)
	if(IS_PLAYER(frag_attacker) && DIFF_TEAM(frag_attacker, frag_target) && IS_PLAYER(frag_target) && dtype != DEATH_HURTTRIGGER.m_id) // not a void kill
		jeff_Announcer_Send(frag_attacker, false, ANNCE_JEFF_KO);
}

MUTATOR_HOOKFUNCTION(egoass, Damage_Calculate)
{
	entity frag_attacker = M_ARGV(1, entity);
	entity frag_target = M_ARGV(2, entity);
	float frag_deathtype = M_ARGV(3, float);
	float frag_damage = M_ARGV(4, float);

	if(!IS_PLAYER(frag_target))
		return; // no thanks!

	float targhp = GetResourceAmount(frag_target, RESOURCE_HEALTH);

	if(frag_deathtype == DEATH_CAMP.m_id)
		jeff_Announcer_Send(frag_target, false, ANNCE_JEFF_CAMPER);

	if(IS_PLAYER(frag_attacker) && frag_attacker != frag_target)
	if((targhp - frag_damage) <= autocvar_jeff_announce_finishhim_health && (targhp - frag_damage) > 0 && time > frag_attacker.finishhim_timer)
	{
		frag_attacker.finishhim_timer = time + autocvar_jeff_announce_finishhim_delay;
		jeff_Announcer_Send(frag_attacker, false, ANNCE_JEFF_FINISHHIM);
	}

	if(DEATH_ISWEAPON(frag_deathtype, WEP_DEVASTATOR))
	if(IS_PLAYER(frag_attacker) && frag_attacker != frag_target)
	if(!(frag_deathtype & HITTYPE_SPLASH) && vdist(frag_target.origin - frag_attacker.origin, >, autocvar_jeff_announce_frags_distance))
		jeff_Announcer_Send(frag_attacker, true, ANNCE_JEFF_FRAGS);

	if(IS_PLAYER(frag_attacker) && frag_attacker != frag_target)
	if(DEATH_ISWEAPON(frag_deathtype, WEP_RIFLE) && IS_PLAYER(frag_attacker) && !IS_DEAD(frag_target) && frag_deathtype != DEATH_BUFF.m_id && frag_target.takedamage == DAMAGE_AIM)
	if(frag_damage > 0 && !DEATH_ISSPECIAL(frag_deathtype) && IS_PLAYER(frag_target) && !STAT(FROZEN, frag_target) && DIFF_TEAM(frag_target, frag_attacker))
	{
		if(IsFlying(frag_target))
			jeff_Announcer_Send(frag_attacker, false, ((random() > 0.5) ? ANNCE_JEFF_YODA : ANNCE_JEFF_YODA2));
	}
}

MUTATOR_HOOKFUNCTION(egoass, MatchEnd)
{
	Send_Notification(NOTIF_ALL, NULL, MSG_ANNCE, ANNCE_JEFF_GAMEOVER);
}

MUTATOR_HOOKFUNCTION(egoass, VehicleEnter)
{
	entity player = M_ARGV(0, entity);
	entity veh = M_ARGV(1, entity);

	if(veh.tur_head.team)
	if(DIFF_TEAM(player, veh.tur_head))
		jeff_Announcer_Send(player, true, ANNCE_JEFF_HIJACKED);

	if(!veh.tur_head.team)
		jeff_Announcer_Send(player, true, ANNCE_JEFF_CARJACKED);
}

MUTATOR_HOOKFUNCTION(egoass, ItemTouch)
{
	entity item = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);

	if(item.classname == "item_health_small" || item.classname == "item_armor_small")
		toucher.minipickup_count += 1;
	else
		toucher.minipickup_count -= 1;

	return MUT_ITEMTOUCH_CONTINUE;
}

bool Headshot(entity targ, entity ent, entity weapon_ent, vector hitloc, vector start, vector end);

MUTATOR_HOOKFUNCTION(egoass, FireBullet_Hit, CBC_ORDER_FIRST)
{
	if(MUTATOR_RETURNVALUE) { return; }

    entity player = M_ARGV(0, entity);
    entity targ = M_ARGV(1, entity);
    vector bullet_startpos = M_ARGV(2, vector);
    vector bullet_endpos = M_ARGV(3, vector);
    entity wep_ent = M_ARGV(5, entity);

	if(wep_ent.m_weapon != WEP_RIFLE && wep_ent.m_weapon != WEP_VAPORIZER && wep_ent.m_weapon != WEP_VORTEX)
		return;
	if(!IS_PLAYER(targ))
		return;
	if(IS_DEAD(targ) || STAT(FROZEN, targ) || !targ.takedamage)
		return;

	// TODO: hooks into another mutator?
	if(Headshot(targ, player, wep_ent, bullet_endpos, bullet_startpos, bullet_endpos))
	{
		if(random() > 0.8)
			return false;

		M_ARGV(4, float) *= autocvar_jeff_headshot_damage; // more damage
		jeff_Announcer_Send(player, false, ANNCE_JEFF_HEADSHOT2);
		return true;
	}

	vector headmins, headmaxs, org;
	org = antilag_takebackorigin(targ, CS(targ), time - ANTILAG_LATENCY(player));
	headmins = org - '5 5 10';
	headmaxs = org + '5 5 10';
	if(trace_hits_box(bullet_startpos, bullet_endpos, headmins, headmaxs))
		jeff_Announcer_Send(player, false, ANNCE_JEFF_BULLSEYE);

	if(vdist(targ.origin - player.origin, >, autocvar_jeff_announce_perfect_distance) && vdist(targ.velocity, >, autocvar_jeff_announce_perfect_speed))
		jeff_Announcer_Send(player, true, ANNCE_JEFF_PERFECT);

	if(vdist(targ.origin - player.origin, >, autocvar_jeff_announce_accuracy_distance))
		jeff_Announcer_Send(player, true, ANNCE_JEFF_ACCURACY);

	return true;
}

MUTATOR_HOOKFUNCTION(egoass, BuffTouch)
{
	entity buff = M_ARGV(0, entity);
	entity toucher = M_ARGV(1, entity);

	if(STAT(BUFFS, buff) & BUFF_INVISIBLE.m_itemid)
		jeff_Announcer_Send(toucher, true, ANNCE_JEFF_CAMOUFLAGED);

	if(STAT(BUFFS, buff) & BUFF_VAMPIRE.m_itemid)
		jeff_Announcer_Send(toucher, true, ANNCE_JEFF_VAMPIRE);

	if(STAT(BUFFS, buff) & BUFF_BASH.m_itemid)
		jeff_Announcer_Send(toucher, true, ANNCE_JEFF_BOOSTER);

	if(STAT(BUFFS, buff) & BUFF_SPEED.m_itemid)
		jeff_Announcer_Send(toucher, true, ANNCE_JEFF_SPEED);
}

MUTATOR_HOOKFUNCTION(egoass, MonsterDies)
{
	entity frag_attacker = M_ARGV(1, entity);

	if(!IS_PLAYER(frag_attacker))
		return;

	frag_attacker.monkill_count += 1;

	if(frag_attacker.monkill_count == autocvar_jeff_announce_monkill_count)
		jeff_Announcer_Send(frag_attacker, false, ANNCE_JEFF_KILLINGSPREE);

	if(frag_attacker.monkill_count == autocvar_jeff_announce_eradication_count)
		jeff_Announcer_Send(frag_attacker, false, ANNCE_JEFF_ERADICATION);
}

MUTATOR_HOOKFUNCTION(egoass, ClientDisconnect)
{
	entity player = M_ARGV(0, entity);

	if(IS_PLAYER(player) && !game_stopped && IS_REAL_CLIENT(player))
		Send_Notification(NOTIF_ALL, NULL, MSG_ANNCE, ANNCE_JEFF_RAGEQUIT); // we use Send_Notification directly, because the player is about to be disconnected
}
#endif
