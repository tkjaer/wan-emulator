# wan-emulator

`vagrant up` spins up two Ubuntu VMs, one `proxy` that does the WAN emulation and one `client` that sits behind it.

The `proxy` VM SNATs the `client` traffic through its own outgoing interface.

WAN emulation can be applied and modified by editing the `wan-emulation.sh` script and running it on the `proxy` VM.