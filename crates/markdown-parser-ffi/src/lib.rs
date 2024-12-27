use libc;
pub struct ByteVector(Vec<u8>);

#[repr(C)]
pub struct ByteResult {
    pub data: u8,
    pub status: ErrorStatus,
}

#[repr(C)]
pub enum ErrorStatus {
    Ok = 0,
    Error = 1,
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_new() -> *mut ByteVector {
    // Create a new ByteVector and return a pointer to it.
    let byte_vector = Box::new(ByteVector(Vec::new()));
    Box::into_raw(byte_vector)
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_free(byte_vector: *mut ByteVector) {
    // Convert the raw pointer back to a Box to ensure it is properly deallocated.
    unsafe {
        if !byte_vector.is_null() {
            drop(Box::from_raw(byte_vector));
        }
    }
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_get(
    byte_vector: *const ByteVector,
    index: libc::size_t,
) -> ByteResult {
    unsafe {
        let byte_vector = &*byte_vector;
        if index < byte_vector.0.len() {
            ByteResult {
                data: byte_vector.0[index],
                status: ErrorStatus::Ok,
            }
        } else {
            ByteResult {
                data: 0,
                status: ErrorStatus::Error,
            }
        }
    }
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_read(
    byte_vector: *const ByteVector,
    index: libc::size_t,
    out_char: *mut u8,
) -> ErrorStatus {
    unsafe {
        let byte_vector = &*byte_vector;
        if byte_vector.0.len() > index {
            if !out_char.is_null() {
                *out_char = byte_vector.0[index];
                ErrorStatus::Ok
            } else {
                ErrorStatus::Error
            }
        } else {
            ErrorStatus::Error
        }
    }
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_length(
    byte_vector: *const ByteVector,
) -> libc::size_t {
    unsafe {
        (*byte_vector).0.len() as libc::size_t
    }
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_byte_vector_push(
    byte_vector: *mut ByteVector,
    byte: u8,
) {
    unsafe {
        (*byte_vector).0.push(byte);
    }
}


#[repr(C)]
pub struct ParseResult {
    pub data: *mut ByteVector,
    pub status: ErrorStatus,
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_parse_utf8_markdown(
    markdown_source: *const ByteVector,
) -> ParseResult {
    let markdown_source = unsafe {
        &*markdown_source
    };
    let output = std::str::from_utf8(&markdown_source.0)
        .map_err(|x| Box::new(x) as Box<dyn std::error::Error>)
        // .and_then(data_model::canonical::parse)
        .and_then(::markdown_format::parse)
        .and_then(|nodes| {
            Ok(serde_json::to_string::<Vec<::markdown_format::Node>>(&nodes)?)
        })
        .map(String::into_bytes)
        .map(ByteVector)
        .map(Box::new)
        .map(Box::into_raw)
        .map_err(|x| x.to_string())
        .map_err(String::into_bytes)
        .map_err(ByteVector)
        .map_err(Box::new)
        .map_err(Box::into_raw);
    match output {
        Ok(payload) => {
            ParseResult {
                data: payload,
                status: ErrorStatus::Ok,
            }
        }
        Err(message) => {
            ParseResult {
                data: message,
                status: ErrorStatus::Error,
            }
        }
    }
}


#[no_mangle]
pub extern "C" fn markdown_parser_ffi_hello_world() {
    println!("Hello World! - From Rust!")
}
