// Forces the player to constantly bounce as if the whole world was a spring.
// Based on the code for the Spring Badge Mod which can be found here: https://steamcommunity.com/sharedfiles/filedetails/?id=2422565858
class Crowd_StatusEffect_SpringBounce extends Crowd_StatusEffect_Persistent;

var Interaction KeyCaptureInteraction;

defaultproperties
{
    Duration = 10;
}

function OnLanded(optional bool UnusualScenario)
{
    class'WorldInfo'.static.GetWorldInfo().Game.SetTimer(0.01, false, NameOf(Bounce), self);
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    class'WorldInfo'.static.GetWorldInfo().Game.SetTimer(0.01f, false, NameOf(RegisterKeyEvent), self);
    if (Hat_Player(a).Physics == Phys_Walking)
    {
        Hat_Player(a).DoSpringJump();
        Owner.SetPhysics(Phys_Falling);
        Owner.Velocity = vect(0,0,1)*200;
    }
}

simulated function OnRemoved(Actor a)
{    
    Hat_PlayerController(Hat_Player(Owner).Controller).Interactions.RemoveItem(KeyCaptureInteraction);

    Super.OnRemoved(a);
}

function Bounce()
{
    local Hat_Player ply;

    ply = Hat_Player(Owner);
    if (ply.IsInSwampWater) return;
    if (ply.HasStatusEffect(class'Hat_StatusEffect_StatueFall', true)) return;
    if (ply.m_iPlatformMove == EPlatformMove_None || ply.m_iPlatformMove == EPlatformMove_WallHardImpact)
    {
        ply.DoSpringJump();
        ply.SetPhysics(Phys_Falling);
        ply.Velocity = vect(0,0,1)*800;
        ply.WallJumpCount = 1;
    }
}

function OnHitWall(vector HitNormal, actor Wall, PrimitiveComponent WallComp)
{
    local Hat_Player ply;

    ply = Hat_Player(Owner);
    ply.DoSpringJump();
    ply.SetPhysics(Phys_Falling); 
    ply.Velocity = HitNormal*800;
    ply.WallJumpCount = 1;
}

function RegisterKeyEvent()
{
    local int iInput;
    local Hat_PlayerController pc;
    pc = Hat_PlayerController(Hat_Player(Owner).Controller);
  
    KeyCaptureInteraction = new(pc) class'Interaction';
    KeyCaptureInteraction.OnReceivedNativeInputKey = ReceivedNativeInputKey;
  
    iInput = pc.Interactions.Find(pc.PlayerInput);
    pc.Interactions.InsertItem(Max(iInput, 0), KeyCaptureInteraction);
}

function bool ReceivedNativeInputKey(int ControllerId, name Key, EInputEvent EventType, float AmountDepressed, bool bGamepad)
{
    if(Key == 'Hat_Player_Interact')
    {
        if(EventType == IE_PRESSED)
        {
            PerformedUseAction();
            return true;
        }
    }
    return false;
}

function bool PerformedUseAction()
{
    local Hat_Pawn p;
    local Hat_PlayerController pc;
	local Hat_HUD hHUD;
	local Hat_Player ply;
    local bool prevPickup;

    pc = Hat_PlayerController(Hat_Player(Owner).Controller);

	if( pc.IsPaused() )
		return true;

	if (pc.IgnoreInput > 0)
		return true;

    if ( pc.Pawn == None )
		return true;

	if (Hat_PawnHiding(pc.Pawn) != None && Hat_PawnHiding(pc.Pawn).ExitHidingPoint()) return true;

	if (pc.Pawn.IsA('Hat_PawnHiding') && Hat_PawnHiding(pc.Pawn).IsFirstPerson())
		return true;

    p = Hat_Pawn(pc.Pawn);
    if (pc.IsTalking())
        return true;

	ply = Hat_Player(pc.Pawn);
	if (ply != None && ply.AttemptUserExitTaunt())
	{
		return true;
	}

    hHUD = Hat_HUD(pc.myHUD);
    if (hHUD != None)
    {
        if (!hHUD.GetElementBlack().IsEnabled() && hHUD.GetElementMissionIntro().Close(pc))
		{
			return true;
		}
    }

    if (pc.IsMoveInputIgnored())
    {
        return true;
    }

	if (Hat_PawnCarryable(pc.Pawn) != None && Hat_PawnCarryable(pc.Pawn).BeginCarryThrow(class'Hat_Player'.const.QuickThrowMagnitude)) return true;

    if (pc.InteractionTarget != None && p != None)
    {
        if(Hat_CarryObject(pc.InteractionTarget) != None)
        {
            prevPickup = Hat_CarryObject(pc.InteractionTarget).CanBePickedUpWhilePlayerInAir;
            Hat_CarryObject(pc.InteractionTarget).CanBePickedUpWhilePlayerInAir = true;
        }
        if (p.AttemptInteraction(pc.InteractionTarget, true))
        {
            if(Hat_CarryObject(pc.InteractionTarget) != None) Hat_CarryObject(pc.InteractionTarget).CanBePickedUpWhilePlayerInAir = prevPickup;
            return true;
        }

        if(Hat_CarryObject(pc.InteractionTarget) != None) Hat_CarryObject(pc.InteractionTarget).CanBePickedUpWhilePlayerInAir = prevPickup;
    }

	if( pc.Role < Role_Authority )
	{
		return false;
	}

	return pc.TriggerInteracted();
}