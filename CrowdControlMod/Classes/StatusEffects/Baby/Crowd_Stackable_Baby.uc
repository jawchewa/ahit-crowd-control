class Crowd_Stackable_Baby extends Crowd_Stackable_Animated
    placeable;

var int CostumeID;
var StaticMeshComponent Knife;

defaultproperties
{
    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'HatinTime_Characters_Grandkid.SkeletalMeshes.Conductor_Grandkid'
        PhysicsAsset=PhysicsAsset'HatinTime_Characters_Grandkid.Physics.Conductor_Grandkid_Physics'
        AnimSets(0)=AnimSet'HatinTime_Characters_Grandkid.AnimSets.Conductor_Grandkid_Anims'
        AnimTreeTemplate=AnimTree'HatinTime_Characters_Grandkid.AnimTrees.Conductor_GrandKid_AnimTree'
    End Object

    Begin Object Class=StaticMeshComponent Name=KnifeMesh0
        StaticMesh=StaticMesh'HatInTime_Levels_Murder_Mecha.models.Objects.knife'
        LightEnvironment=m_hLightEnvironment
        CanBlockCamera=false
        BlockActors=true
        CollideActors=true
        MaxDrawDistance=6000
        BlockZeroExtent=false
        BlockNonZeroExtent=false
        CanBeEdgeGrabbed=false
        HiddenGame=true
        HiddenEditor=true
    End Object
    Components.Add(KnifeMesh0);
    Knife = KnifeMesh0;

    StackHeight = 35
    StackOffset = -15
    StackDistance = 5

    CostumeID = -1
    CanBePickedUpWhilePlayerInAir = true;
}

function bool CanBePicked()
{
	if (!CanBeCarried) return false;
    if (IsBeingCarried()) return false;
    if (Physics == Phys_Interpolating) return false;
	return true;
}

function bool CanBeInteractedWith(Actor a)
{
	if (!CanBePicked()) return false;
	return true;
}

function OnSpawn()
{
    SetCostume();
    CanBeThrown = false;
}

function OnDespawn()
{
    CostumeID = -1;
}

function OnPickUp(Actor p)
{
    Super.OnPickUp(p);
    PlaySound(SoundCue'HatinTime_SFX_Cruise.SoundCues.Conductor_Baby_Pickup1');
}

function OnCompleteDelivery()
{
    Super.OnCompleteDelivery();
    PlaySound(SoundCue'HatinTime_SFX_Cruise.SoundCues.Conductor_Baby_Pickup1');
}

function SetCostume(optional int id = -1)
{
    local Array<int> available;
    local int i;
    local Actor a;

    // randomize costume (avoid duplicates)
    if (id == -1)
    {
        for (i = 0; i < 5; i++)
            available.AddItem(i);

        foreach DynamicActors(class'Actor', a)
        {
            if (Crowd_Stackable_Baby(a) == None) continue;
            if (Crowd_Stackable_Baby(a).CostumeID == -1) continue;
            available.RemoveItem(Crowd_Stackable_Baby(a).CostumeID);
        }

        id = available.Length > 0 ? available[Rand(available.Length)] : Rand(5);
    }

    CostumeID = id;

    Knife.SetHidden(true);
    switch (CostumeID)
    {
        case 1: // Stripe
            Mesh.SetMaterial(0, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(1, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(2, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(3, Material'HatinTime_Characters_Grandkid.Materials.grandkid_stripedeshirt');
            Mesh.SetMaterial(4, Material'HatInTime_Characters.Materials.Invisible');
            break;
        case 2: // Pacifier
            Mesh.SetMaterial(0, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(1, Material'HatinTime_Characters_Grandkid.Materials.grandkid_pacifier');
            Mesh.SetMaterial(2, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(3, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(4, Material'HatInTime_Characters.Materials.Invisible');
            break;
        case 3: // Cute
            Mesh.SetMaterial(0, Material'HatinTime_Characters_Grandkid.Materials.grandkid_strawhat');
            Mesh.SetMaterial(1, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(2, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(3, Material'HatinTime_Characters_Grandkid.Materials.grandkid_pinkshirt');
            Mesh.SetMaterial(4, Material'HatInTime_Characters.Materials.Invisible');
            break;
        case 4: // Sailor
            Mesh.SetMaterial(0, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(1, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(2, Material'HatinTime_Characters_Grandkid.Materials.grandkid_sailorhat');
            Mesh.SetMaterial(3, Material'HatinTime_Characters_Grandkid.Materials.grandkid_whiteshirt');
            Mesh.SetMaterial(4, Material'HatInTime_Characters.Materials.Invisible');
            break;
        default: // Grandpa's Favorite
            Mesh.SetMaterial(0, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(1, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(2, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(3, Material'HatInTime_Characters.Materials.Invisible');
            Mesh.SetMaterial(4, Material'HatinTime_Characters_Grandkid.Materials.grandkid_condhat');
            Knife.SetHidden(false);// let me see what you have
            SkeletalMeshComponent(Mesh).AttachComponentToSocket(Knife, 'Knife');// NO!!!
            break;
    }
}

function bool CanCarryBeDropped()
{
	return ForcingDrop;
}