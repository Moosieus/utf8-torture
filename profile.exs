j = File.read!("sample_data/server_list_causing_issues.json")
# j = <<234>> <> "新欢乐营 |" <> <<233>> <> "Q群:659852768" <> <<235>>

Benchee.run(
  %{
    "Naive" => fn -> UTF8Sub.Naive.replace_bad_chars(j) end,
    "UTF8Sub.Simple" => fn -> UTF8Sub.Simple.replace_bad_chars(j) end,
    "UTF8Sub.Fast" => fn -> UTF8Sub.Fast.replace_bad_chars(j) end,
    "UTF8Sub.FastAlt" => fn -> UTF8Sub.FastAlt.replace_bad_chars(j) end,
  },
  time: 10,
  memory_time: 2,
  unit_scaling: :smallest
)
