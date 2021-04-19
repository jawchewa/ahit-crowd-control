class Crowd_StatusEffect_Slow extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 20;
}


function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).CustomTimeDilation = 0.5;
        Hat_Player(Owner).Controller.CustomTimeDilation = Hat_Player(Owner).CustomTimeDilation;
    }

    return true;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(Owner).CustomTimeDilation = 0.5;
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