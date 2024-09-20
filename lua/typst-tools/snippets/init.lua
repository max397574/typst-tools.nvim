local Snippets = {}

local modules = {
    math = {
        enabled = true,
        modules = {
            "general",
            "matrices",
        },
    },
}

function Snippets.setup()
    for module, config in pairs(modules) do
        if config.enabled then
            require("typst-tools.snippets." .. module).setup(config)
        end
    end
end

return Snippets
