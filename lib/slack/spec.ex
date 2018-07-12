defmodule Engine.Telegram.Spec do
  @moduledoc """
    Speck for a telegram to run engine in the supervisor
  """

  def engine_spec(bot_name, token) do
    [
      {Engine.Slack, Engine.Slack.BotConfig.get(bot_name, token)},
      {Engine.Slack.HubHanlder, Engine.Slack.BotConfig.get(bot_name, token)},
      {Slack.Bot, Engine.Slack.RequestHandler, Engine.Slack.BotConfig.keyword_config(bot_name, token), token, %{name: "#Engine.Slack.RequestHandler::#{bot_name}"}}
    ]
  end
end
