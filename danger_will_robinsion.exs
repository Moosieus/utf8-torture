# cat sample_data/truncated_sequence.json | mix run danger_will_robinsion.exs

# Test script that Pipes bad binary data into `IO.gets`, just to see what happens.
# Generally speaking, passing bad binary data on the command line is unrealistic and just asking for pain.
# Even running curl warns you of this when downloading bad utf-8 encoded stuff.

d = IO.gets(:stdio, "")

j = File.read!("sample_data/truncated_sequence.json")

# Invalid as to be expected
# IO.inspect(j, label: "binary from file", width: :infinity, base: :binary)
IO.inspect(j, label: "hex from file", width: :infinity, base: :hex)
IO.inspect(j, label: "string from file", binaries: :as_strings)
IO.inspect(is_binary(j), label: "file is_binary")
IO.inspect(String.valid?(j), label: "file valid string")

IO.puts("\n")

# Somehow valid?
# IO.inspect(d, label: "binary from stdin", width: :infinity, base: :binary)
IO.inspect(d, label: "hex from stdin", width: :infinity, base: :hex)
IO.inspect(d, label: "string from stdin", binaries: :as_strings)
IO.inspect(is_binary(d), label: "stdin is_binary")
IO.inspect(String.valid?(d), label: "stdin valid string")

IO.puts("\n")
