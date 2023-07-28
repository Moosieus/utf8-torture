_ = """
TODO: Revise all implementations adhering to substitution specification in the Unicode 15.0 standard.
"""

defmodule UTF8Sub.Naive do
  def replace_bad_chars(s) when is_binary(s) do
    s
    |> String.graphemes()
    |> Enum.filter(&String.valid?/1)
    |> IO.iodata_to_binary()
  end
end

defmodule UTF8Sub.Simple do
  @dialyzer(:no_improper_lists)

  @moduledoc """
  Replace malformed utf8 characters by building a new string, replacing any bad characters.
  """
  def replace_bad_chars(s) when is_binary(s) do
    do_filter(s)
  end

  defp do_filter(bin, acc \\ [])

  defp do_filter(<<grapheme::utf8, rest::binary>>, acc) do
    do_filter(rest, [acc | <<grapheme::utf8>>])
  end

  defp do_filter(<<_::binary-size(1), rest::binary>>, acc), do: do_filter(rest, [acc | "�"])

  defp do_filter(<<>>, acc), do: IO.iodata_to_binary(acc)
end

defmodule UTF8Sub.Unicode_Util do
  @moduledoc """
  Optional Alternative to the above could be slightly modifying String.graphemes/1 from the standard library:
  https://github.com/elixir-lang/elixir/blob/81d6007410b3ae43e279cfb689bd03ffc5f06830/lib/elixir/lib/string.ex#L1908
  """
end

defmodule UTF8Sub.Fast do
  @moduledoc """
  Replaces malformed utf8 characters by indexing bad characters and slicing around them.
  """

  @dialyzer(:no_improper_lists)

  def replace_bad_chars(""), do: ""

  def replace_bad_chars(s) when is_binary(s) do
    replace_bad_chars(s, find_bad_chars(s))
  end

  ## replace_bad_chars

  # no bad characters, short circuit
  def replace_bad_chars(s, []), do: s

  # one bad character, short circuit
  def replace_bad_chars(s, [i] = _bad_bytes) when i+1 !== byte_size(s) do
    [binary_slice(s, -byte_size(s)..-(i+2)) | binary_slice(s, -i..-1)] |> IO.iodata_to_binary()
  end

  # edge case: capture first portion if string doesn't start w/ a bad character
  def replace_bad_chars(s, [i | rest] = _bad_bytes) when i+1 !== byte_size(s) do
    do_replace_bad_chars(s, rest, [binary_slice(s, -byte_size(s)..-(i+2))])
  end

  def replace_bad_chars(s, bad_bytes) do
    do_replace_bad_chars(s, bad_bytes)
  end

  def do_replace_bad_chars(s, bad_bytes, acc \\ [])

  def do_replace_bad_chars(_s, [0], acc) do
    [acc | "�"] |> IO.iodata_to_binary()
  end

  def do_replace_bad_chars(s, [i], acc) do
    [[acc | "�"] | binary_slice(s, -i..-1)] |> IO.iodata_to_binary()
  end

  def do_replace_bad_chars(s, [i | [ii | rest]], acc) do
    do_replace_bad_chars(s, [ii | rest], [[acc | "�"] | binary_slice(s, -i..-(ii+2))])
  end

  ## find_bad_chars

  def find_bad_chars(binary, bad_bytes \\ [])

  def find_bad_chars(<<_::utf8, rest::binary>>, bad_bytes) do
    find_bad_chars(rest, bad_bytes)
  end

  # bad bytes are indexed from the end of the binary
  def find_bad_chars(<<_::binary-size(1), rest::binary>>, bad_bytes) do
    find_bad_chars(rest, [byte_size(rest) | bad_bytes])
  end

  def find_bad_chars(<<>>, acc), do: Enum.reverse(acc)
end

defmodule UTF8Sub.FastAlt do
  @moduledoc """
  Like UTF8Sub.Fast but indexes "good" ranges instead of "bad".
  """
  def replace_bad_chars(s) when is_binary(s) do
    do_reduce(s, do_chunks(s, [[byte_size(s)]]))
  end

  def do_chunks(<<_::utf8, rest::binary>>, acc), do: do_chunks(rest, acc)

  # bad bytes are indexed from the end of the binary
  def do_chunks(<<_::binary-size(1), rest::binary>>, [ch | chunks]) do
    x = byte_size(rest)+1

    do_chunks(rest, [[x-1] | [[x | ch] | chunks]])
  end

  def do_chunks(<<>>, [l | rest]) do
    [[0 | l] | rest] |> Enum.reverse
  end

  def do_reduce(s, chunks, acc \\ [])

  def do_reduce(s, [[0, ii]], _acc) when ii == byte_size(s), do: s

  def do_reduce(s, [[i, ii] | rest], acc) when i === ii do
    do_reduce(s, rest, acc)
  end

  def do_reduce(s, [[i, ii] | rest], acc) do
    do_reduce(s, rest, [acc, binary_slice(s, -ii..-(i+1))])
  end

  def do_reduce(_s, [], acc), do: IO.iodata_to_binary(acc)
end
