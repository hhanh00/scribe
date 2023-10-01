use allo_isolate::{ffi, IntoDart};
use std::ffi::{c_char, CStr, CString};
use std::path::PathBuf;
use std::str::FromStr;
use parking_lot::{Mutex, RawRwLock, RwLock};
use anyhow::{anyhow, Error, Result};
use flexi_logger::{detailed_format, Duplicate, FileSpec, Logger};
use log::info;
use parking_lot::lock_api::RwLockReadGuard;

macro_rules! from_c_str {
    ($v: ident) => {
        let $v = CStr::from_ptr($v).to_string_lossy();
    };
}

#[no_mangle]
pub unsafe extern "C" fn transcribe_file(
    audio_filename: *mut c_char) -> CResultBytes {
    let r = || {
        from_c_str!(audio_filename);
        let transcript = crate::transcribe(&audio_filename)?;
        Ok::<_, Error>(transcript)
    };
    r().map(|s| s.into_bytes()).into()
}

#[repr(C)]
pub struct CResult<T> {
    error: *mut c_char,
    pub value: T,
}

impl<T: Default> From<Result<T, Error>> for CResult<T> {
    fn from(value: Result<T, Error>) -> Self {
        match value {
            Ok(value) => Self {
                value,
                error: std::ptr::null_mut(),
            },
            Err(e) => Self {
                value: T::default(),
                error: CString::new(e.to_string()).unwrap().into_raw(),
            }
        }
    }
}

#[repr(C)]
pub struct CResultBytes {
    error: *mut c_char,
    pub len: u32,
    pub value: *const u8,
}

impl From<Result<Vec<u8>, Error>> for CResultBytes {
    fn from(value: Result<Vec<u8>, Error>) -> Self {
        match value {
            Ok(v) => {
                let ptr = v.as_ptr();
                let len = v.len();
                std::mem::forget(v);
                Self {
                    value: ptr,
                    len: len as u32,
                    error: std::ptr::null_mut::<c_char>(),
                }
            }
            Err(e) => {
                log::error!("{}", e);
                Self {
                    value: std::ptr::null(),
                    len: 0,
                    error: CString::new(e.to_string()).unwrap().into_raw(),
                }
            }
        }
    }
}
