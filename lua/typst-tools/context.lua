local typst_context = {}

local ts_utils
if not vim.treesitter.get_node then
    ts_utils = require("nvim-treesitter.ts_utils")
end

local enabled = false
local winnr
local bufnr
local ns = vim.api.nvim_create_namespace("typst-context")

function typst_context.enable()
    enabled = true
end

function typst_context.disable()
    enabled = false
end

function typst_context.toggle()
    enabled = not enabled
end

local function get_contexts()
    local node
    -- TODO: remove after 0.10 release
    if not vim.treesitter.get_node then
        node = ts_utils.get_node_at_cursor(0, true)
    else
        node = vim.treesitter.get_node()
    end
    local lines = {}
    local heading_nodes = {}

    local function is_valid(potential_node)
        local topline = vim.fn.line("w0")
        local row = potential_node:start()
        return row <= (topline + #heading_nodes)
    end

    local function validate_heading_nodes()
        local valid_heading_nodes = heading_nodes
        for i = #heading_nodes, 1, -1 do
            if not is_valid(valid_heading_nodes[i]) then
                table.remove(valid_heading_nodes, i)
            end
        end
        return valid_heading_nodes
    end

    while node do
        if node:type() == "section" then
            for potential_heading in node:iter_children() do
                if potential_heading:type() == "heading" and is_valid(potential_heading) then
                    table.insert(heading_nodes, potential_heading)
                end
            end
        end
        if node:parent() then
            node = node:parent()
        else
            break
        end
    end
    heading_nodes = validate_heading_nodes()
    local title_nodes = {}
    for _, heading_node in ipairs(heading_nodes) do
        table.insert(title_nodes, heading_node:named_child(0))
        -- table.insert(highlights, highlight_table[heading_node:type()])
        -- table.insert(prefixes, prefix_table[heading_node:type()])
    end
    for _, title_node in ipairs(heading_nodes) do
        table.insert(
            lines,
            vim.split(
                -- TODO: remove after 0.10 release
                vim.treesitter.get_node_text and vim.treesitter.get_node_text(title_node, 0, {})
                    or vim.treesitter.query.get_node_text(title_node, 0),
                "\n"
            )[1]
        )
    end
    return vim.iter(lines):rev():totable()
end

local function set_buf()
    local lines = get_contexts()
    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    for i = 0, #lines do
        vim.api.nvim_buf_add_highlight(bufnr, ns, "TypstContext", i, 0, -1)
    end
end

local function open_win()
    set_buf()
    local col = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
    local lines = get_contexts()
    if #lines == 0 then
        if winnr and vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
            winnr = nil
        end
        return
    end
    if not winnr or not vim.api.nvim_win_is_valid(winnr) then
        winnr = vim.api.nvim_open_win(bufnr, false, {
            relative = "win",
            width = vim.api.nvim_win_get_width(0) - col,
            height = #lines,
            row = 0,
            col = col,
            focusable = false,
            style = "minimal",
            noautocmd = true,
        })
    else
        vim.api.nvim_win_set_config(winnr, {
            win = vim.api.nvim_get_current_win(),
            relative = "win",
            width = vim.api.nvim_win_get_width(0) - col,
            height = #lines,
            row = 0,
            col = col,
        })
    end

    -- TODO: use this after next neovim release
    -- vim.api.nvim_set_option_value("winhl","NormalFloat:NeorgContext",{win=winnr})
    vim.api.nvim_win_set_option(winnr, "winhl", "NormalFloat:TypstContext")
end

local function update_window()
    if not enabled then
        if winnr and vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
            winnr = nil
        end
        return
    end
    if vim.bo.filetype ~= "typst" then
        if winnr and vim.api.nvim_win_is_valid(winnr) then
            vim.api.nvim_win_close(winnr, true)
            winnr = nil
        end
        return
    end

    open_win()
end

function typst_context.load()
    local context_augroup = vim.api.nvim_create_augroup("typst-context", {})
    vim.api.nvim_set_hl(0, "TypstContext", { link = "Visual", default = true, bold = true })
    vim.api.nvim_create_autocmd({ "WinScrolled", "BufEnter", "WinEnter", "CursorMoved" }, {
        callback = function()
            update_window()
        end,
        group = context_augroup,
    })
end

return typst_context
