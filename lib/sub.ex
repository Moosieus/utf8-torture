defmodule UTF8Sub do
  @dialyzer(:no_improper_lists)

  @doc """
  Replaces ill-formed utf-8 subsequences (read: invalid bytes) according to Unicode Standard best practices.

  This is particularly desirable when separate systems must handle the same ill-formed utf-8 data and agree on the contents.

  An alternative replacement to code point U+FFFD may be provided as an optional second argument.
  """
  @spec sub(binary, binary) :: binary
  def sub(bytes, replacement \\ "�")

  def sub(<<>>, _), do: ""

  def sub(bytes, replacement) when is_binary(bytes) and is_binary(replacement) do
    find_bad_sequences(bytes)
    |> replace_bad_sequences(bytes, replacement)
  end

  defp find_bad_sequences(s, acc \\ [])

  defp find_bad_sequences(<<_::utf8, rest::binary>>, acc) do
    find_bad_sequences(rest, acc)
  end

  # 2/3-byte truncated
  defp find_bad_sequences(<<0b1110::4, i::4, 0b10::2, ii::6, n_lead::2, n_rest::6, rest::binary>>, acc) when n_lead != 0b10 do
    index = byte_size(rest) + 1

    # tcp = truncated code point, must be valid for 3-bytes
    <<tcp::10>> = <<i::4, ii::6>>
    cond do
      tcp >= 32 && tcp <= 863 ->
        # valid truncated code point -> replace with 1x U+UFFD
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [{index + 1, index} | acc])
      tcp >= 896 && tcp <= 1023 ->
        # valid truncated code point -> replace with 1x U+UFFD
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [{index + 1, index} | acc])
      true ->
        # invalid truncated code point -> replace with 2x U+UFFD
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [index + 1 | [index | acc]])
    end
  end

  # 2/4-byte truncated
  defp find_bad_sequences(<<0b11110::5, i::3, 0b10::2, ii::6, n_lead::2, n_rest::6, rest::binary>>, acc) when n_lead != 0b10 do
    index = byte_size(rest) + 1

    <<tcp::9>> = <<i::3, ii::6>>
    case tcp >= 16 && tcp <= 271 do
      true ->
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [{index + 1, index} | acc])
      false ->
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [index + 1 | [index | acc]])
    end
  end

  # 3/4-byte truncated
  defp find_bad_sequences(<<0b11110::5, i::3, 0b10::2, ii::6, 0b10::2, iii::6, n_lead::2, n_rest::6, rest::binary>>, acc) when n_lead != 0b10 do
    index = byte_size(rest) + 1

    <<tcp::15>> = <<i::3, ii::6, iii::6>>
    case tcp >= 1024 && tcp <= 17407 do
      true ->
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [{index + 2, index} | acc])
      false ->
        find_bad_sequences(<<n_lead::2, n_rest::6, rest::binary>>, [index + 2 | [index + 1 | [index | acc]]])
    end
  end

  defp find_bad_sequences(<<_::binary-size(1), rest::binary>>, acc) do
    find_bad_sequences(rest, [byte_size(rest) | acc])
  end

  defp find_bad_sequences(<<>>, acc), do: Enum.reverse(acc)

  # no bad sequences, short circuit
  defp replace_bad_sequences([], s, _), do: s

  # single bad sequence at start, short circuit
  defp replace_bad_sequences([i], s, r) when is_integer(i) and i === byte_size(s)-1 do
    r <> binary_slice(s, -i..-1)
  end
  defp replace_bad_sequences([{i, ii}], s, r) when i === byte_size(s)-1 do
    r <> binary_slice(s, -ii..-1)
  end

  # acc = iolist of the resulting string
  # b = positions of bad sequences
  # s = original byte sequence
  # r = replacement character

  # single bad sequence at end, short circuit
  defp replace_bad_sequences([0], s, r) do
    binary_slice(s, -byte_size(s)-1..-2//1) <> r
  end

  defp replace_bad_sequences([{i, 0}], s, r) do
    binary_slice(s, -byte_size(s)-1..-(i+2)//1) <> r
  end

  # single bad sequence in middle, short circuit
  defp replace_bad_sequences([i], s, r) when is_integer(i) do
    binary_slice(s, -byte_size(s)-1..-(i+2)) <> r <> binary_slice(s, -i..-1//1)
  end

  defp replace_bad_sequences([{i, ii}], s, r) do
    binary_slice(s, -byte_size(s)-1..-(i+2)) <> r <> binary_slice(s, -ii..-1//1)
  end

  # several bad sequences, use recursive strategy

  # recursive loop slices what's "behind" each bad sequence, so a leading bad sequence is an edge case.
  defp replace_bad_sequences([i | _rest] = b, s, r) when is_integer(i) and i+1 !== byte_size(s) do
    [binary_slice(s, -byte_size(s)..-(i+2)//1)]
    |> do_replace_bad_sequences(b, s, r)
  end

  defp replace_bad_sequences([{i, _ii} | _rest] = b, s, r) when i+1 !== byte_size(s) do
    [binary_slice(s, -byte_size(s)..-(i+2)//1)]
    |> do_replace_bad_sequences(b, s, r)
  end

  defp replace_bad_sequences(b, s, r) do
    do_replace_bad_sequences([], b, s, r)
  end

  # loop

  # last bad sequence
  defp do_replace_bad_sequences(acc, [0], _s, r) do
    [acc | r]
    |> IO.iodata_to_binary()
  end

  defp do_replace_bad_sequences(acc, [{_ii, 0}], _s, r) do
    [acc | r]
    |> IO.iodata_to_binary()
  end

  defp do_replace_bad_sequences(acc, [i], s, r) when is_integer(i) do
    [[acc | r] | binary_slice(s, -i..-1//1)]
    |> IO.iodata_to_binary()
  end

  defp do_replace_bad_sequences(acc, [{_i, ii}], s, r) do
    [[acc | r] | binary_slice(s, -ii..-1//1)]
    |> IO.iodata_to_binary()
  end

  # middle bad sequence(s)
  defp do_replace_bad_sequences(acc, [{_i, i} | [{ii, _} | _] = rest], s, r) when i+1 === ii do
    [acc | r]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [{_i, i} | [{ii, _} | _] = rest], s, r) do
    [[acc | r] | binary_slice(s, -i..-(ii+2)//1)]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [{_, i} | [ii | _] = rest], s, r) when is_integer(ii) and i+1 === ii do
    [acc | r]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [{_, i} | [ii | _] = rest], s, r) when is_integer(ii) do
    [[acc | r] | binary_slice(s, -i..-(ii+2)//1)]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [i | [{ii, _} | _] = rest], s, r) when is_integer(i) and i+1 === ii do
    [acc | r]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [i | [{ii, _} | _] = rest], s, r) when is_integer(i) do
    [[acc | r] | binary_slice(s, -i..-(ii+2)//1)]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [i | [ii | _] = rest], s, r) when is_integer(i) and is_integer(ii) and i+1 === ii do
    [acc | r]
    |> do_replace_bad_sequences(rest, s, r)
  end

  defp do_replace_bad_sequences(acc, [i | [ii | _] = rest], s, r) when is_integer(i) and is_integer(ii) do
    [[acc | r] | binary_slice(s, -i..-(ii+2)//1)]
    |> do_replace_bad_sequences(rest, s, r)
  end
end
