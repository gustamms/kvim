local M = {}

function M.init()
    require("catppuccin").setup({
        flavour = "mocha",
        custom_highlights = function(colors)
            return {
                FloatBorder = { fg = colors.blue, bg = colors.base },
                HarpoonBorder = { fg = colors.blue, bg = colors.base },
                TermBorder = { link = "FloatBorder" },
                NormalFloat = { fg = colors.text, bg = colors.base },
                TelescopeBorder = { link = "FloatBorder" },
                WinSeparator = { fg = colors.blue },
                Breakpoint = { fg = colors.red },
                IncSearch = { bg = colors.lavender },
                IblScope = { fg = colors.overlay1 },
            }
        end,
    })

    vim.cmd.colorscheme("catppuccin")
end

return M
