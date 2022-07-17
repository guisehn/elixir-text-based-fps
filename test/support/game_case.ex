defmodule TextBasedFPS.GameCase do
  @moduledoc """
  This module defines the test case to be used by tests that need
  access to global game state processes, such as `TextBasedFPS.GameState.Players`,
  `TextBasedFPS.GameState.Room`, etc.

  Each test case gets brand new processes, with an empty server state.

  It also injects utility functions from TextBasedFPS.GameTestUtils, for testing
  game logic.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Mox

      setup do
        Mox.verify_on_exit!()
      end

      import TextBasedFPS.GameTestUtils
    end
  end

  setup do
    TextBasedFPS.GameState.Players.setup_local_process_ref()
    TextBasedFPS.GameState.RoomSupervisor.setup_local_process_ref()
    TextBasedFPS.GameState.Room.setup_local_process_prefix()

    TextBasedFPS.GameState.Players.start_link()
    TextBasedFPS.GameState.RoomSupervisor.start_link(:ok)

    :ok
  end
end
