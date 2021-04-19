// Based on the code from the Parade Badge Mod: https://steamcommunity.com/sharedfiles/filedetails/?id=1531502590
// Also just based on the band enemy script from the base game.
class Crowd_Enemy_Band_Base extends Actor
	abstract;
	
const CaptureInterval = 0.05f;
const CaptureExpireDelay = 38;
const HurtReplayDelta = 0.3;
const HurtReplayDuration = 0.5;
const HurtCatchUpSpeed = 1.1;
const InheritBaseVelocity = 1.8;
	
struct PlayerReplayInfo
{
	var float Time;
	var Vector Location;
	var Vector Velocity;
	var Rotator Rotation;
	var EPhysics Physics;
};

enum EScienceBandInstrument
{
	EScienceBandInstrument_Trumpet,
	EScienceBandInstrument_Cello,
	EScienceBandInstrument_Knife,
};

var(Mesh) SkeletalMeshComponent Mesh;
var(Instruments) MeshComponent TrumpetMesh;
var(Instruments) MeshComponent CelloMesh;
var(Instruments) MeshComponent CelloHandleMesh;
var(Instruments) MeshComponent KnifeMesh;
var(Mesh) const editconst LightEnvironmentComponent m_hLightEnvironment;
var() EScienceBandInstrument Instrument;
var() Actor FrontBandMember;
var(Sounds) SoundCue DropDownLandStingerSound;
var(Sounds) SoundCue DropDownLandSound;
var(Sounds) float DropDownLandStingerSoundPitch;

var transient Pawn MimickActor;
var() bool Active;
var() int MimicPlayerIndex;
var() float MimicDelay;
var() class<DamageType> TouchDamageType;
var transient Array<PlayerReplayInfo> PlayerReplayInfos;
var transient float MyRecordSeconds;
var transient float MyReplaySeconds;
var transient float InheritVelocityScale;
`if(`isdefined(WITH_DLC1))
var() bool DeathWishVersion;
`else
var bool DeathWishVersion;
`endif

var(Mesh) MaterialInterface EyesightMaterial;
var(Mesh) StaticMesh EyesightMesh;
var transient StaticMeshComponent EyesightMeshComponent;

var(Particles) ParticleSystemComponent NoiseParticle;
var() Hat_ExpressionComponent Expression;

var transient float SlowDownDelay;
var transient float SlowDown;
var transient float DropDownTime;
var transient float DropDownDelay;
var transient Array<AnimNode> InstrumentNodeList;
var transient float MimickActorSpeedLerp;

var(Chapter) Array<int> ForbiddenActs;
var(Chapter) Array<int> PermittedActs;
var(Chapter) Array< class<Hat_SnatcherContract_DeathWish> > PermittedDeathWishes<HideInSimpleEditor>;
var(Chapter) Array< class<Hat_SnatcherContract_DeathWish> > ForbiddenDeathWishes<HideInSimpleEditor>;

defaultproperties
{
	Begin Object Class=Hat_CheapLightEnvironmentComponent Name=m_hLightEnvironment
		ForceShadowAngle = (Z=1)
		bDynamic=true
		bUseBooleanEnvironmentShadowing=false
	End Object
	m_hLightEnvironment = m_hLightEnvironment;
	Components.Add(m_hLightEnvironment)
	
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=21
		CollisionHeight=30
		BlockActors=true
		CollideActors=true
	End Object
	CollisionComponent = CollisionCylinder;
	Components.Add(CollisionCylinder)
	
	bBlockActors = true;
	bCollideActors=true
	bCollideWorld = false;
	MimicDelay = 1;
	IsActorEnemy = true;
	DropDownTime = -1;
	
	TouchDamageType = class'Hat_DamageType_Shove';
	DropDownLandStingerSoundPitch = 1;
	TickOptimize = TickOptimize_None;
}

