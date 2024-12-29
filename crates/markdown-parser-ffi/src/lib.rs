use libc;
use std::os::raw::c_char;

/// Slower but safer interface for sending strings over FFI boundaries.
/// 
/// Opaque type that wraps a dynamically allocated Rust `Vec`. 
pub struct ByteVector(Vec<u8>);

/// Faster but less safe interface for sending strings over FFI boundaries.
/// 
/// You allocate and manage the string memory, you also provide the length of the array. 
#[repr(C)]
pub struct ByteArray {
    pub data: *const u8,
    pub length: libc::size_t,
}


/// This is simply a wrapper around a dynamically allocated array
/// of chars but this represents memory provisioned in Rust land
/// so make sure to call the appropriate deallocator. 
#[repr(C)]
pub struct RustCStringPointer {
    pub pointer: *mut c_char,
}

impl RustCStringPointer {
    const EMPTY: Self = RustCStringPointer { pointer: std::ptr::null_mut() };
    fn from_string(value: impl Into<String>) -> Option<Self> {
        let c_string = std::ffi::CString::new(value.into()).ok()?;
        let c_string_ptr: *mut c_char = c_string.into_raw();
        Some(Self { pointer: c_string_ptr })
    }
    // fn from_string_or_null(value: impl Into<String>) -> Self {
    //     Self::from_string(value).unwrap_or(Self::EMPTY)
    // }
}

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

/// The encoding format of a data model (like the parsed markdown AST).
#[repr(C)]
pub enum DataModelFormatType {
    JSON = 1,
    BinaryPropertyList = 2,
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
pub struct ByteVectorParseResult {
    pub status: ErrorStatus,
    /// Either the parsed markdown string-encoded AST or an error message (check `status` to determine which one)
    pub output: *mut ByteVector,
}

/// I wonder this to be a slightly safer version compared to `markdown_parser_ffi_parse_utf8_markdown_unsafe`.
/// 
/// This will include an error message if `status` is an error.
#[no_mangle]
pub extern "C" fn markdown_parser_ffi_utf8_byte_vector_parse(
    markdown_source: *const ByteVector,
) -> ByteVectorParseResult {
    let markdown_source = unsafe {
        &*markdown_source
    };
    let output = std::str::from_utf8(&markdown_source.0)
        .map_err(|x| Box::new(x) as Box<dyn std::error::Error>)
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
            ByteVectorParseResult {
                output: payload,
                status: ErrorStatus::Ok,
            }
        }
        Err(message) => {
            ByteVectorParseResult {
                output: message,
                status: ErrorStatus::Error,
            }
        }
    }
}

/// I consider this interface to be relatively less safe because it replies on an implicit null terminating char.
/// 
/// This will include an error message if `status` is an error.
/// 
/// ### Notes: Usage From Swift
/// 
/// In Swift, here is an example of converting native Swift Strings to dynamically allocated arrays of chars with an implicit null terminating char.
/// Note that technically we’re copying bytes from the given `String` (managed by the Swift runtime) to a new region of memory that must be manually cleaned up after use. 
/// ```swift
/// import Foundation
/// 
/// // Function to convert Swift String to C String
/// func toCString(_ string: String) -> UnsafeMutablePointer<CChar>? {
///     // Convert the Swift String to a C string
///     guard let cString = string.cString(using: .utf8) else {
///         return nil
///     }
/// 
///     // Allocate memory for the C string
///     let length = cString.count + 1 // Include space for the null terminator
///     let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: length)
/// 
///     // Copy the C string data to the allocated memory
///     buffer.initialize(from: cString)
///     buffer[length - 1] = 0 // Ensure null termination
/// 
///     return buffer
/// }
/// 
/// // Function to free the allocated C string memory
/// func freeCString(_ cString: UnsafeMutablePointer<CChar>?) {
///     if let cString = cString {
///         cString.deallocate()
///     }
/// }
/// ```
/// As far as I know the above code should be generally safe. But if you’re paranoid use the possibly safer `ByteVector` type and associated API.
/// 
/// Also while less safe if you’re a **no copying** kinda guy with no fear; here’s a very simply alternative that that will be automatically freed when no longer in use by the Swift runtime:
/// ```
/// // Function to convert Swift String to C String
/// func toCString(_ string: String) -> UnsafePointer<CChar> {
///     return (string as NSString).utf8String!
/// }
/// ```
#[no_mangle]
pub extern "C" fn markdown_parser_ffi_utf8_parse_to_json_string(
    c_str: *const c_char,
) -> RustCStringParseResult {
    if c_str.is_null() {
        return RustCStringParseResult {
            output: RustCStringPointer::from_string("given input string is NULL").unwrap_or(RustCStringPointer::EMPTY),
            status: ErrorStatus::Error,
        };
    }

    let c_str = unsafe { std::ffi::CStr::from_ptr(c_str) };
    let r_str: &str = match c_str.to_str() {
        Ok(s) => s,
        Err(_) => {
            return RustCStringParseResult {
                output: RustCStringPointer::from_string("given input string is not valid UTF8").unwrap_or(RustCStringPointer::EMPTY),
                status: ErrorStatus::Error,
            }
        }
    };

    match parse_markdown(r_str) {
        Ok(result) => {
            RustCStringParseResult {
                status: ErrorStatus::Ok,
                output: RustCStringPointer::from_string(result).unwrap_or(RustCStringPointer::EMPTY),
            }
        }
        Err(error) => {
            RustCStringParseResult {
                status: ErrorStatus::Error,
                output: RustCStringPointer::from_string(error.to_string()).unwrap_or(RustCStringPointer::EMPTY),
            }
        }
    }
}

#[repr(C)]
pub struct RustCStringParseResult {
    pub status: ErrorStatus,
    /// Either the parsed markdown string-encoded AST or an error message (check `status` to determine which one)
    pub output: RustCStringPointer,
}

#[no_mangle]
pub extern "C" fn markdown_parser_ffi_rust_c_string_free(rust_string: RustCStringPointer) {
    if rust_string.pointer.is_null() {
        return;
    }
    unsafe {
        let _ = std::ffi::CString::from_raw(rust_string.pointer);
    }
}


#[no_mangle]
pub extern "C" fn markdown_parser_ffi_hello_world() {
    println!("Hello World! - From Rust!")
}


// implementation
fn parse_markdown(input: &str) -> Result<String, Box<dyn std::error::Error>> {
    let nodes = markdown_format::parse(input)?;
    Ok(serde_json::to_string::<Vec<::markdown_format::Node>>(&nodes)?)
}
