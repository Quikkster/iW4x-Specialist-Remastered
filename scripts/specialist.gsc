#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;

/*
*
* 	@FableServers: Specialist Strike Package - Mod by @QKSTR 
*
*/

init()
{
    //Shaders
	PrecacheShader("specialty_hardline");

	PrecacheShader("specialty_marathon");
	PrecacheShader("specialty_quickdraw");
	PrecacheShader("specialty_fastreload");
	PrecacheShader("specialty_lightweight");
	PrecacheShader("specialty_scavenger");
	PrecacheShader("specialty_bulletdamage");
	PrecacheShader("specialty_coldblooded");
	PrecacheShader("specialty_dangerclose");	
	PrecacheShader("specialty_commando");
	PrecacheShader("specialty_steadyaim");
	PrecacheShader("specialty_bulletaccuracy");
	PrecacheShader("specialty_detectexplosive");
	PrecacheShader("specialty_heartbreaker");
	PrecacheShader("specialty_localjammer");
	PrecacheShader("specialty_quieter");
	PrecacheShader("specialty_bombsquad");
	PrecacheShader("specialty_hardline");
	PrecacheShader("specialty_onemanarmy_upgrade");
	//Strings
	PrecacheString( &"PERKS_HARDLINE" );	

	PrecacheString( &"PERKS_MARATHON" );	
	PrecacheString( &"PERKS_SLEIGHT_OF_HAND" );	
	PrecacheString( &"PERKS_QUICKDRAW" );	
	PrecacheString( &"PERKS_SCAVENGER" );	
	//--
	PrecacheString( &"PERKS_STOPPING_POWER" );	
	PrecacheString( &"PERKS_LIGHTWEIGHT" );	
	PrecacheString( &"PERKS_COLDBLOODED" );	
	PrecacheString( &"PERKS_DANGERCLOSE" );	
	//--
	PrecacheString( &"PERKS_EXTENDEDMELEE" );	
	PrecacheString( &"PERKS_STEADY_AIM" );	
	PrecacheString( &"PERKS_LOCALJAMMER" );	
	PrecacheString( &"PERKS_BOMB_SQUAD" );	
	PrecacheString( &"PERKS_NINJA" );
	//Description
	PrecacheString( &"PERKS_DESC_HARDLINE" );

	PrecacheString( &"PERKS_DESC_MARATHON" );
	PrecacheString( &"PERKS_FASTER_RELOADING" );
	PrecacheString( &"PERKS_DESC_QUICKDRAW" );
	PrecacheString( &"PERKS_DESC_SCAVENGER" );
	//--
	PrecacheString( &"PERKS_INCREASED_BULLET_DAMAGE" );
	PrecacheString( &"PERKS_DESC_LIGHTWEIGHT" );
	PrecacheString( &"PERKS_DESC_COLDBLOODED" );
	PrecacheString( &"PERKS_HIGHER_EXPLOSIVE_WEAPON" );
	//--
	PrecacheString( &"PERKS_DESC_EXTENDEDMELEE" );
	PrecacheString( &"PERKS_INCREASED_HIPFIRE_ACCURACY" );
	PrecacheString( &"PERKS_DESC_LOCALJAMMER" );
	PrecacheString( &"PERKS_ABILITY_TO_SEEK_OUT_ENEMY" );
	PrecacheString( &"PERKS_DESC_HEARTBREAKER" );

	SetDvarIfUninitialized( "scr_allow_starting_perks", 1 );
	SetDvarIfUninitialized( "scr_allow_hardline", 1 );
	SetDvarIfUninitialized( "scr_allow_specialist", 1 );

	level thread onPlayerConnect();
	level thread setupSpecialist();
}

