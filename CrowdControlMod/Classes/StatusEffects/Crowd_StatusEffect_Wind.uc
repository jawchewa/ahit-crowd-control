//Applies a constant force to the player in a random direction.
class Crowd_StatusEffect_Wind extends Crowd_StatusEffect_Persistent;

var Vector dir;

defaultproperties
{
    Duration = 15;
}

function SetData(string data)
{
    local Array<String> arr;
    
    arr = SplitString(data, ",", true);
    dir.X = Float(arr[0]);
    dir.Y = Float(arr[1]);
}

function String GetData()
{
    return String(dir.X)$","$String(dir.Y);
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);

	dir.X = RandRange(-1, 1);
	dir.Y = RandRange(-1, 1);   
    dir = Normal(dir) * 200;
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(a).ZiplineMovingFastParticle.SetActive(true);
        Hat_Player(a).ZiplineMovingFastParticle.SetRotation(Rotator(dir));
    }
}

simulated function OnRemoved(Actor a)
{		
    if (Hat_Player(Owner) != None)
    {
        Hat_Player(a).ZiplineMovingFastParticle.SetActive(false);
    }
    Super.OnRemoved(a);
}

function bool Update(float delta)
{
    local Hat_Player p;
	local Actor a;
	local Vector HitLocation, HitNormal;
    if (!Super.Update(delta)) return false;
    p = Hat_Player(Owner);
    if (p.Physics != PHYS_Ladder && p.m_iPlatformMove != EPlatformMove_Rope && p.m_iPlatformMove != EPlatformMove_LedgeHang && !p.IsWallSliding() && p.CanMove(false))
    {

        if(p.Physics == PHYS_Walking)
        {
            p.MoveSmooth(dir * delta);
            a = p.Trace(HitLocation, HitNormal, p.Location - vect(0,0,1) * 60, p.Location, false, p.GetCollisionExtent());
            if(a == none)
            {
                p.SetPhysics(PHYS_Falling);
            }
            else
            {
                p.MoveSmooth(HitLocation - p.Location);
            }
        }
        else
		{
            p.Velocity = p.Velocity + dir * 0.1;
		}
    }

    return true;
}