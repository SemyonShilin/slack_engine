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
    Slack.logger().info("You have just received message. #{format_request_for_log(message)}")

    HubHanlder.handle({message, slack, state})

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

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

  defp format_request_for_log(message) do
    "#{message.user} in #{message.channel} say #{message.text}"
  end
end
