class Crowd_StatusEffect_NoDoubleJump extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 15;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    if (Hat_Player(a) != None)
    {
        Hat_Player(a).DisableDoubleJumpTime = FMax(Hat_Player(a).DisableDoubleJumpTime, Duration);
    }
}

    