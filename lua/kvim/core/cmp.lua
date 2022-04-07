local M = {}
local cmp = require("cmp")
local lspkind = require("lspkind")

function M.init()
    cmp.setup({
        sources = {
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "path" },
            { name = "luasnip" },
            { name = "buffer" },
        },
        snippet = {
            expand = function(args)
                require("luasnip").lsp_expand(args.body)
            end,
        },
        mapping = {
            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<C-space>"] = cmp.mapping.complete(),
            ["<CR>"] = cmp.mapping.confirm({
                select = true,
            }),
            ["<c-y>"] = cmp.mapping.confirm({
                behavior = cmp.ConfirmBehavior.Insert,
                select = true,
            }),
        },
        formatting = {
            format = lspkind.cmp_format({
                with_text = true,
                menu = {
                    buffer = "[buf]",
                    nvim_lsp = "[LSP]",
                    nvim_lua = "[api]",
                    path = "[path]",
                    luasnip = "[snip]",
                },
            }),
        },
        experimental = {
            native_menu = false,
            ghost_text = true,
        },
    })

    cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        }),
        formatting = {
            format = lspkind.cmp_format({
                with_text = false,
                menu = {
                    cmdline = "[cmd]",
                    path = "[path]",
                },
            }),
        },
    })
end

return M
