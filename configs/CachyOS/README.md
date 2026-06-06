# Configurazione Rebos — CachyOS

Port della configurazione **Gentoo** (l'originale, quella vera) verso **CachyOS**.
Stessi pacchetti, ma:

- **`paru`** al posto di `emerge` (repo ufficiali Arch/CachyOS → fallback AUR);
- **`systemd`** al posto di OpenRC (i servizi sono `*.service`);
- **niente layer Portage** (USE flag, `make.conf`, overlay/eselect, keyword, kernel
  config, ccache per-pacchetto… tutto rimosso: su Arch non esiste).

> ⚠️ Tutti i nomi pacchetto sono **da verificare** prima di un build reale.
> Sono stati controllati uno a uno contro i database ufficiali Arch e l'AUR
> (snapshot al momento della scrittura), ma repo e AUR cambiano nel tempo.

> ℹ️ CachyOS **usa i repo Arch**: `core`/`extra`/`multilib` restano attivi (provato
> dallo script ufficiale `install-repo.awk`, che inserisce i repo CachyOS *sopra*
> `[core]` lasciando intatte le righe Arch). Sopra ci sono i repo CachyOS che `paru`
> usa in automatico: `cachyos` (pacchetti esclusivi, es. `proton-pass`,
> `librewolf-bin`, `brave-bin`, `ventoy-bin`, `protonplus`, `protonup-qt`) + i
> rebuild ottimizzati per CPU (`*-v3`, `*-v4`, `znver4/znver5`, stessi *nomi* di
> Arch). La colonna "Fonte" è verificata contro Arch (core/extra/multilib) **e**
> l'unione di tutti i repo CachyOS.

## Attivazione

```sh
~/.config/rebos-cfgs/choose-config.sh   # scegli "CachyOS"
```

La macchina viene selezionata da Rebos in base all'**hostname**
(`machines/<hostname>/gen.toml`). Macchine disponibili: `filosofem`, `sirio`,
`teslacoil`, `teslapower`.

## Struttura (riorganizzata)

Il monoblocco `core.toml` di Gentoo è stato spezzato in import tematici. La
`gen.toml` di base è condivisa da **tutte** le macchine; ogni macchina aggiunge
solo i propri import hardware/ruolo.

| Import | Contenuto |
|---|---|
| `initial_packages` | bootstrap (base-devel, git, flatpak, rustup, ccache) |
| `core` | userland base, archiviatori, postfix/mailx |
| `devel` | toolchain (gcc/llvm/clang), build system, dkms |
| `filesystems` | partizioni, RAID, Btrfs/snapper, recovery base |
| `fonts` · `audio` · `crypto` | noto · alsa/sox/rtkit · age/rhash |
| `networking` · `bluetooth` · `gpm` | NM/avahi/diagnostica · bluez · gpm |
| `hardware` | fwupd, smart, fido/smartcard, backlight |
| `forensics` | testdisk, sleuthkit, volatility3, carving, yara-x… |
| `gaming` · `virtualization` | gamemode/scope/steam · libvirt/docker/k8s |
| `office` · `media` · `cli_tools` | produttività · vlc/gimp/picard · tool CLI |
| `hack` | burpsuite/ghidra/gobuster/seclists |
| `desktop_kde` | Plasma + app KDE + sddm + power-profiles-daemon |
| `desktop_common` | librewolf/brave/libreoffice/rustdesk (comuni a tutte) |
| `work` · `astro` | bitwarden · stellarium |
| `gpu_amd` · `razer` · `ai_rocm` | amdgpu_top · openrazer · ROCm + llama.cpp |

### Macchine

Su Arch la distinzione *source/bin* sparisce, quindi le app comuni stanno in
`desktop_common` e le macchine restano minime:

| Macchina | Import extra |
|---|---|
| `filosofem` | `work` |
| `sirio` (workstation AMD) | `astro`, `gpu_amd`, `razer`, `ai_rocm` |
| `teslacoil` | (solo base) |
| `teslapower` | `gpu_amd` |

Power management: tutte usano **power-profiles-daemon** (da `desktop_kde`), niente TLP.

## Mapping notevoli (Gentoo → CachyOS)

| Gentoo | CachyOS | Fonte |
|---|---|---|
| `app-arch/7zip` | `7zip` | ufficiale |
| `mail-client/mailx` | `s-nail` | ufficiale (provides `mailx`) |
| `net-dns/bind-tools` | `bind` | ufficiale (dig/host/nslookup) |
| `media-libs/exiftool` | `perl-image-exiftool` | ufficiale |
| `dev-perl/libintl-perl` | `perl-libintl-perl` | ufficiale |
| `app-admin/awscli` | `aws-cli` | ufficiale |
| `kde-apps/kdeadmin-meta` | `kde-system-meta` | ufficiale |
| `dev-python/pywinrm` | `python-pywinrm` | ufficiale |
| `app-admin/ansible-core` | `ansible` | ufficiale |
| `net-print/cups-meta` | `cups` | ufficiale |
| `www-client/brave-browser` | `brave-bin` | **repo CachyOS** |
| `www-client/librewolf*` | `librewolf-bin` | **repo CachyOS** |
| `app-admin/proton-pass-bin` | `proton-pass` | **repo CachyOS** |
| `sys-boot/ventoy-bin` | `ventoy-bin` | **repo CachyOS** |
| `net-misc/rustdesk*` | `rustdesk-bin` | **AUR** |
| `app-editors/vscode` | `code` | ufficiale (build MS: AUR `visual-studio-code-bin`) |
| `dev-libs/light` | `brightnessctl` | ufficiale (sostituisce `light`; sintassi `set 5%+`) |
| `app-misc/jdupes`,`net-dialup/tio` | `jdupes`,`tio` | **AUR** |
| `app-forensics/yara-x` | `yara-x` | **AUR** |
| `games-util/game-device-udev-rules` | `game-devices-udev` | **AUR** |
| `net-proxy/burpsuite`,`app-dicts/seclists` | `burpsuite`,`seclists` | **AUR** |
| ROCm: `hip`,`hipcc`,`rocr-runtime`,`rocm-comgr`… | `rocm-hip-sdk` (meta) | ufficiale |
| `sci-misc/llama-cpp` | `llama.cpp-hip` | **AUR** (build ROCm) |
| `sys-apps/openrazer`+driver | `openrazer-daemon`+`openrazer-driver-dkms` | ufficiale |
| `app-portage/*`, `eselect-repository`, … | — | rimosso (vedi sotto) |

## Servizi (OpenRC → systemd)

| OpenRC | systemd | manager |
|---|---|---|
| NetworkManager, avahi-daemon | `NetworkManager`, `avahi-daemon` | `serv_now` |
| bluetooth, gpm, grub-btrfsd | idem | `serv_now` |
| libvirtd, docker, cupsd | `libvirtd`,`docker`,`cups` | `serv_now` |
| power-profiles-daemon | `power-profiles-daemon` | `serv_now` |
| display-manager | `sddm` | `serv_startup` |
| syncthing (user), openrazer-daemon (user) | `*.service --user` | `serv_user` |
| dbus, elogind | gestiti da systemd | — (rimossi) |
| sysklogd | journald (default) | — (rimosso, vedi sotto) |

## Flatpak → nativo

I 28 Flatpak originali (ID tutti validi su Flathub) sono stati divisi così:

- **12 → nativo** (disponibili nei repo ufficiali Arch/CachyOS, quindi nessun
  AUR aggiunto): Steam `steam`, ProtonPlus `protonplus`, EarTag `eartag`,
  Blanket `blanket`, gpu_screen_recorder `gpu-screen-recorder-ui`, drawio
  `drawio-desktop`, Vorta `vorta`, kdiskmark `kdiskmark`, cpu-x `cpu-x`, Firmware
  `gnome-firmware`, rpi-imager `rpi-imager`, Flatseal `flatseal`.
- **2 Flatpak rimossi senza sostituto**: **Ghidra** (doppione del `ghidra` nativo
  in `hack`) e **ProtonUp-Qt** (si sovrappone a ProtonPlus, scelto come unico
  gestore Proton-GE).
- **14 restano Flatpak** (nativo solo su AUR → convertirli aumenterebbe l'AUR
  senza vantaggi): Anydesk, AlizaMS, FFaudioConverter, WinBox, openterfaceQT,
  Stremio, SynologyAssistant, Bottles, boxbuddyrs, RustConn, Trezor Suite,
  ipscan, Siril, Upscayl. Per **Bottles** e **Trezor Suite** il Flatpak è anche
  il metodo consigliato a monte (packaging ufficiale / sandbox per il wallet).

## ⚠️ Da decidere / verificare

- **`rust` vs `rustup`**: la toolchain è fornita da `rustup` (init_pkgs +
  `rustup default stable`). **Non** installare anche `rust` (conflitto).
- **Power management**: tutte le macchine usano **power-profiles-daemon**
  (installato + abilitato in `desktop_kde`). TLP rimosso del tutto.
- **DKMS / OpenRazer**: DKMS **non** scarica da solo gli header del kernel. Una
  installazione fresca di CachyOS ha sia il kernel più recente sia l'LTS, quindi
  `razer` installa `linux-cachyos-headers` **e** `linux-cachyos-lts-headers` così
  il modulo openrazer viene buildato per entrambi. Adatta se usi altri kernel.
- **Stack VPN di NetworkManager**: su CachyOS è **già preinstallato** (incluso
  `openvpn`), quindi l'import `vpn` è stato rimosso del tutto.
- **PipeWire**: già di default su CachyOS, quindi non ri-elencato in `audio.toml`
  (blocco disponibile commentato).
- **`llama.cpp-hip` vs `ollama-rocm`**: in `ai_rocm` uso `llama.cpp-hip` (AUR) per
  fedeltà alla config Gentoo; se preferisci niente AUR, il repo CachyOS offre
  `ollama-rocm`.

## Rimossi (specifici Portage, nessun equivalente)

`app-portage/eix`, `app-portage/gentoolkit`, `dev-util/pkgdev`,
`app-portage/pycargoebuild`, `app-eselect/eselect-repository`,
`app-admin/eclean-kernel`, `app-admin/sysklogd`,
`kde-plasma/plasma-login-sessions` (incluso in `plasma-meta`),
`dev-python/proton-vpn-network-manager` (dipendenza di `proton-vpn-gtk-app`),
`net-vpn/openvpn` + tutti i `net-vpn/networkmanager-*` (preinstallati su CachyOS).

Non portati per scelta: `app-forensics/bulk_extractor` (solo repo BlackArch),
`net-vpn/networkmanager-sstp` (solo AUR `network-manager-sstp-git`),
`sys-power/tlp` (sostituito da power-profiles-daemon). `app-backup/grub-btrfs`
e `app-admin/btrfs-assistant` non sono gestiti perché preinstallati su CachyOS
con installazione GRUB.

> Sostituzioni equivalenti: ricerca pacchetti `paru -Ss <nome>`; pulizia kernel
> gestita da pacman (`linux*` mantiene corrente+fallback); logging via
> `journalctl` (in alternativa `syslog-ng`, ufficiale).
