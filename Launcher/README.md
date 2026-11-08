# Launcher Status

This folder is an architecture scaffold, not a working launcher. The repository currently has no .NET solution, launcher executable, installer, updater, or packaged game build. Do not treat the development manifest under `Updates/` as a live feed.

Planned layout:

```text
Launcher/
├── RiftAndRuin.Launcher.sln
├── RiftAndRuin.Launcher/
│   ├── MainWindow.xaml
│   ├── MainWindow.xaml.cs
│   ├── Services/
│   │   ├── UpdateService.cs
│   │   ├── DownloadService.cs
│   │   ├── FileVerificationService.cs
│   │   ├── InstallService.cs
│   │   └── GameLaunchService.cs
│   └── Settings/
└── Installer/
```

Implement and validate the launcher before publishing it. A release build needs a Windows game package, a reachable signed/verified update artifact, and a configured distribution endpoint; none is available in this repository yet.
