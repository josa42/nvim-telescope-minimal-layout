local ok, telescope = pcall(require, 'telescope')

if not ok then
  error('Install nvim-telescope/telescope.nvim to use josa42/nvim-telescope-minimal-layout.')
end

local empty_border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }

local function results_border(config, border)
  if config.prompt_position == 'top' then
    if config.results_border then
      return { border[1], border[2], border[3], border[4], '├', '┤', border[7], border[8] }
    end
    return { border[1], ' ', ' ', ' ', border[8], border[7], ' ', ' ' }
  end

  -- bottom prompt
  if config.results_border then
    return { border[1], border[2], border[3], border[4], border[5], border[6], '┤', '├' }
  end
  return { ' ', ' ', border[1], ' ', ' ', ' ', border[6], border[5] }
end

return telescope.register_extension({
  setup = function()
    local layout_strategies = require('telescope.pickers.layout_strategies')
    function layout_strategies:minimal(max_columns, max_lines, layout_config)
      layout_config = vim.tbl_extend('keep', self.layout_config.minimal or {}, self.layout_config or {}, {
        prompt_position = 'top',
        prompt_min_width = 40,
        prompt_max_width = 80,
        preview_width = 80,
        results_border = false,
        width = function(self, max_width)
          if not self.previewer or max_width < layout_config.preview_cutoff then
            return layout_config.prompt_max_width
          end
          return math.min(max_width, layout_config.max_width)
        end,
        height = function(_, _, max_height)
          return math.min(math.max(max_height - 4, 10), 40)
        end,
      })

      if layout_config.prompt_min_width > layout_config.prompt_max_width then
        layout_config.prompt_min_width = layout_config.prompt_max_width
      end

      layout_config.preview_cutoff = layout_config.preview_width + layout_config.prompt_min_width
      layout_config.max_width = layout_config.preview_width + layout_config.prompt_max_width

      local layout = layout_strategies.horizontal(self, max_columns, max_lines, {
        horizontal = layout_config,
      })

      local border = layout.results.borderchars

      if layout_config.prompt_position == 'top' then
        return vim.tbl_deep_extend('force', layout, {
          prompt = {
            title = false,
          },
          results = {
            title = false,
            line = layout.results.line - 1,
            height = layout.results.height + 1,
            borderchars = results_border(layout_config, border),
          },
          preview = layout.preview and {
            title = false,
            borderchars = empty_border,
          } or nil,
          --
        })
      end

      return vim.tbl_deep_extend('force', layout, {
        prompt = {
          title = false,
        },
        results = {
          title = false,
          height = layout.results.height + 1,
          borderchars = results_border(layout_config, border),
        },
        preview = layout.preview and {
          title = false,
          borderchars = empty_border,
        } or nil,
        --
      })
    end
  end,
  exports = {},
})
