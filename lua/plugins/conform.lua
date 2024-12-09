return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      black = {
        prepend_args = { "--line-length=100", "--target-version=py310" },
      },
    },
  },
}
