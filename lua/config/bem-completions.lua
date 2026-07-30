--- Custom blink.cmp source that dynamically generates BEM child class completions
--- based on the nearest parent JSX element's className.
---
--- Unlike scss-completions (which reads actual SCSS files), this source generates
--- completions on-the-fly so you get BEM suggestions even before the class exists
--- in any stylesheet.
---
--- Example:
---   <div className="home-page__buy">
---     <div className="          ← typing here → gets "home-page__buy-title", "home-page__buy-content", etc.
---   </div>

--- (No common elements needed — we just suggest the parent BEM prefix)

--- Extract BEM class names (containing __ or --) from a className attribute value.
--- Returns only the first BEM class (typically the block element).
local function extract_bem_classes(attr_value)
  local classes = {}
  for cls in attr_value:gmatch("[%w_%-]+") do
    if cls:find("__", 1, true) or cls:find("--", 1, true) then
      table.insert(classes, cls)
    end
  end
  return classes
end

--- Find the nearest enclosing JSX element with a BEM className, scanning
--- backwards from the cursor. Uses a simple tag-stack approach.
---
--- Returns a list of BEM class names from innermost to outermost.
local function find_parent_bem_classes()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor[1] - 1 -- 0-indexed
  local cursor_col = cursor[2]

  local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_row + 1, false)
  if #lines == 0 then
    return {}
  end

  -- Stack: { tag = string, classes = string[] }
  local open_tags = {}

  -- Walk top-to-bottom, push opening tags, pop on closing tags.
  -- At the end, whatever is on the stack is still open. The innermost one
  -- (top of stack) whose tag has BEM classes is our parent.
  --
  -- Note: we use the full line for each row (not truncated at cursor column)
  -- because nvim's cursor column is 0-indexed and gets clamped to #line-1,
  -- which would miss the last character when cursor is at end of line.

  for row = 0, cursor_row do
    local line = lines[row + 1]
    if not line then
      break
    end

    local content = line

    -- Process this line's tags in order: openings first, then closings.
    -- This handles single-line elements like <div>text</div> correctly:
    -- the opening div gets pushed, then its closing tag pops it.
    -- (Previous code did closings-first, which left single-line parents open.)

    -- 1) Find and push ALL opening tags first
    local tags_on_line = {}
    local pos = 1
    while pos <= #content do
      local open_start = content:find("<", pos)
      if not open_start then
        break
      end

      -- Skip closing tags </tag> — handled in step 2
      if content:sub(open_start, open_start + 1) == "</" then
        pos = open_start + 2
        goto continue
      end

      -- Find the end of this tag
      local tag_end = content:find(">", open_start)
      if not tag_end then
        pos = open_start + 1
        goto continue
      end

      local tag_content = content:sub(open_start + 1, tag_end - 1)

      -- Skip comments
      if tag_content:match("^!%-%-") then
        pos = tag_end + 1
        goto continue
      end

      -- Skip self-closing
      if tag_content:match("/%s*$") then
        pos = tag_end + 1
        goto continue
      end

      local tag_name = tag_content:match("^([%w_%-]+)")
      if not tag_name then
        pos = tag_end + 1
        goto continue
      end

      local attrs = tag_content:sub(#tag_name + 1)
      local class_attr = attrs:match('className="([^"]*)"')
        or attrs:match("className='([^']*)'")
        or attrs:match("class='([^']*)'")
        or attrs:match('class="([^"]*)"')

      -- Record this opening tag for later processing
      table.insert(tags_on_line, {
        tag = tag_name,
        class_attr = class_attr,
      })

      pos = tag_end + 1
      ::continue::
    end

    -- 2) For each opening tag on this line, check if it has a matching
    --    closing tag later on the same line. If not, it stays open.
    --    We scan closing tags from the content for each opening tag.
    for _, entry in ipairs(tags_on_line) do
      -- Check if there's a matching </tag> on this line
      local close_pattern = "</" .. entry.tag .. "%s*>"
      if content:match(close_pattern) then
        -- Remove one occurrence from content so we don't match it again
        content = content:gsub(close_pattern, "", 1)
      else
        -- No matching closing tag → this tag stays open
        if entry.class_attr then
          local bem_classes = extract_bem_classes(entry.class_attr)
          if #bem_classes > 0 then
            table.insert(open_tags, {
              tag = entry.tag,
              classes = bem_classes,
            })
          end
        else
          -- Tag without className, still track for nesting
          table.insert(open_tags, {
            tag = entry.tag,
            classes = {},
          })
        end
      end
    end

    -- 3) Handle orphan closing tags on this line (no matching opening on the
    --    same line). These pop from the ancestor stack.
    for closing_tag in content:gmatch("</([%w_%-]+)%s*>") do
      for i = #open_tags, 1, -1 do
        if open_tags[i].tag == closing_tag then
          table.remove(open_tags, i)
          break
        end
      end
    end
  end

  if #open_tags == 0 then
    return {}
  end

  -- Collect all BEM classes from open tags (innermost first)
  local result = {}
  for i = #open_tags, 1, -1 do
    for _, cls in ipairs(open_tags[i].classes) do
      table.insert(result, cls)
    end
  end

  return result
