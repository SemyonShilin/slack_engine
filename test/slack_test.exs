defmodule Engine.SlackTest do
  use ExUnit.Case
  doctest Engine.Slack

  test "greets the world" do
    assert Engine.Slack.hello() == :world
  end
end
