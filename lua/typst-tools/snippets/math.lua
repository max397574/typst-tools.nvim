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

local function in_math()
    local node = vim.treesitter.get_node()

    while node do
        if node:type() == "source_file" then
            return false
        elseif vim.tbl_contains({ "math" }, node:type()) then
            return true
        end
        node = node:parent()
    end
    return false
end

local function reuse(idx)
    return f(function(args)
        return args[1][1]
    end, { idx })
end

local function math_snip(trigger)
    return {
        trig = trigger,
        condition = function()
            return in_math()
        end,
        show_condition = function()
            return in_math()
        end,
    }
end

local snippets = {}
function snippets.matrices()
    ls.add_snippets("typst", {
        s(
            math_snip("rowmat"),
            fmt("mat(-, {}_1, -; -, {}_2, -;,dots.v,;-, {}_n, -)", { i(1, "a"), reuse(1), reuse(1) })
        ),
        s(
            math_snip("colmat"),
            fmt("mat(|, |, , |;{}_1, {}_2, ..., {}_n;|, |, , |)", { i(1, "a"), reuse(1), reuse(1) })
        ),
        s(math_snip("genmat"), {
            t({
                "mat(a_(1,1), a_(1,2), ..., a_(1,n);a_(2,1), a_(2,2), ..., a_(2,n);dots.v, dots.v, dots.down, dots.v;a_(m,1), a_(m,2), ..., a_(m,n);)",
            }),
        }),
    })
end

function snippets.general()
    ls.add_snippets("typst", {
        s(math_snip("vec"), {
            c(1, {
                sn(1, fmt("vec({}, {})", { i(1), i(2) })),
                sn(2, fmt("vec({}, {}, {})", { i(1), i(2), i(3) })),
                sn(3, fmt("vec({}_1, {}_2)", { i(1, "v"), reuse(1) })),
                sn(
                    4,
                    fmt("vec({}_1, {}_2, {}_3)", {
                        i(1, "v"),
                        reuse(1),
                        reuse(1),
                    })
                ),
                sn(
                    5,
                    fmt("vec({}_1, {}_2, dots.v, {}_{})", {
                        i(1, "v"),
                        reuse(1),
                        reuse(1),
                        i(2, "n"),
                    })
                ),
            }),
        }),
        s(
            math_snip("seq"),
            fmt("{}_1, {}_2, ..., {}_{}", {
                i(1, "a"),
                reuse(1),
                reuse(1),
                i(2, "n"),
            })
        ),
        s(
            math_snip("2seq"),
            fmt("{}_1 {}_1, {}_2 {}_2, ..., {}_{} {}_{}", {
                i(1, "a"),
                i(2, "b"),
                reuse(1),
                reuse(2),
                reuse(1),
                i(3, "n"),
                reuse(2),
                reuse(3),
            })
        ),
        s(math_snip("sum"), {
            c(1, { t("limits(sum)"), t("sum") }),
            t("_"),
            c(2, {
                sn(2, fmt("({}={})", { i(1, "j"), i(2, "1") })),
                sn(1, { i(1, "j") }),
            }),
            t("^"),
            c(3, {
                sn(1, { i(1, "n") }),
                sn(2, fmt("({})", { i(1, "n") })),
            }),
            i(0),
        }),
        s(math_snip("bdu"), fmt("bold(upright({}))", { i(1) })),
        s(math_snip("ubr"), fmt("underbrace({},{})", { i(1), i(2) })),
        s(math_snip("mxn"), { t("m times n") }),
    })
end

local math_snippets = {}

function math_snippets.setup(config)
    for _, module in ipairs(config.modules) do
        snippets[module]()
    end
end

return math_snippets