// Make it so the Player has to carry a stack of babies for the next 20 seconds. (Similar to the Ship Shape mission from Chapter 6)
// Based on the Stackable Scripts from the base game.
class Crowd_StatusEffect_BabyMode extends Hat_StatusEffect;

var int babyCount;

defaultproperties
{
    Duration = 20;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	
	class'WorldInfo'.static.GetWorldInfo().Game.SetTimer(0.5, true, NameOf(SpawnBaby), self);
}

function SpawnBaby()
{
	local Crowd_Stackable_Baby baby;
		
	baby = Owner.Spawn(class'Crowd_Stackable_Baby',,, Owner.Location, Owner.Rotation,, true);
	Hat_Player(Owner).BeginCarry(baby);
	babyCount++;
	if (babyCount >= 5)
	{
		class'WorldInfo'.static.GetWorldInfo().Game.ClearTimer(NameOf(SpawnBaby), self);
	}
}

simulated function OnRemoved(Actor a)
{
	local Crowd_Stackable_Baby baby;
		
	foreach `GameManager.DynamicActors(class'Crowd_Stackable_Baby', baby)
    {
        baby.ForceDrop();
		baby.Destroy();
    }
    Super.OnRemoved(a);
}