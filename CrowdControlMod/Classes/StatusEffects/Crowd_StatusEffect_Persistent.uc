//This is a custom version of the Hat_StatusEffect function. This allows status effects that implement this to persist between levels.
class Crowd_StatusEffect_Persistent extends Hat_StatusEffect;

var int id;
var bool wasPaused;

function bool Update(float delta)
{
    local bool isPaused;
    if (IsExpired()) return false;

    isPaused = class'Crowd_CrowdControl_Gamemod'.static.CannotGiveEffect(Hat_Player(Owner));

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