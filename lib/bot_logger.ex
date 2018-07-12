defmodule Engine.BotLogger do
  @moduledoc false
  require Logger

#  @slack_engine Application.get_env(:slack_engine, Engine.Telegram)
#
#  def debug(message) do
#    @slack_engine
#    |> Keyword.get(:logger)
#    |> debug(message)
#  end
#
#  def info(message) do
#    @slack_engine
#    |> Keyword.get(:logger)
#    |> info(message)
#  end

  defp debug(:console, message) do
    Logger.debug fn -> "----> #{message} <----" end
  end

  def info(:console, message) do
    Logger.info fn -> "----> #{message} <----" end
  end

  defp debug(:file, message) do
  end

#  defp info(:file, message) do
#  end
end
