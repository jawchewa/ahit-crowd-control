class Crowd_StatusEffect_OneHitHero extends Crowd_StatusEffect_Persistent;

defaultproperties
{
    Duration=20;
}

function OnAdded(Actor a)
{
    Super.OnAdded(a);
	if (Hat_Player(a) != None)
    {
        Hat_InventoryManager(Hat_Player(a).InvManager).CreateInventory(class'Crowd_Badge_OneHitDeath');
    }
}

simulated function OnRemoved(Actor a)
{    
    local Hat_InventoryManager inv;
	if (Hat_Player(a) != None)
    {
        inv = Hat_InventoryManager(Hat_Player(a).InvManager);

        inv.RemoveFromInventory(inv.FindInventoryType(class'Crowd_Badge_OneHitDeath'));
    }
    Super.OnRemoved(a);
}