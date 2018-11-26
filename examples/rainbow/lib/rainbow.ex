defmodule Rainbow do
  @moduledoc """
  This is the top-level API for this example project.
  """

  alias Blinkchain.Color

  # We might as well compute these at compile time instead of every time
  # the `colors` function gets called.
  @colors [
    Color.parse("#9400D3"),
    Color.parse("#4B0082"),
    Color.parse("#0000FF"),
    Color.parse("#00FF00"),
    Color.parse("#FFFF00"),
    Color.parse("#FF7F00"),
    Color.parse("#FF0000")
  ]

  @doc """
  Get a list of nice-looking rainbow colors.
  """
  def colors, do: @colors
end
