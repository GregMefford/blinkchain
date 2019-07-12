defmodule Blinkchain.Config do
  @moduledoc """
  Represents the placement of the NeoPixel devices on the virtual drawing canvas.
  """

  alias Blinkchain.Config

  alias Blinkchain.Config.{
    Canvas,
    Channel
  }

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          canvas: Canvas.t(),
          channel0: Channel.t(),
          channel1: Channel.t(),
          dma_channel: non_neg_integer()
        }

  defstruct [
    :canvas,
    :channel0,
    :channel1,
    :dma_channel
  ]

  @doc """
  Build a `t:Blinkchain.Config.t/0` struct based on Application configuration.
  """
  @spec load(Keyword.t() | nil) :: Config.t()
  def load(nil) do
    :blinkchain
    |> Application.get_all_env()
    |> load()
  end

  def load(config) when is_list(config) do
    canvas =
      config
      |> Keyword.get(:canvas)
      |> load_canvas_config()

    channel0 =
      config
      |> Keyword.get(:channel0)
      |> Channel.new(0)

    channel1 =
      config
      |> Keyword.get(:channel1)
      |> Channel.new(1)

    %Config{
      canvas: canvas,
      channel0: channel0,
      channel1: channel1,
      dma_channel: Application.get_env(:blinkchain, :dma_channel, 5)
    }
  end

  # Private Helpers

  defp load_canvas_config({width, height}), do: Canvas.new(width, height)
  defp load_canvas_config(_), do: raise(":blinkchain :canvas dimensions must be configured as {width, height}")
end
