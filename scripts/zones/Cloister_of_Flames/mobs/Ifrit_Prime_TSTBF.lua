-----------------------------------
-- Area: Cloister of Flames
--  Mob: Ifrit Prime
-- Involved in Quest: Trial Size Trial by Fire
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
local entity = {}

entity.onMobSpawn = function(mob)
    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            { id = 848, hpp = math.random(30, 55) }, -- uses Inferno once while near 50% HPP.
        },
    })

    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
    mob:setMobMod(xi.mobMod.SIGHT_RANGE, 20)
    mob:setMobMod(xi.mobMod.MAGIC_RANGE, 40)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1) -- x
    mob:setMod(xi.mod.FIRE_ABSORB, 100) -- x
    -- reduce res rank so avatar can absorb significant amounts from spells
    mob:setMod(xi.mod.FIRE_RES_RANK, 0) -- x
    mob:setMod(xi.mod.UDMGPHYS, -6000) -- x
    mob:setMod(xi.mod.UDMGRANGE, -6000) -- x
    -- online videos show that 24/27 SL were unresisted on retail
    -- this reduction in MEVA roughly gives roughly the correct resist rate
    mob:addMod(xi.mod.LIGHT_MEVA, -35) -- x

    mob:addImmunity(xi.immunity.BLIND) -- x
    mob:addImmunity(xi.immunity.SLOW) -- x
    mob:addImmunity(xi.immunity.PARALYZE) -- x
    mob:addImmunity(xi.immunity.GRAVITY) -- x
    mob:addImmunity(xi.immunity.BIND) -- x
    mob:addImmunity(xi.immunity.SILENCE) -- x
    mob:addImmunity(xi.immunity.LIGHT_SLEEP) -- x
    mob:addImmunity(xi.immunity.DARK_SLEEP) -- x
    mob:addImmunity(xi.immunity.TERROR) -- x
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.ENFIRE, { chance = 100, power = math.random(15, 25) }) -- x
end

entity.onMobEngage = function(mob, target)
    -- always uses a tp move when first engaged
    mob:setTP(3000)
end

entity.onMobFight = function(mob, target)
end

entity.onMobDeath = function(mob, player, optParams)
end

return entity
