# roomctl releases

Signed release packages of roomctl, the controller for General Medicine's conference-room Mac minis. Packages only: the source is private.

Set up a room Mac (as its admin, in Terminal; drop `--test-mac` for a real room):

```sh
curl -fsSL https://raw.githubusercontent.com/bgreenGM/roomctl-releases/main/install.sh | sudo bash -s -- --test-mac
```

`install.sh` downloads the newest package, refuses it unless its roomctl is signed with the roomctl certificate, and starts the package's guided setup. Run it again for setup's Part 2.
