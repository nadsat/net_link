defmodule NetLink do
  alias NetLink.Header

  @moduledoc """
  Documentation for `NetLink`.
  """

  @doc """
  Get addr.

  """
  use Bitwise

  @af_net_link 16
  @rtm_get_addr 22
  @af_inet 2
  @rtmgrp_ipv4_route 0x40

  def get_addr() do
    {:ok, s} = :socket.open(@af_net_link, :raw)
    {:ok, addr} = :socket.sockname(s)
    IO.inspect(addr)
    :ok = :socket.bind(s, addr)

    flags = Header.nlm_f_request() ||| Header.nlm_f_dump()
    seq = :os.system_time(:seconds)
    pid = System.pid() |> String.to_integer()
    h = struct(Header, %{flags: flags, type: @rtm_get_addr, seq_number: seq, proc_pid: pid})

    rtgen_family = <<@af_inet::little-unsigned-integer-size(32)>>

    header = Header.encode(h, byte_size(rtgen_family))

    msg = [header, rtgen_family] |> :erlang.list_to_binary()
    :ok = :socket.send(s, msg)

    {:ok, res} = :socket.recvmsg(s, 2000)

    [data] = res.iov

    :socket.close(s)
    get_addrs_list(data)
  end

  def get_events() do
    {:ok, s} = :socket.open(@af_net_link, :raw)
    {:ok, sname} = :socket.sockname(s)

    pad = <<0::little-unsigned-integer-size(16)>>
    pid = <<0::little-unsigned-integer-size(32)>>
    group = <<@rtmgrp_ipv4_route::little-unsigned-integer-size(32)>>
    bin_addr = [pad, pid, group] |> :erlang.list_to_binary()
    addr = %{sname | addr: bin_addr}
    IO.inspect(addr, label: "addr")
    bind_res = :socket.bind(s, addr)

    IO.inspect(bind_res, label: "bind result")

    {:ok, new_addr} = :socket.sockname(s)

    IO.inspect(new_addr, label: "addr")

    {:ok, res} = :socket.recvmsg(s)

    [data] = res.iov

    IO.inspect(data, label: "event")

    :socket.close(s)
    data
  end

  defp get_addrs_list(data) do
    get_ip_list(data, [])
  end

  defp get_ip_list(<<>>, ip_list) do
    ip_list
  end

  defp get_ip_list(content, ip_list) do
    <<l::little-integer-size(32), _r::binary>> = content
    <<payload::binary-size(l), rest::binary>> = content
    <<_l::little-integer-size(32), msg::binary>> = payload
    new_list = [get_ip(msg) | ip_list]
    get_ip_list(rest, new_list)
  end

  defp get_ip(msg) do
    <<_h::binary-size(24), ip::binary-size(4), _rest::binary>> = msg
    ip
  end
end
