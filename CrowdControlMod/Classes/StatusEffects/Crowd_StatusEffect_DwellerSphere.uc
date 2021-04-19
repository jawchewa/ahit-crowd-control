class Crowd_StatusEffect_DwellerSphere extends Crowd_StatusEffect_Persistent;

var SoundCue StartSound;
var SoundCue EndSound;

const MusicPitch = 0.95f;
const MusicHighFrequency = 0.0f;
const DoFRadius = 1600;
const DoFFalloff = 3.f;
const CooldownTime = 2.f;

var transient bool PitchChangeState;
var transient float PitchChangeProgress;

var bool bIsMalfunctioning;
var float FlickerProgress;
var bool PlayerActivated;
var bool MalfunctionActivated;

defaultproperties
{	
	Duration = 10;
	StartSound = SoundCue'HatinTime_SFX_Player4.Fox_Hat_Start_cue'
	EndSound = SoundCue'HatinTime_SFX_Player4.Fox_Hat_Stop_cue'
	
	PitchChangeProgress = 0;
	
	bIsMalfunctioning = false;
	FlickerProgress = 0;
	PlayerActivated = false;
	MalfunctionActivated = false;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	
	if (bIsMalfunctioning)
	{
		Hat_Player(Owner).DwellerMaskComponent.SetRadius(0);
		Hat_Player(Owner).SphereDwellerMesh.SetScale(0);
		Hat_Player(Owner).SphereDwellerMesh.SetHidden(true);
		
		Hat_Player(Owner).FoxMaskUses++;
	}
	
	Hat_Player(Owner).IsFoxMaskActive = true;
	
	if (StartSound != None)
		Owner.PlaySound(StartSound);
	class'Hat_PawnCombat'.static.ShakeNearbyCameras_Static(128, 256, 7.0f, 1.0f, Owner.Location, None, true);
	SetPostProcessSettings(Hat_Player(Owner), true);
	SetMusicPitch(true, false);
	
	Hat_HUD(PlayerController(Hat_Player(Owner).Controller).MyHUD).DoDwellerEffect(true);
	
	PlayerActivated = true;
	MalfunctionActivated = true;
	
	FlickerProgress = 0;
}

simulated function OnRemoved(Actor a)
{		
	Hat_Player(Owner).IsFoxMaskActive = false;
	Hat_HUD(PlayerController(Hat_Player(Owner).Controller).MyHUD).DoDwellerEffect(false);
	
	if (StartSound != None)
		Owner.PlaySound(EndSound);
	
	class'Hat_PawnCombat'.static.ShakeNearbyCameras_Static(128, 256, 2.0f, 0.5f, Owner.Location, None, true);
	SetPostProcessSettings(Hat_Player(Owner), false);
	SetMusicPitch(false, false);
		
	MalfunctionActivated = false;
	PlayerActivated = false;

    Super.OnRemoved(a);
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
	TickMalfunction(delta);
	TickMusicPitch(delta);

    return true;
}

function SetMusicPitch(bool b, bool instant)
{
	`SetMusicParameterInt('FoxMaskActive', b ? 1 : 0);
	if (instant)
	{
		SetMusicPitch2(b ? 1.f : 0.f);
	}
	else
	{
		PitchChangeState = b;
	}
}

function SetMusicPitch2(float alpha)
{
	if (MusicPitch != 1.f)
	{
		if (`MusicManager != None && `MusicManager.MusicTreeInstance != None)
			`MusicManager.MusicTreeInstance.PitchMultiplier = Lerp(1.f, MusicPitch, alpha);
	}
	if (MusicHighFrequency != 1.f)
	{
		if (`MusicManager != None && `MusicManager.MusicTreeInstance != None)
			`MusicManager.MusicTreeInstance.HighFrequencyGainMultiplier = Lerp(1.f, MusicHighFrequency, alpha);
	}
}

function TickMusicPitch(float d)
{
	if (!PitchChangeState && PitchChangeProgress <= 0) return;
	if (PitchChangeState && PitchChangeProgress >= 1) return;
	
	if (PitchChangeState)
		PitchChangeProgress = FMin(PitchChangeProgress+d/0.2f, 1.f);
	else
		PitchChangeProgress = FMax(PitchChangeProgress-d/0.2f, 0.f);
	
	SetMusicPitch2(PitchChangeProgress);
}

function TickMalfunction(float d)
{
	if(!bIsMalfunctioning) return;
	
	FlickerProgress += d;
	
	if (FlickerProgress >= 0.6)
	{
		MalfunctionActivated = !MalfunctionActivated;
		//DoActivate();
		if (MalfunctionActivated) 
		{
			Hat_Player(Owner).IsFoxMaskActive = true;
			Hat_Player(Owner).DwellerMaskComponent.SetRadius(Hat_Player(Owner).DwellerMaskComponent.Radius);
			Hat_Player(Owner).SphereDwellerMesh.SetScale(Hat_Player(Owner).DwellerMaskComponent.Radius / 160.f);
			Hat_Player(Owner).SphereDwellerMesh.SetHidden(false);
			
			PlayerActivated = false;
		}
		else
		{
			Hat_Player(Owner).IsFoxMaskActive = false;
			Hat_Player(Owner).DwellerMaskComponent.SetRadius(0);
			Hat_Player(Owner).SphereDwellerMesh.SetScale(0);
			Hat_Player(Owner).SphereDwellerMesh.SetHidden(true);
			
			//bIsMalfunctioning = class'Hat_SnatcherContract_DeathWish_FracturedMask'.static.IsActive();
		}
		FlickerProgress = 0;
	}
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

	//set.bOverride_EnableBloom = TRUE;
	//set.bEnableBloom = TRUE;
	//set.bOverride_Bloom_Scale = TRUE;
	//set.bOverride_Bloom_Threshold = TRUE;
	//set.bOverride_DOF_BlurBloomKernelSize = TRUE;
	//set.bOverride_Bloom_InterpolationDuration = TRUE;
	
	// dof
	set.DOF_FocusInnerRadius = DoFRadius;
	set.DOF_BlurKernelSize = 32;
	set.DOF_FalloffExponent = DoFFalloff;
	set.DOF_InterpolationDuration = 0.0f;
	
	// bloom
	//set.Bloom_Scale = 0.2;
	//set.Bloom_Threshold = 0.89;
	//set.DOF_BlurBloomKernelSize = 64;
	//set.Bloom_InterpolationDuration = 0.5f;
	
	set.bOverride_Scene_Colorize = true;
	set.Scene_Colorize = vect(0.9,1.0,0.95);
	
	set.bOverride_Scene_InterpolationDuration = true;
	set.bOverride_MotionBlur_InterpolationDuration = true;
	set.bOverride_RimShader_InterpolationDuration = true;
	
	set.MotionBlur_InterpolationDuration = 0;
	set.Scene_InterpolationDuration = 0;
	set.RimShader_InterpolationDuration = 0;
	return set;
}