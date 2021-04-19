// Shrinks the player down to a tiny version of themself.
// Also disables ladders, because ladders don't work if you're not the right height.
class Crowd_StatusEffect_Shrink extends Crowd_StatusEffect_Persistent;

var bool wasCrouching;

defaultproperties
{
    Duration = 30;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    SetScale(0.4);
    if (Hat_Player(a) != None)
    {
        if (Hat_Player(a).Physics == Phys_Walking)
        {
            Hat_Player(Owner).DoSpringJump();
            Owner.SetPhysics(Phys_Falling);
            Owner.Velocity = vect(0,0,1)*120;
        }
    }
}

simulated function OnRemoved(Actor a)
{    
    ResetScale(a);
    if (Hat_Player(a) != None)
    {
        Hat_Player(a).Mesh.SetTranslation(vect(-4, 0,-36.15));
        if (Hat_Player(a).Physics == Phys_Walking)
        {
            Hat_Player(Owner).DoSpringJump();
            Owner.SetPhysics(Phys_Falling);
            Owner.Velocity = vect(0,0,1)*300;
        }
    }
    Super.OnRemoved(a);
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
        
    if(Pawn(Owner).bIsCrouched != wasCrouching)
    {
        SetScale(0.4);
    }

    wasCrouching = Pawn(Owner).bIsCrouched;
    return true;
}

function SetScale(float f)
{
    local Pawn p;
    
    p = Pawn(Owner);
    p.SetDrawScale(F);
    Hat_Player(p).CylinderComponent.SetCylinderSize(Hat_Player(p).CylinderComponent.default.CollisionRadius*f, Hat_Player(p).CylinderComponent.default.CollisionHeight * f * p.bIsCrouched ? 0.5 : 1.0);
    Hat_Player(p).bCanClimbLadders = false;
    if(p.bIsCrouched)
    {
        Hat_Player(p).Mesh.SetTranslation(vect(-4, 0,-14.46));
    }
    else
    {
        Hat_Player(p).Mesh.SetTranslation(vect(-4, 0,-36.15));
    }
    p.SetLocation(p.Location);
}
    
function ResetScale(Actor a)
{
    local Pawn p;
    
    p = Pawn(a);

    p.SetDrawScale(1);

    Hat_Player(p).CylinderComponent.SetCylinderSize(Hat_Player(p).CylinderComponent.default.CollisionRadius, Hat_Player(p).CylinderComponent.default.CollisionHeight);
    Hat_Player(p).bCanClimbLadders = Hat_Player(p).default.bCanClimbLadders;
	p.SetLocation(p.Location);
}