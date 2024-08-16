-----------------------------------
-- Area: Riverne Site #B01
-- Name: The Wyrmking Descends
-- !pos -612.800 1.750 693.190 29
-----------------------------------
local riverneID = zones[xi.zone.RIVERNE_SITE_B01]
-----------------------------------

local content = Battlefield:new({
    zoneId        = xi.zone.RIVERNE_SITE_B01,
    battlefieldId = xi.battlefield.id.WYRMKING_DESCENDS,
    maxPlayers    = 18,
    levelCap      = 75,
    timeLimit     = utils.minutes(30),
    index         = 1,
    area          = 1,
    entryNpc      = 'Unstable_Displacement',
    exitNpc       = 'SD_BCNM_Exit',
    requiredItems =
    { 
        xi.item.MONARCHS_ORB, 
        wearMessage = riverneID.text.TIME_LIMIT_FOR_THIS_BATTLE_IS + 2, 
        wornMessage = riverneID.text.TIME_LIMIT_FOR_THIS_BATTLE_IS + 1,
    },
    grantXP          = 1500,
})

content:addEssentialMobs({ 'Bahamutv2' })

content.groups =
{
    {
        mobIds =
        {
            riverneID.mob.BAHAMUTV2,
        },

        allDeath = utils.bind(content.handleAllMonstersDefeated, content),
    },
    {
        mobs = { 'Ouryu' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Tiamat' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Jormungand' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Vrtra' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Ziryu' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Water_Elemental' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Earth_Elemental' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Pey' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Iruci' },
        superlink = true,
        spawned = false,
    },
    {
        mobs = { 'Airi' },
        superlink = true,
        spawned = false,
    },
}

content.loot =
{
    {
        { item =    0, weight = 950 }, -- Nothing
        { item = 1842, weight =  50 }, -- Cloud Evoker
    },
    {
        { item =     0, weight = 500 }, -- Nothing
        { item = 15433, weight = 250 }, -- Reverend Sash
        { item = 15434, weight = 250 }, -- Vanguard Belt
    },
    {
        { item =     0, weight = 350 }, -- Nothing
        { item = 13550, weight = 200 }, -- Crossbowman's Ring
        { item = 14675, weight = 150 }, -- Woodsman Ring
        { item = 13549, weight = 300 }, -- Ether Ring
    },
}

return content:register()