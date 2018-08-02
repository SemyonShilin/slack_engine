defmodule Engine.Slack.HubHanlder do
  @moduledoc false

  use GenServer
  alias Engine.Slack.RequestHandler
  alias Engine.Slack

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Engine.Slack.HubHanlder::#{opts[:name]}"])
  end

  def init(opts) do
    {:ok, opts}
  end

  def handle({_, _, state} = tuple) do
    GenServer.cast(:"#Engine.Slack.HubHanlder::#{state[:bot_name]}", tuple)
  end

  def handle_cast({%{text: text} = message, slack, state}, opts) do
    bot = adapter_bot().(opts.token)
    %{"data" => response} =
      %{data: message}
      |> Map.merge(%{platform: "slack", uid: bot.uid})
      |> call_hub().()

    response
    |> Map.get("messages", [])
    |> parse_hub_response()
    |> Enum.filter(& &1)
    |> Enum.each(fn (mess) ->
      reply_message({mess, message.channel, slack})
    end)

    {:noreply, opts}
  end

  defp reply_message({%{text: text, slash: slash}, channel, slack}) do
    reply_message(%{text: text, channel: channel}, slack)

    Enum.each(slash, fn(slash_list) ->
      reply_message(%{text: "#{slash_list.command} #{slash_list.text}", channel: channel}, slack)
    end)
  end

  defp reply_message({%{text: text, url: url}, channel, slack}) do
    reply_message(%{text: "#{text} #{url}", channel: channel}, slack)
  end

  defp reply_message(message = %{}, slack) do
    RequestHandler.answer(
      slack.process,
      {:message, message}
    )
  end

  def parse_hub_response(messages) do
    parse_hub_response(messages, [])
  end

  defp parse_hub_response([message | tail], formatted_messages) do
    messages =
      Enum.reduce(message, %{}, fn {k, v}, acc ->
        message_mapping().({k, v}, acc)
      end)

    parse_hub_response(tail, [messages | formatted_messages])
  end

  defp parse_hub_response([], updated_messages), do: updated_messages |> Enum.reverse

  defp message_mapping do
    fn {k, v}, acc ->
      case k do
        "body" -> Map.put(acc, :text, v)
        "menu" -> type_menu(v, acc)
        _ -> ""
      end
    end
  end

  defp type_menu(v, acc) do
    with %{"type" => type} <- v do
      case type do
        "inline"   -> ""
          Map.put(acc, :slash, format_menu_item(v))
        "keyboard" -> ""
        "auth"     -> ""
        _          -> ""
      end
    end
  end

  defp format_menu_item(%{"items" => items}), do: format_menu_item(items, [])

  defp format_menu_item([%{"url" => url} = menu_item | tail], state) do
    new_state =
      [%{text: menu_item["name"], url: url}| state]
    format_menu_item(tail, new_state)
  end

  defp format_menu_item([%{"code" => code} = menu_item | tail], state) do
    new_state =
      [%{text: menu_item["name"], command: "{#{code}}", response_type: "in_channel"} | state]
    format_menu_item(tail, new_state)
  end

  defp format_menu_item([], state), do: state |> Enum.reverse

  def call_hub do
    fn message ->
      Slack.hub_client().call(message)
    end
  end

  defp adapter_bot() do
    with get_bot_fn <- Slack.get_bot_fn(),
         {func, _}  <- Code.eval_string(get_bot_fn) do
      func
    end
  end
end
