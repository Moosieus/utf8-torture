# UTF8 Torture

A bunch of junk I'm using to play around with utf-8 in Elixir.



Don't use anything here in prod o̶̢̹͍̊̆̑͂͊̍̉͒̊́́̈̑̒̐ř̷̡͔͖̜̳̠͓͉̜͍̰̝͍̎̌̌͘͜͝ ̷͇̯̦͎́̆̓͋͗͌́̈̒̓̐̈́e̸̛͇͎̝̣͗͛̑̌͒̔͝s̵̡̢͖̲̦̗̜͙̹̖̍́͑̍̌̕͜ͅḽ̴̫̟͈̫̫̚ę̶͙̻̞͖͉̯̏̓̾͑͠͝

# Todo
- Add description to the repo
- Create LiveBook breaking down the Unicode specification in layman terms with interactive examples and diagrams.
- Implement a module that substitutes "ill-formed subsequences":
  - According to spec
  - In native Elixir code
  - With minimal overhead
- As far as I can tell there's not an existing implementation of this in Erlang or Elixir.
  - I'd like to be wrong here, ideally someone's thought of this before me and has a more thorough solution!
