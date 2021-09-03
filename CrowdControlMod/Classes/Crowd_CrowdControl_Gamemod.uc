//Mod and Effects pack developed by Jawchewa

//The gamemod class is the brain of the mod. It handles everything to do with initialization as well as processing commands for crowd control.
class Crowd_CrowdControl_Gamemod extends GameMod
	config(Mods);

var Crowd_TcpLink_Client client;
var(Sounds) SoundCue HealSound;

var bool hasStartedLevel;

var Array<Hat_ChapterInfo> Chapters;

const Debug = false;

//This is the main function for processing incoming Effect Requests.
function int ProcessCode(String code, int id, out float timeRemaining)
{
    local Hat_Player ply;
    local Crowd_StatusEffect_Persistent effect;
    ply = Hat_Player(GetALocalPlayerController().Pawn);

    //Don't receive Effects until level is done loading, and deny Effects if game is paused.
    if(!hasStartedLevel || GetALocalPlayerController().IsPaused() || CannotGiveEffect(ply)) return 3;

    switch (code)
    {
        case "heal":
            if (ply.HealDamage(1, None, None))
            {
                PlaySound(HealSound);
            }
            break;
        case "damage":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Invincible') || ply.HasStatusEffect(class'Crowd_StatusEffect_OneHitHero') || ply.health == 1) return 3;
            ply.TakeDamage(1.0, None, Location, vect(0,0,0), class'Hat_DamageType_Bump');
            break;
        case "kill":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Invincible')) return 3;
            Hat_PlayerController(ply.Controller).Suicide();
            break;
        case "make_invincible":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Invincible') || ply.HasStatusEffect(class'Crowd_StatusEffect_OneHitHero')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Invincible'));
            break;
        case "one_hit_hero":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Invincible') || ply.HasStatusEffect(class'Crowd_StatusEffect_OneHitHero')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_OneHitHero'));
            break;
        case "increase_gravity":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_DoubleGravity') || ply.HasStatusEffect(class'Crowd_StatusEffect_HalfGravity')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_DoubleGravity'));
            break;
        case "decrease_gravity":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_DoubleGravity') || ply.HasStatusEffect(class'Crowd_StatusEffect_HalfGravity')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_HalfGravity'));
            break;
        case "wind":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Wind')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Wind'));
            break;
        case "spring_bounce":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_SpringBounce')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_SpringBounce'));
            break;
        case "go_fast":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Fast') || ply.HasStatusEffect(class'Crowd_StatusEffect_Slow')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Fast'));
            break;
        case "go_slow":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Fast') || ply.HasStatusEffect(class'Crowd_StatusEffect_Slow')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Slow'));
            break;
        case "time_stop":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_TimeStop') || ply.HasStatusEffect(class'Hat_StatusEffect_TimeStop', true)) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_TimeStop'));
            break;
        case "dweller_sphere":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_DwellerSphere') || ply.IsFoxMaskActive) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_DwellerSphere'));
            break;
        case "ice_statue":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_IceStatue') || ply.HasStatusEffect(class'Hat_StatusEffect_StatueFall', true)) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_IceStatue'));
            break;
        case "shrink":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Shrink') || ply.HasStatusEffect(class'Crowd_StatusEffect_Grow')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Shrink'));
            break;
        case "grow":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Shrink') || ply.HasStatusEffect(class'Crowd_StatusEffect_Grow')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Grow'));
            break;
        case "make_invisible":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_MakeInvisible')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_MakeInvisible'));
            break;
        case "babysit":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_BabyMode') || ply.IsCarryingItem()) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_BabyMode'));
            break;
        case "give_triple_jump":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_TripleJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoDoubleJump')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_TripleJump'));
            break;
        case "disable_jump":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_TripleJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoDoubleJump')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_NoJump'));
            break;
        case "disable_double_jump":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_TripleJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoJump') || ply.HasStatusEffect(class'Crowd_StatusEffect_NoDoubleJump')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_NoDoubleJump'));
            break;
        case "disable_weapon":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_NoWeapon') || ply.GetWeapon() == None) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_NoWeapon'));
            break;
        case "random_filter":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_RandomFilter')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_RandomFilter'));
            break;
        case "parade_owls":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_Parade')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_Parade'));
            break;
        case "lose_hat":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_LoseHat')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_LoseHat'));
            break;
        case "first_person":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_FirstPerson')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_FirstPerson'));
            break;
        case "reverse_controls":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_ReverseControls')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_ReverseControls'));
            break;
        case "mirror_mode":
            if(ply.HasStatusEffect(class'Crowd_StatusEffect_MirrorMode')) return 3;
            effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(class'Crowd_StatusEffect_MirrorMode'));
            break;
        case "give_timepiece":
            if(!GiveTakeRandomTimePiece(true)) return 2;
            break;
        case "take_timepiece":
            if(!GiveTakeRandomTimePiece(false)) return 2;
            break;
        default:
            break;
    }
    if (effect != None)
    {
        timeRemaining = effect.Duration;
        effect.id = id;
    }

    return 0;
}

