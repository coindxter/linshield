# Marmottes Code

The name `Marmottes` relates to having scripts many, not 1 script do everything. This ensures success even with failure of the script single.

# Downloads

### Installer of the Linux
```bash
wget -qO- https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/bash/executor.sh > exe.sh && chmod u+x exe.sh && bash exe.sh
```

We reccomend starting the image in the following order of execution.

1. Create configs with AI:
```bash
./build-configs
```
2. Audit system users (Requires config):
```bash
./audit
```
3. Audit system groups (Requires config):
```bash
./group-audit
```
4. Audit apt packages:
```bash
./apt
```
4. Audit apt repositories:
```bash
./apt.sh
```
5. Sysctl Stuff:
```bash
./sysctl.sh
```

### Installer of the Windows
- [Solver of the Questions](https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/python/openai_forensics.py) (Windows and Linux)
- [Configurator Windows](https://cyberpatriots.nyc3.cdn.digitaloceanspaces.com/scripts/go/build_configs.exe) (Windows only)