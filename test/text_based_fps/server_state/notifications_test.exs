defmodule TextBasedFPS.ServerState.NotificationsTest do
  use ExUnit.Case, async: true

  alias TextBasedFPS.{Notification, ServerState}

  describe "add_notification/2" do
    test "adds notifications to the end of the list" do
      state =
        ServerState.new()
        |> ServerState.add_notifications([Notification.new("foo", "hello")])
        |> ServerState.add_notifications([Notification.new("foo", "world")])

      assert [
               %Notification{player_key: "foo", body: "hello"},
               %Notification{player_key: "foo", body: "world"}
             ] = state.notifications
    end
  end

  describe "get_and_clear_notifications/1" do
    test "returns the notifications and clears them" do
      {notifications, state} =
        ServerState.new()
        |> ServerState.add_notifications([
          Notification.new("foo", "hello"),
          Notification.new("foo", "world")
        ])
        |> ServerState.get_and_clear_notifications()

      assert [
               %Notification{player_key: "foo", body: "hello"},
               %Notification{player_key: "foo", body: "world"}
             ] = notifications

      assert state.notifications == []
    end
  end

  describe "get_and_clear_notifications/2" do
    test "returns the notifications for a given user and removes the ones for that user" do
      {notifications, state} =
        ServerState.new()
        |> ServerState.add_notifications([
          Notification.new("foo", "hello"),
          Notification.new("bar", "hello"),
          Notification.new("foo", "world"),
          Notification.new("bar", "world")
        ])
        |> ServerState.get_and_clear_notifications("foo")

      assert [
               %Notification{player_key: "foo", body: "hello"},
               %Notification{player_key: "foo", body: "world"}
             ] = notifications

      assert [
               %Notification{player_key: "bar", body: "hello"},
               %Notification{player_key: "bar", body: "world"}
             ] = state.notifications
    end
  end
end
