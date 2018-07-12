defmodule Engine.Slack.HubHanlder do
  @moduledoc false

  use GenServer
  alias Engine.Slack.RequestHandler

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Engine.Slack.HubHanlder::#{opts[:name]}"])
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle({_, _, state} = tuple) do
    GenServer.cast(:"#Engine.Slack.HubHanlder::#{state[:name]}", tuple)  |> IO.inspect
  end

  def handle_cast({%{text: text} = message, slack, state}, opts) do
    RequestHandler.answer(
      slack.process,
      {:message, %{text: text <> " from adapter", channel: message.channel}}
    )

    {:noreply, opts}
  end

#  def handle_cast({message, slack, state}, opts) do
#    bot = adapter_bot.(opts.token)
#
#    %{"data" => response} =
#      %{data: message}
#      |> Map.merge(%{platform: "slack", uid: bot.uid})
#      |> call_hub()
#
#    {:noreply, opts}
#  end
#
#  defp call_hub(message) do
#    HTTPoison.start
#    with {:ok, %HTTPoison.Response{body: body}} =
#           HTTPoison.post(
#             System.get_env("DCH_POST"),
#             Poison.encode!(message),
#             [{"Content-Type", "application/json"}]
#           ) do
#      Poison.decode!(body)
#    end
#  end
#
#  defp adapter_bot do
#    :slack_engine
#    |> Application.get_env(:get_bot_fn)
#  end
end
