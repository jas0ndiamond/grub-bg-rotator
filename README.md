# grub-bg-rotator
Rotate grub background randomly from imageset on file system. Handles grub-friendly conversion automatically to 1080p/256-bit.

### Notes
* Requires sudo access to overwrite grub background image and run `update-grub` to apply changes.
* Imageset is often not available at bootloader launch since it's typically not stored on `/boot/`
* Converted grub-friendly images are stored in `~/.grubbg` in the home of the user that owns the project root shell scripts (run.sh, rotate.sh).
* Image files retrieved for conversion need to have these extensions: jpg,jpeg,png,JPG,JPEG,PNG

### Setup
`sudo apt-get install coreutils imagemagick`

### Run
`sudo ./run.sh /path/to/imageset/`

### Launch on startup
Create a systemd service:
```
[Service]
...
```

### TODO
* Cohesive workflow and usage.
* Iron out parameter presence pathing.
* Detect if `/etc/default/grub` is configured with a custom image, and fallback to grub default
