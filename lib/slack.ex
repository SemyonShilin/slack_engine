defmodule Engine.Slack do
  @moduledoc """

  """

  use GenServer
  alias Engine.BotLogger
  alias Engine.Slack.{HubHanlder, RequestHandler}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Engine.Slack::#{opts.name}"])
  end

  def init(opts) do
    BotLogger.info(:console, "Slack bot #{opts.name} started.")

    {:ok, opts}
  end

  def message_pass(bot_name, hub, message) do
    GenServer.cast(:console, :"#Engine.Slack::#{bot_name}", {:message, hub, message})
  end

  def pre_down(bot_name) do
    :ok
  end

  def handle_cast({:message, message}, state) do
    {:noreply, state}
  end

  def handle_cast({:message, _hub, message}, state) do
    RequestHandler.answer(
      "#Engine.Slack.RequestHandler::#{state[:name]}",
      {:message, message}
    )

    {:noreply, state}
  end
end
