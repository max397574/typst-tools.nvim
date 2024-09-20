local utils = {}

function utils.compile_document() end

function utils.watch_document()
    local job = vim.system({
        "typst",
        "watch",
        ---@diagnostic disable-next-line: assign-type-mismatch
        vim.fn.expand("%"),
        "--open",
        "/Applications/Skim.app/",
    })
    vim.api.nvim_buf_create_user_command(0, "TypstStop", function()
        job:kill(9)
        vim.api.nvim_buf_del_user_command(0, "TypstStop")
    end, {})

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            job:kill(9)
            vim.api.nvim_buf_del_user_command(0, "TypstStop")
        end,
    })
end

function utils.watch_document_with_viewer(viewer)
    local job = vim.system({
        "typst",
        "watch",
        ---@diagnostic disable-next-line: assign-type-mismatch
        vim.fn.expand("%"),
        "--open",
        viewer,
    })
    vim.api.nvim_buf_create_user_command(0, "TypstStop", function()
        job:kill(9)
        vim.api.nvim_buf_del_user_command(0, "TypstStop")
    end, {})

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            job:kill(9)
            vim.api.nvim_buf_del_user_command(0, "TypstStop")
        end,
    })
end

local heading_query = [[
[
    (heading) @next-segment
]
]]

local function jump_to_previous_query_match(query_string)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_number, col_number = cursor[1], cursor[2]

    local parser = vim.treesitter.get_parser(0, "typst")
    local tree = parser:parse()[1]

    if not tree or not tree:root() then
        return
    end

    local document_root = tree:root()

    local previous_match_query = vim.treesitter.query.parse("typst", query_string)
    local final_node = nil

    for id, node in previous_match_query:iter_captures(document_root, 0, 0, line_number) do
        if previous_match_query.captures[id] == "next-segment" then
            local start_line, _, _, end_col = node:range()
            -- start_line is 0-based; increment by one so we can compare it to the 1-based line_number
            start_line = start_line + 1

            -- Skip node if it's inside a closed fold
            if not vim.tbl_contains({ -1, start_line }, vim.fn.foldclosed(start_line)) then
                goto continue
            end

            -- Find the last matching node that ends before the current cursor position.
            if start_line < line_number or (start_line == line_number and end_col < col_number) then
                final_node = node
            end
        end

        ::continue::
    end
    if final_node then
        ---@diagnostic disable-next-line: undefined-global
        require("nvim-treesitter.ts_utils").goto_node(final_node)
    end
end

local function jump_to_next_query_match(query_string)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_number, col_number = cursor[1], cursor[2]

    local parser = vim.treesitter.get_parser(0, "typst")
    local tree = parser:parse()[1]

    if not tree or not tree:root() then
        return
    end

    local document_root = tree:root()

    local next_match_query = vim.treesitter.query.parse("typst", query_string)
    for id, node in next_match_query:iter_captures(document_root, 0, line_number - 1, -1) do
        if next_match_query.captures[id] == "next-segment" then
            local start_line, start_col = node:range()
            -- start_line is 0-based; increment by one so we can compare it to the 1-based line_number
            start_line = start_line + 1

            -- Skip node if it's inside a closed fold
            if not vim.tbl_contains({ -1, start_line }, vim.fn.foldclosed(start_line)) then
                goto continue
            end

            -- Find and go to the first matching node that starts after the current cursor position.
            if (start_line == line_number and start_col > col_number) or start_line > line_number then
                require("nvim-treesitter.ts_utils").goto_node(node)
                return
            end
        end

        ::continue::
    end
end

function utils.jump_to_next_heading()
    jump_to_next_query_match(heading_query)
end

function utils.jump_to_previous_heading()
    jump_to_previous_query_match(heading_query)
end

function utils.heading_loclist()
    local bufnr = vim.fn.bufnr()
    local locations = {}

    local parser = vim.treesitter.get_parser(0, "typst")
    local tree = parser:parse()[1]

    if not tree or not tree:root() then
        return
    end

    local document_root = tree:root()

    local next_match_query = vim.treesitter.query.parse("typst", heading_query)
    for id, node in next_match_query:iter_captures(document_root, 0, 0, -1) do
        if next_match_query.captures[id] == "next-segment" then
            local start_line, start_col = node:range()
            table.insert(locations, {
                bufnr = bufnr,
                lnum = start_line + 1,
                col = start_col,
                ---@diagnostic disable-next-line: param-type-mismatch
                text = vim.treesitter.get_node_text(node:named_child(0), 0),
            })
        end
    end

    vim.fn.setqflist(locations, "r")
    vim.fn.setqflist({}, "a", { title = "Typst Outline" })
    vim.cmd.copen()
end

return utils
