# There's definitely far better ways to do this.

defmodule UTF8Sub do
  def sub(s) when is_binary(s) do
    # bad_chars = find_bad_chars(s)
    find_bad_sequences(s)
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

  # technically should support truncated 5 and 6 bytes sequences... oh well.
  # browsers do 1 special character each when they render (doesn't meet best practices)
  
  defp find_bad_sequences(<<_::binary-size(1), rest::binary>>, acc) do
    find_bad_sequences(rest, [byte_size(rest) | acc])
  end
  
  defp find_bad_sequences(<<>>, acc), do: Enum.reverse(acc)

  # Okay, now I need to implement substitution code here
end