function bool CannotGiveEffect(Hat_Player player)
{
	local Hat_PlayerController cont;

	if (player.Health <= 0) return true;
	if (player.Health <= 0) return true;
	if (player.bWaitingForCaveRiftIntro) return true;
	if (player.IsTaunting()) return true;
	if (player.IsNewItemState()) return true;
	if (player.MyDoor != None) return true;
	if (player.bHidden && !player.bCollideWorld && !player.bBlockActors) return true;
	if (player.bHidden && player.CanTakeDamage(false)) return true;
	if (player.SwampSinkProgress > 0.75) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_FreezeMovement', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Scared', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Stoning', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_FallHurtTransition', true)) return true;

	cont = Hat_PlayerController(player.Controller);
	if (cont == None) return true;
	if (cont.IsTalking()) return true;
    if (cont.bCinematicMode) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementActTitleCard')) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementLoadingScreen')) return true;
	if (Hat_HUD(cont.MyHUD).ElementsDisablesMovement() && !Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDMenu_SwapHat')) return true;

	return false;
}

//Spawn and Initialize the TCP Link Client when the mod is loaded.
//Also Set Chapter Info Count to unlock areas that have already been unlocked.
function OnModLoaded()
{
    if (client == None)
    {
        client = Spawn(class'Crowd_TcpLink_Client');
    }
    
    //Need this so people don't lose access to areas when they lose timepieces.
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest', 7);
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science', 4);
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails', 14);
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale', 25);
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise', 35);
    SetChapterInfoCount(Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro', 20);
    SetChapterInfoCount(Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown', 0);
}

//If Area has been unlocked, set RequiredHourglassCount to 0. This is the only way to keep areas unlocked after losing timepieces.
function SetChapterInfoCount(Hat_ChapterInfo chap, int defaultCount)
{
    if (class'Hat_SpaceshipPowerPanel'.static.IsPowerPanelActivated(chap))
    {
        chap.RequiredHourglassCount = 0;
    }
    else
    {
        chap.RequiredHourglassCount = defaultCount;
    }
}

//Reset Required hourglass count when mod is unloaded.
event OnModUnloaded()
{
    Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest'.RequiredHourglassCount = 7;
    Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science'.RequiredHourglassCount = 4;
    Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails'.RequiredHourglassCount = 14;
    Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Mu_Finale'.RequiredHourglassCount = 25;
    Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise'.RequiredHourglassCount = 35;
    Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro'.RequiredHourglassCount = 20;
    Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown'.RequiredHourglassCount = 1;

    client.Destroy();
}

//Wait until after level intro to allow status effects to be recieved.
//Also, Load persistent status effects after Level Intro.
function OnPostLevelIntro()
{
    hasStartedLevel = true;
    LoadStatusEffects(Hat_Player(GetALocalPlayerController().Pawn));
}

// Don't allow base game Timestop and StatueFall status effects to be activated if custom version is activated.
function OnPreStatusEffectAdded(Pawn PawnCombat, out class<Object> StatusEffect, optional out float OverrideDuration)
{
    if(ClassIsChildOf(StatusEffect, class'Hat_StatusEffect_TimeStop') && Hat_Player(PawnCombat) != None && Hat_Player(PawnCombat).HasStatusEffect(class'Crowd_StatusEffect_TimeStop'))
    {
        StatusEffect = None;
    }
    else if(ClassIsChildOf(StatusEffect, class'Hat_StatusEffect_StatueFall') && Hat_Player(PawnCombat) != None && Hat_Player(PawnCombat).HasStatusEffect(class'Hat_StatusEffect_StatueFall') && Hat_Player(PawnCombat).HasStatusEffect(class'Crowd_StatusEffect_IceStatue'))
    {
        StatusEffect = None;
    }
}
    
// Don't allow base gaame FoxMask Ability to be activated if custom Dweller Sphere Status Effect is active.
function OnAbilityUsed(Pawn Player, Inventory Ability)
{
    if(Ability.IsA('Hat_Ability_FoxMask') && Hat_Player(Player) != None && Hat_Player(Player).HasStatusEffect(class'Crowd_StatusEffect_DwellerSphere'))
    {
        Hat_Ability_FoxMask(Ability).Activated = false;
    }
}

//Save Persistent Status Effect.
static function SaveStatusEffect(string className, int pid, float duration, string data, int id)
{
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("Saving: "$"persistentStatus;"$className$";"$pid$";"$duration$";"$data$";"$id);
	class'Hat_SaveBitHelper'.static.SetLevelBits(locs("persistentStatus;"$className$";"$pid$";"$duration$";"$data$";"$id), 1, "CrowdControl");
}

//Load and Apply Persistent Status Effects.
static function LoadStatusEffects(Hat_Player ply)
{
	local Hat_SaveGame_Base s;
	local int i, ii;
    local int pid;
    local Array<String> arr;
    local class<Hat_StatusEffect> statusEffectClass;
    local Crowd_StatusEffect_Persistent effect;
    
	s = class'Hat_SaveBitHelper'.static.GetSaveGame();
	if (s == None) return;

	i = s.GetLevelSaveInfoIndex(class'Hat_SaveBitHelper'.static.GetCorrectedMapFilename("CrowdControl"), true);
	if (i < 0) return;

    Hat_PlayerController(ply.Controller).IsSplitscreenPlayer(pid);

	for (ii = 0; ii < s.LevelSaveInfo[i].LevelBits.Length; ii++)
	{
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("Loading"$s.LevelSaveInfo[i].LevelBits[ii].Id$s.LevelSaveInfo[i].LevelBits[ii].Bits);
		arr = SplitString(s.LevelSaveInfo[i].LevelBits[ii].Id, ";", true);
		if (arr[0] ~= "persistentStatus" && int(arr[2]) == pid)
		{
			statusEffectClass = class<Hat_StatusEffect>(class'Hat_ClassHelper'.static.GetScriptClass(arr[1]));
            if(statusEffectClass != None)
            {
                if(s.LevelSaveInfo[i].LevelBits[ii].Bits > 0)
                {
                    effect = Crowd_StatusEffect_Persistent(ply.giveStatusEffect(statusEffectClass, Float(arr[3])));
                    effect.SetData(arr[4]);
                    effect.id = Int(arr[5]);
                    class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(effect.id, 7, effect.Duration - effect.CurrentDuration);
                }
            }
		}
    }
    WipeStatusEffects();
}

//Delete Save Bits for Persistent Status Effects after loading.
static function WipeStatusEffects()
{
	local Hat_SaveGame_Base s;
	local int i;
    

	s = class'Hat_SaveBitHelper'.static.GetSaveGame();
	if (s == None) return;

	i = s.GetLevelSaveInfoIndex(class'Hat_SaveBitHelper'.static.GetCorrectedMapFilename("CrowdControl"), true);
	if (i < 0) return;

    s.LevelSaveInfo[i].LevelBits.Length = 0;
}

// Give or Take a random TimePiece
function bool GiveTakeRandomTimePiece(bool Unlock)
{
    local int rand;
    local Array<Hat_ChapterInfo> UncompletedChapters;
    local Hat_ChapterInfo chap;
    local bool result;

	if (`SaveManager.SaveData == None) return false;

    foreach Chapters(chap)
    {
        if((Unlock ? !AreAllActsComplete(chap, false) : !AreNoActsComplete(chap)) && chap.HasDLCSupported(true))
        {
            UncompletedChapters.AddItem(chap);
        }
    }

    if(UncompletedChapters.Length == 0) 
    {
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("No Chapters Available ");
        return false;
    }

	rand = RandRange(0, UncompletedChapters.Length);

    result = UnlockRandomTimePiece(UncompletedChapters[rand], Unlock);
    
	if(result) `SaveManager.SaveToFile(true);
    return result;
}

// Give or Take a random TimePiece
function bool UnlockRandomTimePiece(Hat_ChapterInfo ci, bool Unlock)
{
	local int rand;
    local Array<Hat_ChapterActInfo> AvailableActs;
    local Hat_ChapterActInfo act;

    ci.ConditionalUpdateActList();

    foreach ci.ChapterActInfo(act)
    {
        if(`GameManager.HasTimePiece(act.Hourglass) != Unlock && act.Hourglass != "" && act.HasDLCSupported(true))
        {
            AvailableActs.AddItem(act);
        }
    }
    
    if(AvailableActs.Length == 0) 
    {
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("No Acts Available "$ci.ChapterName);
        return false;
    }

    rand = RandRange(0, AvailableActs.Length);
    if (Unlock)
    {
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("Unlocked: " $ AvailableActs[rand].Hourglass $" : "$ AvailableActs[rand].HourglassUncanny);

        `GameManager.GiveTimePiece(AvailableActs[rand].Hourglass, true);
        if (AvailableActs[rand].HourglassUncanny != "")
        {
            `GameManager.GiveTimePiece(AvailableActs[rand].HourglassUncanny, true);
        }
        UnlockPowerPanels();
        return true;
    }
    else
    {
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("Removed: " $ AvailableActs[rand].Hourglass $" : "$ AvailableActs[rand].HourglassUncanny);

        `SaveManager.GetCurrentSaveData().RemoveTimePiece(AvailableActs[rand].Hourglass);
        if (AvailableActs[rand].HourglassUncanny != "")
        {
            `SaveManager.GetCurrentSaveData().RemoveTimePiece(AvailableActs[rand].HourglassUncanny);
        }
        LockPowerPanels();
        return true;
    }
}

//Unlock Power Panels in HUB after gaining a timepiece
function UnlockPowerPanels()
{
    local Hat_SpaceshipPowerPanel pan;

	foreach DynamicActors(class'Hat_SpaceshipPowerPanel', pan)
	{
        if(!pan.HasBeenActivated() && !pan.NeedsDLC() && pan.CanBeUnlocked())
        {
            if (pan.InteractPoint == None)
            {
                pan.InteractPoint = Spawn(class'Hat_InteractPoint',pan,,pan.Location + Vector(pan.Rotation)*10 + vect(0,0,1)*20,pan.Rotation,,true);
                pan.InteractPoint.PushDelegate(pan.OnInteractDelegate);
                pan.RuntimeMat.SetScalarParameterValue('Unlockable', 1);
                pan.ElectricityParticle[0].SetActive(true);
                pan.ElectricityParticle[1].SetActive(true);
                pan.ReadyToActivateParticle.SetActive(true);
                pan.SetTimer(1.8, true, NameOf(pan.DoAttentionBeep), pan);
            }
        }
	}
}

//Lock Power Panels in HUB after removing a timepiece
function LockPowerPanels()
{
    local Hat_SpaceshipPowerPanel pan;

	foreach DynamicActors(class'Hat_SpaceshipPowerPanel', pan)
	{
        if(!pan.HasBeenActivated() && !pan.NeedsDLC() && !pan.CanBeUnlocked())
        {
            if (pan.InteractPoint != None)
            {
                pan.InteractPoint.Destroy();
                pan.InteractPoint = None;
                pan.RuntimeMat.SetScalarParameterValue('Unlockable', 0);
                pan.ElectricityParticle[0].SetActive(false);
                pan.ElectricityParticle[1].SetActive(false);
                pan.ReadyToActivateParticle.SetActive(false);
                pan.ClearTimer(NameOf(pan.DoAttentionBeep), pan);
            }
        }
	}
}

//Check if All Acts in a chapter have been completed.
static function bool AreAllActsComplete(Hat_ChapterInfo ChapterInfo, optional bool IncludeUnownedDLC = true)
{
    local int i;

	ChapterInfo.ConditionalUpdateActList();
	for (i = 0; i < ChapterInfo.ChapterActInfo.Length; i++)
	{
		if (ChapterInfo.ChapterActInfo[i].ActID >= 99) continue; // do not count free roam
		if (!IncludeUnownedDLC && !ChapterInfo.ChapterActInfo[i].HasDLCSupported(true)) continue;
        if (ChapterInfo.ChapterActInfo[i].Hourglass == "") continue;

		if (!`GameManager.HasTimePiece(ChapterInfo.ChapterActInfo[i].Hourglass))
		{
			return false;
		}
	}

	return true;
}

//Check if No Acts in a chapter have been completed yet.
static function bool AreNoActsComplete(Hat_ChapterInfo ChapterInfo, optional bool IncludeUnownedDLC = true)
{
    local int i;

	ChapterInfo.ConditionalUpdateActList();
	for (i = 0; i < ChapterInfo.ChapterActInfo.Length; i++)
	{
		if (ChapterInfo.ChapterActInfo[i].ActID >= 99) continue; // do not count free roam
		if (!IncludeUnownedDLC && !ChapterInfo.ChapterActInfo[i].HasDLCSupported(true)) continue;
        if (ChapterInfo.ChapterActInfo[i].Hourglass == "") continue;
		if (`GameManager.HasTimePiece(ChapterInfo.ChapterActInfo[i].Hourglass))
		{
			return false;
		}
	}

	return true;
}

//Helper function to get a reference to the gamemod in a static way.
static function Crowd_CrowdControl_Gamemod GetGameMod()
{
    local Crowd_CrowdControl_Gamemod mod;

    foreach class'WorldInfo'.static.GetWorldInfo().DynamicActors(class'Crowd_CrowdControl_Gamemod', mod)
    {
		return mod;
    }
    
    return None;
}

function OnPreOpenHUD(HUD InHUD, out class<Object> InHUDElement)
{
	local Hat_PlayerController c;
	local Hat_HUD hHUD;
	local Hat_StatusEffect fx;
	local Crowd_StatusEffect_Persistent pfx;

    c = Hat_PlayerController(GetALocalPlayerController());

    hHUD = Hat_HUD(c.MyHUD);

    if (hHUD == None) return;
    
    //This sets up the pause menu to not actually pause the game in the background, so players can't just cheat by pausing the game. This also helps with syncing
    if(InHUDElement == class'Hat_HUDMenuLoadout' || ClassIsChildOf(InHUDElement, class'Hat_HUDMenuLoadout'))
    {
        //If pause menu is not open, that means we are opening it. If a pause menu already exists, that means we are closing it.
        if(hHUD.GetHUD(class<Hat_HUDMenuLoadout>(InHUDElement)) == None)
        {
            //Pause
            foreach Hat_PawnCombat(c.Pawn).StatusEffects(fx)
            {
			    if (Crowd_StatusEffect_Persistent(fx) != None)
                {
                    pfx = Crowd_StatusEffect_Persistent(fx);
                    class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(pfx.id, 6, pfx.Duration - pfx.CurrentDuration);
                }
            }
        }
        else 
        {
            //UnPause
            foreach Hat_PawnCombat(c.Pawn).StatusEffects(fx)
            {
                if (Crowd_StatusEffect_Persistent(fx) != None)
                {
                    pfx = Crowd_StatusEffect_Persistent(fx);
                    class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(pfx.id, 7, pfx.Duration - pfx.CurrentDuration);
                }
            }
        }
    }
}

//Function to simplify logging messages to the dev console.
//This will only log messages to the dev console if Debug flag is set to true.
static function DebugLog(String s)
{
    if (Debug) class'WorldInfo'.static.GetWorldInfo().Game.Broadcast(class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().GetALocalPlayerController().Pawn, s);
}

defaultproperties
{
    HealSound = SoundCue'HatinTime_SFX_Player4.SoundCues.Health_Heal_Addon'
    Chapters(0) = Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.MafiaTown'
    Chapters(1) = Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.subconforest'
    Chapters(2) = Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.trainwreck_of_science'
    Chapters(3) = Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.Sand_and_Sails'
    Chapters(4) = Hat_ChapterInfo'HatinTime_ChapterInfo.maingame.hub_spaceship'
    Chapters(5) = Hat_ChapterInfo'HatinTime_ChapterInfo_DLC1.ChapterInfos.ChapterInfo_Cruise'
    Chapters(6) = Hat_ChapterInfo'hatintime_chapterinfo_dlc2.ChapterInfos.ChapterInfo_Metro'
}