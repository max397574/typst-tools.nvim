---@diagnostic disable: unused-local
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet

local function reuse(idx)
    return f(function(args)
        return args[1][1]
    end, { idx })
end

local snippets = {}

function snippets.colors()
    ls.add_snippets("typst", {
        s("red", fmt("#text(red)[{}]", { i(1) })),
        s("blue", fmt("#text(blue)[{}]", { i(1) })),
        s("green", fmt("#text(green)[{}]", { i(1) })),
        s("orange", fmt("#text(orange)[{}]", { i(1) })),
        s("yellow", fmt("#text(yellow)[{}]", { i(1) })),
        s("color", fmt("#text({})[{}]", { i(1, "red"), i(2) })),
    })
end

local general_snippets = {}

function general_snippets.setup(config)
    for _, module in ipairs(config.modules) do
        snippets[module]()
    end
end

return general_snippets
