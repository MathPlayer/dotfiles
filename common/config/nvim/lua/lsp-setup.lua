-- Uncomment when debugging LSP servers.
-- vim.lsp.set_log_level("debug")

-- Signs not added when moving from init.vim to init.lua
-- sign define LspDiagnosticsSignError text=🔴
-- sign define LspDiagnosticsSignWarning text=🟠
-- sign define LspDiagnosticsSignInformation text=🔵
-- sign define LspDiagnosticsSignHint text=🟢

local servers = {
  bashls = {},
  clangd = {},
  helm_ls = {
    filetypes = { "helm" },
    cmd = { "helm_ls", "serve" },
  },
  -- kotlin_language_server = {},
  lemminx = {},
  marksman = {},
  pylsp = {
    cmd_env = {
      VIRTUAL_ENV=vim.g.neovim_python_env,
      PATH=vim.g.neovim_python_env .. "/bin/" .. ":" .. vim.env.PATH
    },
  },
  tsserver = {},
  terraformls = {},
  tflint = {},
  yamlls = {
    filetypes = { "yaml", "yaml.docker-compose" },
    settings = {
      yaml = {
        trace = {
          server = "verbose"
        },
  --       schemas = {
  --         ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"] = "/azure-pipelines/**/*",
  --         ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
  --       },
  --       customTags = {
  --         "!And scalar",
  --         "!And mapping",
  --         "!And sequence",
  --         "!If scalar",
  --         "!If mapping",
  --         "!If sequence",
  --         "!Not scalar",
  --         "!Not mapping",
  --         "!Not sequence",
  --         "!Equals scalar",
  --         "!Equals mapping",
  --         "!Equals sequence",
  --         "!Or scalar",
  --         "!Or mapping",
  --         "!Or sequence",
  --         "!FindInMap scalar",
  --         "!FindInMap mappping",
  --         "!FindInMap sequence",
  --         "!Base64 scalar",
  --         "!Base64 mapping",
  --         "!Base64 sequence",
  --         "!Cidr scalar",
  --         "!Cidr mapping",
  --         "!Cidr sequence",
  --         "!Ref scalar",
  --         "!Ref mapping",
  --         "!Ref sequence",
  --         "!Sub scalar",
  --         "!Sub mapping",
  --         "!Sub sequence",
  --         "!GetAtt scalar",
  --         "!GetAtt mapping",
  --         "!GetAtt sequence",
  --         "!GetAZs scalar",
  --         "!GetAZs mapping",
  --         "!GetAZs sequence",
  --         "!ImportValue scalar",
  --         "!ImportValue mapping",
  --         "!ImportValue sequence",
  --         "!Select scalar",
  --         "!Select mapping",
  --         "!Select sequence",
  --         "!Split scalar",
  --         "!Split mapping",
  --         "!Split sequence",
  --         "!Join scalar",
  --         "!Join mapping",
  --         "!Join sequence"
  --       },
      },
    },
  },
}

-- Setup neovim lua configuration
-- require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require('mason').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = require('keymaps').on_attach,
      settings = servers[server_name],
      filetypes = servers[server_name].filetypes,
    }
  end
}

-- vim: ts=2 sts=2 sw=2 et
