defmodule TextBasedFPS.CLI.Utils do
  def set_cookie(%{cookie: cookie}) do
    Node.set_cookie(Node.self(), String.to_atom(cookie))
  end

  def set_cookie(_), do: nil

  def get_hostname(%{local_network: true}), do: get_private_ipaddr()

  @doc """
  Returns private IP address (e.g. 192.168.0.41)
  """
  @spec get_private_ipaddr() :: String.t()
  def get_private_ipaddr() do
    {:ok, ifaddrs} = :inet.getifaddrs()

    # TODO: is it always en0 that we want?
    {_, info} = Enum.find(ifaddrs, fn {key, _} -> key == 'en0' end)

    info
    |> Enum.filter(fn {key, _} -> key == :addr end)
    |> Enum.map(&elem(&1, 1))
    |> find_ipv4_addr()
    |> ipaddr_tuple_to_string()
  end

  @spec ipaddr_tuple_to_string(tuple()) :: String.t()
  defp ipaddr_tuple_to_string(ipaddr) do
    ipaddr
    |> Tuple.to_list()
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join(".")
  end

  defp find_ipv4_addr(tuples) do
    Enum.find(tuples, &(tuple_size(&1) == 4))
  end
end
