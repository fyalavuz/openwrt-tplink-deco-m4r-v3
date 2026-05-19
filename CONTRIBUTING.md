# Contributing

Contributions are welcome if they improve reproducibility, safety, or device
support.

Please include:

- Exact hardware version and region.
- OpenWrt branch and commit used.
- Boot log or relevant serial output for hardware changes.
- File sizes and hashes for generated images when reporting flashing results.
- Whether the device booted with persistent overlay enabled.

Do not include:

- Full flash backups.
- ART partitions.
- MAC addresses unless redacted.
- Wi-Fi passwords or other secrets.

Before opening a pull request, run:

```sh
make patch-check
```

Full firmware builds can be run with:

```sh
make build
```
