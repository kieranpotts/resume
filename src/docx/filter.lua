--[[
Pandoc Lua filter for the Word (.docx) build of the CV.

Pandoc's LaTeX reader turns the CV into a generic document: centred blocks,
minipages, headings, bullet lists, and tables. This filter maps that structure
onto the custom styles defined in `reference.docx`, so the Word document follows
the PDF's design as closely as Word allows:

- The name and specialisms row become the document title and subtitle.
- The intro and footer lines get their own centred paragraph styles.
- The three skills columns become a borderless three-column table.
- Bullet items become "CV Bullet" paragraphs, with the last item of each list
  styled "CV Bullet Last", so each list stays on one page with its heading.
- The contact details and employment history tables get their own table styles.
- Engagement headings set the company in small caps, the rest smaller.
- Every `·` separator is greyed out, in the "Quiet" character style.

Run by `run/build-docx`, after `macros.tex` has simplified the CV's macros.
]]

local function styled_div(style, blocks)
  return pandoc.Div(blocks, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

local function styled_span(style, inlines)
  return pandoc.Span(inlines, pandoc.Attr('', {}, { ['custom-style'] = style }))
end

local function has_class(el, class)
  return el.classes and el.classes:includes(class)
end

-- The inline content of a block, if it is a paragraph.
local function inlines_of(block)
  if block.t == 'Para' or block.t == 'Plain' then
    return block.content
  end
end

-- Pandoc wraps some content in empty spans, eg. from `\small{...}`. Unwrap them.
local function unwrap_spans(inlines)
  return pandoc.Inlines(inlines):walk({
    Span = function(span)
      if span.identifier == '' and #span.classes == 0 and #span.attributes == 0 then
        return span.content
      end
    end,
  })
end

-- Drop leading and trailing spaces and line breaks.
local function trim(inlines)
  local blank = { Space = true, SoftBreak = true, LineBreak = true }
  while #inlines > 0 and blank[inlines[1].t] do inlines:remove(1) end
  while #inlines > 0 and blank[inlines[#inlines].t] do inlines:remove(#inlines) end
  return inlines
end

-- "KIERAN POTTS" -> "Kieran Potts". The title style capitalises it again for display.
local function title_case(text)
  return (text:lower():gsub("(%a)([%w']*)", function(first, rest)
    return first:upper() .. rest
  end))
end

-- A bullet list, as styled paragraphs.
local function bullet_paragraphs(list)
  local blocks = pandoc.Blocks({})
  for i, item in ipairs(list.content) do
    local style = (i == #list.content) and 'CV Bullet Last' or 'CV Bullet'
    local inlines = pandoc.Inlines({})
    for _, block in ipairs(item) do
      local content = inlines_of(block)
      if content then
        if #inlines > 0 then inlines:insert(pandoc.Space()) end
        inlines:extend(content)
      end
    end
    blocks:insert(styled_div(style, { pandoc.Para(trim(unwrap_spans(inlines))) }))
  end
  return blocks
end

-- A skills column is a minipage holding a label paragraph and a bullet list.
local function is_skills_column(block)
  if block.t ~= 'Div' or not has_class(block, 'minipage') then return false end
  local first, second = block.content[1], block.content[2]
  return #block.content == 2 and first and inlines_of(first) ~= nil
      and second and second.t == 'BulletList'
end

local function skills_cell(column)
  local label = trim(unwrap_spans(pandoc.utils.blocks_to_inlines({ column.content[1] })))
  -- The label is set in small caps by its paragraph style.
  label = label:walk({ SmallCaps = function(sc) return sc.content end })
  local blocks = pandoc.Blocks({ styled_div('Skills Label', { pandoc.Para(label) }) })
  blocks:extend(bullet_paragraphs(column.content[2]))
  return blocks
end

local function skills_table(columns)
  local widths, aligns, cells = {}, {}, {}
  for i, column in ipairs(columns) do
    widths[i] = 1 / #columns
    aligns[i] = pandoc.AlignLeft
    cells[i] = skills_cell(column)
  end
  local simple = pandoc.SimpleTable({}, aligns, widths, {}, { cells })
  local tbl = pandoc.utils.from_simple_table(simple)
  tbl.attr = pandoc.Attr('', {}, { ['custom-style'] = 'SkillsTable' })
  return tbl
end

-- Pandoc reads the first row of a LaTeX tabular as a header row. The CV's
-- tables have no header, so move every row into the body.
local function headless(tbl)
  local rows = pandoc.List({})
  rows:extend(tbl.head.rows)
  for _, body in ipairs(tbl.bodies) do rows:extend(body.body) end
  tbl.head = pandoc.TableHead({})
  tbl.bodies = { { attr = pandoc.Attr(), row_head_columns = 0, head = {}, body = rows } }
  return tbl
end

local function contact_table(tbl)
  tbl = headless(tbl)
  tbl.colspecs = { { pandoc.AlignLeft, 0.5 }, { pandoc.AlignRight, 0.5 } }
  tbl.attr = pandoc.Attr('', {}, { ['custom-style'] = 'ContactTable' })
  return tbl
end

local function history_table(tbl)
  tbl = headless(tbl)
  tbl.colspecs = { { pandoc.AlignLeft, 0.16 }, { pandoc.AlignLeft, 0.84 } }
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      for _, cell in ipairs(row.cells) do
        local inlines = trim(unwrap_spans(pandoc.utils.blocks_to_inlines(cell.contents)))
        cell.contents = { styled_div('History Cell', { pandoc.Para(inlines) }) }
      end
    end
  end
  tbl.attr = pandoc.Attr('', {}, { ['custom-style'] = 'HistoryTable' })
  return tbl
end

-- "Company Role (type) · dates": the company stays in small caps at the
-- heading size, the rest is set smaller. Drops "()" for an empty type.
local function engagement_heading(header)
  local content = unwrap_spans(header.content)
  local company = content[1]
  if not company or company.t ~= 'SmallCaps' then return header end
  local rest = pandoc.Inlines({})
  for i = 2, #content do
    local el = content[i]
    if not (el.t == 'Str' and el.text == '()') then rest:insert(el) end
  end
  rest = trim(rest)
  -- Collapse the double space an empty "()" leaves behind.
  local detail = pandoc.Inlines({})
  for _, el in ipairs(rest) do
    if not (el.t == 'Space' and #detail > 0 and detail[#detail].t == 'Space') then
      detail:insert(el)
    end
  end
  -- An em space separates the company from the role, as `\quad` does in the PDF.
  header.content = { company, pandoc.Str('\u{2003}'), styled_span('HeadingDetail', detail) }
  header.identifier = ''
  return header
end

-- Flatten minipages, which only exist in the PDF to stop page breaks.
local function flatten(blocks)
  local out = pandoc.Blocks({})
  for _, block in ipairs(blocks) do
    if block.t == 'Div' and has_class(block, 'minipage') and not is_skills_column(block) then
      out:extend(flatten(block.content))
    else
      out:insert(block)
    end
  end
  return out
end

function Pandoc(doc)
  local blocks = flatten(doc.blocks)
  local out = pandoc.Blocks({})
  local centres, section = 0, nil
  local i = 1

  while i <= #blocks do
    local block = blocks[i]

    if block.t == 'Div' and has_class(block, 'center') then
      centres = centres + 1
      local inlines = trim(unwrap_spans(pandoc.utils.blocks_to_inlines(block.content)))
      if centres == 1 then
        doc.meta.title = pandoc.Inlines({ pandoc.Str(title_case(pandoc.utils.stringify(inlines))) })
      elseif centres == 2 then
        doc.meta.subtitle = inlines:walk({ SmallCaps = function(sc) return sc.content end })
      elseif i == #blocks then
        out:insert(styled_div('CV Footer', { pandoc.Para(inlines) }))
      else
        out:insert(styled_div('Intro', { pandoc.Para(inlines) }))
      end
      i = i + 1

    elseif is_skills_column(block) then
      local columns = {}
      while i <= #blocks and is_skills_column(blocks[i]) do
        table.insert(columns, blocks[i])
        i = i + 1
      end
      out:insert(skills_table(columns))

    elseif block.t == 'Header' then
      if block.level == 1 then
        section = pandoc.utils.stringify(block.content)
        block.identifier = ''
        out:insert(block)
      else
        out:insert(engagement_heading(block))
      end
      i = i + 1

    elseif block.t == 'BulletList' then
      out:extend(bullet_paragraphs(block))
      i = i + 1

    elseif block.t == 'Table' then
      -- The contact details come before the first section heading.
      if section == nil then
        out:insert(contact_table(block))
      else
        out:insert(history_table(block))
      end
      i = i + 1

    else
      out:insert(block)
      i = i + 1
    end
  end

  -- Grey out the `·` separators, wherever they are, and widen the spaces on
  -- either side to en spaces, as `\hspace{0.5em}` does in the PDF.
  local en_space = '\u{2002}'
  local function quiet(inlines)
    local result = pandoc.Inlines({})
    for i, el in ipairs(inlines) do
      if el.t == 'Str' and el.text == '·' then
        if #result > 0 and result[#result].t == 'Space' then
          result[#result] = pandoc.Str(en_space)
        end
        result:insert(styled_span('Quiet', { el }))
        if inlines[i + 1] and inlines[i + 1].t == 'Space' then
          inlines[i + 1] = pandoc.Str(en_space)
        end
      else
        result:insert(el)
      end
    end
    return result
  end
  doc.blocks = out:walk({ Inlines = quiet })
  doc.meta.subtitle = doc.meta.subtitle and pandoc.Inlines(doc.meta.subtitle):walk({ Inlines = quiet })

  return doc
end
