-- Instead of LUA_PATH
package.path = package.path .. ';luigi/?.lua'

local function choose (name, label, options)
    local buttons = {flow = 'x'}
    for _, option in ipairs(options) do
        buttons[_] = {
            type = 'radio',
            text = tostring(option),
            group = name
        }
    end

    return {
        flow = 'x',
        {type = 'label', text = label},
        buttons
    }
end

local function number (name, label, initial)
    return {
        flow = 'x',
        {type = 'label', text = label},
        {type = 'text', text = tostring(initial)}
    }
end

local function option (name, label, initial)
    return {
        flow = 'x',
        {type = 'label', text = label},
        {type = 'check'}
    }
end

local Layout = require('luigi.layout')
local layout = Layout({
    id = 'h3mapgen',
    type = 'panel',
    padding = 10,
    choose('version', 'Version', {'RoE', 'SoD'}),
    number('seed', 'Seed', 0),
    choose('size', 'Map size', {'S', 'M', 'L', 'XL'}),
    option('underground', 'Two level map', false),
})

layout:setTheme(require('luigi.theme.light'))
layout:show()
