defmodule TextBasedFPS.CLI.Utils do
  def maybe_set_cookie(options) do
    if options[:cookie] do
      Node.set_cookie(Node.self(), String.to_atom(options[:cookie]))
    end
  end
end
