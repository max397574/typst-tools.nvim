local typst = {}

typst.config = {
    treesitter = true,
    lsp = {
        enabled = true,
        on_attach = function() end,
    },
    formatter = {
        formatter_nvim = false,
        conform_nvim = false,
    },
}

function typst.setup(opts)
    vim.filetype.add({
        extension = {
            typ = "typst",
        },
    })

    typst.config = vim.tbl_deep_extend("force", typst.config, opts or {})
    if typst.config.treesitter then
        require("typst-tools.treesitter").setup()
    end

    require("typst-tools.formatter").setup(typst.config.formatter)

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
            vim.bo.commentstring = "//%s"
            vim.cmd.TSBufEnable("highlight")
            vim.bo.shiftwidth = 2
        end,
    })
end

return typst
