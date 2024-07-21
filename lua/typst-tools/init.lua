local typst = {}

typst.config = {
    -- treesitter = true,
    lsp = {
        enabled = false,
        on_attach = function() end,
    },
    formatter = {
        formatter_nvim = false,
        conform_nvim = false,
    },
    context = {
        enabled = true,
    },
    default_mappings = true,
}

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
    vim.filetype.add({
        extension = {
            typ = "typst",
        },
    })

    typst.config = vim.tbl_deep_extend("force", typst.config, opts or {})
    -- if typst.config.treesitter then
    --     require("typst-tools.treesitter").setup()
    -- end

    require("typst-tools.formatter").setup(typst.config.formatter)

    if typst.config.lsp.enabled then
        require("typst-tools.lsp").setup(typst.config.lsp)
    end

    create_commands()

    if typst.config.default_mappings then
        create_default_mappings()
    end

    if typst.config.context.enabled then
        require("typst-tools.context").load()
        require("typst-tools.context").enable()
    end

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
            vim.bo.commentstring = "// %s"
            vim.cmd.TSBufEnable("highlight")
            vim.bo.shiftwidth = 2
        end,
    })
end

return typst
