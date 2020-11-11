# mpv-lastfm-scrobbler

Last.fm scrobbler script for MPV. It uses [hauzer/scrobbler](https://github.com/hauzer/scrobbler) to communicate with last.fm.

### Setup
Install and setup [hauzer/scrobbler](https://github.com/hauzer/scrobbler). Remember to place the executable in your path.
```
mv lastfm.lua ~/.mpv/scripts/
vim ~/.mpv/script-opts/lastfm.conf
```
Add `username=<your username>` to the config file. The username is case-sensitive, so remember to wirte it correctly!
