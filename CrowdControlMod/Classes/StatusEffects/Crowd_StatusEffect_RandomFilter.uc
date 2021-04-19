// Apply a random screen filter/effect for the next 30 seconds.
// Based on the code for my playable Camera Filters Mod: https://steamcommunity.com/sharedfiles/filedetails/?id=1303740330
// Also based off of code for the Retro Badge, the Retro VR Badge and the Nostalgia Badge from DLC2
class Crowd_StatusEffect_RandomFilter extends Crowd_StatusEffect_Persistent;

const PostProcessMaterialEffectName = 'CameraFilterMaterialEffect';
var MaterialInstanceConstant MaterialEffectInstance;
var MaterialInterface Mat;
var PostProcessSettings set;
var Texture2D GradientLUT; 
var MaterialEffect MaterialEffect;
var int randInt;
var float randParam;

defaultproperties
{
    Duration = 30;
    CanClear = false;
    randInt = -1;
    randParam = -1;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    initPostProccessSettings(Pawn(a));
    if (Hat_Player(a) != None)
    SetPostProcessSettings(Pawn(a));
}

function SetData(string data)
{
    local Array<String> arr;
    
    arr = SplitString(data, ",", true);
    randInt = Int(arr[0]);
    randParam = Float(arr[1]);
    RemoveEffect(Owner);
    initPostProccessSettings(Pawn(Owner));    
}

function String GetData()
{
    return String(randInt)$","$String(randParam);
}

function initPostProccessSettings(Pawn pawn)
{
    local HUD H;
    local PlayerController pc;
    pc = PlayerController(Pawn(Owner).Controller);
    H = pc.MyHUD;

    set = GetCinematicPostProcessSettings(H);

    set.bOverride_Scene_ColorGradingLUT = true;

    if(randInt < 0) randInt = Rand(16);
    if(randParam < 0) randParam = RandRange(0,1);

    switch (randInt)
    {
        case 0:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_action_blue';
            break;
        case 1:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_cold';
            break;
        case 2:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_dreamy';
            break;
        case 3:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_girlythings';
            break;
        case 4:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_noir';
            break;
        case 5:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_purple_night';
            break;
        case 6:
            Mat = Material'hatintime_render.Materials.Photo_DepthGradient';
            break;
        case 7:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_sunrise';
            break;
        case 8:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_sunset';
            break;
        case 9:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_neon';
            break;
        case 10:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_vintage2';
            break;
        case 11:
            GradientLUT = Texture2D'hatintime_ColorGradings.Cinematic.lut_cinematic_vintage';
            break;
        case 12:
            Hat_HUD(H).SetMaterialEffectActive('Pixelated_Simple', true);
            Hat_HUD(H).SetMaterialEffectActive('RetroHandheld', true);
            Hat_HUD(pc.MyHUD).OpenHUD(class'Hat_HUDElementNostalgia', "RetroHandheld");
            break;
        case 13:
            Hat_HUD(H).SetMaterialEffectActive('Pixelated_Simple2', true);
            Hat_HUD(H).SetMaterialEffectActive('VirtualGirl', true);
            Hat_HUD(pc.MyHUD).OpenHUD(class'Hat_HUDElementNostalgia', "RedtroVR");
            break;
        case 14:
            pc.ConsoleCommand("SCALE TRANSIENTTEXLOD " $ "World" $ " " $ 8);
            pc.ConsoleCommand("SCALE TRANSIENTTEXLOD " $ "WorldNormalMap" $ " " $ 6);
            Hat_HUD(H).SetMaterialEffectActive('Pixelated', true);
            Hat_HUD(pc.MyHUD).OpenHUD(class'Hat_HUDElementNostalgia', "Nostalgia");
            break;
        default:
            break;
    }
    set.bEnableDOF = false;

    if(randInt >= 12) return;

    set.ColorGrading_LookupTable = GradientLUT;

    MaterialEffect = MaterialEffect(LocalPlayer(H.PlayerOwner.Player).PlayerPostProcess.FindPostProcessEffect(PostProcessMaterialEffectName));
    if (MaterialEffect != None)
    {
        MaterialEffect.bShowInGame = Mat != None; 
        if(MaterialEffect.bShowInGame)
        {
            if (MaterialEffectInstance == None || MaterialEffectInstance.Parent != Mat)
            {
                MaterialEffectInstance = new class'MaterialInstanceConstant';
                MaterialEffectInstance.SetParent(Mat);
                MaterialEffect.SetMaterial(MaterialEffectInstance);
            }
            MaterialEffectInstance.SetScalarParameterValue('DOFOffset', 0);
            MaterialEffectInstance.SetScalarParameterValue('Rand', randParam);
        }
        else
        {
            MaterialEffect.SetMaterial(None);
            MaterialEffectInstance = None;
        }
    }
}

