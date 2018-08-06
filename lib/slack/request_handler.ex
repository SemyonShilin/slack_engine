defmodule Engine.Slack.RequestHandler do
  @moduledoc false

  use Slack
  alias Engine.Slack.HubHanlder
  alias Engine.Slack

  def answer(process, tuple) do
    send(process, tuple)
  end

  def handle_connect(slack, state) do
    Slack.logger().info("#{slack.me.name} connected ")

    {:ok, state}
  end

  def handle_event(message = %{type: "message"}, slack, state) do
    Slack.logger().info("You have just received message. #{format_request_for_log(message, slack)}")

    HubHanlder.handle({message, slack, state})

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, _hub,  %{"data" => %{"messages" => messages, "chat" => %{"id" => id}}} = _message}, slack, state) do
    names =
      slack.users
      |> Enum.map(fn {key, val} -> val.name end)
    IO.inspect names
    channel =
      slack.users
      |> Enum.find(fn {key, val} -> val.name == id end)
      |> elem(0)

    messages
    |> HubHanlder.parse_hub_response()
    |> Enum.filter(& &1)
    |> Enum.each(fn (mess) ->
      send_message(mess.text, channel, slack)
      Slack.logger().info("You have just sent message. #{find_user_name(channel, slack)} : #{mess.text}")
    end)

    {:ok, state}
  end

  def handle_info({:message, %{channel: channel, text: text} = _message}, slack, state) do
    send_message(text, channel, slack)

    Slack.logger().info("You have just sent message. #{channel} : #{text}")
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  def handle_close(reason, _, state) do
    IO.inspect reason
    {:ok, state}
  end

  defp format_request_for_log(message, slack) do
    "#{find_user_name(message.user, slack)} in #{message.channel} say #{message.text}"
  end

  defp find_user_name(user_id, slack) do
    user =
      slack.users
      |> Enum.find(fn {key, val} -> key == user_id end)
      |> elem(1)

    user.profile.real_name
  end
end
