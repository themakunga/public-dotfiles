# cliamp

Public starter settings, podcast subscriptions and radio favorites for cliamp 2.3.0.
The Nix application module seeds missing files into `~/.config/cliamp/` and keeps
existing files intact. These are ordinary writable files because cliamp saves
subscriptions and favorites using atomic replacements.

`config.toml` contains only public defaults. The private
`shared-conf/cliamp/config.toml` continues to supply authenticated providers and
takes precedence over this starter file during Nix activation. Other private
cliamp files are no longer copied over subscriptions or radio favorites.
Edit the live config for local preference changes; edit the private source for
preferences that must survive Nix activation on authenticated hosts.

## Add podcasts

```sh
cliamp --provider podcast
```

1. Press `/`, type a show name or a publisher's RSS URL, then press `Enter`.
2. Highlight a show and press `f` to subscribe or unsubscribe.
3. Press `F` to open subscriptions. Press `Enter` to load a show, then select an
   episode to play. Press `l` to append only a show's latest episode.

On an episode, `f` bookmarks the episode; it does not subscribe to the show.
Subscriptions are saved in `~/.config/cliamp/podcast_subscriptions.json`.
No account is needed for podcasts.

## Add radios

```sh
cliamp --provider radio
```

Use `/` to search the directory and `f` to toggle a station favorite. Favorites
are saved in `~/.config/cliamp/radio_favorites.toml`.

For a custom stream, edit `~/.config/cliamp/radios.toml` and restart cliamp:

```toml
[[station]]
name = "My station"
url = "https://example.com/live.mp3"
```

## Save changes to dotfiles

Close cliamp before copying files. Review the lists before publishing: use only
public feeds and streams, without access tokens or private subscription URLs.
The explicit file list keeps credentials and listening history out of the repo.

```sh
cp ~/.config/cliamp/podcast_subscriptions.json ~/.public-dotfiles/cliamp/
cp ~/.config/cliamp/radio_favorites.toml ~/.public-dotfiles/cliamp/
cp ~/.config/cliamp/radios.toml ~/.public-dotfiles/cliamp/
git -C ~/.public-dotfiles diff -- cliamp/
```

Do not copy the live `config.toml`, authentication files, cookies or the entire
config directory into this public repository.

On an existing host, Git updates do not replace live lists. To apply a repository
list deliberately, close cliamp, back up the corresponding live file, then copy
that individual file from `~/.public-dotfiles/cliamp/` to `~/.config/cliamp/`.
This replaces that list rather than merging it.

References: [Podcasts](https://github.com/bjarneo/cliamp/blob/v2.3.0/docs/podcasts.md),
[Radio](https://github.com/bjarneo/cliamp/blob/v2.3.0/docs/radio.md),
[Configuration](https://github.com/bjarneo/cliamp/blob/v2.3.0/docs/configuration.md).
