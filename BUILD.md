## Requirements

- [Flutter](https://flutter.dev/)
- [Rust](https://www.rust-lang.org/)
- Android SDK/NDK (for Android) v25.1.8937393
- XCode (for MacOS)
- [cargo-ndk](https://github.com/bbqsrc/cargo-ndk)

## Checkout


## Clone
```
git clone https://github.com/hhanh00/scribe.git
cd scribe
git submodule update --init --recursive
```

## Remove nested workspace specifications
Edit `scribe/whisper-rs/Cargo.toml`, and remove the workspace section
```
[workspace]
members = ["sys"]
exclude = ["examples/full_usage"]
```

## Download model

- Download one of the [models](https://huggingface.co/ggerganov/whisper.cpp/tree/main).
`ggml-base.en.bin` or `ggml-medium.en.bin` or large
- Put it in the project directory

## Build whisper 
```
cargo ndk --target arm64-v8a build --release
```

## Install the whisper dynamic library in the android project
```
mkdir -p scribe/android/app/src/main/jniLibs/arm64-v8a
cp target/aarch64-linux-android/release/libscribe_whisper.so scribe/android/app/src/main/jniLibs/arm64-v8a
```

## Create a signing key
Android release apps need to be signed.

> The store and key password must be the same and set to the environment variable `JKS_PASSWORD`
The key alias should be `zwallet`.

Create a key file `key.jks` by following the steps [here](https://docs.flutter.dev/deployment/android#signing-the-app)

Put it in the android folder `scribe/android`

## Build the android project
```
cd scribe
flutter build apk
```

The apk should be in the `build/app/outputs/flutter-apk/app-release.apk`
