class Crowd_StatusEffect_ReverseControls extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration = 20;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    if (Hat_Player(a) != None)
    {
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.MoveForwardSpeed=-1200;
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.MoveStrafeSpeed=-1200;
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.InvertTurn();
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.InvertMouse();
    }
}

simulated function OnRemoved(Actor a)
{
    if (Hat_Player(a) != None)
    {
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.MoveForwardSpeed=1200;
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.MoveStrafeSpeed=1200;
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.InvertTurn();
        Hat_PlayerController(Hat_Player(a).Controller).PlayerInput.InvertMouse();
    }
    Super.OnRemoved(a);
}

function bool Update(float delta)
{
    if (!Super.Update(delta)) return false;
    
    if (Hat_Player(Owner) != None)
    {
        Hat_PlayerController(Hat_Player(Owner).Controller).PlayerInput.MoveForwardSpeed=-1200;
        Hat_PlayerController(Hat_Player(Owner).Controller).PlayerInput.MoveStrafeSpeed=-1200;
    }

    return true;
}