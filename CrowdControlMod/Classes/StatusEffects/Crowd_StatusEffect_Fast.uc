// Speeds up the player's Time Dilation to double speed.
class Crowd_StatusEffect_Fast extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 30;
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).CustomTimeDilation = 2;
        Hat_Player(Owner).Controller.CustomTimeDilation = Hat_Player(Owner).CustomTimeDilation;
    }

    return true;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).CustomTimeDilation = 2;
        Hat_Player(Owner).Controller.CustomTimeDilation = Hat_Player(Owner).CustomTimeDilation;
    }
}

simulated function OnRemoved(Actor a)
{		
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).CustomTimeDilation = 1;
        Hat_Player(Owner).Controller.CustomTimeDilation = Hat_Player(Owner).CustomTimeDilation;
    }
    Super.OnRemoved(a);
}