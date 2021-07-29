defmodule TextBasedFPS.CLI.Utils do
  def maybe_set_cookie(options) do
    if options[:cookie] do
      Node.set_cookie(Node.self(), String.to_atom(options[:cookie]))
    end
  end

  @doc """
  Returns local IP address (e.g. 192.168.0.41)
  """
  @spec get_internal_ipaddr() :: String.t()
  def get_internal_ipaddr() do
    {:ok, ifaddrs} = :inet.getifaddrs()

    # TODO: is it always en0 that we want?
    {_, info} = Enum.find(ifaddrs, fn {key, _} -> key == 'en0' end)

    info
    # TODO: this looks like a keyword list but has duplicate keys...
    |> Enum.filter(fn {key, _} -> key == :addr end)
    # TODO: In my tests it returned :addr for both IPv6 and IPv4, but IPv4
    # comes last, so get it here. Will it always come last?
    |> List.last()
    |> elem(1)
    |> ipaddr_tuple_to_string()
  end

  @spec ipaddr_tuple_to_string(tuple()) :: String.t()
  defp ipaddr_tuple_to_string(ipaddr) do
    ipaddr
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(".")
  end
end
