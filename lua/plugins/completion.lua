return {
  "saghen/blink.cmp",
  version = "*",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  },
  opts = {
    keymap = {
      preset = "default",
      ["<C-y>"] = { "select_and_accept" },
      ["<C-e>"] = { "cancel" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true },
      menu = { border = "rounded" },
    },
    snippets = {
      preset = "luasnip",
    },
  },
  config = function()
    -- ── Load friendly-snippets (react, js, ts, etc.) ──
    require("luasnip.loaders.from_vscode").lazy_load()

    -- ── Custom snippets ──
    local ls = require("luasnip")
    local s = ls.snippet
    local t = ls.text_node
    local i = ls.insert_node

    local custom_js = {
      s("fn", {
        t("function "), i(1, "name"), t("("), i(2), t(") {"),
        t({ "", "\t" }), i(0),
        t({ "", "}" }),
      }),
      s("afn", {
        t("async function "), i(1, "name"), t("("), i(2), t(") {"),
        t({ "", "\t" }), i(0),
        t({ "", "}" }),
      }),
      s("cfn", {
        t("const "), i(1, "name"), t(" = ("), i(2), t(") => {"),
        t({ "", "\t" }), i(0),
        t({ "", "}" }),
      }),
      s("cafn", {
        t("const "), i(1, "name"), t(" = async ("), i(2), t(") => {"),
        t({ "", "\t" }), i(0),
        t({ "", "}" }),
      }),
    }

    -- Register for all JS/TS/React filetypes
    for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
      ls.add_snippets(ft, custom_js)
    end

    -- ── Finally, setup blink.cmp ──
    require("blink.cmp").setup({
      keymap = {
        preset = "default",
        ["<C-y>"] = { "select_and_accept" },
        ["<C-e>"] = { "cancel" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true },
        menu = { border = "rounded" },
      },
      snippets = {
        preset = "luasnip",
      },
    })
  end,
}
