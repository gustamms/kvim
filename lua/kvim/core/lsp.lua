local keymapping = require("kvim.keymappings")
local utils = require("utils")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local M = {}

local function rename()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/prepareRename", params, function(_, result, event)
        if result then
            local r_start
            local r_end
            if result.range then
                r_start = result.range.start
                r_end = result.range["end"]
            else
                r_start = result.start
                r_end = result["end"]
            end

            local text =
                vim.api.nvim_buf_get_text(event.bufnr, r_start.line, r_start.character, r_end.line, r_end.character, {})

            require("kvim.core.input").rename({
                prompt = "New Name",
                default = table.concat(text),
            }, function(input)
                if not input or #input == 0 then
                    return
                end
                params.newName = input
                vim.lsp.buf_request(event.bufnr, "textDocument/rename", params, vim.lsp.handlers["textDocument/rename"])
            end)
        end
    end)
end

local servers = {
    sumneko_lua = {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                        [vim.fn.stdpath("config") .. "/lua"] = true,
                    },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    },
    tsserver = {},
    rust_analyzer = {},
    dockerls = {},
    yamlls = {},
    html = {},
    cssls = {},
    -- intelephense = {},
    phpactor = {
        init_options = {
            ["language_server_phpstan.enabled"] = false,
            ["language_server_psalm.enabled"] = false,
        },
    },
    elixirls = {
        cmd = { vim.fn.expand("$HOME") .. "/.local/bin/elixir-ls" },
    },
    clangd = {},
    gopls = {},
    pyright = {},
}

local disabled_formatting_on_save = { "tsserver", "sumneko_lua" }

function M.enable_format_on_save(client, bufnr)
    bufnr = bufnr or 0

    if client.resolved_capabilities.document_formatting then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            group = "LspFormatting",
            callback = function()
                if vim.g.format_on_save then
                    vim.lsp.buf.formatting_sync()
                end
            end,
        })
    end
end

function M.disable_format_on_save(client)
    client.resolved_capabilities.document_formatting = false
end

function M.enable_highlight(client, bufnr)
    bufnr = bufnr or 0

    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_create_autocmd("CursorHold", {
            buffer = bufnr,
            group = "LspDocumentHighlight",
            callback = function()
                vim.lsp.buf.document_highlight()
            end,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = bufnr,
            group = "LspDocumentHighlight",
            callback = function()
                vim.lsp.buf.clear_references()
            end,
        })
    end
end

function M.lsp_config()
    vim.g.format_on_save = true
    vim.api.nvim_create_augroup("LspFormatting", { clear = true })
    vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })

    local mapping = {
        normal_mode = {
            ["K"] = function()
                vim.lsp.buf.hover()
            end,
            ["gd"] = function()
                vim.lsp.buf.definition()
            end,
            ["ga"] = function()
                vim.lsp.buf.code_action()
            end,
            ["gr"] = function()
                vim.lsp.buf.references()
            end,
            ["gi"] = function()
                vim.lsp.buf.implementation()
            end,
            ["<Leader>rn"] = function()
                rename()
            end,
            ["g["] = function()
                vim.diagnostic.goto_prev()
            end,
            ["g]"] = function()
                vim.diagnostic.goto_next()
            end,
            ["<S-u>"] = function()
                vim.diagnostic.open_float()
            end,
            ["<Leader>ff"] = function()
                vim.lsp.buf.formatting()
            end,
            ["<Leader>fo"] = function()
                if vim.g.format_on_save then
                    vim.g.format_on_save = false
                    print("format_on_save=disabled")
                else
                    vim.g.format_on_save = true
                    print("format_on_save=enabled")
                end
            end,
        },
        visual_mode = {
            ["<Leader>ff"] = function()
                vim.lsp.buf.range_formatting()
            end,
        },
    }

    local on_attach = function(client, bufnr)
        keymapping.load(mapping, bufnr)

        if utils.contains(disabled_formatting_on_save, client.name) then
            M.disable_format_on_save(client)
        else
            M.enable_format_on_save(client, bufnr)
        end

        M.enable_highlight(client, bufnr)
    end

    local capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

    for server, config in pairs(servers) do
        config["on_attach"] = on_attach
        config["capabilities"] = capabilities

        lspconfig[server].setup(config)
    end
end

function M.handlers()
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })
end

function M.diagnostics()
    local signs = {
        { name = "DiagnosticSignError", text = "" },
        { name = "DiagnosticSignWarn", text = "" },
        { name = "DiagnosticSignHint", text = "" },
        { name = "DiagnosticSignInfo", text = "" },
    }

    for _, sign in ipairs(signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
    end

    local config = {
        virtual_text = true,
        signs = {
            active = signs,
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }

    vim.diagnostic.config(config)
end

function M.init()
    M.lsp_config()
    M.handlers()
    M.diagnostics()
end

return M
