defmodule NetLinkTest do
  use ExUnit.Case
  use Bitwise
  alias NetLink.Header
  doctest NetLink

  test "build header" do
    encoded_header = <<20, 0, 0, 0, 22, 0, 1, 3, 153, 190, 38, 98, 63, 189, 10, 0>>
    flags = Header.nlm_f_request() ||| Header.nlm_f_dump()
    seq = 1_646_706_329
    pid = 703_807
    rtm_get_addr = 22
    h = struct(Header, %{flags: flags, type: rtm_get_addr, seq_number: seq, proc_pid: pid})

    assert Header.encode(h, 4) == encoded_header
  end
end
