void RemoveFB(entity player);

AUTOCVAR(g_nospawnfb, bool, false, "Override PlayerSpawn to remove EF_FULLBRIGHT from players in instagib (only if g_powerups 0)");

REGISTER_MUTATOR(mod_nospawnfb, (autocvar_g_instagib && autocvar_g_nospawnfb) && !autocvar_g_powerups);

MUTATOR_HOOKFUNCTION(mod_nospawnfb, PlayerSpawn, CBC_ORDER_LAST)
{
   entity player = M_ARGV(0, entity);

   RemoveFB(player);
}

MUTATOR_HOOKFUNCTION(mod_nospawnfb, PlayerPowerups, CBC_ORDER_LAST)
{
   entity player = M_ARGV(0, entity);

   RemoveFB(player);
}

void RemoveFB(entity player)
{
   if(player.effects & EF_FULLBRIGHT)
      player.effects &= ~EF_FULLBRIGHT;
}
