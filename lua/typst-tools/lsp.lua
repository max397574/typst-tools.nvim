local typst_lsp = {}

function typst_lsp.setup(opts)
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            opts.on_attach(vim.lsp.get_client_by_id(args.data.client_id), args.buf)
        end,
    })

    -- vim.lsp.start({
    --     name = "tinymist",
    --     cmd = { "tinymist" },
    --     root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())),
    --     autostart = true,
    --     settings = {
    --         exportPdf = "never",
    --     },
    -- })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(args)
            vim.lsp.start({
                name = "tinymist",
                cmd = { "tinymist" },
                root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(args.buf)),
                autostart = true,
                settings = {
                    exportPdf = "never",
                },
            })
        end,
    })
end

return typst_lsp
