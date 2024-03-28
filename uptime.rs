extern crate libc;

use libc::{sysctlbyname, timeval};
use std::mem::zeroed;
use std::ptr;
use std::time::{SystemTime, UNIX_EPOCH};

fn main() {
    unsafe {
        let mut boottime: timeval = zeroed();
        let mut len: libc::size_t = std::mem::size_of::<timeval>() as libc::size_t;
        let name = std::ffi::CString::new("kern.boottime").unwrap();

        if sysctlbyname(
            name.as_ptr(),
            &mut boottime as *mut _ as *mut _,
            &mut len,
            ptr::null_mut(),
            0,
        ) == 0
        {
            let now = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .expect("Time went backwards")
                .as_secs() as i64;

            let uptime_seconds = now - boottime.tv_sec;
            println!("Uptime: {} seconds", uptime_seconds);
        } else {
            eprintln!("Failed to get system uptime");
        }
    }
}
