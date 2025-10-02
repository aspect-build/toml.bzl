"""

"""

# FIXME: Needs to come from a repo
_path = "/private/var/tmp/_bazel_arrdem/b722cd93482e0fe2f551644b7f4782fc/execroot/_main/bazel-out/darwin_arm64-opt/bin/tomltool_aarch64_apple_darwin"

def _decode_file(ctx, content_path):
    out = ctx.execute(
        [
            _path,
            "-d",
            content_path
        ]
    )
    if out.return_code == 0:
        return json.decode(out.stdout)

toml = struct(
    decode_file = _decode_file
)
