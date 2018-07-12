defmodule Engine.Slack.BotConfig do
  @moduledoc false

  def get(name, token) do
    config(name, token)
  end

  defp keyword_config(name, token) do
    [name: "#Engine.Slack.RequestHandler::#{name}", token: token]
  end

  defp config(name, token) do
    %{
      name: name,
      token: token
    }
  end
end
