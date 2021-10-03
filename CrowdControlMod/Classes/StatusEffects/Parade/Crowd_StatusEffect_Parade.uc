// Give the Player a parade of owls to follow them for the next 30 seconds. (Similar to The Big Parade mission from Chapter 2)
// Based on the code from the Parade Badge Mod: https://steamcommunity.com/sharedfiles/filedetails/?id=1531502590
class Crowd_StatusEffect_Parade extends Crowd_StatusEffect_Persistent;

var int MaxBirdCount;
var Array<Crowd_Enemy_Band> birds;
var int currentBird;

defaultproperties
{
    MaxBirdCount = 15
    Duration = 30
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
    Owner.SetTimer(0.2, false, NameOf(IntroTimer), self);
}

simulated function OnRemoved(Actor a)
{
    local Crowd_Enemy_Band bird;

    foreach birds(bird) {
        bird.Destroy();
    }
    currentBird = 0;
    Super.OnRemoved(a);
}

function IntroTimer()
{
    local Crowd_Enemy_Band bird;
    local int i;
    if (!class'Crowd_CrowdControl_Gamemod'.static.CannotGiveEffect(Hat_Player(Owner)))
    {
        bird = Owner.Spawn(class'Crowd_Enemy_Band',,,Owner.Location - vector(Owner.Rotation) * 300);
        bird.MimicDelay = 0.75;
        bird.SetMimickActor(Hat_Player(Owner));
        bird.SetHidden(true);
        bird.Active = false;
        birds.addItem(bird);
        for(i = 0; i < MaxBirdCount-1; i++)
        {
            bird = Owner.Spawn(class'Crowd_Enemy_Band',,,birds[birds.length - 1].Location);
            bird.TouchDamageType = None;
            bird.FrontBandMember = birds[birds.length - 1];
            bird.Active = false;
            bird.MimicDelay = birds.length * 0.75 + 0.75;
            bird.SetMimickActor(Hat_Player(Owner));
            bird.SetHidden(true);
            bird.SetDrawScale(0);
            birds.addItem(bird);
        }

        Owner.SetTimer(0.75, true, NameOf(SpawnBird), self);
    }
}

function SpawnBird()
{
    if(currentBird >= birds.length)
    {
        Owner.Cleartimer(NameOf(SpawnBird), self);

        return;
    }
    if(!class'Crowd_CrowdControl_Gamemod'.static.CannotGiveEffect(Hat_Player(Owner)))
    {
        if(currentBird < birds.length)
        {
            birds[currentBird+1].SetHidden(false);
            birds[currentBird].SetDrawScale(1);
        }
        birds[currentBird].SetHidden(false);
        birds[currentBird].SetDrawScale(1);
        birds[currentBird].TouchDamageType = class'Hat_DamageType_Shove';

        birds[currentBird].Active = true;
        currentBird++;
    }
}