# grub-bg-rotator

Rotate grub background randomly from imageset on file system. Handles grub-friendly conversion automatically to 1080p/256-bit.

---

### Notes
* Requires sudo access to overwrite grub background image and run `update-grub` to apply changes.
* Imageset is often not available at bootloader launch since it's typically not stored on `/boot/`
* Converted grub-friendly images are stored in `~/.grubbg` in the home of the user that owns the project root shell scripts (run.sh, rotate.sh).
* Image files retrieved for conversion need to have these extensions: jpg,jpeg,png,JPG,JPEG,PNG
* Remove an image from the imageset by deleting the image from `~/.grubbg` and either running `update-grub` or `run.sh`
---

### Setup

`sudo apt-get install coreutils imagemagick`

---

### Run

`sudo ./run.sh /path/to/imageset/`

---

### Launch on startup

Create a systemd service at `/etc/systemd/system/grub-rotator.service`:
```
[Unit]
Description=GRUB Background Rotator
After=network.target local-fs.target

[Service]
Type=oneshot
ExecStart=/home/user/grub-bg-rotator/run.sh /home/user/myImages
RemainAfterExit=yes
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Load the new service into systemd:

```
sudo systemctl daemon-reload
sudo systemctl status grub-rotator
sudo systemctl enable grub-rotator
sudo systemctl status grub-rotator
```

---

### TODO
* Cohesive workflow and usage.
* Iron out parameter presence pathing.
* Detect if `/etc/default/grub` is configured with a custom image, and fallback to grub default
