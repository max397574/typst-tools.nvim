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

local rec_ls
rec_ls = function()
    return sn(nil, {
        c(1, {
            t({ "" }),
            sn(nil, { t({ "", "- " }), i(1), d(2, rec_ls, {}) }),
        }),
    })
end

local rec_tbl_cell
rec_tbl_cell = function()
    return sn(nil, {
        c(1, {
            t({ "" }),
            sn(nil, {
                c(1, { sn(nil, { t("["), i(1), t("],") }), sn(nil, { t("[$"), i(1), t("$],") }) }),
                d(2, rec_tbl_cell, {}),
            }),
        }),
    })
end

local snippets = {}
function snippets.general()
    ls.add_snippets("typst", {
        s(
            "fig",
            fmt(
                [[#figure(
    image("{}", width: 100%),
    caption: [{}],
  ) <{}>]],
                { i(1), i(2), i(3) }
            )
        ),
        s(
            "table",
            fmt(
                [[#table(
 columns: {},
 {}
)]],
                { i(1), d(2, rec_tbl_cell, {}) }
            )
        ),

        s("ls", {
            t("- "),
            i(1),
            d(2, rec_ls, {}),
        }),

        s({ trig = "table(%d+)x(%d+)", regTrig = true }, {
            d(1, function(args, snip)
                local nodes = {
                    t({ "#table(", "" }),
                    t({ "  columns: " .. snip.captures[2] .. ",", "" }),
                }
                local i_counter = 0
                local hlines = ""
                table.insert(nodes, t("table.header("))
                for _ = 1, snip.captures[2] - 1 do
                    i_counter = i_counter + 1
                    table.insert(nodes, t("["))
                    table.insert(nodes, i(i_counter, "Column" .. i_counter))
                    table.insert(nodes, t("],"))
                end
                i_counter = i_counter + 1
                table.insert(nodes, t("["))
                table.insert(nodes, i(i_counter, "Column" .. i_counter))
                table.insert(nodes, t("]),"))
                table.insert(nodes, t({ "" }))
                table.insert(nodes, t({ hlines, "" }))
                for _ = 1, snip.captures[1] do
                    for _ = 1, snip.captures[2] do
                        i_counter = i_counter + 1
                        table.insert(nodes, t("["))
                        table.insert(nodes, i(i_counter))
                        table.insert(nodes, t("], "))
                    end
                    table.insert(nodes, t({ "", "" }))
                end
                table.insert(nodes, t(")"))
                return sn(nil, nodes)
            end),
        }),

        s({ trig = "table(%d+)", regTrig = true }, {
            d(1, function(args, snip)
                local columns = snip.captures[1]
                local nodes = {
                    t({ "#table(", "" }),
                    t({ "  columns: " .. columns .. ",", "" }),
                }
                local i_counter = 0
                local hlines = ""
                table.insert(nodes, t("table.header("))
                for _ = 1, columns - 1 do
                    i_counter = i_counter + 1
                    table.insert(nodes, t("["))
                    table.insert(nodes, i(i_counter, "Column" .. i_counter))
                    table.insert(nodes, t("],"))
                end
                i_counter = i_counter + 1
                table.insert(nodes, t("["))
                table.insert(nodes, i(i_counter, "Column" .. i_counter))
                table.insert(nodes, t("]),"))
                table.insert(nodes, t({ "" }))
                table.insert(nodes, t({ hlines, "" }))

                for _ = 1, columns do
                    i_counter = i_counter + 1
                    table.insert(nodes, t("["))
                    table.insert(nodes, i(i_counter))
                    table.insert(nodes, t("], "))
                end

                local rec_table_row
                rec_table_row = function()
                    local row_nodes = {}
                    for _ = 1, columns do
                        i_counter = i_counter + 1
                        table.insert(row_nodes, t("["))
                        table.insert(row_nodes, i(i_counter))
                        table.insert(row_nodes, t("], "))
                    end
                    table.insert(row_nodes, d(i_counter + 1, rec_table_row, {}))
                    return sn(nil, {
                        c(1, {
                            t({ "" }),
                            sn(nil, row_nodes),
                        }),
                    })
                end

                table.insert(nodes, sn(nil, { d(1, rec_table_row, {}) }))
                table.insert(nodes, t({ "", "" }))
                table.insert(nodes, t(")"))
                return sn(nil, nodes)
            end),
        }),
    })
end

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
