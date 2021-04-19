class Crowd_Enemy_Band extends Crowd_Enemy_Band_Base
	placeable;

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=Model
		SkeletalMesh=SkeletalMesh'HatInTime_Characters_SciOwls.models.ScienceOwl_Groovy'
		PhysicsAsset=PhysicsAsset'HatInTime_Characters_SciOwls.Physics.ScienceOwl_Groovy_Physics'
		AnimTreeTemplate = AnimTree'HatInTime_Characters_SciOwls.AnimTrees.ScienceBand_ParadeFollow'
		AnimSets(0) = AnimSet'HatInTime_Characters_SciOwls.AnimSets.ScienceOwl_Anims'
		AnimSets(1) = AnimSet'HatInTime_Characters_SciOwls.AnimSets.ScienceOwl_Instruments_Anims'
		Translation=(Z=-35)
		
		bUpdateSkelWhenNotRendered=false
		bTickAnimNodesWhenNotRendered = false;
		LightEnvironment=m_hLightEnvironment
		MaxDrawDistance = 6000;
		bDisableFaceFX = true;
		bDisableAllRigidBody = true;
		bAcceptsStaticDecals = false;
		bAcceptsDynamicDecals = false;
	End Object
	Mesh=Model
	Components.Add(Model)
	
	Begin Object Class=Hat_ExpressionComponent_Owl Name=hExpression
	End Object
	Components.Add(hExpression);
	Expression = hExpression;
	
	Begin Object Class=StaticMeshComponent Name=TrumpetMesh0
		StaticMesh=StaticMesh'HatInTime_Levels_Science_H.models.science_trumpet'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		BlockActors=false
		CollideActors=false
		bUsePrecomputedShadows=FALSE
		ShadowParent = Model
		LightEnvironment=m_hLightEnvironment
	End Object
	TrumpetMesh=TrumpetMesh0
	Components.Add(TrumpetMesh0)
	
	Begin Object Class=StaticMeshComponent Name=CelloMesh0
		StaticMesh=StaticMesh'HatInTime_Levels_Science_H.models.science_cello'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		BlockActors=false
		CollideActors=false
		bUsePrecomputedShadows=FALSE
		ShadowParent = Model
		LightEnvironment=m_hLightEnvironment
	End Object
	CelloMesh=CelloMesh0
	Components.Add(CelloMesh0)
	
	Begin Object Class=StaticMeshComponent Name=CelloHandleMesh0
		StaticMesh=StaticMesh'HatInTime_Levels_Science_H.models.science_cello_bow'
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		BlockActors=false
		CollideActors=false
		bUsePrecomputedShadows=FALSE
		ShadowParent = Model
		LightEnvironment=m_hLightEnvironment
	End Object
	CelloHandleMesh=CelloHandleMesh0
	Components.Add(CelloHandleMesh0)
	
    Begin Object Class=ParticleSystemComponent Name=NoiseParticle0 
        Template = ParticleSystem'HatinTime_Levels_Moon_Mecha.Particles.OwlBandNoise'
		bAutoActivate=false
		Translation=(Z=25)
		AbsoluteRotation=true
    End Object 
    Components.Add(NoiseParticle0) 
    NoiseParticle = NoiseParticle0
	
	Begin Object Class=StaticMeshComponent Name=KnifeMesh0
		StaticMesh = StaticMesh'HatInTime_Levels_Murder_Mecha.models.Objects.Knife'
		LightEnvironment=m_hLightEnvironment
		ShadowParent = Model
		bUsePrecomputedShadows=FALSE
		CanBeEdgeGrabbed = false;
		CanBeWallSlid = false;
		BlockActors=false
		CollideActors=false
		bAcceptsStaticDecals = false
		bAcceptsDynamicDecals = false
		CanBlockCamera = false
		MaxDrawDistance = 6000;
		Translation=(X=25);
	End Object
	Components.Add(KnifeMesh0);
	KnifeMesh = KnifeMesh0
	
	EyeSightMaterial = MaterialInstanceConstant'HatinTime_Levels_Moon_Mecha.Materials.Parade_Follow_Trail'
	EyeSightMesh = StaticMesh'HatinTime_PrimitiveShapes.TexPropPlane'
}