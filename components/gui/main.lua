-- Instead of LUA_PATH
package.path = package.path .. ';libs/?.lua;luigi/?.lua'

local Serialization = require('Serialization')

-- Defaults
local model = {
    version = 'RoE',
    seed = 0,
    size = 'S',
    underground = false,
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
    winning = 'Random',
    water = 'Random',
    grail = false,
    towns = 'Random',
    monsters = 'Random',
    welfare = 'Random',
    branching = 'Random',
    focus = 'Random',
    transitivity = 'Random',
    locations = 'Random',
    zonesize = 'Random'
}

-- Controls
local function choose (name, label, options)
    local buttons = {flow = 'x'}
    for _, option in ipairs(options) do
        buttons[_] = {
            type = 'radio',
            text = tostring(option),
            group = name,
            value = option == model[name]
        }
    end

    return {
        flow = 'x',
        {type = 'label', text = label},
        buttons
    }
end

local function number (name, label)
    return {
        flow = 'x',
        {type = 'label', text = label},
        {type = 'text', text = tostring(model[name]), id = name}
    }
end

local function option (name, label)
    return {
        flow = 'x',
        {type = 'label', text = label},
        {type = 'check', value = model[name], id = name}
    }
end

-- Layout
local Layout = require('luigi.layout')
local layout = Layout({
    id = 'h3mapgen',
    type = 'panel',
    padding = 10,
    choose('version', 'Version', {'RoE', 'SoD'}),
    number('seed', 'Seed'),
    choose('size', 'Map size', {'S', 'M', 'L', 'XL'}),
    option('underground', 'Two level map'),
    -- TODO: Players component.
    choose('winning', 'Winning condition', {'Random', 'Defeat all your enemies', 'Capture Town', 'Defeat Monster', 'Acquire Artifact or Defeat All Enemies', 'Build a Grail Structure or Defeat All Enemies'}),
    choose('water', 'Water', {'Random', 'None', 'Low (lakes, seas)', 'Standard (continents)', 'High (islands)'}),
    option('grail', 'Map contains Grail.'),
    choose('towns', 'Towns frequency', {'Random', 'Very rare', 'Rare', 'Normal', 'Common', 'Very common'}),
    choose('monsters', 'Monster Strength', {'Random', 'Very weak', 'Weak', 'Medium', 'Strong', 'Very strong'}),
    choose('welfare', 'Welfare', {'Random', 'Very poor', 'Poor', 'Medium', 'Rich', 'Very rich'}),
    choose('branching', 'Branching', {'Random', 'All zones contain as small number of entrances as possible', 'Most zones contain only minimal number of entrances', 'Some zones contain multiple entrances, some not', 'Most zones contain multiple entrances', 'All zones contain multiple entrances'}),
    choose('focus', 'Challenge focus', {'Random', 'Strong PvP', 'More PvP', 'Balanced', 'More PvE', 'Strong PvE'}),
    choose('transitivity', 'transitivity', {'Random', 'Strongly mazelike zones', 'More zones containing mazelike style', 'Zones containing various styles', 'More zones containing open terrain', 'Strongly open terrain zones'}),
    choose('locations', 'Locations frequency', {'Random', 'Very rare', 'Rare', 'Standard', 'Common', 'Very common'}),
    choose('zonesize', 'Zone size', {'Random', 'Strongly decreased', 'Decreased', 'Standard', 'Increased', 'Strongly increased'}),
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
            value = input.selected.text
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
