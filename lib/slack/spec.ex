defmodule Engine.Slack.Spec do
  @moduledoc """
    Speck for a slack to run engine in the supervisor
  """

  def engine_spec(bot_name, token) do
    [
      {Engine.Slack, Engine.Slack.BotConfig.get(bot_name, token)},
      {Engine.Slack.HubHanlder, Engine.Slack.BotConfig.get(bot_name, token)},
      {Slack.Bot, Engine.Slack.RequestHandler,
                  [name: "#Engine.Slack.RequestHandler::#{bot_name}", token: token],
                  token,
                  %{name: "#Engine.Slack.RequestHandler::#{bot_name}"}}
    ]
  end
end
