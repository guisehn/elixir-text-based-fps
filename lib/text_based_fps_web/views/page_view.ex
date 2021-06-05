defmodule TextBasedFPSWeb.PageView do
  use TextBasedFPSWeb, :view

  def missing_host_env_var? do
    Mix.env() == :prod && !System.get_env("HOST")
  end
end