setupSpecialist()
{
	level endon( "prematch_done" );
	//QKSTR - Proper spawn perks with DVAR selection for server owners.
	if( getDvarInt( "scr_allow_starting_perks" ) == 1 )
	{
		level.StartingPerk1 = getRandomPerk( 0 );
		level.StartingPerk2 = getRandomPerk( 1 );
		level.StartingPerk3 = getRandomPerk( 2 );
		self _setPerk("specialty_extraammo");
		self _setPerk("specialty_bulletdamage");
	}
	//QKSTR - Proper specialist perks with DVAR selection for server owners.
	if( getDvarInt( "scr_allow_specialist" ) == 1 )
	{
		level.SpecialistPerk1 = getRandomPerk( 0 );
		level.SpecialistPerk2 = getRandomPerk( 1 );
		level.SpecialistPerk3 = getRandomPerk( 2 );
		level.Specialist = "specialty_onemanarmy_upgrade";
	}
	//QKSTR - Re-run the getRandomPerk if the spawn perk is the same as Specialist perk(s).
	while( level.StartingPerk1 == level.SpecialistPerk1 )
	{
		level.SpecialistPerk1 = getRandomPerk( 0 );
		wait 0.01;
	}
	
	while( level.StartingPerk2 == level.SpecialistPerk2 )
	{
		level.SpecialistPerk2 = getRandomPerk( 1 );
		wait 0.01;
	}
	
	while( level.StartingPerk3 == level.SpecialistPerk3 )
	{
		level.SpecialistPerk3 = getRandomPerk( 2 );
		wait 0.01;
	}
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player.hud_EventPopup = player createEventPopup();
        player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
    self endon( "disconnect" );
	for(;;)
	{
		self waittill("spawned_player");

		self thread ___Specialist();

		if(self _hasperk("specialty_hardline"))
			self.hardlineOffset = 1;
		else
			self.hardlineOffset = 0;
    }
}

___Specialist()
{
	wait 0.2; 
	//QKSTR - 0.2 is mandatory, any less will result it not to run this function.
	self clearPerks();

	if( getDvarInt( "scr_allow_starting_perks" ) == 1 )
	{
		self _SetPerk( level.StartingPerk1 );
		self _SetPerk( level.StartingPerk2 );
		self _SetPerk( level.StartingPerk3 );
		self _setPerk("specialty_extraammo");
		self _setPerk("specialty_bulletdamage");
		
		if( getDvarInt( "scr_allow_hardline" ) == 1 ) {
			// self Specialist( level.HardlineS, GetGoodColor(), level.HardlineM, level.HardlineD, "specialty_hardline" );
			self _setperk("specialty_hardline");
		}
	}

	if( getDvarInt( "scr_allow_specialist" ) == 1 )
		self thread Specialist_Main();
}

Specialist_Main()
{
	self thread CurrentKS();
	self thread DeleteKSIcons();
	self thread Specialist_Think();
	//QKSTR - Let's call this if they get specialist at least.
	self thread DeleteOnEndGame(); 
	level.HardlineM = getPerkMaterial( "specialty_hardline" );
	level.HardlineS = getPerkString( "specialty_hardline" );
	level.HardlineD = getPerkDescription( "specialty_hardline" );
	//QKSTR - Didn't want a gigantic line inside of createKSIcon/Specialist.
	level.SpecialistPerk1M = getPerkMaterial( level.SpecialistPerk2 );
	level.SpecialistPerk2M = getPerkMaterial( level.SpecialistPerk2 );
	level.SpecialistPerk3M = getPerkMaterial( level.SpecialistPerk3 );
	//--
	level.SpeicliastPerk1S = getPerkString( level.SpecialistPerk1 );
	level.SpeicliastPerk2S = getPerkString( level.SpecialistPerk2 );
	level.SpeicliastPerk3S = getPerkString( level.SpecialistPerk3 );
	//--
	level.SpecialistPerk1D = getPerkDescription( level.SpecialistPerk1 );
	level.SpecialistPerk2D = getPerkDescription( level.SpecialistPerk2 );
	level.SpecialistPerk3D = getPerkDescription( level.SpecialistPerk3 );
	//QKSTR - They're set so leggo.
	self.ksOneIcon = createKSIcon( level.SpecialistPerk1M, -90 );
	self.ksTwoIcon = createKSIcon( level.SpecialistPerk2M, -115 );
	self.ksThrIcon = createKSIcon( level.SpecialistPerk3M, -140 );
	self.ksForIcon = createKSIcon( level.Specialist, -165 );
}

