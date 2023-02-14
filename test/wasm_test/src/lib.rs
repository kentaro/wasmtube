use std::mem;
use std::ptr;
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
pub extern "C" fn echo(index: *const u8, length: usize) -> i32 {
    let slice = unsafe {
      slice::from_raw_parts(index, length)
    };
    let args: Args = serde_json::from_str::<Args>(
      str::from_utf8(slice).unwrap()
    ).unwrap();

    let out_addr = index as *mut u8;
    let data_vec = serde_json::to_vec(&args).unwrap();
    let data_size = data_vec.len();
    for i in 0..data_size {
      unsafe {
        ptr::write(out_addr.offset(i.try_into().unwrap()), *data_vec.get(i).unwrap());
      }
    }

    data_size as i32
}

#[no_mangle]
pub extern "C" fn image_size(index: *const u8, length: usize) -> i32 {
    let slice = unsafe {
      slice::from_raw_parts(index, length * mem::size_of::<u64>() as usize)
    };
    let img = image::RgbImage::from_raw(429, 500, slice.to_vec()).unwrap();

    let image_info = ImageInfo {
        width: img.width(),
        height: img.height(),
    };

    let out_addr = index as *mut u8;
    let data_vec = serde_json::to_vec(&image_info).unwrap();
    let data_size = data_vec.len();
    for i in 0..data_size {
      unsafe {
        ptr::write(out_addr.offset(i.try_into().unwrap()), *data_vec.get(i).unwrap());
      }
    }

    data_size as i32
}
