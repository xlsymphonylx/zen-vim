return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    -- Mason is installed but does nothing — all LSPs come from Nix
    require("mason").setup({ ui = { border = "rounded" } })

    local on_attach = function(client, bufnr)
      local bufopts = { noremap = true, silent = true, buffer = bufnr }

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, bufopts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, bufopts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, bufopts)
      vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, bufopts)
    end

    -- Capabilities for completion (blink.cmp will override this)
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    local servers = {
      nil_ls = {},
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      },
      ts_ls = {},
      html = {},
      cssls = {},
      jsonls = {},
      yamlls = {},
      bashls = {},
      emmet_ls = {},
    }

    for server, config in pairs(servers) do
      vim.lsp.config(server, vim.tbl_deep_extend("force", {
        on_attach = on_attach,
        capabilities = capabilities,
      }, config))
    end
    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
