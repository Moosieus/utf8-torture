j = File.read!("sample_data/server_list_causing_issues.json")
# j = <<234>> <> "新欢乐营 |" <> <<233>> <> "Q群:659852768" <> <<235>>
"""
j = "Shove this in your pipe and smoke it! " <> <<
  0b11110000, 0b10011101, 0b10010100, 0b10011010,   # 𝔚
  0b11110000, 0b10011101, 0b10010100, 0b10011110,   # 𝔞
  0b11110000, 0b10011101, 0b10010100, # 0b10101001, # 𝔩
  0b11110000, 0b10011101, 0b10010100, 0b10110001,   # 𝔱
  0b11110000, 0b10011101, 0b10010100, # 0b10100010, # 𝔢
  0b11110000, 0b10011101, 0b10010100, 0b10101111,   # 𝔯
  0b00100000,                                       # " "
  0b11100010, 0b10000100, 0b10101101,               # ℭ
  0b11111111,                                       # bad byte
  0b11111111,                                       # bad byte
  0b11111111,                                       # bad byte
  0b11110000, 0b10011101, 0b10010100, 0b10101001,   # 𝔩
  0b11110000, 0b10011101, 0b10010100, 0b10100010,   # 𝔢
  0b11110000, 0b10011101, 0b10010100, # 0b10101010, # 𝔪
  0b11110000, 0b10011101, # 0b10010100, 0b10100010, # 𝔢
  0b11110000, 0b10011101, 0b10010100, 0b10101011,   # 𝔫
  0b11110000, 0b10011101, 0b10010100, 0b10110001,   # 𝔱
  0b11110000, # 0b10011101, 0b10010100, 0b10110000, # 𝔰
  0b100001                                          # !
>> <> "\n"                                          # \N
"""

Benchee.run(
  %{
    "Naive" => fn -> UTF8Sub.Naive.replace_bad_chars(j) end,
    "Simple" => fn -> UTF8Sub.Simple.replace_bad_chars(j) end,
    # These actually break under the stress test
    #"Fast" => fn -> UTF8Sub.Fast.replace_bad_chars(j) end,
    #"FastAlt" => fn -> UTF8Sub.FastAlt.replace_bad_chars(j) end,
    "Correct" => fn -> UTF8Sub.sub(j) end,
  },
  time: 10,
  memory_time: 2,
  unit_scaling: :smallest
)
