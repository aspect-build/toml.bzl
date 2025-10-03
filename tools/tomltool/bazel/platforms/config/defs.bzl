"""This module generated the platforms list for the build matrix."""

def linker_suffix(delimiter, linker):
    if linker == "unknown":
        return ""
    return delimiter + linker

cpus = ["aarch64", "x86_64"]

os_to_libc = {
    "linux": ["musl", "gnu"],
    "macos": ["unknown"],
}

platforms = [
    struct(os = os, cpu = cpu, libc = libc)
    for os in os_to_libc
    for libc in os_to_libc[os]
    for cpu in cpus
]
