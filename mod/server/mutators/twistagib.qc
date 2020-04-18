// TODO: Animate sprite
// TODO: Fade out sprite
// TODO: Maybe do something with nades

void updateRIP(entity player);
void RIPThink(entity this);

string ripspr = "models/twlz/dead.spr";
float ripsprlife = 2.2;

.entity ripentity;

AUTOCVAR(g_twistagib, bool, false, "InstaGib with a twist");

REGISTER_MUTATOR(twistagib, autocvar_g_twistagib && autocvar_g_instagib && !teamplay)
{
   MUTATOR_ONADD
   {
      precache_model(ripspr);
   }
}

MUTATOR_HOOKFUNCTION(twistagib, PlayerDies)
{
   entity frag_attacker = M_ARGV(1, entity);
   entity frag_target = M_ARGV(2, entity);
   float frag_deathtype = M_ARGV(3, float);

   if(!(IS_PLAYER(frag_attacker) && IS_PLAYER(frag_target)) || frag_deathtype == DEATH_HURTTRIGGER.m_id || teamplay)
      return;

   vector org = frag_attacker.origin;
   vector ang = frag_attacker.angles;
   vector vng = frag_attacker.v_angle;
   vector vel = frag_attacker.velocity;

   RemoveGrapplingHooks(frag_attacker);
   RemoveGrapplingHooks(frag_target);

   frag_attacker.respawn_flags |= RESPAWN_SILENT;
   PutClientInServer(frag_attacker);

   updateRIP(frag_target);
   SetResourceExplicit(frag_target, RES_HEALTH, start_health);

   //if(autocvar_g_nades)
   //{
   //   STAT(NADE_BONUS, frag_target)++;
   //   toss_nade(frag_target, true, '0 0 100', time + 0.05);
   //}

   setorigin(frag_target, org);
   frag_target.oldorigin = org;
   frag_target.angles = ang;
   frag_target.v_angle = vng;
   frag_target.velocity = vel;

   return true;
}

MUTATOR_HOOKFUNCTION(twistagib, BuildMutatorsString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ":TwistaGib");
}

MUTATOR_HOOKFUNCTION(twistagib, BuildMutatorsPrettyString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ", TwistaGib");
}

//MUTATOR_HOOKFUNCTION(twistagib, SetModname)
//{
//   M_ARGV(0, string) = "TwistaGib";
//   return true;
//}

void updateRIP(entity player)
{
   player.ripentity = new(ripentity);
   player.ripentity.owner = player;
   setthink(player.ripentity, RIPThink);
   player.ripentity.nextthink = time + ripsprlife;
   _setmodel(player.ripentity, ripspr);
   setorigin(player.ripentity, player.origin);
   player.ripentity.mdl = player.ripentity.model;
   player.ripentity.effects = EF_LOWPRECISION;
}

void RIPThink(entity this)
{
        if(this.owner)
            this.owner.ripentity = NULL;
        delete(this);
        return;
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
