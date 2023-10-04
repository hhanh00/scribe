use scribe_whisper::transcribe;
use anyhow::Result;


fn main() -> Result<()> {
    let res = transcribe("audio.wav")?;
    println!("{}", res);
    Ok(())
}
