local config = {}

config.options = {}

config.defaults = {
    lsp = {
        enabled = true,
        on_attach = function() end,
    },
    formatter = {
        formatters = {
            -- "typstfmt",
            "typstyle",
        },
        conform_nvim = false,
    },
    context = {
        enabled = true,
    },
    default_mappings = true,
    snippets = {
        math = {
            enabled = true,
            modules = {
                "general",
                "matrices",
            },
        },
    },
}

function config.setup(opts)
    if vim.tbl_isempty(config.options) then
        config.options = vim.tbl_deep_extend("force", config.defaults, opts or {})
    else
        config.options = vim.tbl_deep_extend("force", config.options, opts or {})
    end
end

config.setup({})

return config
