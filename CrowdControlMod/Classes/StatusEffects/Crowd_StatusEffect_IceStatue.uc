class Crowd_StatusEffect_IceStatue extends Crowd_StatusEffect_Persistent;

const NumSpins = 2;

var(Sounds) SoundCue StartStatueSound;
var(Sounds) SoundCue EndStatueSound;

defaultproperties
{
	Duration = 10;
	StartStatueSound = SoundCue'HatinTime_SFX_Player3.SoundCues.Ice_Statue_Badge_Activate1_Overlay'
}

function OnAdded(Actor a)
{
	local Hat_StatusEffect_StatueFall fx;
    Super.OnAdded(a);
	
	CancelAllOtherAbilities();
	
	if (StartStatueSound != None)
		Owner.PlaySound(StartStatueSound);

	fx = Hat_StatusEffect_StatueFall(Hat_PawnCombat(Owner).GiveStatusEffect(class'Hat_StatusEffect_StatueFall'));
	fx.StatueHealth = 1000;
}

simulated function OnRemoved(Actor a)
{    
	local Rotator NewRotation;

	if (Hat_Pawn(Owner) != None && Hat_Pawn(Owner).bMidLaunch) return;
	if (EndStatueSound != None)
		Owner.PlaySound(EndStatueSound);

	NewRotation = Owner.Rotation;
	NewRotation.Pitch = 0;
	Owner.SetRotation(NewRotation);
	Hat_PawnCombat(Owner).SetRotationSequence.Rotation.Pitch = 0;
	Hat_PawnCombat(Owner).RemoveStatusEffect(class'Hat_StatusEffect_StatueFall');

    Super.OnRemoved(a);
}

function bool Update(float delta)
{
        
	local Hat_Pawn HPawn;
	local float LaunchTime;
	local float LaunchPercent;
	local Rotator NewRotation;
    if (!Super.Update(delta)) return false;

	HPawn = Hat_Pawn(Owner);

	if (HPawn != None && HPawn.bMidLaunch)
	{
		LaunchTime = class'WorldInfo'.static.GetWorldInfo().TimeSeconds - HPawn.LaunchStart;
		LaunchPercent = LaunchTime / HPawn.LaunchLength;
		NewRotation = HPawn.Rotation;
		NewRotation.Pitch = -65536 * LaunchPercent * NumSpins;
		HPawn.SetRotation(NewRotation);

		if (HPawn.IsA('Hat_PawnCombat'))
			Hat_PawnCombat(HPawn).SetRotationSequence.Rotation.Pitch = NewRotation.Pitch;
	}
    return true;
}

function CancelAllOtherAbilities()
{
	local Hat_InventoryManager inv;
	local int i;
	
	if (Hat_Player(Owner) == None) return;
	if (Hat_Player(Owner).InvManager == None) return;
	inv = Hat_InventoryManager(Hat_Player(Owner).InvManager);
	if (inv == None) return;
	
	for (i = 0; i < inv.Badges.Length; i++)
	{
		if (inv.Badges[i] == None) continue;
		if (inv.Badges[i].bDeleteMe) continue;
		inv.Badges[i].DoDeactivate(true, false);
	}
}