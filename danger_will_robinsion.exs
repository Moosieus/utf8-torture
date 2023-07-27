# cat sample_data/bad_binary_test.json | mix run danger_will_robinsion.exs

d = IO.gets(:stdio, "")

j = File.read!("sample_data/bad_binary_test.json")

# Invalid as to be expected
IO.inspect(j, label: "from file", width: :infinity, base: :binary)
IO.inspect(j, label: "from file", binaries: :as_strings)
IO.inspect(is_binary(j), label: "file is_binary")
IO.inspect(String.valid?(j), label: "file valid string")

IO.puts("\n")

# Somehow valid?
IO.inspect(d, label: "from stdio", width: :infinity, base: :binary)
IO.inspect(d, label: "from stdio", width: :infinity, base: :hex)
IO.inspect(d, label: "from stdio", binaries: :as_strings)
IO.inspect(is_binary(d), label: "stdio is_binary")
IO.inspect(String.valid?(d), label: "stdio valid string")

IO.puts("\n")
