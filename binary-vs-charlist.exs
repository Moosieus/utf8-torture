# Illustrating how utf-8 gets destructured / evaluated.

# utf-8 encoded data. Headers and value bits are split by _'s for illustration
valid_utf8_binary = <<0b1110_0111, 0b10_010101, 0b10_001100>>

IO.inspect(valid_utf8_binary) # "界"

<<0b1110::4, i::4, 0b10::2, ii::6, 0b10::2, iii::6>> = valid_utf8_binary

<<valid_codepoint::16>> = <<i::4, ii::6, iii::6>>

valid_charlist = [valid_codepoint] # [32008]

IO.inspect(valid_charlist, charlists: :as_charlists) # ~c"界"
