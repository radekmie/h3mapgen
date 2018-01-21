-- Instead of LUA_PATH
package.path = package.path .. ';libs/?.lua;luigi/?.lua'

local Serialization = require('Serialization')

-- Defaults
local model = {
    branching = 0,
    focus = 0,
    grail = false,
    locations = 0,
    monsters = 0,
    players = {
        {id = 1, enabled = true,  team = 1, computerOnly = false},
        {id = 2, enabled = true,  team = 2, computerOnly = false},
        {id = 3, enabled = true,  team = 3, computerOnly = false},
        {id = 4, enabled = true,  team = 4, computerOnly = false},
        {id = 5, enabled = false, team = 5, computerOnly = false},
        {id = 6, enabled = false, team = 6, computerOnly = false},
        {id = 7, enabled = false, team = 7, computerOnly = false},
        {id = 8, enabled = false, team = 8, computerOnly = false}
    },
    seed = 0,
    size = 'S',
    towns = 0,
    transitivity = 0,
    underground = false,
    version = 'RoE',
    water = 0,
    welfare = 0,
    winning = 0,
    zonesize = 0
}

-- Controls
local function bool (name, label)
    return {
        flow = 'x',
        {type = 'label', align = 'right', width = 130, text = label},
        {type = 'check', value = model[name], id = name}
    }
end

local function input (name, label)
    return {
        flow = 'x',
        {type = 'label', align = 'right', width = 130, text = label},
        {type = 'text', text = tostring(model[name]), id = name}
    }
end

local function playersComputerOnly ()
    local items = {flow = 'x', {type = 'label', align = 'right', width = 130, text = 'Computer only'}}

    for id = 1, 8 do
        items[id + 1] = {type = 'check', align = 'center', id = 'players.' .. id .. '.computerOnly', value = model.players[id].computerOnly}
    end

    return items
end

local function playersEnabled ()
    local items = {flow = 'x', {type = 'label', align = 'right', width = 130, text = 'Enabled'}}

    for id = 1, 8 do
        items[id + 1] = {type = 'check', align = 'center', id = 'players.' .. id .. '.enabled', value = model.players[id].enabled}
    end

    return items
end

local function playersLabels ()
    local items = {flow = 'x', {type = 'label', align = 'right', width = 130, text = 'Players'}}

    for id = 1, 8 do
        items[id + 1] = {type = 'label', align = 'center', text = tostring(id)}
    end

    return items
end

local function playersTeam ()
    local items = {flow = 'x', {type = 'label', align = 'right', width = 130, text = 'Team'}}

    for id = 1, 8 do
        -- TODO: Stepper resets its value.
        items[id + 1] = {type = 'stepper', align = 'center', id = 'players.' .. id .. '.team', index = model.players[id].team}

        for team = 1, 8 do
            items[id + 1][team] = {value = team, text = tostring(team)}
        end
    end

    return items
end

local function radio (name, label, bools, labelsAsValues)
    local buttons = {flow = 'x'}
    for index, bool in ipairs(bools) do
        local label = bool.label or bool
        local value

        if labelsAsValues then
            value = label
        else
            value = bool.value or (index - 1)
        end

        buttons[index] = {
            type = 'radio',
            text = label,
            exact = value,
            group = name,
            value = value == model[name],
            width = false
        }
    end

    return {
        flow = 'x',
        {type = 'label', align = 'right', width = 130, text = label},
        buttons
    }
end

-- Layout
local Layout = require('luigi.layout')
local layout = Layout({
    id = 'h3mapgen',
    type = 'panel',
    padding = 10,
    radio('version', 'Version', {'RoE', 'SoD'}, true),
    input('seed', 'Seed'),
    radio('size', 'Map size', {'S', 'M', 'L', 'XL'}, true),
    bool('underground', 'Two level map'),
    playersLabels(),
    playersEnabled(),
    playersTeam(),
    playersComputerOnly(),
    radio('winning', 'Winning condition', {'Random', 'Defeat all your enemies', 'Capture Town', 'Defeat Monster', 'Acquire Artifact or Defeat All Enemies', 'Build a Grail Structure or Defeat All Enemies'}),
    radio('water', 'Water', {'Random', 'None', 'Low (lakes, seas)', 'Standard (continents)', 'High (islands)'}),
    bool('grail', 'Map contains Grail'),
    radio('towns', 'Towns frequency', {'Random', 'Very rare', 'Rare', 'Normal', 'Common', 'Very common'}),
    radio('monsters', 'Monster Strength', {'Random', 'Very weak', 'Weak', 'Medium', 'Strong', 'Very strong'}),
    radio('welfare', 'Welfare', {'Random', 'Very poor', 'Poor', 'Medium', 'Rich', 'Very rich'}),
    radio('branching', 'Branching', {'Random', 'All zones contain as small number of entrances as possible', 'Most zones contain only minimal number of entrances', 'Some zones contain multiple entrances, some not', 'Most zones contain multiple entrances', 'All zones contain multiple entrances'}),
    radio('focus', 'Challenge focus', {'Random', 'Strong PvP', 'More PvP', 'Balanced', 'More PvE', 'Strong PvE'}),
    radio('transitivity', 'Transitivity', {'Random', 'Strongly mazelike zones', 'More zones containing mazelike style', 'Zones containing various styles', 'More zones containing open terrain', 'Strongly open terrain zones'}),
    radio('locations', 'Locations frequency', {'Random', 'Very rare', 'Rare', 'Standard', 'Common', 'Very common'}),
    radio('zonesize', 'Zone size', {'Random', 'Strongly decreased', 'Decreased', 'Standard', 'Increased', 'Strongly increased'}),
    {
        id = 'submit',
        type = 'button',
        text = 'Generate'
    }
})

local function serialize ()
    local result = {}

    for key, _ in pairs(model) do
        local input = layout[key]
        local value

        if key == 'players' then
            value = {}

            for id = 1, 8 do
                value[#value + 1] = {
                    id = id,
                    computerOnly = layout['players.' .. id .. '.computerOnly'].value,
                    enabled = layout['players.' .. id .. '.enabled'].value,
                    team = layout['players.' .. id .. '.team'].value
                }
            end
        elseif input.type == nil then
            value = input.selected.exact
        elseif input.type == 'check' then
            value = input.value
        elseif input.type == 'text' then
            value = input.value
        else
            error('Unhandled field: ' .. key)
        end

        result[key] = value
    end

    return result
end

layout.submit:onPress(function ()
    print((Serialization.Table(serialize())))
end)

-- Start
layout:setTheme(require('luigi.theme.light'))
layout:show()

-- TODO: Stepper resets its value.
for id = 1, 8 do
    local stepper = layout['players.' .. id .. '.team']

    stepper[2][1] = nil
    stepper[2]:addChild(stepper.items[model.players[id].team])
end
