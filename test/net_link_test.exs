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

  test "decode header" do
    header = <<76, 0, 0, 0, 20, 0, 2, 0, 85, 92, 41, 98, 123, 49, 13, 0>>

    decoded = %NetLink.Header{
      flags: 2,
      len: 76,
      proc_pid: 864_635,
      seq_number: 1_646_877_781,
      type: 20
    }

    h = Header.decode(header)

    assert ^h = decoded
  end
end
