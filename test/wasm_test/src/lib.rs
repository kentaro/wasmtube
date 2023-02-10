use std::mem;
use std::slice;
use std::str;

use serde_json;
use serde::{Serialize, Deserialize};

use image;

#[derive(Serialize, Deserialize)]
struct Args {
    args: String,
}

#[derive(Serialize, Deserialize)]
struct ImageInfo {
    width: u32,
    height: u32,
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
    json.as_ptr()
}

#[no_mangle]
pub extern "C" fn image_size(index: *const u8, length: usize) -> *const u8 {
    let slice = unsafe {
      slice::from_raw_parts(index, length * mem::size_of::<u64>() as usize)
    };
    let img = image::RgbImage::from_raw(429, 500, slice.to_vec()).unwrap();

    let image_info = ImageInfo {
        width: img.width(),
        height: img.height(),
    };

    let json = serde_json::to_string(&image_info).unwrap();
    json.as_ptr()
}
