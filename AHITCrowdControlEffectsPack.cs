using System;
using System.Collections.Generic;
using CrowdControl.Common;
using CrowdControl.Games.Packs;
using ConnectorType = CrowdControl.Common.ConnectorType;

public class AHITCrowdControlEffectsPack : SimpleTCPPack
{
    public override string Host => "127.0.0.1";

    public override ushort Port => 1452;

    public AHITCrowdControlEffectsPack(IPlayer player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

    public override Game Game => new Game(42, "A Hat in Time", "ahit", "PC", ConnectorType.SimpleTCPConnector);

    public override List<Effect> Effects => new List<Effect>
    {
        new Effect("Give Health", "heal"),
        new Effect("Take Damage", "damage"),
        new Effect("Kill", "kill"),
        new Effect("Make Invincible (15 sec)", "make_invincible"),
        new Effect("One Hit Hero (20 sec)", "one_hit_hero"),
        new Effect("Increase Gravity (20 sec)", "increase_gravity"),
        new Effect("Decrease Gravity (30 sec)", "decrease_gravity"),
        new Effect("Wind (15 sec)", "wind"),
        new Effect("Spring World (10 sec)", "spring_bounce"),
        new Effect("Give Triple Jump (25 sec)", "give_triple_jump"),
        new Effect("Disable Jump (7 sec)", "disable_jump"),
        new Effect("Disable Double Jump (15 sec)", "disable_double_jump"),
        new Effect("Disable Weapon (15 sec)", "disable_weapon"),
        new Effect("Lose Hat (20 sec)", "lose_hat"),
        new Effect("Babysitting (20 sec)", "babysit"),
        new Effect("Parade (30 sec)", "parade_owls"),
        new Effect("Go Fast (30 sec)", "go_fast"),
        new Effect("Go Slow (20 sec)", "go_slow"),
        new Effect("Force Time Stop (20 sec)", "time_stop"),
        new Effect("Force Dweller Sphere (10 sec)", "dweller_sphere"),
        new Effect("Force Ice Statue (10 sec)", "ice_statue"),
        new Effect("Shrink (30 sec)", "shrink"),
        new Effect("Grow (30 sec)", "grow"),
        new Effect("Make Invisible (20 sec)", "make_invisible"),
        new Effect("Random Filter (30 sec)", "random_filter"), 
        new Effect("First Person (30 sec)", "first_person"),
        new Effect("Reverse Controls (20 sec)", "reverse_controls"),
        new Effect("Mirror Mode (30 sec)", "mirror_mode"),
        new Effect("Give Random Timepiece", "give_timepiece"),
        new Effect("Take Random Timepiece", "take_timepiece"),
    };
}
