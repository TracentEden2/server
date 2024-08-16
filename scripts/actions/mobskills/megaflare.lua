-----------------------------------
--  Megaflare
--  Family: Bahamut
--  Description: Deals heavy Fire damage to enemies within a fan-shaped area.
--  Type: Magical
--  Utsusemi/Blink absorb: Wipes shadows
--  Notes: Used by Bahamut when at 90%, 80%, 70%, 60%, 50%, 40%, 30%, 20% HP
--  Notes: Used by BahamutV2 when at 90%, 80%, 70% HP
--  Notes: No evidence that either Bahamut can use it at will
--  Notes: See (Bv1 https://youtu.be/da2ox_Wu374?t=5002 and Bv2 https://youtu.be/5uoWLnYtQGM)
-----------------------------------
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 1
end

mobskillObject.onMobWeaponSkill = function(target, mob, skill)
    -- Mob logic. TODO: Remove from here
    mob:setLocalVar('MegaFlareQueue', mob:getLocalVar('MegaFlareQueue') - 1)
    mob:setLocalVar('FlareWait', 0)
    mob:setLocalVar('tauntShown', 0)

    mob:setMobAbilityEnabled(true) -- re-enable the other actions on success

    if bit.band(mob:getBehaviour(), xi.behavior.NO_TURN) == 0 then -- re-enable noturn
        mob:setBehaviour(bit.bor(mob:getBehaviour(), xi.behavior.NO_TURN))
    end

    -- Damage calculation
    local damage = mob:getWeaponDmg() * 10

    damage = xi.mobskills.mobMagicalMove(mob, target, skill, damage, xi.element.FIRE, 1, xi.mobskills.magicalTpBonus.NO_EFFECT)
    damage = xi.mobskills.mobFinalAdjustments(damage, mob, skill, target, xi.attackType.MAGICAL, xi.damageType.FIRE, xi.mobskills.shadowBehavior.WIPE_SHADOWS)

    target:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.FIRE)

    return damage
end

return mobskillObject
