//Slows down time to a quarter speed for 20 seconds.
//Based on the code for the Time Stop hat from the main game.
class Crowd_StatusEffect_TimeStop extends Crowd_StatusEffect_Persistent;

const ParameterName = 'TimeStop';
const TimeScale = 0.25f;
const ZeroVelocityOnExit = false;
const MusicPitchNormal = 0.9f;
const MusicPitchRace = 0.5f;
const MusicVolume = 0.7f;
const DoFRadius = 2200;
const DoFFalloff = 0.5f;

var float PlayerSpeed;
var Rotator MoveRotation;
var Rotator PlayerCurrentRotation;

var ParticleSystem TimeStopParticle;
var ParticleSystem FootstepParticle;
var ParticleSystem JumpParticle;
var ParticleSystemComponent TimeStopParticleComp;
var SoundCue StartSound;
var SoundCue EndSound;
var SoundCue LoopSound;
var transient AudioComponent LoopAudioComponent;
var transient float TargetMusicPitch;

defaultproperties
{
    Duration = 5;
	PlayerSpeed = 1.0;
	TimeStopParticle = ParticleSystem'HatInTime_Badges.Particles.timeStop_fx'
	FootstepParticle = ParticleSystem'HatInTime_Badges.Particles.timestop_footsteps'
	JumpParticle = ParticleSystem'HatInTime_Badges.Particles.TimeStop_Jump'
	StartSound = SoundCue'HatinTime_SFX_Player2.Dodge_Badge_Start_cue'
	EndSound = SoundCue'HatinTime_SFX_Player2.DodgeBadge_Stop_cue'
	LoopSound = SoundCue'HatinTime_SFX_Player2.Dodge_Badge_Loop_With_Clocks_cue'
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	if (StartSound != None)
		a.PlaySound(StartSound);
	
	TargetMusicPitch = MusicPitchNormal;
	if (`GameManager.GetCurrentMapFilename() == "mafia_town" && `GameManager.IsCurrentAct(5))
		TargetMusicPitch = MusicPitchRace;

	LoopAudioComponent = a.CreateAudioComponent(LoopSound, true, true,,,true);

	if (VSize(a.Acceleration) > 0.01)
		MoveRotation = Rotator(a.Acceleration*vect(1,1,0));
	else
		MoveRotation = a.Rotation;

	PlayerCurrentRotation = a.Rotation;

	OnStartTeleport(a);
}