simulated function OnRemoved(Actor a)
{
    RemoveEffect(a);
    Super.OnRemoved(a);
}

function RemoveEffect(Actor a)
{
    local PlayerController pc;
    pc = PlayerController(Pawn(a).Controller);

    set = GetCinematicPostProcessSettings(pc.MyHUD);
    set.ColorGrading_LookupTable = None;
    set.bEnableDOF = false;
    if (MaterialEffect != None)
    {
        MaterialEffect.SetMaterial(None);
        MaterialEffectInstance = None;
    }

        LocalPlayer(pc.Player).OverridePostProcessSettings(set);

    if (randInt == 12)
    {
        Hat_HUD(pc.MyHUD).SetMaterialEffectActive('Pixelated_Simple', false);
        Hat_HUD(pc.MyHUD).SetMaterialEffectActive('RetroHandheld', false);
        class'Hat_HUDElementNostalgia'.static.SubtractUse(pc.MyHUD, "RetroHandheld");
    }
    else if (randInt == 13)
    {
        Hat_HUD(pc.MyHUD).SetMaterialEffectActive('Pixelated_Simple2', false);
        Hat_HUD(pc.MyHUD).SetMaterialEffectActive('VirtualGirl', false);
        class'Hat_HUDElementNostalgia'.static.SubtractUse(pc.MyHUD, "RedtroVR");
    }
    else if (randInt == 14)
    {
        pc.ConsoleCommand("SCALE TRANSIENTTEXLOD " $ "World" $ " " $ -1);
        pc.ConsoleCommand("SCALE TRANSIENTTEXLOD " $ "WorldNormalMap" $ " " $ -1);
        Hat_HUD(pc.MyHUD).SetMaterialEffectActive('Pixelated', false);
        class'Hat_HUDElementNostalgia'.static.SubtractUse(pc.MyHUD, "Nostalgia");
    }
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        SetPostProcessSettings(Pawn(Owner));
    }

    return true;
}

function CleanUp()
{
    Super.CleanUp();
}

function PostProcessSettings GetCinematicPostProcessSettings(HUD H)
{
    return class'Hat_CamMode_InstantCamera'.static.GetCinematicPostProcessSettings();
}

function SetPostProcessSettings(Pawn pawn)
{
    local LocalPlayer p;
    local HUD H;

    h = PlayerController(pawn.Controller).MyHUD;
    p = LocalPlayer(H.PlayerOwner.Player);	

    if(Mat != None && MaterialEffectInstance != None)
    {
        MaterialEffect = MaterialEffect(LocalPlayer(H.PlayerOwner.Player).PlayerPostProcess.FindPostProcessEffect(PostProcessMaterialEffectName));
        if (MaterialEffect != None)
        {
            MaterialEffect.bShowInGame = Mat != None; 
            if(MaterialEffect.bShowInGame)
            {
                if (MaterialEffectInstance != None)
                {
                    MaterialEffect.SetMaterial(MaterialEffectInstance);
                }
            }
            else
            {
                MaterialEffect.SetMaterial(None);
                MaterialEffectInstance = None;
            }
        }
    }
    p.OverridePostProcessSettings(set);
}