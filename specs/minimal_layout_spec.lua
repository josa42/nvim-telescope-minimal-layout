local telescope = require('telescope')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local previewers = require('telescope.previewers')
local layout_strategies = require('telescope.pickers.layout_strategies')

local borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }

local function layout(defaults, opts)
  opts = opts or {}

  require('telescope.config').clear_defaults()
  telescope.setup({
    defaults = vim.tbl_extend('force', { layout_strategy = 'minimal', borderchars = borderchars }, defaults or {}),
  })
  telescope.load_extension('minimal_layout')

  local picker = pickers.new({}, {
    finder = finders.new_table({ results = {} }),
    previewer = opts.previewer and previewers.vim_buffer_cat.new({}) or nil,
  })

  return layout_strategies.minimal(picker, opts.columns or 200, opts.lines or 50)
end

describe('minimal layout', function()
  it('limits the width to prompt_max_width without a previewer', function()
    local l = layout()

    assert.is_falsy(l.preview)
    assert.are.same(78, l.prompt.width)
    assert.are.same(78, l.results.width)
  end)

  it('shows the preview next to the prompt if there is enough space', function()
    local l = layout({}, { previewer = true })

    assert.are.same(80, l.preview.width)
    assert.are.same(76, l.prompt.width)
  end)

  it('hides the preview if there is not enough space', function()
    local l = layout({}, { previewer = true, columns = 100 })

    assert.is_falsy(l.preview)
    assert.are.same(78, l.prompt.width)
  end)

  it('respects layout_config.minimal', function()
    local l = layout({ layout_config = { minimal = { prompt_max_width = 60 } } })

    assert.are.same(58, l.prompt.width)
  end)

  it('removes all titles', function()
    local l = layout({}, { previewer = true })

    assert.is_false(l.prompt.title)
    assert.is_false(l.results.title)
    assert.is_false(l.preview.title)
  end)

  describe('prompt_position = top', function()
    it('attaches the results to the bottom of the prompt', function()
      local l = layout()

      assert.are.same(l.prompt.line + 2, l.results.line)
      assert.are.same(borderchars, l.prompt.borderchars)
      assert.are.same({ '─', ' ', ' ', ' ', '╰', '╯', ' ', ' ' }, l.results.borderchars)
    end)

    it('renders a border around the results with results_border', function()
      local l = layout({ layout_config = { minimal = { results_border = true } } })

      assert.are.same({ '─', '│', '─', '│', '├', '┤', '╯', '╰' }, l.results.borderchars)
    end)
  end)

  describe('prompt_position = bottom', function()
    it('attaches the results to the top of the prompt', function()
      local l = layout({ layout_config = { minimal = { prompt_position = 'bottom' } } })

      assert.are.same(l.prompt.line - 1, l.results.line + l.results.height)
      assert.are.same({ ' ', ' ', '─', ' ', ' ', ' ', '╮', '╭' }, l.results.borderchars)
    end)

    it('renders a border around the results with results_border', function()
      local l = layout({ layout_config = { minimal = { prompt_position = 'bottom', results_border = true } } })

      assert.are.same({ '─', '│', '─', '│', '╭', '╮', '┤', '├' }, l.results.borderchars)
    end)
  end)

  it('supports borderchars per window', function()
    local prompt = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' }
    local results = { '1', '2', '3', '4', '5', '6', '7', '8' }
    local l = layout({ borderchars = { prompt = prompt, results = results, preview = borderchars } })

    assert.are.same(prompt, l.prompt.borderchars)
    assert.are.same({ '1', ' ', ' ', ' ', '8', '7', ' ', ' ' }, l.results.borderchars)
  end)
end)
