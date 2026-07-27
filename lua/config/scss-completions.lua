--- Custom blink.cmp source that scans SCSS/CSS/JSX/TSX/HTML files for class names
--- and provides completions when editing JSX/HTML or SCSS/CSS.
--- Handles BEM-style SCSS nesting: .foo { &--bar {} } -> "foo--bar"
--- Handles JSX: className="foo bar" -> "foo", "bar"
---
--- Import-aware scoping:
---   JSX/TSX: suggestions come only from SCSS/CSS files it imports
---   HTML:    suggestions come only from stylesheets linked via <link>
---   SCSS/CSS:suggestions come only from JSX/TSX/HTML files that import this file

local cache = {}
local cache_ttl = 5

--- Escape Lua pattern magic characters in a string so it can be used
--- as a literal pattern fragment. Covers all magic chars: ^ $ ( ) % . [ ] * + - ?
local function escape_pattern(str)
  return (str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
end

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
      "-name", "*.tsx", "-o",
      "-name", "*.html",
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
local function parse_jsx_classes(filepath)
  local content = vim.fn.readfile(filepath)
  if not content or #content == 0 then return {} end

  local text = table.concat(content, "\n")
  local classes = {}
  local seen = {}

  for val in text:gmatch('className="([^"]*)"') do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  for val in text:gmatch("className='([^']*)'") do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  for val in text:gmatch("className[=]`([^`]*)`") do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  return classes
end

--- Parse HTML class names from class="..." attributes.
local function parse_html_classes(filepath)
  local content = vim.fn.readfile(filepath)
  if not content or #content == 0 then return {} end

  local text = table.concat(content, "\n")
  local classes = {}
  local seen = {}

  for val in text:gmatch('class="([^"]*)"') do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  for val in text:gmatch("class='([^']*)'") do
    for cls in val:gmatch("[%w_%-]+") do
      if not seen[cls] then seen[cls] = true; table.insert(classes, cls) end
    end
  end

  return classes
end

--- Parse JSX/TSX import statements to find imported CSS/SCSS files.
--- Handles:
---   import './styles.scss'
---   import styles from './styles.module.scss'
---   import './styles.css'
local function parse_tsx_imports(filepath)
  local lines = vim.fn.readfile(filepath)
  if not lines or #lines == 0 then return {} end

  local result = {}
  local seen = {}
  local dir = vim.fn.fnamemodify(filepath, ":h")

  for _, line in ipairs(lines) do
    local path

    -- import './foo.scss' or import "./foo.scss" (bare import, no `from`)
    path = line:match("^%s*import%s+['\"]([^'\"]+%.s?c?[sa][cs][cs]?)['\"]%s*$")
    if not path then
      -- import x from './foo.scss' or import { x } from './foo.scss'
      path = line:match("^%s*import%s+.+%s+from%s+['\"]([^'\"]+%.s?c?[sa][cs][cs]?)['\"]")
    end

    -- Skip npm package imports (starting with ~ or @ or a bare name)
    if path and not path:match("^[~@]") and not path:match("^[%w_][%w_%-]*/") then
      local resolved = vim.fn.resolve(dir .. "/" .. path)
      if vim.fn.filereadable(resolved) == 1 and not seen[resolved] then
        seen[resolved] = true
        table.insert(result, resolved)
      end
    end
  end
  return result
end

--- Parse HTML for <link rel="stylesheet" href="..."> tags
local function parse_html_links(filepath)
  local content = vim.fn.readfile(filepath)
  if not content then return {} end
  local text = table.concat(content, "\n")

  local result = {}
  local seen = {}
  local dir = vim.fn.fnamemodify(filepath, ":h")

  -- Double-quoted href
  for href in text:gmatch('<link[^>]-href="([^"]+%.s?c?[sa][cs][cs]?)"') do
    if not href:match("^https?://") and not seen[href] then
      seen[href] = true
      local resolved = vim.fn.resolve(dir .. "/" .. href)
      if vim.fn.filereadable(resolved) == 1 then
        table.insert(result, resolved)
      end
    end
  end

  -- Single-quoted href
  for href in text:gmatch("<link[^>]-href='([^']+%.s?c?[sa][cs][cs]?)'") do
    if not href:match("^https?://") and not seen[href] then
      seen[href] = true
      local resolved = vim.fn.resolve(dir .. "/" .. href)
      if vim.fn.filereadable(resolved) == 1 then
        table.insert(result, resolved)
      end
    end
  end

  return result
end

--- Build a complete project index:
---   file_classes[path] = { classes = [...], type = "scss"|"jsx"|"html" }
---   forward_map[path]  = { imported/stylesheet paths }   (for JSX/TSX/HTML)
---   reverse_map[path]  = { importing file paths }        (for SCSS/CSS)
local function build_index(project_root)
  local files = find_project_files(project_root)

  local file_classes = {}
  local forward_map = {}
  local reverse_map = {}

  -- Phase 1: parse all files for their class names
  for _, filepath in ipairs(files) do
    local classes
    local file_type

    if filepath:match("%.jsx$") or filepath:match("%.tsx$") then
      classes = parse_jsx_classes(filepath)
      file_type = "jsx"
    elseif filepath:match("%.html$") then
      classes = parse_html_classes(filepath)
      file_type = "html"
    else
      classes = parse_scss_classes(filepath)
      file_type = "scss"
    end

    file_classes[filepath] = { classes = classes, type = file_type }
  end

  -- Phase 2: build forward + reverse dependency maps
  for _, filepath in ipairs(files) do
    local info = file_classes[filepath]
    if not info then goto skip end

    if info.type == "jsx" then
      local imports = parse_tsx_imports(filepath)
      forward_map[filepath] = imports
      for _, scss_path in ipairs(imports) do
        if not reverse_map[scss_path] then
          reverse_map[scss_path] = {}
        end
        table.insert(reverse_map[scss_path], filepath)
      end
    elseif info.type == "html" then
      local links = parse_html_links(filepath)
      forward_map[filepath] = links
      for _, css_path in ipairs(links) do
        if not reverse_map[css_path] then
          reverse_map[css_path] = {}
        end
        table.insert(reverse_map[css_path], filepath)
      end
    end

    ::skip::
  end

  return {
    file_classes = file_classes,
    forward_map = forward_map,
    reverse_map = reverse_map,
  }
end

--- Get scoped class completions for a given file.
local function get_scoped_classes(filepath, index)
  local info = index.file_classes[filepath]
  if not info then return {} end

  local ft = vim.bo.filetype
  local seen = {}
  local result = {}

  local function add_classes(classes)
    for _, cls in ipairs(classes) do
      if not seen[cls] then
        seen[cls] = true
        table.insert(result, cls)
      end
    end
  end

  if info.type == "jsx" then
    -- JSX/TSX: suggest classes from imported stylesheets
    local imports = index.forward_map[filepath] or {}
    for _, scss_path in ipairs(imports) do
      local scss_info = index.file_classes[scss_path]
      if scss_info then
        add_classes(scss_info.classes)
      end
    end

  elseif info.type == "html" then
    -- HTML: suggest classes from linked stylesheets
    local links = index.forward_map[filepath] or {}
    for _, css_path in ipairs(links) do
      local css_info = index.file_classes[css_path]
      if css_info then
        add_classes(css_info.classes)
      end
    end

  elseif info.type == "scss" then
    -- SCSS: suggest className usages from files that import this stylesheet,
    -- plus classes declared in this file itself (so you can &-nest against them)
    add_classes(info.classes)

    local importers = index.reverse_map[filepath] or {}
    for _, importing_path in ipairs(importers) do
      local importer_info = index.file_classes[importing_path]
      if importer_info then
        add_classes(importer_info.classes)
      end
    end
  end

  table.sort(result)
  return result
end

--- Get all scoped classes with caching
local function get_cached(project_root, current_file)
  local now = vim.loop.now()
  local cached = cache[project_root]

  if cached and (now - cached.cache_time) < cache_ttl then
    return get_scoped_classes(current_file, cached.index)
  end

  local index = build_index(project_root)
  cache[project_root] = { index = index, cache_time = now }
  return get_scoped_classes(current_file, index)
end

-- Exposed for the <leader>sc keybind
local source_refresh = function() cache = {} end

-- Auto-refresh cache when entering insert mode
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
      for i = #context, 1, -1 do
        if context[i].indent >= indent then
          table.remove(context, i)
        end
      end
    else
      -- Check if this line starts a block with a class
      local class = trimmed:match("^%.([%w_%-]+)%s*{")
      if not class then
        class = trimmed:match("^&([%w_%-]+)%s*{")
        if class and #context > 0 then
          class = context[#context].name .. class
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
  local current_file = vim.api.nvim_buf_get_name(0)
  local classes = get_cached(project_root, current_file)

  -- Detect SCSS context for & completions
  local scss_ctx = nil
  if vim.bo.filetype == "scss" then
    scss_ctx = get_scss_context()
  end

  -- Detect if user is already typing &-prefixed (e.g. "&__" or "&--")
  -- so we can suppress full class names and only show &-shortened variants
  local is_amp_input = false
  if scss_ctx then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1] or ""
    local before_cursor = line:sub(1, cursor[2])
    local last_token = before_cursor:match("(%S+)$")
    if last_token and last_token:match("^&") then
      is_amp_input = true
    end
  end

  local items = {}
  for _, cls in ipairs(classes) do
    local suffix = scss_ctx and cls:match("^" .. escape_pattern(scss_ctx) .. "([%_%-].+)$")

    if is_amp_input then
      -- User typed &: only show &-shortened variants, skip full names entirely
      if suffix then
        table.insert(items, {
          label = "&" .. suffix,
          kind = 15,
          detail = "(SCSS & shorthand)",
        })
      end
    else
      -- Normal input: show full class name, and add & variant as an extra
      table.insert(items, {
        label = cls,
        kind = 15,
        detail = "(CSS class)",
      })
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
