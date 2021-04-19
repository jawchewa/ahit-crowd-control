
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
    if (!CannotSpawn(Hat_Player(Owner)))
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
    if(!CannotSpawn(Hat_Player(Owner)))
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

function bool CannotSpawn(Hat_Player player)
{
	local Hat_PlayerController cont;

	if (player.Health <= 0) return true;
	if (player.Health <= 0) return true;
	if (player.bWaitingForCaveRiftIntro) return true;
	if (player.IsTaunting()) return true;
	if (player.IsNewItemState()) return true;
	if (player.MyDoor != None) return true;
	if (player.bHidden && !player.bCollideWorld && !player.bBlockActors) return true;
	if (player.bHidden && player.CanTakeDamage(false)) return true;
	if (player.SwampSinkProgress > 0.75) return true;
	// note: there's no way to hook bosses pushing you away that doesn't also hook bonking into a wall, so just don't get shoved!
	if (player.HasStatusEffect(class'Hat_StatusEffect_FreezeMovement', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Scared', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_Stoning', true)) return true;
	if (player.HasStatusEffect(class'Hat_StatusEffect_FallHurtTransition', true)) return true;

	cont = Hat_PlayerController(player.Controller);
	if (cont == None) return true;
	if (cont.IsTalking()) return true;
    if (cont.bCinematicMode) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementActTitleCard')) return true;
	if (Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDElementLoadingScreen')) return true;
	if (Hat_HUD(cont.MyHUD).ElementsDisablesMovement() && !Hat_HUD(cont.myHUD).IsHUDEnabled('Hat_HUDMenu_SwapHat')) return true;

	return false;
}