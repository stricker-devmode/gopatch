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
Required structures:
- Id `(string)`
- Description `(string)`
- Dependencies `(array)` (optional)
    - Id `(string)` other profile's Id
    - Id `(string)`
    - ...
- Connection `(struct)`
    - Socket `(string)` like "<Hostname/IP>:<Port>" , e.g. localhost:22 / 192.168.10.55:42069
    - UseProxy `(bool)`
    - Proxy URI `(string)` like "http://myproxy.example.com:3128" (optional, can be inherited from global settings)
- Authentication `(struct)` (optional, can be inherited from global settings)
    - User `(string)`
    - Password `(string)` (optional, at least one of `Password` or `SshKey` required)
    - SshKey `(string)` An FS path (optional, at least one of `Password` or `SshKey` required)
- Virtualisation `(struct)` (optional)
    - Type `(string)` Like vsphere, proxmox, etc.
    - Host `(string)` Hostname/IP of virtualisation API (optional, can be inherited from global settings)
    - Username `(string)` (optional, can be inherited from global settings)
    - Password `(string)` (optional, can be inherited from global settings)
    - SnapshotNameTemplate `(string)` templating string (optional, can be inherited from global settings)
    - SnapshotDescTemplate `(string)` templating string (optional, can be inherited from global settings)
    - Id `(string)` VM identifier in virtualisation system
- Action `(struct)` (optional, can be inherited from global settings)
    - Chain `(string)` templating string for chain (optional, at least one of `Chain` or `Commands` required)
    - Commands `(array)` (optional, at least one of `Chain` or `Commands` required)
        - Command `(struct)`
            - Cmd `(string)` shell command, can include templating, or templating for chain
            - OnSuccess `(string)` shell command, can include templating, or templating for chain (optional)
            - OnFailure `(string)` shell command, can include templating, or templating for chain (optional)
        - Command `(struct)`
        - ...

> [!CAUTION]
> Due to commands supporting templating and inclusion of other action chains it's
> entirely possible to build recursive chains and commands.
> Recursion detection should be built into the resolving process (and likely reject
> recursive chains).
