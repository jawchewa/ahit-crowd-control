// Status Effect that doubles the strenth of gravity for the player, so they can only jump half as high.
class Crowd_StatusEffect_DoubleGravity extends Crowd_StatusEffect_Persistent;

var float GravityScaling;

defaultproperties
{
    Duration = 20;
    GravityScaling = 1.5;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    if (Hat_Player(a) != None)
    {
        if (GravityScaling > 0)
            Hat_Player(a).CustomGravityScaling = GravityScaling;
    }
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        if (GravityScaling > 0)
            Hat_Player(Owner).CustomGravityScaling = GravityScaling;
    }

    return true;
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
    
    if (GravityScaling > 0)
        Hat_Player(a).CustomGravityScaling = Hat_Player(a).default.CustomGravityScaling;
}