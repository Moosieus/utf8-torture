File.write!("browser_test/test.html", EEx.eval_file("browser_test/test.eex"))

# truncated characters surrounded by "A" on either side
File.write!("sample_data/bad_binary_test.json", "{\"foo\": \"A" <> <<0xE1, 0x80, 0xE2, 0xF0, 0x91, 0x92, 0xF1, 0xBF, 0x41>> <> "\"}")


@doc"""
Table 3-8. U+FFFD for Non-Shortest Form Sequences ->
  Replace each byte in the sequence with a U+FFFD
"""
<< 0xC0, 0xAF, 0xE0, 0x80, 0xBF, 0xF0, 0x81, 0x82, 0x41 >>
|> IO.inspect(base: :binary, width: :infinity)
"""
<<0b11000000, 0b10101111, 0b11100000, 0b10000000, 0b10111111, 0b11110000, 0b10000001, 0b10000010, 0b1000001>>
"""

@doc"""
Table 3-9. U+FFFD for Ill-Formed Sequences for Surrogates ->

"""
<< 0xED, 0xA0, 0x80, 0xED, 0xBF, 0xBF, 0xED, 0xAF, 0x41 >>
|> IO.inspect(base: :binary, width: :infinity)
"""
<<0b11101101, 0b10100000, 0b10000000, 0b11101101, 0b10111111, 0b10111111, 0b11101101, 0b10101111, 0b1000001>>
"""

@doc"""
Table 3-10. U+FFFD for Other Ill-Formed Sequences ->
"""
