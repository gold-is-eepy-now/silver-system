# Silver System OS

Silver System now boots into a **real VGA graphical desktop** (320x200x256, Mode 13h) with a panel-style launcher and windowed apps inspired by classic desktop OS layouts.

> This remains an educational 16-bit real-mode x86 OS prototype.

## Implemented components

- **Bootloader** (`bootloader/boot.asm`)
  - BIOS stage-1 loader.
  - Initializes segment/stack state.
  - Loads 40 sectors of kernel image at `0000:8000`.

- **Kernel GUI** (`kernel/kernel.asm`)
  - Switches to VGA Mode 13h.
  - Draws a gradient wallpaper, left icon rail, taskbar, start button, and central control-panel window.
  - Renders app tiles and hotkey help on desktop.

- **Desktop apps**
  - **Terminal** (`T`): commands `help`, `tasks`, `echo TEXT`, `desktop`, `reboot`.
  - **Task Manager** (`M`): process list popup.
  - **Notes** (`N`): simple typing pad popup, ESC to exit.

## Controls

- `T` Terminal
- `M` Task Manager
- `N` Notes
- `D` Redraw desktop
- `ESC` Reboot

## Build (Linux/macOS)

Requirements:
- `nasm`
- `qemu-system-i386`
- `make`

```bash
make build
```

Artifacts:
- `out/boot.bin`
- `out/kernel.bin`
- `out/silver.img`

## Run (Linux/macOS)

```bash
make run
```

## Build on Windows

### Option A: WSL (recommended)
Use Ubuntu (or similar) in WSL and run the same commands as Linux:

```bash
sudo apt update
sudo apt install -y nasm qemu-system-x86 make
make build
make run
```

### Option B: Native PowerShell
1. Install **NASM** and **QEMU** and add both to your `PATH`.
2. From repository root, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_windows.ps1
```

To build and run immediately:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_windows.ps1 -Run
```

## Next steps toward a modern OS

1. Protected mode + GDT/IDT.
2. Hardware timer and preemptive scheduler.
3. Filesystem-backed app loading.
4. Mouse cursor, event loop, and proper GUI widgets.
5. User/kernel separation and syscall ABI.