simulated function OnRemoved(Actor a)
{
	if (EndSound != None)
		a.PlaySound(EndSound);

    if (Hat_Player(a) != None)
	{
		Hat_Player(a).HeartMesh.SetHidden(true);
		if (`MusicManager != None && `MusicManager.MusicTreeInstance != None)
		{
			`MusicManager.MusicTreeInstance.PitchMultiplier = 1;
			`MusicManager.MusicTreeInstance.VolumeMultiplier = 1;
		}
	}

	if (LoopAudioComponent != None)
	{
		LoopAudioComponent.Stop();
		LoopAudioComponent = None;
	}

	OnExitTeleport(a);
	if (TimeScale > 0 && TimeScale < 1.f)
		`GameManager.SlowTime(TimeScale, false, false);
	Super.OnRemoved(a);
}


function bool Update(float delta)
{
	if (!Super.Update(delta)) return false;
	
    if (Hat_Player(Owner) != None)
	{
		if (`MusicManager != None && `MusicManager.MusicTreeInstance != None)
		{
			`MusicManager.MusicTreeInstance.PitchMultiplier = Lerp(`MusicManager.MusicTreeInstance.PitchMultiplier, TargetMusicPitch, FMin(delta/0.1f,1));
			`MusicManager.MusicTreeInstance.VolumeMultiplier = Lerp(`MusicManager.MusicTreeInstance.VolumeMultiplier, MusicVolume, FMin(delta/0.1f,1));
		}
	}

	return true;
}

static function DoTimeStopParticleEffect(Actor InOwner, out ParticleSystemComponent p, bool b)
{
	if (b)
	{
		if (p != None) return;
		p = new class'ParticleSystemComponent';
		if (p == None) return;

		p.SetTemplate(default.TimeStopParticle);
		p.KillParticlesForced();
		p.ActivateSystem(true);
		InOwner.AttachComponent(p);
	}
	else
	{
		if (p == None) return;
		p.SetActive(false);
		p.KillParticlesForced();
		InOwner.DetachComponent(p);
		p = None;
	}
}

function OnStartTeleport(Actor a)
{
	Hat_Player(a).HeartMesh.SetHidden(false);

	if (TimeStopParticle != None && TimeStopParticleComp == None)
	{
		DoTimeStopParticleEffect(a, TimeStopParticleComp, true);
	}

	if (Hat_Player(a) != None)
	{
		Hat_Player(a).m_hWalkParticle.SetTemplate(FootstepParticle);
		Hat_Player(a).m_hWalkParticle.SetActive(false);
		Hat_Player(a).JumpParticle.SetTemplate(JumpParticle);
		Hat_Player(a).JumpParticle.SetActive(false);
	}

	Hat_Pawn(a).SetMaterialScalarValue(ParameterName, 1);

    a.CustomTimeDilation = (1.f / TimeScale)*PlayerSpeed;
	Pawn(a).Controller.CustomTimeDilation = a.CustomTimeDilation;
	Hat_InventoryManager( Pawn(a).InvManager ).SetInventoryCustomTimeDilation(a.CustomTimeDilation);

	if (Hat_Player(a) != None)
		SetPostProcessSettings(Pawn(a), true);

	if (TimeScale > 0 && TimeScale < 1.f)
		`GameManager.SlowTime(TimeScale, true, false);
}

function OnExitTeleport(Actor a)
{
	a.CustomTimeDilation = a.default.CustomTimeDilation;
	Pawn(a).Controller.CustomTimeDilation = a.CustomTimeDilation;
	Hat_InventoryManager( Pawn(a).InvManager ).SetInventoryCustomTimeDilation(a.CustomTimeDilation);
	Hat_Pawn(a).SetMaterialScalarValue(ParameterName, 0);

	if (Hat_Player(a) != None)
	{
		Hat_Player(a).m_hWalkParticle.SetTemplate(Hat_Player(a).m_hWalkParticle.default.Template);
		Hat_Player(a).m_hWalkParticle.SetActive(false);
		Hat_Player(a).JumpParticle.SetTemplate(Hat_Player(a).JumpParticle.default.Template);
		Hat_Player(a).JumpParticle.SetActive(false);
	}

	DoTimeStopParticleEffect(a, TimeStopParticleComp, false);

	if (a.Physics == Phys_Falling)
	{
		if (ZeroVelocityOnExit)
			a.Velocity = a.Velocity*vect(0,0,1);
	}
	if (a.IsA('Pawn'))
	{
		SetPostProcessSettings(Pawn(a), false);
	}
}

function ParticleSystemComponent SpawnParticle(ParticleSystem par, optional Name BoneName, optional bool IsSocket)
{
	local ParticleSystemComponent p;
	if (par == None) return None;

	p = new class'ParticleSystemComponent';

	if (p != None)
	{
		p.SetTemplate(par);
		p.KillParticlesForced();

		if (IsSocket)
			Pawn(Owner).Mesh.AttachComponentToSocket(p, BoneName);
		else
			Pawn(Owner).Mesh.AttachComponent(p, BoneName);

		p.ActivateSystem(true);
		return p;
	}
	return None;
}

function SetPostProcessSettings(Pawn InPawn, bool b)
{
	local LocalPlayer p;
	local PostProcessSettings set;

	p = LocalPlayer(PlayerController(InPawn.Controller).Player);

	if (b)
	{
		set = GetPostProcessSettings(InPawn);
		p.OverridePostProcessSettings(set);
	}
	else
		p.ClearPostProcessSettingsOverride(0.5f);
}

function PostProcessSettings GetPostProcessSettings(Pawn InPawn)
{
	local PostProcessSettings set;
	set = PlayerController(InPawn.Controller).PlayerCamera.CamPostProcessSettings;


	set.bOverride_EnableDOF = TRUE;
	set.bEnableDOF = TRUE;
	set.bOverride_DOF_FocusInnerRadius = TRUE;
	set.bOverride_DOF_BlurKernelSize = TRUE;
	set.bOverride_DOF_FalloffExponent = TRUE;
	set.bOverride_DOF_InterpolationDuration = TRUE;
	set.bOverride_DOF_FocusType = TRUE;
	set.bOverride_DOF_FocusPosition = TRUE;

	set.bOverride_EnableBloom = TRUE;
	set.bEnableBloom = TRUE;
	set.bOverride_Bloom_Scale = TRUE;
	set.bOverride_Bloom_Threshold = TRUE;
	set.bOverride_DOF_BlurBloomKernelSize = TRUE;
	set.bOverride_Bloom_InterpolationDuration = TRUE;

	// dof
	set.DOF_FocusInnerRadius = DoFRadius;
	set.DOF_BlurKernelSize = 32;
	set.DOF_FalloffExponent = DoFFalloff;
	set.DOF_InterpolationDuration = 0.0f;

	// bloom
	set.Bloom_Scale = 0.3;
	set.Bloom_Threshold = 0.89;
	set.DOF_BlurBloomKernelSize = 64;
	set.Bloom_InterpolationDuration = 0.5f;

	set.bOverride_Scene_Colorize = true;
	set.Scene_Colorize = vect(0.9,0.6,1.0);

	set.bOverride_Scene_InterpolationDuration = true;
	set.bOverride_MotionBlur_InterpolationDuration = true;
	set.bOverride_RimShader_InterpolationDuration = true;

	set.MotionBlur_InterpolationDuration = 0;
	set.Scene_InterpolationDuration = 0;
	set.RimShader_InterpolationDuration = 0;
	return set;
}
