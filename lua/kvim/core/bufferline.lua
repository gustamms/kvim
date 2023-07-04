local bufferline = require("bufferline")
local keymappings = require("kvim.keymappings")

local M = {}

function M.init()
    bufferline.setup({
        options = {
            indicator = {
                style = "",
            },
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(count, level, diagnostics_dict, context)
                local icon = level:match("error") and " " or " "
                return " " .. icon .. count
            end,
            show_close_icon = false,
            show_buffer_close_icons = false,
            show_tab_indicators = true,
            enforce_regular_tabs = false,
            sort_by = function(buff_a, buff_b)
                return buff_a.id < buff_b.id
            end,
        },
        highlights = {
            fill = {
                bg = "#1a1a24",
            },
        },
    })

    keymappings.load({
        normal_mode = {
            ["<Leader>1"] = ":BufferLineGoToBuffer 1<CR>",
            ["<Leader>2"] = ":BufferLineGoToBuffer 2<CR>",
            ["<Leader>3"] = ":BufferLineGoToBuffer 3<CR>",
            ["<Leader>4"] = ":BufferLineGoToBuffer 4<CR>",
            ["<Leader>5"] = ":BufferLineGoToBuffer 5<CR>",
            ["<Leader>6"] = ":BufferLineGoToBuffer 6<CR>",
            ["<Leader>7"] = ":BufferLineGoToBuffer 7<CR>",
            ["<Leader>8"] = ":BufferLineGoToBuffer 8<CR>",
            ["<Leader>9"] = ":BufferLineGoToBuffer 9<CR>",
        },
    })
end

return M
