local M = {  }


local generic_opts = {
    noremap = true, silent = true,
}

local mode_adapter = {
    normal_mode = "n",
    visual_mode = "v",
    visual_block_mode = "x",
    insert_mode = "i",
}

local default_mappings = {
    insert_mode = {
        ["<C-c>"] = "<ESC>",
    },
    normal_mode = {
        ["<Space>"] = "<NOP>",
        ["<C-t>"] = ":tabnew<CR>",
        ["<Leader>1"] = ":tabn 1<CR>",
        ["<Leader>2"] = ":tabn 2<CR>",
        ["<Leader>3"] = ":tabn 3<CR>",
        ["<Leader>4"] = ":tabn 4<CR>",
        ["<Leader>5"] = ":tabn 5<CR>",
        ["<Leader>6"] = ":tabn 6<CR>",
        ["<Leader>7"] = ":tabn 7<CR>",
        ["<Leader>8"] = ":tabn 8<CR>",
        ["<Leader>9"] = ":tabn 9<CR>",

        -- Altenate shortcut to save
        ["<C-s>"] = ":w<CR>",
        ["<C-w>"] = ":x!<CR>",
        ["<C-q>"] = ":q<CR>",
        ["<C-c>"] = "<ESC>",

        -- Navigate in windows
        ["<C-Left>"] = "<C-w>h",
        ["<C-Down>"] = "<C-w>j",
        ["<C-Up>"] = "<C-w>k",
        ["<C-Right>"] = "<C-w>l",

        -- Duplicate lines
        -- ["<S-d>"] = "<ESC>yyp",

        -- Set uppercase
        ["<S-u>"] = "<ESC>viwUi",
        ["<S-u>"] = "viwUi<ESC>",

        -- Set lowercase
        ["<S-l>"] = "<ESC>viwu",
        ["<S-l>"] = "viwu<ESC>",

        ["<C-h>"] = "<ESC>:%s/",
        ["<Leader>v"] = ":vsplit<CR>",
        ["<Leader>h"] = ":sv<CR>",

        ["<ESC>"] = ":noh<CR>",

        ["<C-s>"] = ":w<CR>",
        
        ['<Leader>v'] = ":vsplit<CR>",
        ['<Leader>h'] = ":sv<CR>",
    },
    visual_mode = {
        ["<S-u>"] = "<ESC>viwUi",
        ["<S-u>"] = "<ESC>viwUi",
        ["<S-l>"] = "viwu<ESC>",
        ["<S-l>"] = "viwu<ESC>",
        ["<"] = "<gv",
        [">"] = ">gv",
        ["<C-c>"] = "<ESC>",
    },
    visual_block_mode = {
        ["<C-c>"] = "<ESC>",
    }
}

function M:set_keymaps(mode, key, val)
    vim.api.nvim_set_keymap(mode, key, val, generic_opts)
end

function M:load_mode(mode, mapping)
    mode = mode_adapter[mode] and mode_adapter[mode] or mode
    for key, value in pairs(mapping) do 
        M:set_keymaps(mode, key, value)
    end 
end

function M:load(mappings)
    for mode, mapping in pairs(mappings) do 
        M:load_mode(mode, mapping)
    end
end

function M:init()
    vim.g.mapleader = ' '
    M:load(default_mappings)
end

return M

