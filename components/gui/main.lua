-- Instead of LUA_PATH
package.path = package.path .. ';libs/?.lua;luigi/?.lua'

local Serialization = require('Serialization')

-- Defaults
local model = {
    version = 'RoE',
    seed = 0,
    size = 'S',
    underground = false
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
