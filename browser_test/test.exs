valid_truncated_sequence = <<34, 0b11110000, 0b10010000, 0b10100100, 34>>

File.write!("browser_test/test.html", EEx.eval_file("browser_test/test.eex", body: valid_truncated_sequence))

# truncated characters surrounded by "A" on either side
File.write!("sample_data/truncated_sequence.json", "{\"foo\": " <> valid_truncated_sequence <> "}")
