#+feature dynamic-literals
package build

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

get_project_name_from_dir :: proc() -> (name: string) {
	workingDir, osError := os.get_working_directory(context.allocator)
	if (osError != nil) {
		fmt.printf("Failed to get working dir: %v\n", osError)
		os.exit(69)
	}
	dirs, stringError := strings.split_after(workingDir, "/") /**/
	if (stringError != nil) {
		fmt.printf("Failed to get : %v\n", stringError)
		os.exit(69)
	}
	return dirs[len(dirs)-1]
}

/* get_object_files :: proc() -> []string {
    entries, err := os.read_all_directory_by_path("build", context.temp_allocator)
    if err != nil {
        fmt.printf("Failed to read build directory: %v\n", err)
        os.exit(69)
    }

    objects := make([dynamic]string, 0, context.temp_allocator)

    for entry in entries {
        if strings.has_suffix(entry.name, ".obj") {
            path, path_err := filepath.join(
                { "build", entry.name },
                context.temp_allocator,
            )
            if path_err != nil {
                fmt.printf("Failed to construct object path: %v\n", path_err)
                os.exit(69)
            }

            append(&objects, path)
        }
    }

    return objects[:]
}
*/

get_windows_path :: proc(path: string) -> string {
	return run_cmd_capture({ "wslpath", "-w", path})
}

main :: proc() {
	args := os.args[1:]
	target := len(args) > 0 ? args[0] : "build"

	projectName := get_project_name_from_dir()
	odinRoot := run_cmd_capture({ "odin", "root"})
	mingw := "/usr/x86_64-w64-mingw32/lib"

	switch target {
	case "run-linux":
		run_cmd_stream({ "odin", "build", "src/", fmt.tprintf("-out:build/%v", projectName), "-debug"})
		run_cmd_stream({ fmt.tprintf("./build/%v", projectName) })

	case "build-linux":
		run_cmd_stream({ "odin", "build", "src/", fmt.tprintf("-out:build/%v", projectName), "-debug"})

	case "run-linux-release":
		run_cmd_stream({ "odin", "build", "src/", fmt.tprintf("-out:build/%v", projectName), "-o:speed" })
		run_cmd_stream({ fmt.tprintf("./build/%v", projectName) })

	case "build-linux-release":
		run_cmd_stream({ "odin", "build", "src/", fmt.tprintf("-out:build/%v", projectName), "-o:speed" })

	case "run-wsl": 
		project_path := get_windows_path(".")
		exe_name := fmt.tprintf("%v.exe", projectName)

		command := fmt.tprintf(
			"pushd %v && odin.exe build src\\ -out:build\\%v -debug && build\\%v && popd",
			project_path, exe_name, exe_name,
		)

		run_cmd_stream({ "cmd.exe", "/c", command, })

	case "build-wsl":
		project_path := get_windows_path(".")
		exe_name := fmt.tprintf("%v.exe", projectName)

		command := fmt.tprintf(
			"pushd %v && odin.exe build src\\ -out:build\\%v -debug",
			project_path, exe_name, 
		)

		run_cmd_stream({ "cmd.exe", "/c", command, })

	case "run-wsl-release":
		project_path := get_windows_path(".")
		exe_name := fmt.tprintf("%v.exe", projectName)

		command := fmt.tprintf(
			"pushd %v && odin.exe build src\\ -out:build\\%v -o:speed && build\\%v && popd",
			project_path, exe_name, exe_name
		)

		run_cmd_stream({ "cmd.exe", "/c", command, })

	case "build-wsl-release":
		project_path := get_windows_path(".")
		exe_name := fmt.tprintf("%v.exe", projectName)

		command := fmt.tprintf(
			"pushd %v && odin.exe build src\\ -out:build\\%v -o:speed",
			project_path, exe_name, 
		)

		run_cmd_stream({ "cmd.exe", "/c", command, })
	case:
		fmt.printf("Unknown target: %v\n", target)
	}

}

run_cmd_capture :: proc(cmd: []string, allocator: runtime.Allocator = context.temp_allocator) -> string {
	// fmt.printf("> %v\n", strings.join(cmd, " "))
	desc := os.Process_Desc {
		command = cmd,
	}

	state, out, _, err := os.process_exec(desc, allocator)
	if (err != nil || !state.success) {
		fmt.printf("Command failed with exit code %v\n", state.exit_code)
		os.exit(69)
	}
	return strings.trim_space(string(out))
}

run_cmd_stream :: proc(cmd: []string) {
	fmt.printf("> %v\n", strings.join(cmd, " "))
	desc := os.Process_Desc {
		command = cmd,
		stdout = os.stdout,
		stdin = os.stdin,
		stderr = os.stderr
	}

	process, proccessError := os.process_start(desc)
	if (proccessError != nil) {
		fmt.printf("Failed to start process: %v\n", proccessError)
		os.exit(69)
	}

	state, waitError := os.process_wait(process)
	if (waitError != nil) {
		fmt.printf("Command failed with exit code: %v\n", state.exit_code)
		os.exit(69)
	}
}

