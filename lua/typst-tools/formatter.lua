local typst_formatter = {}

function typst_formatter.setup(opts)
    if not vim.fn.executable("typstfmt") then
        return
    end

    if opts.formatter_nvim then
        require("formatter").setup({
            filetype = {
                function()
                    vim.cmd.w()
                    return {
                        exe = "typstfmt",
                        args = { vim.fn.expand("%"), "-o", "-" },
                        stdin = true,
                    }
                end,
            },
        })
    end

    if opts.conform_nvim then
        require("conform").setup({
            formatters_by_ft = {
                typst = { "typstfmt" },
            },
        })
    end
end

return typst_formatter
