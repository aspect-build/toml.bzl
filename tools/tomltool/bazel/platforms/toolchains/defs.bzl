"""This module registers all the LLVM toolchains that we want to use."""

execution_oses = ["macos", "linux"]
execution_cpus = ["aarch64", "x86_64"]
target_oses = ["macos", "linux"]
target_cpus = ["aarch64", "x86_64"]
os_to_libc = {
    "macos": ["unknown"],
    "linux": ["gnu", "musl"],
}

platforms = [
    struct(
        exec_os = exec_os,
        exec_cpu = exec_cpu,
        tgt_os = tgt_os,
        tgt_cpu = tgt_cpu,
        tgt_libc = tgt_libc,
    )
    for exec_os in execution_oses
    for exec_cpu in execution_cpus
    for tgt_os in target_oses
    for tgt_cpu in target_cpus
    for tgt_libc in os_to_libc[tgt_os]
]
