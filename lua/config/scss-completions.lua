--- Custom blink.cmp source that scans SCSS/CSS files for class names
--- and provides completions when editing JSX/HTML.
--- Handles BEM-style SCSS nesting: .foo { &--bar {} } → "foo--bar"

local M = {}

-- Cache: file mtime -> { classes = {string}, cache_time = number }
local cache = {}
local cache_ttl = 5 -- seconds before re-scanning

--- Check if a given filetype is one we should complete in
function M.should_complete(filetype)
  return filetype == "javascriptreact"
    or filetype == "typescriptreact"
    or filetype == "html"
    or filetype == "css"
    or filetype == "scss"
end

--- Find all CSS/SCSS files in the project (node_modules / .git excluded)
local function find_css_files(project_root)
  if not project_root or project_root == "" then
    return {}
  end

  local find_cmd = {
    "find", project_root,
    "-type", "f",
    "\\(", "-name", "*.css", "-o", "-name", "*.scss", "\\",
    "!", "-path", "*/node_modules/*",
    "!", "-path", "*/.git/*",
    "!", "-path", "*/dist/*",
    "!", "-path", "*/build/*",
    "\\)",
  }

  local ok, result = pcall(vim.fn.system, table.concat(find_cmd, " "))
  if not ok or result == "" then
    return {}
  end

  -- Filter to only files that exist
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
--- Returns a set of unique class names (without the leading dot).
local function parse_classes(filepath)
  local lines = vim.fn.readfile(filepath)
  if not lines or #lines == 0 then
    return {}
  end

  local classes = {}
  local seen = {}
  local context = {}       -- stack: list of { name = "foo", indent = 2 }

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

    -- Calculate indentation level
    local leading = line:match("^(%s*)")
    local indent = leading and #leading or 0

    -- Close blocks at or deeper than current indent
    if trimmed:find("^}") then
      local pop_indent = nil
      for i = #context, 1, -1 do
        if context[i].indent >= indent then
          pop_indent = i
        end
      end
      if pop_indent then
        for _ = pop_indent, #context do
          table.remove(context)
        end
      end
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

--- Get all class names from the project, using cache
function M.get_classes(project_root)
  local now = vim.loop.now()
  local cached = cache[project_root]

  -- Return cache if still fresh
  if cached and (now - cached.cache_time) < cache_ttl then
    return cached.classes
  end

  local files = find_css_files(project_root)
  local all_classes = {}

  for _, filepath in ipairs(files) do
    local file_classes = parse_classes(filepath)
    for _, cls in ipairs(file_classes) do
      all_classes[cls] = true
    end
  end

  -- Convert to sorted list
  local class_list = {}
  for cls, _ in pairs(all_classes) do
    table.insert(class_list, cls)
  end
  table.sort(class_list)

  -- Cache it
  cache[project_root] = {
    classes = class_list,
    cache_time = now,
  }

  return class_list
end

--- Force refresh the cache
function M.refresh()
  cache = {}
end

--- blink.cmp source definition
--- The module exports a new() constructor as blink.cmp expects
function M.new(_opts, _config)
  local source = {
    name = "scss-classes",

    refresh = function()
      cache = {}
    end,

    enabled = function(ctx)
      return M.should_complete(ctx.filetype)
    end,

    get_completions = function(ctx, callback)
      local project_root = vim.fn.getcwd()
      local classes = M.get_classes(project_root)
      if #classes == 0 then
        callback({})
        return
      end

      local items = {}
      for _, cls in ipairs(classes) do
        table.insert(items, {
          label = cls,
          kind = 15, -- Value
          detail = "(SCSS class)",
        })
      end

      callback({
        items = items,
        is_incomplete_forward = false,
        is_incomplete_backward = false,
      })
    end,
  }

  return source
end

return M
