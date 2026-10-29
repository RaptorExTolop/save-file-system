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
    I32, F32, BOOL, STRING, UNKNOWN
}

Registered_Data :: struct {
    name: string, type: Registry_Data_Types, data: rawptr
}

Data_Registry :: struct {
	filename: string, entries: [dynamic]Registered_Data
}

add_data_to_registry :: proc(
    using registry: ^Data_Registry, name: string, value: ^$T,
) -> (err: string) where T == i32 || T == f32 || T == bool || T == string {
	type := data_kind_of(T)
	append(&entries, Registered_Data{
		name = name, type = type, data = cast(rawptr)value
	})
	return "None"
}

get_data_from_registry :: proc(
	registry: ^Data_Registry, name: string, out: ^$T
) -> (err: string) where T == i32 || T == f32 || T == bool || T == string {
	for entry in registry.entries {
		if (entry.name != name) { continue }
		type := data_kind_of(T)
		is_type_valid := entry.type != type || type == .UNKNOWN
		if (is_type_valid) { 
			fmt.printf(
				"WARNING: getting %v from registry expected %v got %v\n", 
				entry.name, entry.type, data_kind_of(T)
			)
			return "None" 
		}
		out^ = (cast(^T)entry.data)^
	}
	return "None"
}

data_kind_of :: proc($T: typeid) -> (kind: Registry_Data_Types) {
	when T == i32 {
		return .I32
	} else when T == f32 {
		return .F32
	} else when T == bool {
		return .BOOL
	} else when T == string {
		return .STRING
	} else {
		return .UNKNOWN
	}
}

set_data_to_registry :: proc(
	registry: ^Data_Registry, name: string, value: ^$T
) -> (err: string) where T == i32 || T == f32 || T == bool || T == string {
	for entry in registry.entries {
		if (entry.name != name) { continue }
		type := data_kind_of(T)
		is_type_valid := entry.type != type || type == .UNKNOWN
		if (is_type_valid) { 
			fmt.printf(
				"WARNING: getting %v from registry expected %v got %v\n", 
				entry.name, entry.type, data_kind_of(T)
			)
			return "None" 
		}
		entry.data = rawptr(value)
	}
	return "None"
}

main :: proc() {
    test_int   : i32    = 69
    test_float : f32    = 4.20
    test_bool  : bool   = false
    test_string: string = "your mum"
    test_registry: Data_Registry = { 
		filename = "Data", entries = make([dynamic]Registered_Data)
	}

	defer delete(test_registry.entries)
    add_data_to_registry(&test_registry, "test_int", &test_int)
    add_data_to_registry(&test_registry, "test_float", &test_float)
    add_data_to_registry(&test_registry, "test_bool", &test_bool)
    add_data_to_registry(&test_registry, "test_string", &test_string)

	query := "test_int"
	test_get_int: i32
	err := get_data_from_registry(&test_registry, query, &test_get_int)
	if (err != "None") {
		fmt.printf("Unable to get data from registry %v\n", err)
	}
	fmt.printf("Got value %v from query %v\n", test_get_int, query)
}

