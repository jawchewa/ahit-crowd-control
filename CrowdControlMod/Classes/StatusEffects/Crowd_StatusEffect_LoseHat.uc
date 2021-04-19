//Take away the player's ability to use their hat for 20 seconds.
class Crowd_StatusEffect_LoseHat extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 20;
}

function OnAdded(Actor a)
{
	local Hat_InventoryManager invm;
	local Hat_CosmeticItem hat;
	local int i;
    
    Super.OnAdded(a);

	invm = Hat_InventoryManager(Pawn(a).InvManager);
	if (invm.LostHat) return;
	
	Hat_Player(a).CancelAllAbilities(, true);
	invm.LostHat = true;
	
	hat = invm.Hat;
	if (hat != None)
	{
		// Give Hat to pawn
		hat.DetachFromOwner();
		hat.SetHidden(true);
		invm.Hat = None;
	}
	for (i = 0; i < invm.Badges.Length; i++)
		invm.Badges[i].SetOcclusionHidden(true);
}

simulated function OnRemoved(Actor a)
{		
	local Hat_InventoryManager invm;

	invm = Hat_InventoryManager(Pawn(a).InvManager);
	invm.LostHat = false;

	if (a.IsA('Hat_Player'))
		Hat_Player(a).PutAwayWeapon();
	Pawn(a).AddDefaultInventory();
    Super.OnRemoved(a);
}