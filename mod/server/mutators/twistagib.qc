// TODO: Animate sprite
// TODO: Fade out sprite
// TODO: Maybe sprite only visible for frag_target
// TODO: Maybe do something with nades

void updateRIP(entity player);
void RIPThink(entity this);

string ripspr    = "models/twlz/dead.spr";
float ripsprlife = 2;
int speedmode    = 2; // 0 = attacker is 'spawned' normally after a frag (standing still)
                      // 1 = attacker forward speed only is carried over
                      // 2 = speed in any direction is translated to forwardspeed

.entity ripentity;

AUTOCVAR(g_twistagib, bool, false, "InstaGib with a twist");

REGISTER_MUTATOR(twistagib, autocvar_g_twistagib && autocvar_g_instagib && !teamplay)
{
   MUTATOR_ONADD
   {
      precache_model(ripspr);
   }
}

MUTATOR_HOOKFUNCTION(twistagib, PlayerDies, CBC_ORDER_LAST)
{
   entity frag_attacker = M_ARGV(1, entity);
   entity frag_target   = M_ARGV(2, entity);
   float frag_deathtype = M_ARGV(3, float);

   if(!(IS_PLAYER(frag_attacker) && IS_PLAYER(frag_target)) || frag_deathtype == DEATH_HURTTRIGGER.m_id || teamplay)
      return;

   vector org = frag_attacker.origin;
   vector ang = frag_attacker.angles;
   vector vng = frag_attacker.v_angle;
   vector vel = frag_attacker.velocity;

   RemoveGrapplingHooks(frag_attacker);
   RemoveGrapplingHooks(frag_target);

   entity spot = SelectSpawnPoint (frag_attacker, false);

   if(spot)
   {
      Send_Effect(EFFECT_TELEPORT, org, '0 0 0', 1);

      frag_attacker.deadflag = DEAD_NO;
      frag_attacker.effects  = 0;
      frag_attacker.effects |= EF_TELEPORT_BIT;

      frag_attacker.angles = spot.angles;

      frag_attacker.angles_z = 0; // never spawn tilted even if the spot says to
      frag_attacker.fixangle = true; // turn this way immediatelyo

      if(speedmode == 2)
      {
         vector forward, right, up;
         MAKE_VECTORS(frag_attacker.angles, forward, right, up);

         frag_attacker.velocity = forward * vlen(vel);
      }
      else if (speedmode == 1)
      {
         // TODO
      }
      else
      {
         frag_attacker.velocity = '0 0 0';
      }

      frag_attacker.avelocity   = '0 0 0';
      frag_attacker.punchangle  = '0 0 0';
      frag_attacker.punchvector = '0 0 0';
      frag_attacker.oldvelocity = frag_attacker.velocity;

      setorigin(frag_attacker, spot.origin + '0 0 1' * (1 - frag_attacker.mins.z - 24));
      frag_attacker.oldorigin   = frag_attacker.origin;
      frag_attacker.spawnorigin = spot.origin;

      Send_Effect(EFFECT_TELEPORT, frag_attacker.origin, '0 0 0', 1);
   }
   else
   {
      frag_attacker.respawn_flags |= RESPAWN_SILENT;
      PutClientInServer(frag_attacker);
   }

   for(int slot = 0; slot < MAX_WEAPONSLOTS; ++slot)
   {
      .entity went = weaponentities[slot];
      Weapon wep = frag_target.(went).m_weapon;
      wep.wr_playerdeath(wep, frag_target, went);
      SpawnThrownWeapon(frag_target, frag_target.origin + (frag_target.mins + frag_target.maxs) * 0.5, frag_target.(went).m_weapon, went);
   }

   updateRIP(frag_target);
   SetResourceExplicit(frag_target, RES_HEALTH, start_health);
   SetResource(frag_target, RES_CELLS, start_ammo_cells);

   //if(autocvar_g_nades)
   //{
   //   STAT(NADE_BONUS, frag_target)++;
   //   toss_nade(frag_target, true, '0 0 100', time + 0.05);
   //}

   Send_Effect(EFFECT_TELEPORT, frag_target.origin, '0 0 0', 1);

   frag_target.deadflag = DEAD_NO;
   frag_target.effects  = 0;
   frag_target.effects |= EF_TELEPORT_BIT;

   frag_target.angles      = ang;
   frag_target.fixangle    = true; 
   frag_target.v_angle     = vng;
   frag_target.velocity    = vel;
   frag_target.avelocity   = '0 0 0';
   frag_target.punchangle  = '0 0 0';
   frag_target.punchvector = '0 0 0';
   frag_target.oldvelocity = frag_target.velocity;

   setorigin(frag_target, org);
   frag_target.oldorigin = frag_target.origin;

   Send_Effect(EFFECT_TELEPORT, frag_target.origin, '0 0 0', 1);

   return true;
}

void updateRIP(entity player)
{
   player.ripentity       = new(ripentity);
   player.ripentity.owner = player;

   setthink(player.ripentity, RIPThink);

   player.ripentity.nextthink = time + ripsprlife;

   _setmodel(player.ripentity, ripspr);
   setorigin(player.ripentity, player.origin);

   player.ripentity.mdl     = player.ripentity.model;
   player.ripentity.effects = EF_LOWPRECISION;
}

void RIPThink(entity this)
{
   if(this.owner)
      this.owner.ripentity = NULL;

   delete(this);
}

MUTATOR_HOOKFUNCTION(twistagib, BuildMutatorsString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ":TwistaGib");
}

MUTATOR_HOOKFUNCTION(twistagib, BuildMutatorsPrettyString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ", TwistaGib");
}

MUTATOR_HOOKFUNCTION(twistagib, SetModname)
{
   M_ARGV(0, string) = "TwistaGib";
   return true;
}

// 1511 //DP_SV_EFFECT
// 1512 //idea: LordHavoc
// 1513 //darkplaces implementation: LordHavoc
// 1514 //builtin definitions:
// 1515 void(vector org, string modelname, float startframe, float endframe, float framerate) effect = #404;
// 1516 //SVC definitions:
// 1517 //float svc_effect = #52; // [vector] org [byte] modelindex [byte] startframe [byte] framecount [byte] framerate
// 1518 //float svc_effect2 = #53; // [vector] org [short] modelindex [byte] startframe [byte] framecount [byte] framerate
// 1519 //description:
// 1520 //clientside playback of simple custom sprite effects (explosion sprites, etc).
