local Snippets = {}

function Snippets.setup()
    for module, config in pairs(require("typst-tools.config").options.snippets) do
        if config.enabled then
            require("typst-tools.snippets." .. module).setup(config)
        end
    end
end

return Snippets
