package main

import "core:reflect"
import "core:fmt"
Some_Struct :: struct {
	some_int: i32,
	some_float: f32,
	some_bool: bool,
	some_string: string,
	some_vec2: [2]f32,
}

// STRUCT_NAME FILE_VERSION (version needed?)
// VALUE_IDENTIFIER EXPECTED_TYPE VALUE
/*

* [x] Get the struct name
* [x] Get the variable names for each one
* [x] Get their types
* [x] And I guess get there values
* [ ] Set the value

*/

main :: proc() {
	some_struct := Some_Struct{
		some_bool = false, some_float = 4.20, some_int = 69, some_string = "your mum", some_vec2 = { 420, 69 }
	}

	// Get's the name of the struct 
	// Type of must return the underlying type (e.g. the Some_Struct in this case)
	// Then we get the type_id of that type, which get's us the name
	type_id := typeid_of(type_of(some_struct))
	name := type_id
	fmt.printf("Struct name is: %v\n", name)
	
	// so the base info is the information about the underlying struct 
	base_info := reflect.type_info_base(type_info_of(type_id))
	//fmt.printf("Base info: %v\n", base_info)

	// interesting to look at it underneath the hood. So the varient contains the actual data
	// for each variable, which was def an interesting read
	//fmt.printf("Flags: %v\n", base_info.variant)

	{ // get the values
	for field in reflect.struct_fields_zipped(name) {
		val := reflect.struct_field_value(some_struct, field)
		fmt.printf("Name: %v. Type: %v. Value: %v\n", field.name, field.type, val)
	}
	}

	{ // set some values
	some_struct_ptr := &some_struct
	for field in reflect.struct_fields_zipped(name) {
		
	}
	}
}