Specialist( text, glowColor, shader, description, perk )
{
	self endon("disconnect");
	//QKSTR - Well since we have for the 8th kill SetAllPerks, I couldn't make a big ass line.
	//So instead we'll add an extra property to see if we have a perk to be set.
	if( isDefined( perk ) )
		self _setPerk( perk );	

	notifyData = spawnStruct();
	
	notifyData.glowColor = glowColor;
	notifyData.hideWhenInMenu = false;
	notifyData.titleText = text;
	notifyData.notifyText = description;
	notifyData.iconName = shader;
	notifyData.sound = "AB_1mc_achieve_ac130";
	// notifyData.sound = "mp_bonus_start";
	
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

Specialist2( text, glowColor, shader, description, perk )
{
	self endon("disconnect");
	//QKSTR - Well since we have for the 8th kill SetAllPerks, I couldn't make a big ass line.
	//So instead we'll add an extra property to see if we have a perk to be set.
	if( isDefined( perk ) )
		self _setPerk( perk );	

	notifyData = spawnStruct();
	
	notifyData.glowColor = glowColor;
	notifyData.hideWhenInMenu = false;
	notifyData.titleText = text;
	notifyData.notifyText = description;
	notifyData.iconName = shader;
	notifyData.sound = "AB_1mc_achieve_airstrike";
	// notifyData.sound = "AB_1mc_achieve_ac130";
	// notifyData.sound = "mp_bonus_start";
	
	self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

Specialist_Think()
{
	self endon("death");
	self endon("disconnect");
	self endon("joined_team");

	while( isAlive( self ) )
	{
		self waittill("killed_enemy");

		if(self _hasperk("specialty_hardline"))
			self.hardlineOffset = 1;
		else
			self.hardlineOffset = 0;

		killstreak = self.pers["cur_kill_streak"] + self.hardlineOffset;
		// self.streak.alpha = 1;
		if( killstreak == 2 )
		{
			self.ksOneIcon.alpha = 1;
			self Specialist( level.SpeicliastPerk1S, GetGoodColor(), level.SpecialistPerk1M, level.SpecialistPerk1D, level.SpecialistPerk1 );

			self _setPerk("specialty_fastreload");
			self _setPerk("specialty_quickdraw");

		}
		else if( killstreak == 4 )
		{
			self.ksTwoIcon.alpha = 1;
			self Specialist( level.SpeicliastPerk2S, GetGoodColor(), level.SpecialistPerk2M, level.SpecialistPerk2D, level.SpecialistPerk2 );

			self _setPerk("specialty_lightweight");
			self _setPerk("specialty_marathon");
		}		
		else if( killstreak == 6 )
		{
			self.ksThrIcon.alpha = 1;
			self Specialist( level.SpeicliastPerk3S, GetGoodColor(), level.SpecialistPerk3M, level.SpecialistPerk3D, level.SpecialistPerk3 );

			self _setPerk("specialty_bulletaccuracy");
			self _setPerk("specialty_holdbreath");
		}
		else if( killstreak == 8 )
		{
			self.ksOneIcon.alpha = 1;
			self.ksTwoIcon.alpha = 1;
			self.ksThrIcon.alpha = 1;
			self.ksForIcon.alpha = 1;
			self Specialist2( "Specialist Bonus", GetGoodColor(), level.Specialist, "Received all Perks" );

			self setAllPerks();	
		}
		else if( killstreak == 25 || killstreak == 50 || killstreak == 75 || killstreak == 100 || killstreak == 125 /*  && getDvarInt( "moab" ) == 1  */)
		{
			self maps\mp\killstreaks\_killstreaks::giveKillstreak( "nuke", true );
			self thread maps\mp\gametypes\_hud_message::killstreakSplashNotify( "nuke", 24 );
		}
	}
	wait ( 0.05 );
}

DeleteKSIcons()
{
	//QKSTR - Just adding another check to track when a player dies/changes teams.
	self waittill_either( "death", "joined_team" );
	self.ksOneIcon.alpha = 0;
	self.ksTwoIcon.alpha = 0;
	self.ksThrIcon.alpha = 0;
	self.ksForIcon.alpha = 0;	
	self.streak.alpha = 0;
}

CurrentKS()
{
    self.streak = self createFontString( "hudsmall", 0.8 );
    self.streak setPoint("TOPLEFT", "TOPLEFT", 5, 110);
	self.streak.hidewheninmenu = true;
	self.streak.alpha = 1;
	//QKSTR - Keep the text not showing until you get a kill.
	while( self.team == "allies" || self.team == "axis" )
	{
		self waittill( "killed_enemy" );
		self.streak setText( "Killstreak: " + self.pers["cur_kill_streak"] );
	}
}

createKSIcon( ksShader, y )
{
	ksIcon = createIcon( ksShader, 20, 20 );
	ksIcon setPoint( "BOTTOM RIGHT", "BOTTOM RIGHT", -32, y );
	ksIcon.alpha = 0.5;
	ksIcon.hideWhenInMenu = true;
	ksIcon.foreground = true;
	return ksIcon;
}

createEventPopup()
{
	hud_EventPopup = newClientHudElem( self );
	hud_EventPopup.children = [];		
	hud_EventPopup.horzAlign = "center";
	hud_EventPopup.vertAlign = "middle";
	hud_EventPopup.alignX = "center";
	hud_EventPopup.alignY = "middle";
    hud_EventPopup.x = 50;
    hud_EventPopup.y = -35;
	hud_EventPopup.font = "default";
	hud_EventPopup.fontscale = 1;
	// hud_EventPopup.fontscale = 0;
	hud_EventPopup.archived = false;
	hud_EventPopup.color = (0.5,0.5,0.5);
	hud_EventPopup.sort = 10000;
	hud_EventPopup.elemType = "font"; //msgText
	hud_EventPopup maps\mp\gametypes\_hud::fontPulseInit( 3.0 );
	return hud_EventPopup;
}

EventPopup( event, hudColor, glowAlpha )
{
	self endon( "disconnect" );

	self notify( "EventPopup" );
	self endon( "EventPopup" );

	wait ( 0.05 );
		
	if ( !isDefined( hudColor ) )
		hudColor = (1,1,0.5);
	if ( !isDefined( glowAlpha ) )
		glowAlpha = 0;

	self.hud_EventPopup.color = hudColor;
	self.hud_EventPopup.glowColor = hudColor;
	self.hud_EventPopup.glowAlpha = glowAlpha;

	self.hud_EventPopup setText(event);
	self.hud_EventPopup.alpha = 0.85;

	wait ( 1.0 );
	
	self.hud_EventPopup fadeOverTime( 0.75 );
	self.hud_EventPopup.alpha = 0;
}


getRandomPerk( type )
{
	perks = [];
	//QKSTR - Much thanks to master131 for showing me arrary's & strTok.
	perks[perks.size] = strTok("specialty_scavenger,specialty_fastreload,specialty_marathon", ",");
	perks[perks.size] = strTok("specialty_lightweight,specialty_coldblooded,specialty_explosivedamage", ",");
	perks[perks.size] = strTok("specialty_bulletaccuracy,specialty_quickdraw,specialty_heartbreaker,specialty_detectexplosive,specialty_extendedmelee,specialty_localjammer", ",");
	
	return perks[type][randomInt(perks[type].size)];
}

getPerkDescription( perk )
{
	//QKSTR - Thanks to EMZ for the Black Ops variant, changed for MW2.
	//QKSTR - This function gives the STRING for the PERK DESCRIPTION.
	return tableLookUpIString( "mp/perkTable.csv", 1, perk, 4 );
}

getPerkMaterial( perk )
{
	//QKSTR - Thanks to EMZ for the Black Ops variant, changed for MW2.
	//QKSTR - This function gives the MATERIAL for the PERK. (Most of the time in MW2 the name of the perk = shader but other times it's not.)
	return tableLookUp( "mp/perkTable.csv", 1, perk, 3 );
}

getPerkString( perk )
{
	//QKSTR - Thanks to EMZ for the Black Ops variant, changed for MW2.
	//QKSTR - This function gives the STRING for the PERK.
	return tableLookUpIString( "mp/perkTable.csv", 1, perk, 2 );
}

team_refillEverything( team )
{
	foreach( player in level.players )
	{
		if( player.team == team )
		player refillEverything();
	}
}

refillEverything()
{
	weaponList = self GetWeaponsListAll();
	
	if ( self _hasPerk( "specialty_tacticalinsertion" ) && self getAmmoCount( "flare_mp" ) < 1 )
		self _setPerk( "specialty_tacticalinsertion");	
	
	foreach ( weaponName in weaponList )
	{
		if ( isSubStr( weaponName, "grenade" ) )
		{
			if ( self getAmmoCount( weaponName ) >= 1 )
				continue;
		} 
		
		if( weaponName != "beretta_silencer_mp" && weaponName != level.zombieHands )
		self giveMaxAmmo( weaponName );
	}

	self playLocalSound( "ammo_crate_use" );
	self iPrintLn( "ALL WEAPONS AND EQUIPMENT REFILLED!" );
}

setAllPerks()
{
	self _setPerk("specialty_marathon");
	self _setPerk("specialty_fastmantle");

	self _setPerk("specialty_fastreload");
	self _setPerk("specialty_quickdraw");

	self _setPerk("specialty_lightweight");
	self _setPerk("specialty_fastsprintrecovery");

	self _setPerk("specialty_scavenger");
	self _setPerk("specialty_extraammo");

	self _setPerk("specialty_bulletdamage");
	self _setPerk("specialty_armorpiercing");
	
	self _setPerk("specialty_coldblooded");
	self _setPerk("specialty_spygame");

	self _setPerk("specialty_explosivedamage");
	self _setPerk("specialty_dangerclose");	

	self _setPerk("specialty_extendedmelee");
	self _setPerk("specialty_falldamage");

	self _setPerk("specialty_bulletaccuracy");
	self _setPerk("specialty_holdbreath");

	self _setPerk("specialty_localjammer");
	self _setPerk("specialty_delaymine");

	self _setPerk("specialty_heartbreaker");
	self _setPerk("specialty_quieter");

	self _setPerk("specialty_detectexplosive");
	self _setPerk("specialty_selectivehearing");

	self _setPerk("specialty_hardline");
	self _setPerk("specialty_rollover");
}

getGoodColor()
{
	color = [];
	//QKSTR - This is momo5502's code, rather interesting way too :D.
	for( i = 0; i < 3; i++ )
	{
		color[i] = randomint( 2 );
	}
	
	if( color[0] == color[1] && color[1] == color[2] )
	{
		rand = randomint(3);
		color[rand] += 1;
		color[rand] %= 2;
	}
	
	return ( color[0], color[1], color[2] );
}

DeleteOnEndGame()
{
	level waittill("game_ended");
	
	self.ksOneIcon.alpha = 0;//Specialist 1
	self.ksTwoIcon.alpha = 0;//Specialist 2
	self.ksThrIcon.alpha = 0;//Specialist 3
	self.ksForIcon.alpha = 0;//Specialist 4
	self.streak.alpha = 0;	 //Killstreak
}

