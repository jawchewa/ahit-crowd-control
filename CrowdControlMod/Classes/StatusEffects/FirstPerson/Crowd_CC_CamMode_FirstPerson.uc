// Based on the First Person Camera Badge Mod: https://steamcommunity.com/sharedfiles/filedetails/?id=1765599993
class Crowd_CC_CamMode_FirstPerson extends Hat_CamMode_Script;

var bool isFocus;
var Actor Carried;

function Render(Hat_PlayerCamera_Base PlayerCamera, Pawn TPawn, const float DeltaTime, out Vector camEnd, out Rotator camRotation, const Rotator PlayerRotation, out float FoV, out sDynamicCameraInfo DynamicCameraInfo)
{
    local int delta;
    local Hat_Player ply;
    if (TPawn.bIsCrouched) {
		camEnd = TPawn.Location + vect(0,0,5);
	} else {
    	camEnd = TPawn.Location + vect(0,0,28);
	}
    ply = Hat_Player(TPawn);
	if(isFocus && ply != None) 
	{
        if(!ply.IsTaunting("Bench_Sit"))
        {
	        ply.FaceCamera();
        }

        if(ply.HasScooterAbility || ply.HasSubconScooterAbility)
        {
            camEnd += vect(0,0,15);
        }

        if(ply.CarriedObject != None){
			Carried = ply.CarriedObject;
			Carried.SetDrawScale3D(vect(0.4,0.4,0.4));
        }
        else{
			Carried.SetDrawScale3D(vect(1,1,1));
			Carried = None;
        }

        HideStuff(TPawn, true);
        ClampRotAxis(camRotation.Pitch,delta, 16000, -16000);
        camRotation.Pitch += delta;
	}
}

function bool IsRelevant(Hat_PlayerCamera_Base c)
{
    return !IsRemoved;
}

function bool IgnorePlayerMovement(Hat_PlayerCamera_Base c)
{
    return false;
}

function OnLeaveFocus(Hat_PlayerCamera_Base c)
{
    HideStuff(Hat_PlayerCamera(c).PCOwner.Pawn, false);
	isFocus = false;
    if (Hat_Player(Hat_PlayerCamera(c).PCOwner.Pawn).CarriedObject != None)
    {
		Carried = Hat_Player(Hat_PlayerCamera(c).PCOwner.Pawn).CarriedObject;
		Carried.SetDrawScale3D(vect(1,1,1));
    }
}

function OnGainFocus(Hat_PlayerCamera_Base c, const Pawn TPawn) {
    HideStuff(TPawn, true);
	isFocus = true;
	Carried.SetDrawScale3D(vect(0.4,0.4,0.4));
}

function HideStuff(Pawn p, bool fp)
{
    local Hat_CosmeticItem inv;
    local Hat_PlayerCustomizable pawnc;

    pawnc = Hat_PlayerCustomizable(p);

    StaticMeshComponent(Hat_Player(p).StatueFall).SetOwnerNoSee(fp);
    StaticMeshComponent(Hat_Player(p).StatueFall).bCastHiddenShadow = fp;

    p.Mesh.SetOwnerNoSee(fp);
    p.Mesh.bCastHiddenShadow = fp;

    if (pawnc != None) pawnc.SetCustomizableFirstPerson(fp);

    foreach p.InvManager.InventoryActors(class'Hat_CosmeticItem', inv)
    {
        inv.OnFirstPerson(fp);
    }
}

defaultproperties
{
	isFocus = true;
    CameraPriority = 150;
    FadeInTime = 0.1f;
    FadeOutTime = 0.25f;
    ShouldApplyInvert = false;
    NoPlayerControl = false;
    SupportsFirstPerson = false;
}