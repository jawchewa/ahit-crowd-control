//This is a custom version of the Hat_StatusEffect function. This allows status effects that implement this to persist between levels.
class Crowd_StatusEffect_Persistent extends Hat_StatusEffect;

var int id;
var bool wasPaused;

function bool Update(float delta)
{
    local bool isPaused;
    if (IsExpired()) return false;

    isPaused = InDialog(Hat_Player(Owner));

    if (!isPaused)
    {
        if (wasPaused)
        {
            //Call CC to unpause
            class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(id, 7, Duration - CurrentDuration);
        }
        if (!Paused)
        {
            CurrentDuration += delta;

            if (!Infinite && CurrentDuration >= Duration)
            {
                CurrentDuration = Duration;
                OnExpired();
                return false;
            }
        }
    }
    else
    {
        if (!wasPaused)
        {
            //Call CC to pause
            class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(id, 6, Duration - CurrentDuration);
        }
    }

    wasPaused = isPaused;
    return true;
}

function bool InDialog(Hat_Player player)
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

simulated function OnRemoved(Actor a)
{
    local int pid;
    Hat_PlayerController(Pawn(a).Controller).IsSplitscreenPlayer(pid);
    if(Duration - CurrentDuration > 0)
    {
	    class'Crowd_CrowdControl_Gamemod'.static.SaveStatusEffect(String(class.Name), pid, Duration - CurrentDuration, GetData(), id);
        class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(id, 6, Duration - CurrentDuration);
    }
    else
    {
        class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().client.UpdateTimedEffect(id, 8, 0);
    }
    Super.OnRemoved(a);
}

function SetData(string data)
{
}

function String GetData()
{
    return "";
}