# UTF8 Torture

Develop a utf-8 substitution function that:
- Produces the same output as other languages and applications (for consensus-sake)
- Has no external dependencies (no mix packages, must be native Elixir)
- Is fast enough for all but the most large scale exceptional use-cases

This repo's effectively a bunch of junk I'm using to play around with utf-8 in Elixir.

`UTF8Sub.sub` is on its way to matching the Unicode spec's best practices. Those are followed by:
- Chrome, Firefox, and Safari when parsing utf-8 encoded HTML.
- JavaScript's `TextDecoder` class (all browsers + Node v18).
- Python 3.11's `bytes` class (using the decode method).
- Golang's `bytes.ToValidUTF8` function.
- .NET's `UTF8Encoding` class.



Don't use anything here in prod o̶̢̹͍̊̆̑͂͊̍̉͒̊́́̈̑̒̐ř̷̡͔͖̜̳̠͓͉̜͍̰̝͍̎̌̌͘͜͝ ̷͇̯̦͎́̆̓͋͗͌́̈̒̓̐̈́e̸̛͇͎̝̣͗͛̑̌͒̔͝s̵̡̢͖̲̦̗̜͙̹̖̍́͑̍̌̕͜ͅḽ̴̫̟͈̫̫̚ę̶͙̻̞͖͉̯̏̓̾͑͠͝



# Todo
- Update the todo
- Add description to the repo
- Create LiveBook breaking down the Unicode specification in layman terms with interactive examples and diagrams.
- Implement a module that substitutes "ill-formed subsequences":
  - According to spec
  - In native Elixir code
  - With minimal overhead
- As far as I can tell there's not an existing implementation of this in Erlang or Elixir.
  - I'd like to be wrong here, ideally someone's thought of this before me and has a more thorough solution!

# Notes to self
Don't use the "Mark Kuhn" test file circa 2015. It's not accurate.
