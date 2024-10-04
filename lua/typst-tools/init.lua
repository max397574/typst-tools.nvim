local typst = {}

local function create_commands()
    vim.api.nvim_create_user_command("TypstToc", function()
        require("typst-tools.utils").heading_loclist()
    end, {})
end

local function create_default_mappings()
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.typ",
        callback = function()
            vim.keymap.set("n", "]]", function()
                require("typst-tools.utils").jump_to_next_heading()
            end, { buffer = true })
            vim.keymap.set("n", "[[", function()
                require("typst-tools.utils").jump_to_previous_heading()
            end, { buffer = true })
            vim.keymap.set("n", "gO", function()
                require("typst-tools.utils").heading_loclist()
            end, { buffer = true })
        end,
    })
end

function typst.setup(opts)
    require("typst-tools.config").setup(opts)
end

function typst.initialize()
    local config = require("typst-tools.config").options
    create_commands()

    if config.formatter.conform_nvim then
        require("conform").setup({
            formatters_by_ft = {
                -- TODO: check if they are available
                typst = config.formatter.formatters,
            },
        })
    end

    if config.lsp.enabled then
        require("typst-tools.lsp").setup(config.lsp)
    end

    require("typst-tools.snippets").setup()

    if config.default_mappings then
        create_default_mappings()
    end

    if config.context.enabled then
        require("typst-tools.context").load()
        require("typst-tools.context").enable()
    end
end

return typst