simulated event PostBeginPlay()
{
	local int i;

	if (Owner == None && CreationTime <= 0 && worldinfo.game != None)
	{
		i = `GameManager.GetCurrentAct();
		if (PermittedActs.Length > 0 && PermittedActs.Find(i) == INDEX_NONE)
		{
			Destroy();
			return;
		}
		if (ForbiddenActs.Length > 0 && ForbiddenActs.Find(i) != INDEX_NONE)
		{
			Destroy();
			return;
		}
		if (!class'Hat_SnatcherContract_DeathWish'.static.IsActorAllowed(PermittedDeathWishes, ForbiddenDeathWishes))
		{
			Destroy();
			return;
		}
	}
	
	Super.PostBeginPlay();

	DeathWishVersion = DeathWishVersion || class'Hat_SnatcherContract_DeathWish_DifficultParade'.static.IsActive();

	if (DeathWishVersion)
	{
		MimicDelay -= 0.66;
		MimicDelay *= 1.15;
	}

    if (Expression != None)
        Expression.Init();
	
	Mesh.AttachComponentToSocket(TrumpetMesh, 'Trumpet');
	Mesh.AttachComponentToSocket(CelloMesh, 'Cello');
	Mesh.AttachComponentToSocket(CelloHandleMesh, 'CelloHandle');
	Mesh.AttachComponentToSocket(KnifeMesh, 'Knife');
	
	SetInstrument(Instrument);

	UpdateHiddenStatus();
}

simulated function SetInstrument(EScienceBandInstrument inst)
{
	local Hat_AnimBlendBase b;
	local int i;
	
	Instrument = inst;
	TrumpetMesh.SetHidden(Instrument != EScienceBandInstrument_Trumpet);
	CelloMesh.SetHidden(Instrument != EScienceBandInstrument_Cello);
	CelloHandleMesh.SetHidden(Instrument != EScienceBandInstrument_Cello);
	KnifeMesh.SetHidden(Instrument != EScienceBandInstrument_Knife);
	
	for (i = 0; i < InstrumentNodeList.Length; i++)
	{
		b = Hat_AnimBlendBase(InstrumentNodeList[i]);
		if (b == None) continue;
		b.SetActiveChild(int(Instrument), 0);
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local AnimNode AnimNode;
	local int i;
	local Hat_AnimBlendBase b;
	if (SkelComp == Mesh)
	{
		InstrumentNodeList = SkelComp.FindAnimNodesByName('Instrument');
		for (i = 0; i < InstrumentNodeList.Length; i++)
		{
			b = Hat_AnimBlendBase(InstrumentNodeList[i]);
			if (b == None) continue;
			b.SetActiveChild(int(Instrument), 0);
		}
		AnimNode = SkelComp.FindAnimNode('Playing');
		if (AnimNode != None)
			AnimNodeBlendList(AnimNode).SetActiveChild(0, 0);
	}
	super.PostInitAnimTree(SkelComp);
}

function bool ShouldHide()
{
	if (MimickActor == None && Active)
	{
		AutoSetMimickActor();
		if (MimickActor == None) return true;
	}
	if (`GameManager.IsCoop() && DeathWishVersion && MimicDelay > 13.f) return true;
	if (!`GameManager.IsCoop() && MimicPlayerIndex > 0) return true;
	return false;
}

function UpdateHiddenStatus()
{
	local bool Hide;

	Hide = ShouldHide();
	SetHidden(Hide);
	SetCollision(!Hide, false);
}

function AutoSetMimickActor()
{
	local array<LocalPlayer> GamePlayers;

	GamePlayers = class'Engine'.static.GetEngine().GamePlayers;

	if (Active && GamePlayers.length > MimicPlayerIndex)
	{
		SetMimickActor(GamePlayers[MimicPlayerIndex].Actor.Pawn);
	}
	else
	{
		SetMimickActor(None);
	}
}

simulated event Tick(float d)
{
	local float speed, delta_seconds;
	Super.Tick(d);
	
	if (MimickActor == None)
	{
		AutoSetMimickActor();
	}
	UpdateHiddenStatus();
	if (bHidden) return;

	if (MimickActor != None && !MimickActor.IsTicking()) return;
	if (MimickActor != None && ShouldFreeze(Hat_Player(MimickActor))) return;

	if (MimickActor != None)
	{
		speed = VSize((MimickActor.Velocity)*vect(1,1,0));
		MimickActorSpeedLerp = Lerp(MimickActorSpeedLerp, speed, d/(speed >= MimickActorSpeedLerp ? 0.5f : 2.f));
	}
	
    if (Expression != None && !bHidden)
        Expression.Update(d);

	if (SlowDownDelay > 0)
		SlowDownDelay -= d;
	
	if (SlowDown > 0 && SlowDownDelay <= 0)
	{
		MyReplaySeconds += d*HurtReplayDelta;
		SlowDown -= d*HurtReplayDelta;
	}
	else if (MyReplaySeconds < MyRecordSeconds)
	{
		delta_seconds = MyRecordSeconds - MyReplaySeconds;
		speed = Lerp(1, 3, FClamp((delta_seconds-2.f)/4.0f,0,1))*HurtCatchUpSpeed;
		MyReplaySeconds = FMin(MyReplaySeconds+d*(speed-1), MyRecordSeconds)+d;
		SlowDownDelay -= d*(speed-1);
	}
	else
		MyReplaySeconds += d;
	
	MyRecordSeconds += d;
	
	if (MimickActor != None)
	{
		DoPlayerReplay();
		if (EyesightMeshComponent != None)
			UpdateLineSightMesh();
	}
	if (DropDownTime >= 0)
		UpdateDropDown(d);
}

function SetMimickActor(Pawn p)
{
	local PlayerReplayInfo pri;
	local vector delta;
	local AnimNode AnimNode;
	if (MimickActor == p) return;
	MimickActor = p;
	
	SetCollision(default.bCollideActors, false);
	
	pri.Time = MyRecordSeconds-MimicDelay;
	pri.Location = Location;
	delta = MimickActor.Location - pri.Location;
	pri.Velocity = Normal(delta) * FMin(Vsize(delta), 400);
	pri.Rotation = Rotation;
	pri.Physics = Physics;
	
	PlayerReplayInfos.Length = 0;
	PlayerReplayInfos.AddItem(pri);
	
	DoPlayerReplay();
	
	NoiseParticle.SetActive(true);
	MimickActorSpeedLerp = 400;
	
	AnimNode = Mesh.FindAnimNode('Playing');
	if (AnimNode != None)
		AnimNodeBlendList(AnimNode).SetActiveChild(1, 0.5f);
	
	CreateLineSightMesh();
	
	Expression.ForcedViewTarget = MimickActor;
}

function DoCaptureState()
{
	local PlayerReplayInfo pri;
	local float alpha;
	
	if (PlayerReplayInfos.Length > 0 && (MyRecordSeconds - PlayerReplayInfos[PlayerReplayInfos.Length-1].Time) < CaptureInterval)
		return;
	
	pri.Time = MyRecordSeconds;
	pri.Location = MimickActor.Location;
	pri.Velocity = MimickActor.Velocity;
	pri.Rotation = MimickActor.Rotation;
	pri.Physics = MimickActor.Physics;
	
	// Inherit base velocity
	if (MimickActor.Base != None)
	{
		InheritVelocityScale = FMin(InheritVelocityScale+CaptureInterval/3.f,1.f);
		pri.Location += MimickActor.Base.Velocity*vect(1,1,0)*InheritBaseVelocity*InheritVelocityScale;
	}
	else
	{
		InheritVelocityScale = FMax(InheritVelocityScale-CaptureInterval/0.5f,0.f);
	}
	
	if (MimickActorSpeedLerp <= 300)
	{
		alpha = FClamp((300-MimickActorSpeedLerp)/200,0,1);
		pri.Location += Normal(MimickActor.Velocity)*vect(1,1,0)*Lerp(0,300, alpha);
	}
	
	PlayerReplayInfos.AddItem(pri);
	
	// 30s old, expire it
	while (PlayerReplayInfos.Length > 0 && MyRecordSeconds - CaptureExpireDelay >= PlayerReplayInfos[0].Time)
	{
		PlayerReplayInfos.Remove(0,1);
	}
}

function DoPlayerReplay()
{
	local PlayerReplayInfo StartInterp;
	local PlayerReplayInfo EndInterp;
	local float alpha, MyReplaySecondsDelta, MyMimicDelay;
	local Vector v;
	local Rotator r;
	
	DoCaptureState();
	
	MyMimicDelay = MimicDelay;
	MyReplaySecondsDelta = MyReplaySeconds - MyMimicDelay;
	/*
	if (MimickActorSpeedLerp <= 300)
	{
		//alpha = FClamp((300-MimickActorSpeedLerp)/100,0,1);
		alpha = 1;
		MyReplaySecondsDelta = FMin(MyReplaySecondsDelta+alpha*1.5f, MyRecordSeconds-CaptureInterval);
	}
	*/
	
	if (!GetPlayerReplayInfo(MyReplaySecondsDelta, StartInterp, EndInterp, alpha)) return;
	
	v = VLerp(StartInterp.Location, EndInterp.Location, alpha);
	Move(v - Location);
	
	v = VLerp(StartInterp.Velocity, EndInterp.Velocity, alpha);
	Velocity = v;
	
	r = class'Hat_Math'.static.RLerpShortest(StartInterp.Rotation, EndInterp.Rotation, alpha);
	SetRotation(r);
}

function bool GetPlayerReplayInfo(float inTime, out PlayerReplayInfo StartInterp, out PlayerReplayInfo EndInterp, out float alpha)
{
	local int i;
	
	for (i = PlayerReplayInfos.Length-1; i >= 1; i--)
	{
		if (PlayerReplayInfos[i-1].Time >= InTime) continue;
		
		EndInterp = PlayerReplayInfos[i];
		StartInterp = PlayerReplayInfos[i-1];
		
		alpha = (InTime - StartInterp.Time) / (EndInterp.Time - StartInterp.Time);
		alpha = FClamp(alpha,0,1);
		return true;
	}
	return false;
}

event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local Hat_Enemy_ScienceBand_Base sb;
	if (MimickActor != None && TouchDamageType != None && Other != None && Other.IsA('Hat_Player') && Hat_Pawn(Other).CanTakeDamage(FALSE, self, 1))
	{
		Other.TakeDamage(1.0, None, Location, (Normal((Other.Location - Location)*vect(1,1,0)) + vect(0,0,1)*0.6) * class'Hat_DamageType_Shove'.default.PushStrength, TouchDamageType,,self);
		
		foreach DynamicActors(class'Hat_Enemy_ScienceBand_Base', sb)
		{
			sb.OnPlayerTakeHit();
		}
	}
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

simulated function OnToggle( SeqAct_Toggle Action )
{
	if( Action.InputLinks[0].bHasImpulse )
	{
		Active = true;
		AutoSetMimickActor();
	}
}

function CreateLineSightMesh()
{
	local StaticMeshComponent m;
	m = new class'StaticMeshComponent';
	m.SetStaticMesh(EyesightMesh);
	m.SetLightEnvironment(Mesh.LightEnvironment);
	m.SetShadowParent(Mesh);
	m.SetMaterial(0, EyesightMaterial);
	m.SetAbsolute(true, true, true);
	m.CastShadow = false;
	AttachComponent(m);
	m.SetScale3D(vect(1,1,0.015));
	m.CachedMaxDrawDistance = 4000;
	m.SetActorCollision(false,false,false);
	
	EyesightMeshComponent = m;
}

function UpdateLineSightMesh()
{
	local Vector s, delta, startv, endv;
	local Rotator r;
		
	startv = Location;
	endv = FrontBandMember != None ? FrontBandMember.Location : MimickActor.Location;
	
	r = Rotator(endv - startv);
	startv += Vector(r)*vect(1,1,1)*40;
	endv -= Vector(r)*vect(1,1,0)*40;
	
	delta =  (endv - startv);
	
	s = EyesightMeshComponent.Scale3D;
	s.Y = (VSize(delta) - 50)/320;
	
	EyesightMeshComponent.SetScale3D(s);
	EyesightMeshComponent.SetTranslation(startv + delta/2);
	
	r = Rotator(delta);
	r.Yaw += 65536/4;
	r.Roll = r.Pitch;
	r.Pitch = 0;
	EyesightMeshComponent.SetRotation(r);
}

function OnPlayerTakeHit()
{
	// We need to slowly catch up to the player being shot through the air
	SlowDown = HurtReplayDuration;
	SlowDownDelay = MimicDelay + FMax(MyRecordSeconds - MyReplaySeconds,0);
	MimickActorSpeedLerp = 400;
}

function Vector GetDropDownTranslation(float inval)
{
	return vect(0,0,1)*class'Hat_Math'.static.InterpolationBounce(700, 0, inval, 0.4f);
}

simulated function DoDropDown(optional float delay = 0)
{
	if (DropDownTime >= 0) return;
	DropDownTime = 0;
	DropDownDelay = delay;
	
	Mesh.SetTranslation(Mesh.Translation + GetDropDownTranslation(0));
}

simulated function UpdateDropDown(float d)
{
	local float prev;
	local AudioComponent a;
	
	if (DropDownDelay > 0)
	{
		DropDownDelay -= d;
		return;
	}
	
	prev = DropDownTime;
	DropDownTime += d;
	DropDownTime = FMin(DropDownTime,1);
	Mesh.SetTranslation(Mesh.Translation + (GetDropDownTranslation(DropDownTime) - GetDropDownTranslation(prev)));
	
	if (DropDownTime >= 1)
	{
		DropDownTime = -1;
	}
	else if (DropDownTime >= 0.35 && prev < 0.35)
	{
		if (DropDownLandSound != None)
			PlaySound(DropDownLandSound);
		if (DropDownLandStingerSound != None)
		{
			a = CreateAudioComponent(DropDownLandStingerSound, false, true, true, Location, true);
			a.bAutoDestroy = true;
			a.PitchMultiplier = DropDownLandStingerSoundPitch;
			a.Play();
		}
	}
}

function bool ShouldFreeze(Hat_Player player)
{
	local Hat_PlayerController cont;

	if (player.Health <= 0) return true;
	if (player.bWaitingForCaveRiftIntro) return true;
	if (player.IsTaunting()) return true;
	if (player.IsNewItemState()) return true;
	if (player.MyDoor != None) return true;
	if (player.bHidden && !player.bCollideWorld && !player.bBlockActors) return true;
	if (player.bHidden && player.CanTakeDamage(false)) return true;
	if (player.SwampSinkProgress > 0.75) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_FreezeMovement', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Scared', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Stoning', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_FallHurtTransition', true)) return true;
	cont = Hat_PlayerController(player.Controller);
	if (cont == None) return true;
	if (cont.IsTalking()) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementActTitleCard')) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementLoadingScreen')) return true;
	if (Hat_HUD(cont.MyHUD).ElementsDisablesMovement() && !Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDMenu_SwapHat')) return true;

	return false;
}