// Status Effect that halves the strenth of gravity for the player, so they can jump twice as high.
class Crowd_StatusEffect_HalfGravity extends Crowd_StatusEffect_DoubleGravity;

defaultproperties
{
    Duration = 30;
    GravityScaling = 0.5;
}