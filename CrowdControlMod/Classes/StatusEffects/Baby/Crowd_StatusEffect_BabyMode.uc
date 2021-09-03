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
	BeginCarry(Hat_Player(Owner), baby);
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

function bool BeginCarry(Hat_Player p, Actor o, optional bool force)
{
	local float SizeInCM;
    if (o == None) return false;
    
	p.CancelAllHandRequiredBadges();
	
	if (!p.MoveWhileLifting)
		p.ZeroMovementVariables();
	
	SizeInCM = 0;
	p.CurrentThrowMagnitude = -1;
    p.CarriedObject = o;
	if (o.IsA('Hat_CarryObject'))
	{
		Hat_CarryObject(o).OnPickUp(p);
		SizeInCM = Hat_CarryObject(o).CarryWidthInCm;
	}
		
    p.SetAnimCarryMode(ECarryMode_Lift);
	p.ReplayNodeGroup('PickUp');
	p.SetAnimCarryWeight(SizeInCM);
	
	p.ClearTimer(NameOf(p.DropCarry));
	p.ClearTimer(NameOf(p.PostThrowCarry));
	p.SetTimer(0.48*0.1, false, NameOf(p.PostBeginCarry2));
	p.SetTimer(0.48, false, NameOf(p.PostBeginCarry));
	p.IsPerformingCarryAnimation = true;
	
	if (!o.IsA('Hat_CarryObject') || Hat_CarryObject(o).CanBeDropped)
		Hat_HUD(PlayerController(p.Controller).MyHUD).OpenHUD(class'Hat_HUDElementCarryHelp');
    
    return true;
}
