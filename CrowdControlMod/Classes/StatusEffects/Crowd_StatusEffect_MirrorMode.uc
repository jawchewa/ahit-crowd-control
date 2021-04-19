class Crowd_StatusEffect_MirrorMode extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 30;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    class'Hat_GameManager'.static.SetMirrorModeForAct(true);
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
    class'Hat_GameManager'.static.SetMirrorModeForAct(false);
}