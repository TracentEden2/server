-----------------------------------
-- Area: Cloister of Flames
-- Mob: Fire Elemental
-- Quest: Waking the Beast
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    mob:setMod(xi.mod.UDMGPHYS, -2500)
    mob:setMod(xi.mod.FIRE_ABSORB, 100) -- x
    mob:setMod(xi.mod.FIRE_RES_RANK, 0) -- x
    mob:addImmunity(xi.immunity.LIGHT_SLEEP) -- x
    mob:addImmunity(xi.immunity.DARK_SLEEP) -- x
    mob:addImmunity(xi.immunity.SILENCE) -- x
    mob:addImmunity(xi.immunity.STUN) -- x
    mob:setMobMod(xi.mobMod.SKIP_ALLEGIANCE_CHECK, 1)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1) -- x
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.PLAGUE, { chance = 10, power = 50 })
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity