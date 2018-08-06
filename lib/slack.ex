defmodule Engine.Slack do
  @moduledoc """

  """

  use GenServer
  alias Engine.BotLogger
  alias Engine.Slack.{HubHanlder, RequestHandler}

  @slack_engine Application.get_env(:slack_engine, Engine.Slack)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Engine.Slack::#{opts.name}"])
  end

  def init(opts) do
    logger().info("Slack bot #{opts.name} started.")

    {:ok, opts}
  end

  def message_pass(bot_name, hub, message) do
    GenServer.cast(:"#Engine.Slack::#{bot_name}", {:message, hub, message})
  end

  def pre_down(bot_name) do
    :ok
  end

  def handle_cast({:message, message}, state) do
    {:noreply, state}
  end

  def handle_cast({:message, hub, message}, state) do
    RequestHandler.answer(
      :"#Engine.Slack.RequestHandler::#{state[:name]}",
      {:message, hub, message}
    )

    {:noreply, state}
  end

  def logger() do
    @slack_engine
    |> Keyword.get(:logger)
  end

  def hub_client do
    @slack_engine
    |> Keyword.get(:hub_client)
  end

  def get_bot_fn do
    @slack_engine
    |> Keyword.get(:get_bot_fn)
  end
end
