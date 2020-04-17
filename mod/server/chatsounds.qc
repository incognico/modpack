// TODO: Animate sprite

void snd_precache(string inpattern);
string snd_exists(string inpattern);
void UpdateFlower(entity player);
void FlowerThink(entity this);

.entity flowerentity;
.float floodcontrol_chatsounds;

int delay        = 8;
float spritelife = 2;
string folder    = "twlz/";
string ohsprite  = "models/twlz/flower.spr";

AUTOCVAR(g_chatsounds, bool, false, "Enable Chat Sounds");

REGISTER_MUTATOR(mod_chatsounds, autocvar_g_chatsounds)
{
   MUTATOR_ONADD
   {
      precache_model(ohsprite);
      snd_precache("*.ogg");
      snd_precache("*.wav");
   }
}

MUTATOR_HOOKFUNCTION(mod_chatsounds, PreFormatMessage)
{
   entity player  =     M_ARGV(0, entity);
   string thesnd  = car(M_ARGV(1, string));
   string therest = cdr(M_ARGV(1, string));

   if(!IS_CLIENT(player) || thesnd == "")
      return;

   FOREACH_CHAR(thesnd, true, { if(!((it >= 'a' && it <= 'z') || (it >= 'A' && it <= 'Z') || (it >= '0' && it <= '9') || it == '?' || it == '!' || it == '\0')) return; });

   string exists = snd_exists(thesnd);

   if(exists && IS_REAL_CLIENT(player) && !(IS_SPEC(player) || IS_OBSERVER(player)))
   {
      if (time >= player.(floodcontrol_chatsounds))
      {
         player.(floodcontrol_chatsounds) = time + delay;

         _sound(player, CH_PLAYER, exists, VOL_BASE, 0.4);

         UpdateFlower(player);

         if(therest == "")
            M_ARGV(1, string) = "";
      }
      else
      {
         M_ARGV(1, string) = "";
         sprint(player, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(player.(floodcontrol_chatsounds) - time), "^3 seconds until you can use chat sounds again\n"));
      }
   }
}

MUTATOR_HOOKFUNCTION(mod_chatsounds, ClientDisconnect)
{
   entity player = M_ARGV(0, entity);

   if(player.flowerentity)
      delete(player.flowerentity);
}

void snd_precache(string inpattern)
{
   string pattern = strcat("sound/", folder, inpattern);

   float globhandle, i, n;
   string f;

   globhandle = search_begin(pattern, true, false);
   if (globhandle < 0)
      return;
   n = search_getsize(globhandle);
   for (i = 0; i < n; ++i)
   {
      f = search_getfilename(globhandle, i);
      precache_sound(substring(f,strlen(folder)+1,strlen(f)));
   }
   search_end(globhandle);
}

string snd_exists(string inpattern)
{
   string pattern = strcat("sound/", folder, inpattern);

   string try;
   try = strcat(pattern, ".ogg");
   if(fexists(try))
      return substring(try,strlen(folder)+1,strlen(try));
   try = strcat(pattern, ".wav");
   if(fexists(try))
      return substring(try,strlen(folder)+1,strlen(try));

   return string_null;
}

void UpdateFlower(entity player)
{
    if (player.alpha < 0)
        return;

    if (!player.flowerentity)
    {
        player.flowerentity = new(flowerentity);
        player.flowerentity.owner = player;
        player.flowerentity.exteriormodeltoclient = player;
        setthink(player.flowerentity, FlowerThink);
        player.flowerentity.nextthink = time + spritelife;
        _setmodel(player.flowerentity, ohsprite);
        setorigin(player.flowerentity, '0 0 15' + player.maxs_z * '0 0 1');
        setattachment(player.flowerentity, player, "");
        player.flowerentity.mdl = player.flowerentity.model;
        player.flowerentity.effects = EF_LOWPRECISION;
    }
}

void FlowerThink(entity this)
{
        if(this.owner)
            this.owner.flowerentity = NULL;
        delete(this);
        return;
}
