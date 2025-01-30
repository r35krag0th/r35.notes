# The r35 Note Taking System

## The Journey

I've tried a bunch of different things and the closest to being happy was [Neorg](https://github.com/nvim-neorg/neorg). The major disconnect was not being able to have a to-do list that crosses all of my daily journal entries and other notes.

I tried out [orgmode](https://github.com/nvim-orgmode/orgmode), but the syntax was too funky to learn and I didn't want to have to learn a new language just to take notes.

So here we are. Clean and simple markdown. I've largely built this around using [Markview](https://github.com/OXY2DEV/markview.nvim) with [Marksman](https://github.com/artempyanykh/marksman) to handle the aesthetics.

There is much to do and I'm sure I'll be tweaking this for a while.

Credit to [dhananjaylatkar/notes.nvim](https://github.com/dhananjaylatkar/notes.nvim) for some of the base code and inspiration to keep it simple.

## What this is (and isn't)

This isn't some fancy solution that does anything magical. It is just adding keybinds to make navigation easier. The big QoL improvement is _yesterday_ and _tomorrow_ intelligently skip the weekends. I mainly use this for work so I always hated having to skip over the weekends when I was looking for something.

## The Bindings

| Mode | Key               | Action                                          |
| ---- | ----------------- | ----------------------------------------------- |
| `n`  | `<localleader>ny` | Go to yesterday (`:RNYesterday`)                |
| `n`  | `<localleader>nd` | Go to today (`:RNToday`)                        |
| `n`  | `<localleader>nt` | Go to tomorrow (`:RNTomorrow`)                  |
| `n`  | `<localleader>ng` | Grep for contents using mini.pick (`:RNGrep`)   |
| `n`  | `<localleader>nf` | Find a file by name using mini.pick (`:RNFind`) |
