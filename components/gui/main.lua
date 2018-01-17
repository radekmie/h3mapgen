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
        {id = 1, team = 1, computerOnly = false},
        {id = 2, team = 2, computerOnly = false},
        {id = 3, team = 3, computerOnly = false},
        {id = 4, team = 4, computerOnly = false},
        {id = 5, team = 5, computerOnly = false},
        {id = 6, team = 6, computerOnly = false},
        {id = 7, team = 7, computerOnly = false},
        {id = 8, team = 8, computerOnly = false}
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
    -- TODO: Players component.
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

        -- TODO: Players component.
        if key == 'players' then
            input = {type = 'text', value = model[key]}
        end

        if input.type == nil then
            value = input.selected.exact
        end

        if input.type == 'check' then
            value = input.value
        end

        if input.type == 'text' then
            value = input.value
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
