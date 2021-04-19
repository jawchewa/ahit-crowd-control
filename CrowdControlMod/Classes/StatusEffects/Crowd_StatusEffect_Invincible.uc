// Make the player invincible for 15 seconds.
class Crowd_StatusEffect_Invincible extends Crowd_StatusEffect_Persistent;

defaultproperties
{
	Duration = 15;
}

function bool CannotTakeDamage(bool world)
{
	return true;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	
    if (Hat_Player(a) != None)
    {
        Hat_Player(a).PowerGlowParticle.SetActive(true);
    }
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
    if (Hat_Player(a) != None)
    {
        Hat_Player(a).PowerGlowParticle.SetActive(false);
    }
}