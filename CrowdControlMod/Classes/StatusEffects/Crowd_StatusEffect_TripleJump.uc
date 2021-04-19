// Give the player the ability to jump a third time, instead of twice.
class Crowd_StatusEffect_TripleJump extends Crowd_StatusEffect_Persistent;

var bool canUseTripleJump;

defaultproperties
{
    Duration = 25;
    canUseTripleJump = true;
}

function OnLanded(optional bool UnusualScenario) {
    canUseTripleJump = true;
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (!Hat_Player(Owner).bReadyToDoubleJump && canUseTripleJump)
    {
        Hat_Player(Owner).bReadyToDoubleJump = true;
        canUseTripleJump = false;
    }

    return true;
}