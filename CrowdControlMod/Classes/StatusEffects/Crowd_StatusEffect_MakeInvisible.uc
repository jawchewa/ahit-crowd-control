// Make the Player turn Invisible for the next 20 seconds.
class Crowd_StatusEffect_MakeInvisible extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 20;
}

function OnAdded(Actor a)
{
    local Hat_Weapon wep;

    Super.OnAdded(a);
    if (Hat_Player(a) != None)
    {
        Hat_Player(a).SetHidden(true);
        wep = Hat_Player(Owner).GetWeapon();
        if (wep != None)
        {
            wep.SetHidden(true);
        }
    }
}

simulated function OnRemoved(Actor a)
{    
    local Hat_Weapon wep;

    if (Hat_Player(a) != None)
    {
        Hat_Player(a).SetHidden(false);
        wep = Hat_Player(Owner).GetWeapon();
        if (wep != None)
        {
            wep.SetHidden(false);
        }
    }
    Super.OnRemoved(a);
}


function bool Update(float delta)
{
    local Hat_Weapon wep;

    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).SetHidden(true);
        wep = Hat_Player(Owner).GetWeapon();
        if (wep != None)
        {
            wep.SetHidden(true);
        }
    }

    return true;
}