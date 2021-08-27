// Disable the Player's ability to jump for 7 seconds.
class Crowd_StatusEffect_NoJump extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 7;
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).bJumpCapable = false;
    }

    return true;
}

simulated function OnRemoved(Actor a)
{		
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).bJumpCapable = true;
    }

    Super.OnRemoved(a);
}