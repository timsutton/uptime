extern crate libc;

use std::mem::zeroed;

#[cfg(target_os = "macos")]
fn uptime() {
    use libc::{sysctlbyname, timeval};
    use std::ptr;
    use std::time::{SystemTime, UNIX_EPOCH};

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
            println!("{}", uptime_seconds);
        } else {
            eprintln!("Failed to get system uptime");
        }
    }
}

#[cfg(target_os = "linux")]
fn uptime() {
    use libc::sysinfo;
    unsafe {
        let mut info: libc::sysinfo = zeroed();
        if libc::sysinfo(&mut info) == 0 {
            println!("{}", info.uptime);
        } else {
            eprintln!("Failed to get system uptime");
        }
    }
}

fn main() {
    uptime();
}
