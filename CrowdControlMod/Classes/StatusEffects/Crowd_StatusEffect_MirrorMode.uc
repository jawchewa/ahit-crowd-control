//  Give the player Mirror Mode so the screen is flipped Horizontally for the next 30 seconds.
class Crowd_StatusEffect_MirrorMode extends Hat_StatusEffect;

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