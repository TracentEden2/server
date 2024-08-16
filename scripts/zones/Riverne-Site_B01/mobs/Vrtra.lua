-----------------------------------
-- Area: Riverne Site B01
-- Note: Weaker version of Vrtra summoned by Bahamut during The Wyrmking Descends
-----------------------------------
require("scripts/globals/quests")
require("scripts/globals/follow")
-----------------------------------
local entity = {}

local petIDOffsets = { 7, 9, 11, 8, 10, 12 }

entity.onMobSpawn = function(mob)
    mob:setMobMod(xi.mobMod.GA_CHANCE, 75)
    mob:setMod(xi.mod.DEF, 466)
    mob:setMod(xi.mod.ATT, 344)
    mob:setMod(xi.mod.EVA, 450)
    mob:setMod(xi.mod.UFASTCAST, 50)
    mob:setMod(xi.mod.DARK_MEVA, 100)
    mob:setMobMod(xi.mobMod.NO_STANDBACK, 1)
    mob:setMod(xi.mod.UDMGRANGE, -5000)
    mob:setMod(xi.mod.UDMGMAGIC, -5000)
    mob:setMod(xi.mod.UDMGBREATH, -5000)
    mob:setMod(xi.mod.MATT, 75)
    mob:setMobMod(xi.mobMod.SIGHT_RANGE, 30)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
end

entity.onMobEngaged = function(mob, target)
    mob:setLocalVar("addSpawnTime", 0)
    mob:setLocalVar("charmTime", 0)
    -- if engaged then send pets at target
    for i, petIDOffset in ipairs(petIDOffsets) do
        local pet = GetMobByID(mob:getID() + petIDOffset)
        if pet:isAlive() then
            pet:updateEnmity(mob:getTarget())
        end
    end
end

entity.onMobFight = function(mob, target)
    local addSpawnTime = mob:getLocalVar("addSpawnTime")
    local charmTime = mob:getLocalVar("charmTime")
    local battleTime = mob:getBattleTime()

    if charmTime == 0 then
        mob:setLocalVar("charmTime", battleTime + math.random(3, 7))
    end

    if addSpawnTime == 0 then
        mob:setLocalVar("addSpawnTime", battleTime + math.random(9, 15))
    end

    if
        battleTime > charmTime and
        mob:checkDistance(target) < 17 and
        mob:canUseAbilities()
    then
        -- need to fix so charm does not reset tp!!
        mob:useMobAbility(710)
        -- Spams Charm in bv2 version roughly every 5s
        -- (see https://youtu.be/YHBfqLpGsp0?t=544)
        mob:setLocalVar("charmTime", battleTime + math.random(3, 7))
    elseif battleTime > addSpawnTime + 10 then
        local mobId = mob:getID()

        for _, petIDOffset in ipairs(petIDOffsets) do
            local pet = GetMobByID(mobId + petIDOffset)

            if not pet:isSpawned() then
                mob:entityAnimationPacket("casm")
                mob:setAutoAttackEnabled(false)
                mob:setMagicCastingEnabled(false)
                mob:setMobAbilityEnabled(false)

                mob:timer(3000, function(mobArg)
                    if mobArg:isAlive() then
                        mobArg:entityAnimationPacket("shsm")
                        mobArg:setAutoAttackEnabled(true)
                        mobArg:setMagicCastingEnabled(true)
                        mobArg:setMobAbilityEnabled(true)
                        pet:spawn()
                        local pos = mobArg:getPos()
                        pet:setPos(pos.x, pos.y, pos.z)
                        local options = { followDistance = 0.0 }
                        xi.follow.follow(pet, mobArg, options)
                        if mobArg:getTarget() ~= nil then
                            pet:updateEnmity(target)
                        end
                    end
                end)

                break
            end
        end

        mob:setLocalVar("addSpawnTime", battleTime + 4)
    end
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.ENDARK, { power = math.random(45, 90), chance = 10 })
end

entity.onMobDeath = function(mob, player, optParams)
    if mob:getLocalVar("deathTrigger") == 0 then
        -- if vrtra dies then kill all pets
        local mobId = mob:getID()
        for i, petIDOffset in ipairs(petIDOffsets) do
            local pet = GetMobByID(mobId + petIDOffset)
            if pet:isAlive() then
                pet:setHP(0)
            end
        end

        mob:setLocalVar("deathTrigger", 1)
    end
end

return entity
