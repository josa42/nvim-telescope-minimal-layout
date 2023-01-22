local ok, telescope = pcall(require, 'telescope')

if not ok then
  error('Install nvim-telescope/telescope.nvim to use josa42/nvim-telescope-minimal-layout.')
end

return telescope.register_extension({
  setup = function()
    local layout_strategies = require('telescope.pickers.layout_strategies')
    function layout_strategies:minimal(max_columns, max_lines, config)
      local border = self.window.borderchars

      config = vim.tbl_extend('keep', self.layout_config.minimal or {}, {
        prompt_position = 'top',
        prompt_min_width = 40,
        prompt_max_width = 80,
        preview_width = 80,
      })

      if config.prompt_min_width > config.prompt_max_width then
        config.prompt_min_width = config.prompt_max_width
      end

      config.preview_cutoff = config.preview_width + config.prompt_min_width
      config.max_width = config.preview_width + config.prompt_max_width

      local layout = layout_strategies.horizontal(self, max_columns, max_lines, {
        horizontal = {
          prompt_position = config.prompt_position,
          width = function(self, max_width)
            if self.previewer == nil or max_width < config.preview_cutoff then
              return config.prompt_max_width
            end
            return math.min(max_width, config.max_width)
          end,
          height = function(_, _, max_height)
            return math.min(math.max(max_height - 4, 10), 40)
          end,
          preview_width = config.preview_width,
          preview_cutoff = config.preview_cutoff,
        },
      })
      return vim.tbl_deep_extend('force', layout, {
        prompt = {
          title = false,
          borderchars = border,
        },
        results = {
          title = false,
          line = layout.results.line - 1,
          height = layout.results.height + 1,
          borderchars = { border[1], ' ', ' ', ' ', border[8], border[7], ' ', ' ' },
        },
        preview = layout.preview and {
          title = false,
          borderchars = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        } or nil,
        --
      })
    end
  end,
  exports = {},
})
