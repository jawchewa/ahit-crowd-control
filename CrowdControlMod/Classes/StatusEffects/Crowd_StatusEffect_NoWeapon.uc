class Crowd_StatusEffect_NoWeapon extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 15;
}

function bool OnAttack() 
{
	return true; 
}