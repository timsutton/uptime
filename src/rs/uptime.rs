extern crate libc;
extern crate sysctl;

#[cfg(target_os = "macos")]
fn uptime() {
    use sysctl::Sysctl;

    use std::time::{SystemTime, UNIX_EPOCH};

    let boottime = sysctl::Ctl::new("kern.boottime").unwrap();

    let bt_val = boottime.value();

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards")
        .as_secs() as i64;

    let uptime_seconds = now - bt_val;
    println!("{}", uptime_seconds);
}

#[cfg(target_os = "linux")]
fn uptime() {
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
