#+feature using-stmt
package main

import "core:os"
import "core:fmt"

Struct_Values :: struct {
    some_string: string,
    some_int: i32,
    some_float: f32
}

test_struct := Struct_Values{ 
    some_float = 4.20, some_int = 69, some_string = "your mum" 
}

@(private)
// @TODO: vectors could be nice
Registry_Data_Types :: enum u8 {
    I32, F32, BOOL, STRING
}

Registered_Data :: struct {
    name: string, type: Registry_Data_Types, data: rawptr
}

Data_Registry :: struct {
    filename: string, registered_data: Registered_Data
}

add_data_to_registry :: proc(
    using registry: Data_Registry, name: string, 
    type: Registry_Data_Types, data: rawptr,
) -> (err: string) {
    switch type {
    case .I32:
        // i32 has a size of 4 bytes
        data_ptr := cast(^i32)data
        data_value := data_ptr^
        fmt.printf(
            "Adding %v of size %v with data %v\n", type, size_of(i32), data_value
        )
    case .F32:
        // f32 has a size of 4 bytes
        data_ptr := cast(^f32)data
        data_value := data_ptr^
        fmt.printf(
            "Adding %v of size %v with data %v\n", type, size_of(f32), data_value
        )
    case .BOOL:
        // bool has unknown size
        data_ptr := cast(^bool)data
        data_value := data_ptr^
        fmt.printf(
            "Adding %v of size %v with data %v\n", type, size_of(bool), data_value
        )
    case .STRING:
        data_ptr := cast(^string)data
        data_value := data_ptr^
        fmt.printf(
            "Adding %v of size %v with data %v\n", type, size_of(string) * len(data_value), data_value
        )
    }
    return "None"
}

main :: proc() {
    test_int   : i32    = 69
    test_float : f32    = 4.20
    test_bool  : bool   = false
    test_string: string = "your mum"
    test_registry: Data_Registry = {}
    add_data_to_registry(test_registry, "test_name", .I32, &test_int)
    add_data_to_registry(test_registry, "test_name", .F32, &test_float)
    add_data_to_registry(test_registry, "test_name", .BOOL, &test_bool)
    add_data_to_registry(test_registry, "test_name", .STRING, &test_string)
}

