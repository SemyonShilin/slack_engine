defmodule Engine.Slack.Spec do
  @moduledoc """
    Speck for a slack to run engine in the supervisor
  """

  def engine_spec(bot_name, token) do
    [
      {Engine.Slack, Engine.Slack.BotConfig.get(bot_name, token)},
      {Engine.Slack.HubHanlder, Engine.Slack.BotConfig.get(bot_name, token)},
      slack_bot_spec(%{bot_name: bot_name, token: token})
    ]
  end

  def slack_bot_spec(%{bot_name: bot_name, token: token}) do
    %{
      id: Slack.Bot,
      start: {Slack.Bot, :start_link,
        [Engine.Slack.RequestHandler,
          [name: "#Engine.Slack.RequestHandler::#{bot_name}", token: token],
          token,
          %{name: "#Engine.Slack.RequestHandler::#{bot_name}"}] }
    }
  end
end
