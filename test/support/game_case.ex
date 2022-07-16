defmodule TextBasedFPS.GameCase do
  @moduledoc """
  This module defines the test case to be used by tests that need
  access to global game state processes, such as `TextBasedFPS.Process.Players`,
  `TextBasedFPS.Process.Room`, etc.

  Each test case gets brand new processes, with an empty server state.
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
    TextBasedFPS.Process.Players.setup_local_process_ref()
    TextBasedFPS.Process.RoomSupervisor.setup_local_process_ref()
    TextBasedFPS.Process.Room.setup_local_process_prefix()

    TextBasedFPS.Process.Players.start_link()
    TextBasedFPS.Process.RoomSupervisor.start_link(:ok)

    :ok
  end
end
