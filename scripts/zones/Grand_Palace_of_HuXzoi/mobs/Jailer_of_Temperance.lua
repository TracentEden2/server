-----------------------------------
-- Area: Grand Palace of Hu'Xzoi
--   NM: Jailer of Temperance
-----------------------------------
local huxzoiGlobal = require('scripts/zones/Grand_Palace_of_HuXzoi/globals')
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

local useOpticInduration = function(mob)
    -- do not do any other attacks or abilities
    -- between the pair of optic indurations
    mob:setAutoAttackEnabled(false)
    mob:setMobAbilityEnabled(false)

    -- start the second optic induration a few seconds after the first
    mob:timer(3000, function(mobArg)
        if mobArg:isAlive() then
            mobArg:useMobAbility(xi.mobSkill.OPTIC_INDURATION)
        end
    end)

    -- set opticCounter back to 0 and set back to normal after the second optic induration
    -- use a timer here so everything resets even if optic induration is interrupted
    -- (cannot use onMobWeaponSkill because it is not called after an interruption)
    mob:timer(6500, function(mobArg)
        if mobArg:isAlive() then
            mobArg:setLocalVar('opticCounter', 0)
            mobArg:setAutoAttackEnabled(true)
            mobArg:setMobAbilityEnabled(true)
        end
    end)
end

local changeToPot = function(mob)
    mob:setMod(xi.mod.HTH_SDT, 1000)
    mob:setMod(xi.mod.SLASH_SDT, 0)
    mob:setMod(xi.mod.PIERCE_SDT, 0)
    mob:setMod(xi.mod.IMPACT_SDT, 1000)
end

local changeToPoles = function(mob)
    mob:setMod(xi.mod.HTH_SDT, 0)
    mob:setMod(xi.mod.SLASH_SDT, 0)
    mob:setMod(xi.mod.PIERCE_SDT, 1000)
    mob:setMod(xi.mod.IMPACT_SDT, 0)
end

local changeToRings = function(mob)
    mob:setMod(xi.mod.HTH_SDT, 0)
    mob:setMod(xi.mod.SLASH_SDT, 1000)
    mob:setMod(xi.mod.PIERCE_SDT, 0)
    mob:setMod(xi.mod.IMPACT_SDT, 0)
end

-- animationSub for different forms: 1 = Pot, 2 = Poles, 3 = Rings
-- table index is animationSub for current form and table entries for that index are
-- valid forms to change into with the structure { newFormAnimationSub, newFormChangeFunction }
local changeFormTable = {
    [1] = { { 2, changeToPoles }, { 3, changeToRings } },
    [2] = { { 1, changeToPot }, { 3, changeToRings } },
    [3] = { { 1, changeToPot }, { 2, changeToPoles } },
}

-- list of all available forms so can randomly select from them at spawn
local allFormTable = { { 1, changeToPot }, { 2, changeToPoles }, { 3, changeToRings } }

entity.onMobSpawn = function(mob)
    xi.mix.jobSpecial.config(mob, {
        specials =
        {
            {
                id = xi.jsa.MEIKYO_SHISUI,
                hpp = math.random(65, 75),
                endCode = function(mobArg)
                    mobArg:setLocalVar('twoHour', 1)
                end
            },
        },
    })

    -- select initial form at random
    local initialForm = allFormTable[math.random(1, 3)]
    mob:setAnimationSub(initialForm[1])
    local changeFunction = initialForm[2]
    changeFunction(mob)

    -- always takes no damage from direct magic
    mob:setMod(xi.mod.UDMGMAGIC, -10000)
    -- confirmed on retail that breath damage does not work
    mob:setMod(xi.mod.UDMGBREATH, -10000)
    mob:setAutoAttackEnabled(true)
    mob:setMobAbilityEnabled(true)
    -- 50% ATT boost
    mob:addMod(xi.mod.ATTP, 50)
    -- 10 EVA boost
    mob:addMod(xi.mod.EVA, 10)
    -- -50 DEF penalty
    mob:addMod(xi.mod.DEF, -50)
    mob:addImmunity(xi.immunity.BIND)
    mob:addImmunity(xi.immunity.STUN)
    mob:addImmunity(xi.immunity.SILENCE)
    mob:addImmunity(xi.immunity.PARALYZE)
    mob:addImmunity(xi.immunity.BLIND)
    mob:addImmunity(xi.immunity.SLOW)
    mob:addImmunity(xi.immunity.ELEGY)
    mob:addImmunity(xi.immunity.REQUIEM)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:addImmunity(xi.immunity.DARK_SLEEP)
    mob:addImmunity(xi.immunity.TERROR)
    mob:setSpeed(60)
end

entity.onMobEngage = function(mob, target)
    -- captures show the change time can range from 1 min to at least 6 mins
    mob:setLocalVar('changeTime', os.time() + math.random(60, 360))
end

entity.onMobFight = function(mob)
    local changeTime = mob:getLocalVar('changeTime')
    local isBusy = false

    -- we do not want to change forms while charging optic induration
    local act = mob:getCurrentAction()
    if
        act == xi.act.MOBABILITY_START or
        act == xi.act.MOBABILITY_USING or
        act == xi.act.MOBABILITY_FINISH or
        mob:getLocalVar('opticCounter') == 1
    then
        isBusy = true
    end

    -- if time to change form and not busy
    if
        os.time() > changeTime and
        not isBusy
    then
        -- select a valid form to change into from current form
        local changeTableEntry = changeFormTable[mob:getAnimationSub()][math.random(1, 2)]

        -- set the animation of the new form
        mob:setAnimationSub(changeTableEntry[1])
        local changeFunction = changeTableEntry[2]
        -- call the function to set mods for the new form
        changeFunction(mob)
        -- captures show the change time can range from 1 min to at least 6 mins
        mob:setLocalVar('changeTime', os.time() + math.random(60, 360))
    end

    -- Jailer of Temperance uses second two hour around 40%
    if mob:getHPP() < 40 and mob:getLocalVar('twoHour') == 1 then
        mob:useMobAbility(xi.jsa.MEIKYO_SHISUI)
        mob:setLocalVar('twoHour', 2)
    end
end

entity.onMobWeaponSkill = function(target, mob, skill)
    -- if just used optic induration
    if skill:getID() == xi.mobSkill.OPTIC_INDURATION then
        -- and it was the first optic induration of the pair
        if mob:getLocalVar('opticCounter') == 0 then
            -- increment counter
            mob:setLocalVar('opticCounter', 1)
            -- and start the logic for the second optic induration
            useOpticInduration(mob)
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
end

entity.onMobDespawn = function(mob)
    local ph = mob:getLocalVar('ph')
    DisallowRespawn(mob:getID(), true)
    DisallowRespawn(ph, false)
    GetMobByID(ph):setRespawnTime(GetMobRespawnTime(ph))
    mob:setLocalVar('pop', os.time() + 900) -- 15 mins
    huxzoiGlobal.pickTemperancePH()
end

return entity