end

--- Check if the cursor is in a context where className completions make sense.
--- Returns the prefix the user has typed so far for filtering.
local function get_completion_context(before_cursor)
  -- Context 1: Inside a className="..." or className='...' attribute
  -- Use plain find to avoid Lua pattern escaping complexity.
  local class_attr_start = before_cursor:find('className=', 1, true)
  if class_attr_start then
    local after_equals = before_cursor:sub(class_attr_start + 10)
    if after_equals:match('^["\']') then
      return "class_attr"
    end
  end

  -- Context 2: After a tag prefix, like `div.` or `span.prefix`
  if before_cursor:match("([%w_%-]+)%.([%w_%-]*)$") then
    return "emmet_abbr"
  end

  -- Not in a className context
  return nil
end

--- Generate BEM parent prefix completions.
--- Just gives the parent class name with a trailing `-` as a starting line,
--- so you can add your own element name after it.
local function generate_bem_completions(parent_classes)
  local items = {}
  local seen = {}

  for _, parent_class in ipairs(parent_classes) do
    local block = parent_class:match("^([%w_%-]+)__")
      or parent_class:match("^([%w_%-]+)%-%-")
      or parent_class

    -- Extended BEM: {parent}-  (e.g. home-page__buy-)
    local extended = parent_class .. "-"
    if not seen[extended] then
      seen[extended] = true
      table.insert(items, {
        label = extended,
        kind = 15,
        detail = "(BEM prefix from " .. parent_class .. ")",
      })
    end

    -- Flat BEM: {block}__  (e.g. home-page__)
    local flat = block .. "__"
    if not seen[flat] then
      seen[flat] = true
      table.insert(items, {
        label = flat,
        kind = 15,
        detail = "(BEM block prefix from " .. block .. ")",
      })
    end
  end

  return items
end

--- blink.cmp Source
local Source = {}

function Source.new(_, _config)
  return setmetatable({}, { __index = Source })
end

function Source:enabled()
  local ft = vim.bo.filetype
  return ft == "javascriptreact"
    or ft == "typescriptreact"
    or ft == "html"
    or ft == "javascript"
    or ft == "typescript"
end

function Source:get_completions(context, resolve)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, cursor[1] - 1, cursor[1], false)[1] or ""
  local ctx_type = get_completion_context(line)

  -- Only activate in className or emmet abbreviation contexts
  if not ctx_type then
    resolve({ items = {} })
    return
  end

  -- Find parent BEM classes
  local parent_classes = find_parent_bem_classes()

  if #parent_classes == 0 then
    resolve({ items = {} })
    return
  end

  -- Generate BEM prefix completions (just the parent class + dash)
  local items = generate_bem_completions(parent_classes)

  resolve({ items = items })
end

return Source
