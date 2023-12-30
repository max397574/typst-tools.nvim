local typst_treesitter = {}

function typst_treesitter.setup()
    local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
    parser_config.typst = {
        install_info = {
            url = "https://github.com/uben0/tree-sitter-typst",
            files = { "src/parser.c", "src/scanner.c" },
            generate_requires_npm = true,
        },
    }
end

return typst_treesitter
