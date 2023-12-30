local typst = {}

local config = {
    treesitter = true,
    lsp = true,
    formatter = {
        formatter_nvim = false,
        conform_nvim = false,
    },
}

function typst.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
    if config.treesitter then
        require("typst-tools.treesitter").setup()
    end

    require("typst-tools.formatter").setup(config.formatter)

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
