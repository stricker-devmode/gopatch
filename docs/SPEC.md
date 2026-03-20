# Application Specifications

## Purpose
- Simultaneous execution of arbitrary commands on arbitrary POSIX systems over SSH
- Definition of arbitrary target POSIX systems in a structured file format (system profiles)
- Definition of dependencies between multiple system profiles
- Additive building of profile definition to reduce configuration overhead (global standard -> User defaults -> system profiles -> command overrides)
- Definition of arbitrary commands in a structured file format (action chains) for reuse
- TUI driven user experience, multipane
- Full per profile logging capability
- Proxy support (HTTP support required, SOCKS support maybe at a later stage)
- Virtualisation platform support (mainly snapshot management) (vSphere required, Proxmox planned, others maybe)

## UI
- TUI driven
    - Bubbletea is strongest contender library so far
- Multiple views
    - List View
        - Shows profiles by fields
            - Id
            - Decription
            - Percentage of action chain done
            - Status display
        - Filterable by fields
        - Allows control of that execution unit
            - start
            - stop
            - restart
            - pause
            - continue (can double for manual intervention))
        - Status display is colour coded
    - Log View
        - Live preview of a given profile's log

## System Profiles
```markdown
SystemProfile
├── connectionSocket `(string)`: like "<Hostname/IP>:<Port>" , e.g. localhost:22 / 192.168.10.55:42069
├── description `(string)`: a description that is to be displayed for this profile
├── id `(string)`: the unique identifier for this system profile
├── loadAuthentication `(string)`: load authentication profile by this id (optional, merges authentication struct)
├── loadProxy `(string)`: load proxy profile by this id (optional, merges proxy struct)
├── loadVirtualization `(string)`: load virtualization profile by this id (optional, merges virtualization struct)
├── action `(struct)`: defines execution actions for this system profile
│   ├── chain `(string)`: which action chain to load (overrides commands array is present) (optional, at least one of `chain` or `commands` required)
│   └── commands `(array)`: defines commands for this system profile to execute (optional, at least one of `chain` or `commands` required)
│       └── command `(struct)`: describes an executable command (optional)
│           ├── cmd `(string)`: main shell command, can include templating
│           ├── onFailure `(string)`: shell command to run on main command failure, can include templating (optional)
│           └── onSuccess `(string)`: shell command to run on main command success, can include templating (optional)
├── authentication `(struct)`: defines authentication to this system (optional, can be merged)
│   ├── password `(string)`: user password for authentication (optional, at least one of `password` or `sshKey` required)
│   ├── profileId `(string)`: unique identifier for authentication profile (only present when merged)
│   ├── sshKey `(string)`: path to ssh key for authentication (optional, at least one of `password` or `sshKey` required)
│   └── username `(string)`: username for authentication (optional, can be merged)
├── dependencies `(array)`: defines dependencies for this system profile (optional)
│   └── id `(string)`: another system profile's unique identifier
├── proxy `(struct)`: defines what proxy connection to use (optional, can be omitted or merged)
│   ├── profileId `(string)`: unique identifier for proxy profile (only present when merged)
│   └── proxyUri `(string)`: proxy to use, syntax: "http://myproxy.example.com:3128" (optional, can be merged)
└── virtualization `(struct)`: defines how this system is virtualized (optional, can be omitted or merged)
    ├── hostname `(string)`: Hostname/IP of virtualization API (optional, can be merged)
    ├── id `(string)`: unique vm identifier in virtualization system
    ├── password `(string)`: password to access virtualization API (optional, can be merged)
    ├── profileId `(string)`: unique identifier for virtualization profile (only present when merged)
    ├── snapshotDescriptionTemplate `(string)`: templating string for snapshot descriptions (optional, can be merged)
    ├── snapshotNameTemplate `(string)`: templating string for snapshot names (optional, can be merged)
    ├── type `(string)`: virtualization system type, e.g. vsphere, proxmox, xen (optional, can be merged)
    └── username `(string)`: username to access virtualization API (optional, can be merged)
```

> [!CAUTION]
> Due to commands supporting templating and inclusion of other action chains it's
> entirely possible to build recursive chains and commands.
> Recursion detection should be built into the resolving process (and likely reject
> recursive chains).

## Global Settings
```markdown
Settings
├── authenticationProfiles `(array)`: contains externally loadable authentication structs
│   └── authentication `(struct)`: defines authentication to this system (optional, can be merged)
│       ├── password `(string)`: user password for authentication (optional, at least one of `password` or `sshKey` required)
│       ├── profileId `(string)`: unique identifier for authentication profile (only present when merged)
│       ├── sshKey `(string)`: path to ssh key for authentication (optional, at least one of `password` or `sshKey` required)
│       └── username `(string)`: username for authentication (optional, can be merged)
├── connections `(struct)`: global connection settings
│   ├── max `(int)`: maximum number of active connections
│   └── maxProxy `(int)`: maximum number of active connections per defined proxy
├── defaultSystemProfile `(struct)`: default system profile from which to build
├── directories `(struct)`: global directory paths
│   ├── chains `(string)`: path from which to load action chains
│   └── logs `(string)`: path to which logs will be written (supports templating)
├── formats `(struct)`: global settings for formats
│   └── logfileName `(string)`: templatable formatting string for logfiles
├── proxyProfiles `(array)`: contains externally loadable proxy profiles
│   └── proxy `(struct)`: defines what proxy connection to use (optional, can be omitted or merged)
│       ├── profileId `(string)`: unique identifier for proxy profile (only present when merged)
│       └── proxyUri `(string)`: proxy to use, syntax: "http://myproxy.example.com:3128" (optional, can be merged)
└── virtualizationProfiles `(array)`: contains externally loadable virtualization profiles
    └── virtualization `(struct)`: defines how this system is virtualized (optional, can be omitted or merged)
        ├── hostname `(string)`: Hostname/IP of virtualization API (optional, can be merged)
        ├── password `(string)`: password to access virtualization API (optional, can be merged)
        ├── profileId `(string)`: unique identifier for virtualization profile (only present when merged)
        ├── snapshotDescriptionTemplate `(string)`: templating string for snapshot descriptions (optional, can be merged)
        ├── snapshotNameTemplate `(string)`: templating string for snapshot names (optional, can be merged)
        ├── type `(string)`: virtualization system type, e.g. vsphere, proxmox, xen (optional, can be merged)
        └── username `(string)`: username to access virtualization API (optional, can be merged)
```
