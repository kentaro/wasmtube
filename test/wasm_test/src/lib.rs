use std::slice;
use std::str;

use serde_json;
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct Args {
    buffer_size: i32,
    arg: String,
}

#[no_mangle]
pub extern "C" fn echo(index: *const u8, length: usize) -> *const u8 {
    let slice = unsafe {
      slice::from_raw_parts(index, length)
    };
    let args: Args = serde_json::from_str::<Args>(
      str::from_utf8(slice).unwrap()
    ).unwrap();

    let json = serde_json::to_string(&args).unwrap();
    return json.as_ptr();
}
