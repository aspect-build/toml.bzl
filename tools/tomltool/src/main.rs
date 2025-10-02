use clap::{Arg, ArgAction, Command};
use serde_transcode::transcode;
use std::{
    env, fs,
    io::{self, BufWriter, Write},
    process,
};

fn bail(msg: &str) -> ! {
    eprintln!("{msg}");
    process::exit(1)
}

fn main() {
    let cmd = Command::new("tomltool")
        .arg(
            Arg::new("encode")
                .short('e')
                .required(false)
                .num_args(0)
                .help("Encode JSON to TOML"),
        )
        .arg(
            Arg::new("decode")
                .short('d')
                .required(false)
                .num_args(0)
                .help("Decode TOML to JSON"),
        )
        .arg(
            Arg::new("src")
                .required(false)
                .num_args(1)
                .action(ArgAction::Set)
                .value_name("FILE")
                .help("Source file to read from"),
        );

    let matches = cmd.get_matches();

    let input = if let Some(path) = matches.get_one::<String>("src") {
        fs::read_to_string(&path).unwrap_or_else(|e| bail(&format!("Failed to read {path}: {e}")))
    } else {
        io::read_to_string(io::stdin()).unwrap_or_else(|e| bail(&format!("Failed to drain stdin")))
    };

    let stdout = io::stdout();
    let handle = stdout.lock();
    let mut out = BufWriter::with_capacity(256 * 1024, handle);

    if matches.get_flag("encode") {
        panic!("Not implemented yet");
    } else if matches.get_flag("decode") {
        // Set up TOML -> JSON transcoding
        let toml_de = toml::de::Deserializer::parse(&input)
            .unwrap_or_else(|e| bail(&format!("Parse failed: {e}")));

        // Buffered stdout to reduce write syscalls.
        let mut json_ser = serde_json::Serializer::new(&mut out); // compact/fast

        // Stream from TOML deserializer into JSON serializer.
        transcode(toml_de, &mut json_ser)
            .unwrap_or_else(|e| bail(&format!("Transcode failed: {e}")));

        // Ensure everything is flushed to stdout before exiting.
        out.flush()
            .unwrap_or_else(|e| bail(&format!("Flush failed: {e}")));
    }
}
