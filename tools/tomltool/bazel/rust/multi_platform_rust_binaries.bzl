"""Release rule for a rust binary"""

load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@bazel_skylib//rules:copy_file.bzl", "copy_file")
load("@with_cfg.bzl", "with_cfg")
load("//bazel/release:hashes.bzl", "hashes")

opt_filegroup, _opt_filegroup_internal = with_cfg(native.filegroup).set("compilation_mode", "opt").build()

TARGET_TRIPLES = [
    ("aarch64_unknown_linux_musl", "linux_aarch64_musl"),
    ("aarch64_unknown_linux_gnu",  "linux_aarch64_gnu"),
    ("x86_64_unknown_linux_musl",  "linux_x86_64_musl"),
    ("x86_64_unknown_linux_gnu",   "linux_x86_64_gnu"),
    ("x86_64_apple_darwin",        "macos_x86_64"),
    ("aarch64_apple_darwin",       "macos_aarch64"),
]

# Map a Rust naming scheme to a custom name.
TARGET_NAMING_SCHEME = {}

def multi_platform_rust_binaries(name, target, name_scheme = TARGET_NAMING_SCHEME, target_triples = TARGET_TRIPLES, prefix = "", pkg_type = "zip", **kwargs):
    """The multi_platform_rust_binaries macro creates a filegroup containing rust binaries that are ready for release.

    Args:
        name: The name of the filegroup containing all rust targets produced by this macro.
        target: rust_binary that releases will be created for.
        name_scheme: Mapping overriding the "standard" naming for a triple to a custom string.
        target_triples: Map of target tiples to the target platform to build for.
        prefix: An optional prefix added to the output rust binary file name.
        pkg_type: The packaging type that the {name}.packaged target outputs, can be one of 'zip' or 'tar'.
        **kwargs: All other args, forwarded to the output filegroups.
    """

    mac_bins = []
    linux_bins = []

    bin = Label(target).name

    for (target_triple, target_platform) in target_triples:
        target_naming = name_scheme.get(target_triple, target_triple)

        transition_build = "{}_{}_build".format(bin, target_naming)
        platform_transition_filegroup(
            name = transition_build,
            srcs = [target],
            target_platform = "//bazel/platforms:{}".format(target_platform),
            tags = ["manual"],
        )

        copy_name = "{}{}_{}".format(prefix, bin, target_naming)
        copy_file(
            name = "{}_copy".format(copy_name),
            src = transition_build,
            out = copy_name,
            tags = ["manual"],
        )

        bin_sha256 = "{}_bin_hash".format(copy_name)
        hashes(
            name = bin_sha256,
            src = copy_name,
            tags = ["manual"],
        )

        bin_outs = [copy_name, bin_sha256]
        if target_platform.startswith("linux"):
            linux_bins.extend(bin_outs)
        else:
            mac_bins.extend(bin_outs)

    opt_filegroup(
        name = name,
        srcs = linux_bins + mac_bins,
        tags = kwargs.get("tags", []),
        visibility = kwargs.get("visibility", []),
    )
