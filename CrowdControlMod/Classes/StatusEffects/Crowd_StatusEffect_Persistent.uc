//This is a custom version of the Hat_StatusEffect function. This allows status effects that implement this to persist between levels.
class Crowd_StatusEffect_Persistent extends Hat_StatusEffect;

simulated function OnRemoved(Actor a)
{
    local int pid;
    Hat_PlayerController(Pawn(a).Controller).IsSplitscreenPlayer(pid);
    if(Duration - CurrentDuration > 0)
    {
	    class'Crowd_CrowdControl_Gamemod'.static.SaveStatusEffect(String(class.Name), pid, Duration - CurrentDuration, GetData());
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