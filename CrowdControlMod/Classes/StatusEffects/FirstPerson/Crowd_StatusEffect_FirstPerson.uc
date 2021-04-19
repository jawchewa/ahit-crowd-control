class Crowd_StatusEffect_FirstPerson extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 30;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    if (Hat_Player(a) != None)
    {
        SetCamera(Hat_PlayerController(Hat_Player(a).Controller));
    }
}

simulated function OnRemoved(Actor a)
{
    Super.OnRemoved(a);
    
    if (Hat_Player(a) != None)
    {
        RemoveCamera(Hat_PlayerController(Hat_Player(a).Controller));
    }
}

function SetCamera(Hat_PlayerController controller)
{
    local Hat_PlayerCamera camera;

    camera = Hat_PlayerCamera(controller.PlayerCamera);
    camera.AddCameraModeClass(class'Crowd_CC_CamMode_FirstPerson');
    camera.RemoveCameraModeClass(class'Hat_CamMode_InWaterAngle');
    camera.RemoveCameraModeClass(class'Hat_CamMode_TurnCameraToFaceMovement');
    camera.RemoveCameraModeClass(class'Hat_CamMode_ForcedRotation');
    camera.RemoveCameraModeClass(class'Hat_CamMode_ForcedRotation_TwoPoints');
}

function RemoveCamera(Hat_PlayerController controller)
{
    local Hat_PlayerCamera camera;

    camera = Hat_PlayerCamera(controller.PlayerCamera);
    camera.RemoveCameraModeClass(class'Crowd_CC_CamMode_FirstPerson');
    camera.AddCameraModeClass(class'Hat_CamMode_InWaterAngle');
    camera.AddCameraModeClass(class'Hat_CamMode_TurnCameraToFaceMovement');
}