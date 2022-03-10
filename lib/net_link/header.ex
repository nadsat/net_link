defmodule NetLink.Header do
  import NetLink.Constants
  use Bitwise

  @len_size 4
  @header_size 16

  const(:nlm_f_request, 0x01)
  const(:nlm_f_multi, 0x02)
  const(:nlm_f_ack, 0x04)
  const(:nlm_f_echo, 0x08)
  const(:nlm_f_dump_intr, 0x10)
  const(:nlm_f_dump_filtered, 0x20)

  const(:nlm_f_root, 0x100)
  const(:nlm_f_match, 0x200)
  const(:nlm_f_atomic, 0x400)
  const(:nlm_f_dump, 0x100 ||| 0x200)

  const(:nlm_f_replace, 0x100)
  const(:nlm_f_excl, 0x200)
  const(:nlm_f_create, 0x400)
  const(:nlm_f_append, 0x800)

  const(:nlm_f_nonrec, 0x100)

  const(:nlm_f_capped, 0x100)
  const(:nlm_f_ack_tlvs, 0x200)

  const(:nlmsg_noop, 0x1)
  const(:nlmsg_error, 0x2)
  const(:nlmsg_done, 0x3)
  const(:nlmsg_overrun, 0x4)

  defstruct [:len, :type, :flags, :seq_number, :proc_pid]

  @spec encode(%NetLink.Header{}, integer) :: term()
  def encode(h, payload_len) do
    nlh_type = <<h.type::little-unsigned-integer-size(16)>>
    nlh_flags = <<h.flags::little-unsigned-integer-size(16)>>
    nlh_seq = <<h.seq_number::little-unsigned-integer-size(32)>>
    nlh_pid = <<h.proc_pid::little-unsigned-integer-size(32)>>

    content =
      [nlh_type, nlh_flags, nlh_seq, nlh_pid]
      |> :erlang.list_to_binary()

    header = %{h | :len => @len_size + payload_len + byte_size(content)}
    nlh_len = <<header.len::little-unsigned-integer-size(32)>>

    [nlh_len, content]
    |> :erlang.list_to_binary()
  end

  @spec decode(term()) :: %NetLink.Header{} | {:error, term()}
  def decode(header) when byte_size(header) == @header_size do
    <<len::little-integer-size(32), type::little-integer-size(16), flags::little-integer-size(16),
      seq::little-integer-size(32), proc_pid::little-integer-size(32)>> = header

    struct(NetLink.Header, %{
      len: len,
      flags: flags,
      type: type,
      seq_number: seq,
      proc_pid: proc_pid
    })
  end

  def decode(_header) do
    {:error, "invalid header size"}
  end
end
