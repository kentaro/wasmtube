use std::{ptr, slice, str};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
struct Args {
    args: String,
}

#[derive(Serialize, Deserialize)]
struct ImageInfo {
    width: u32,
    height: u32,
}

/// # Safety
#[no_mangle]
pub unsafe extern "C" fn echo(index: *const u8, length: usize) -> i32 {
    let slice = unsafe { slice::from_raw_parts(index, length) };
    let args: Args = serde_json::from_str::<Args>(str::from_utf8(slice).unwrap()).unwrap();

    store_into_memory(index, args)
}

/// # Safety
#[no_mangle]
pub unsafe extern "C" fn image_size(
    index: *const u8,
    _length: usize,
    width: u32,
    height: u32,
) -> i32 {
    let slice = unsafe { slice::from_raw_parts(index, (width * height * 3) as usize) };
    let img = image::RgbImage::from_raw(width, height, slice.to_vec()).unwrap();

    let image_info = ImageInfo {
        width: img.width(),
        height: img.height(),
    };

    store_into_memory(index, image_info)
}

fn store_into_memory<T: Serialize>(index: *const u8, data: T) -> i32 {
    let out_addr = index as *mut u8;
    let data_vec = serde_json::to_vec(&data).unwrap();
    let data_size = data_vec.len();
    for i in 0..data_size {
        unsafe {
            ptr::write(
                out_addr.offset(i.try_into().unwrap()),
                *data_vec.get(i).unwrap(),
            );
        }
    }

    data_size as i32
}
