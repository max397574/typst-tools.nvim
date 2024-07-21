local M = {}

M.check = function()
    local config = require("typst-tools").config
    vim.health.report_start("typst-tools.nvim")
    if config.lsp.enabled then
        if vim.fn.executable("typst-lsp") == 0 then
            vim.health.error("Enabled lsp but didn't find typst-lsp executable")
        else
            vim.health.ok("Enabled lsp and found typst-lsp executable")
        end
    end

    local enabled_formatters = {}
    for formatter, enabled in pairs(config.formatter) do
        if enabled then
            table.insert(enabled_formatters, formatter)
        end
    end
    if #enabled_formatters > 0 then
        local formatters = table.concat(enabled_formatters, ", ")
        if vim.fn.executable("typstfmt") == 0 then
            vim.health.error("Enabled formatter(s) " .. formatters .. " but didn't find typstfmt executable")
        else
            vim.health.ok("Enabled formatter(s) " .. formatters .. " and found typstfmt executable")
        end
    end
end

return M
