--- Custom blink.cmp source that scans SCSS/CSS/JSX files for class names
--- and provides completions when editing JSX/HTML or SCSS/CSS.
--- Handles BEM-style SCSS nesting: .foo { &--bar {} } → "foo--bar"
--- Handles JSX: className="foo bar" → "foo", "bar"

local cache = {}
local cache_ttl = 5

--- Find all CSS/SCSS/JSX/TSX files in the project (node_modules / .git excluded)
local function find_project_files(project_root)
  if not project_root or project_root == "" then return {} end

  local ok, result = pcall(vim.fn.system, {
    "find", project_root,
    "-type", "f",
    "(",
      "-name", "*.css", "-o",
      "-name", "*.scss", "-o",
      "-name", "*.jsx", "-o",
      "-name", "*.tsx",
    ")",
    "!", "-path", "*/node_modules/*",
    "!", "-path", "*/.git/*",
    "!", "-path", "*/dist/*",
    "!", "-path", "*/build/*",
  })
  if not ok or result == "" then return {} end

  local files = vim.split(result, "\n", { trimempty = true })
  local valid = {}
  for _, f in ipairs(files) do
    f = vim.trim(f)
    if f ~= "" and vim.fn.filereadable(f) == 1 then
      table.insert(valid, f)
    end
  end
  return valid
end

--- Parse SCSS class names from a file, handling BEM-style & nesting.
local function parse_scss_classes(filepath)
  local lines = vim.fn.readfile(filepath)
  if not lines or #lines == 0 then return {} end

  local classes = {}
  local seen = {}
  local context = {}

  local function resolve_ancestors()
    if #context == 0 then return "" end
    local parts = {}
    for _, ctx in ipairs(context) do
      table.insert(parts, ctx.name)
    end
    return table.concat(parts)
  end

  for _, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.*)$")
    if not trimmed or trimmed == "" then goto continue end

    local leading = line:match("^(%s*)")
    local indent = leading and #leading or 0

    if trimmed:find("^}") then
      local pop_at = nil
      for i = #context, 1, -1 do
        if context[i].indent >= indent then pop_at = i end
      end
      if pop_at then for _ = pop_at, #context do table.remove(context) end end
      goto continue
    end

    local root_class = trimmed:match("^%.([%w_%-]+)")
    local amp_class = trimmed:match("^&([%w_%-]+)")

    if root_class then
      if indent == 0 then
        context = {}
        table.insert(context, { name = root_class, indent = indent })
        if not seen[root_class] then
          seen[root_class] = true
          table.insert(classes, root_class)
        end
      elseif #context > 0 then
        table.insert(context, { name = root_class, indent = indent })
      else
        table.insert(context, { name = root_class, indent = indent })
        if not seen[root_class] then
          seen[root_class] = true
          table.insert(classes, root_class)
        end
      end
    elseif amp_class then
      local resolved = resolve_ancestors() .. amp_class
      if not seen[resolved] then
        seen[resolved] = true
        table.insert(classes, resolved)
      end
      table.insert(context, { name = amp_class, indent = indent })
    end

    ::continue::
  end

  return classes
end

--- Parse JSX/TSX class names from className="..." attributes.
--- Handles double quotes, single quotes, and template literals.
local function parse_jsx_classes(filepath)
  local content = vim.fn.readfile(filepath)
  if not content or #content == 0 then return {} end

  local text = table.concat(content, "\n")
  local classes = {}
  local seen = {}

  -- Match className="foo bar"
  for val in text:gmatch('className="([^"]*)"') do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  -- Match className='foo bar'
  for val in text:gmatch("className='([^']*)'") do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  -- Match className={`foo bar`} (template literals)
  for val in text:gmatch("className[=]`([^`]*)`") do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  return classes
end

--- Get all class names from the project (SCSS + JSX), using cache
local function get_classes(project_root)
  local now = vim.loop.now()
  local cached = cache[project_root]

  if cached and (now - cached.cache_time) < cache_ttl then
    return cached.classes
  end

  local files = find_project_files(project_root)
  local all_classes = {}

  for _, filepath in ipairs(files) do
    local file_classes
    if filepath:match("%.jsx$") or filepath:match("%.tsx$") then
      file_classes = parse_jsx_classes(filepath)
    else
      file_classes = parse_scss_classes(filepath)
    end
    for _, cls in ipairs(file_classes) do
      all_classes[cls] = true
    end
  end

  local class_list = {}
  for cls, _ in pairs(all_classes) do
    table.insert(class_list, cls)
  end
  table.sort(class_list)

  cache[project_root] = { classes = class_list, cache_time = now }
  return class_list
end

-- Exposed for the <leader>sc keybind
local source_refresh = function() cache = {} end

-- Auto-refresh cache when entering insert mode
-- Next completion will pick up newly added classes from JSX/SCSS
local autocmd_setup = false
local function ensure_autocmd()
  if autocmd_setup then return end
  autocmd_setup = true
  vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
      cache = {}
    end,
  })
end

--- blink.cmp source
local Source = {}

function Source.new(_, _config)
  ensure_autocmd()
  return setmetatable({}, { __index = Source })
end

function Source:enabled()
  local ft = vim.bo.filetype
  return ft == "javascriptreact"
    or ft == "typescriptreact"
    or ft == "html"
    or ft == "css"
    or ft == "scss"
end

--- Detect current SCSS nesting context by scanning backwards from cursor
local function get_scss_context()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  local context = {}

  for _, line in ipairs(lines) do
    local trimmed = line:match("^%s*(.-)%s*$")
    if not trimmed or trimmed == "" then goto next end

    local indent = #(line:match("^(%s*)") or "")

    if trimmed:find("^}") then
      -- Pop the last context entry at or above this indent
      for i = #context, 1, -1 do
        if context[i].indent >= indent then
          table.remove(context, i)
        end
      end
    else
      -- Check if this line starts a block with a class
      local class = trimmed:match("^%.([%w_%-]+)%s*{")
      -- Also match BEM: .parent { &--child { ... } }
      if not class then
        class = trimmed:match("^&([%w_%-]+)%s*{")
        if class and #context > 0 then
          class = context[#context].name .. class
          -- Push with indent so we can pop later
          table.insert(context, { name = class, indent = indent })
          goto next
        end
      end
      if class then
        table.insert(context, { name = class, indent = indent })
      end
    end

    ::next::
  end

  if #context == 0 then return nil end
  return context[#context].name
end

function Source:get_completions(context, resolve)
  local project_root = vim.fn.getcwd()
  local classes = get_classes(project_root)

  -- Detect SCSS context for & completions
  local scss_ctx = nil
  if vim.bo.filetype == "scss" then
    scss_ctx = get_scss_context()
  end

  local items = {}
  for _, cls in ipairs(classes) do
    table.insert(items, {
      label = cls,
      kind = 15, -- Value
      detail = "(CSS class)",
    })

    -- If inside a SCSS context, also add & variants for matching classes
    if scss_ctx then
      local suffix = cls:match("^" .. scss_ctx .. "([%_%-].+)$")
      if suffix then
        table.insert(items, {
          label = "&" .. suffix,
          kind = 15,
          detail = "(SCSS & shorthand)",
        })
      end
    end
  end

  resolve({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
end

Source.refresh = source_refresh

return Source
