AUTOCVAR(g_hitrefire, bool, false, "Faster refire if a hit was scored the Vaporizer");

REGISTER_MUTATOR(hitrefire, autocvar_g_hitrefire && autocvar_g_instagib);

MUTATOR_HOOKFUNCTION(hitrefire, Damage_Calculate)
{
   entity att = M_ARGV(1, entity);
   float  dt  = M_ARGV(3, float);
   entity wep = M_ARGV(7, entity);

   if(wep.m_weapon != WEP_VAPORIZER || (dt & HITTYPE_SECONDARY))
      return;

   .entity weaponentity = wep.weaponentity_fld;
   ATTACK_FINISHED(att, weaponslot(weaponentity)) = time;
   PHYS_INPUT_BUTTON_ATCK(att) = false;
   weapon_thinkf(att, weaponentity, WFRAME_DONTCHANGE, 0, w_ready);
   //weapon_thinkf(att, weaponentity, WFRAME_DONTCHANGE, WEP_CVAR_PRI(vaporizer, animtime), w_ready);
}

MUTATOR_HOOKFUNCTION(hitrefire, BuildMutatorsString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ":HitRefire");
}

MUTATOR_HOOKFUNCTION(hitrefire, BuildMutatorsPrettyString)
{
   M_ARGV(0, string) = strcat(M_ARGV(0, string), ", HitRefire");
}
