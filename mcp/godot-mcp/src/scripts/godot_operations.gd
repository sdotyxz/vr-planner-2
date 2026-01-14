#!/usr/bin/env -S godot --headless --script
extends SceneTree

# Debug mode flag
var debug_mode = false

func _init():
    var args = OS.get_cmdline_args()
    
    # Check for debug flag
    debug_mode = "--debug-godot" in args
    
    # Find the script argument and determine the positions of operation and params
    var script_index = args.find("--script")
    if script_index == -1:
        log_error("Could not find --script argument")
        quit(1)
    
    # The operation should be 2 positions after the script path (script_index + 1 is the script path itself)
    var operation_index = script_index + 2
    # The params should be 3 positions after the script path
    var params_index = script_index + 3
    
    if args.size() <= params_index:
        log_error("Usage: godot --headless --script godot_operations.gd <operation> <json_params>")
        log_error("Not enough command-line arguments provided.")
        quit(1)
    
    # Log all arguments for debugging
    log_debug("All arguments: " + str(args))
    log_debug("Script index: " + str(script_index))
    log_debug("Operation index: " + str(operation_index))
    log_debug("Params index: " + str(params_index))
    
    var operation = args[operation_index]
    var params_json = args[params_index]
    
    # Support reading JSON from file if it starts with @
    if params_json.begins_with("@"):
        var file_path = params_json.substr(1)
        if not file_path.begins_with("res://") and not file_path.begins_with("/") and not file_path.begins_with("C:") and not file_path.begins_with("D:"):
            file_path = "res://" + file_path
        if FileAccess.file_exists(file_path):
            var file = FileAccess.open(file_path, FileAccess.READ)
            if file:
                params_json = file.get_as_text()
                file.close()
                log_info("Read JSON from file: " + file_path)
            else:
                log_error("Failed to open file: " + file_path)
                quit(1)
        else:
            log_error("File not found: " + file_path)
            quit(1)
    
    log_info("Operation: " + operation)
    log_debug("Params JSON: " + params_json)
    
    # Parse JSON using Godot 4.x API
    var json = JSON.new()
    var error = json.parse(params_json)
    var params = null
    
    if error == OK:
        params = json.get_data()
    else:
        log_error("Failed to parse JSON parameters: " + params_json)
        log_error("JSON Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
        quit(1)
    
    # Check if params is null (not just empty - empty dict {} is valid)
    if params == null:
        log_error("Failed to parse JSON parameters: " + params_json)
        quit(1)
    
    log_info("Executing operation: " + operation)
    
    match operation:
        "create_scene":
            create_scene(params)
        "add_node":
            add_node(params)
        "load_sprite":
            load_sprite(params)
        "export_mesh_library":
            export_mesh_library(params)
        "save_scene":
            save_scene(params)
        "get_uid":
            get_uid(params)
        "resave_resources":
            resave_resources(params)
        # SceneBuilder operations
        "list_collections":
            list_collections(params)
        "list_collection_items":
            list_collection_items(params)
        "get_item_info":
            get_item_info(params)
        "create_scene_builder_item":
            create_scene_builder_item(params)
        "place_item":
            place_item(params)
        "place_items_batch":
            place_items_batch(params)
        _:
            log_error("Unknown operation: " + operation)
            quit(1)
    
    quit()

# Logging functions
func log_debug(message):
    if debug_mode:
        print("[DEBUG] " + message)

func log_info(message):
    print("[INFO] " + message)

func log_error(message):
    printerr("[ERROR] " + message)

# Get a script by name or path
func get_script_by_name(name_of_class):
    if debug_mode:
        print("Attempting to get script for class: " + name_of_class)
    
    # Try to load it directly if it's a resource path
    if ResourceLoader.exists(name_of_class, "Script"):
        if debug_mode:
            print("Resource exists, loading directly: " + name_of_class)
        var script = load(name_of_class) as Script
        if script:
            if debug_mode:
                print("Successfully loaded script from path")
            return script
        else:
            printerr("Failed to load script from path: " + name_of_class)
    elif debug_mode:
        print("Resource not found, checking global class registry")
    
    # Search for it in the global class registry if it's a class name
    var global_classes = ProjectSettings.get_global_class_list()
    if debug_mode:
        print("Searching through " + str(global_classes.size()) + " global classes")
    
    for global_class in global_classes:
        var found_name_of_class = global_class["class"]
        var found_path = global_class["path"]
        
        if found_name_of_class == name_of_class:
            if debug_mode:
                print("Found matching class in registry: " + found_name_of_class + " at path: " + found_path)
            var script = load(found_path) as Script
            if script:
                if debug_mode:
                    print("Successfully loaded script from registry")
                return script
            else:
                printerr("Failed to load script from registry path: " + found_path)
                break
    
    printerr("Could not find script for class: " + name_of_class)
    return null

# Instantiate a class by name
func instantiate_class(name_of_class):
    if name_of_class.is_empty():
        printerr("Cannot instantiate class: name is empty")
        return null
    
    var result = null
    if debug_mode:
        print("Attempting to instantiate class: " + name_of_class)
    
    # Check if it's a built-in class
    if ClassDB.class_exists(name_of_class):
        if debug_mode:
            print("Class exists in ClassDB, using ClassDB.instantiate()")
        if ClassDB.can_instantiate(name_of_class):
            result = ClassDB.instantiate(name_of_class)
            if result == null:
                printerr("ClassDB.instantiate() returned null for class: " + name_of_class)
        else:
            printerr("Class exists but cannot be instantiated: " + name_of_class)
            printerr("This may be an abstract class or interface that cannot be directly instantiated")
    else:
        # Try to get the script
        if debug_mode:
            print("Class not found in ClassDB, trying to get script")
        var script = get_script_by_name(name_of_class)
        if script is GDScript:
            if debug_mode:
                print("Found GDScript, creating instance")
            result = script.new()
        else:
            printerr("Failed to get script for class: " + name_of_class)
            return null
    
    if result == null:
        printerr("Failed to instantiate class: " + name_of_class)
    elif debug_mode:
        print("Successfully instantiated class: " + name_of_class + " of type: " + result.get_class())
    
    return result

# Create a new scene with a specified root node type
func create_scene(params):
    print("Creating scene: " + params.scene_path)
    
    # Get project paths and log them for debugging
    var project_res_path = "res://"
    var project_user_path = "user://"
    var global_res_path = ProjectSettings.globalize_path(project_res_path)
    var global_user_path = ProjectSettings.globalize_path(project_user_path)
    
    if debug_mode:
        print("Project paths:")
        print("- res:// path: " + project_res_path)
        print("- user:// path: " + project_user_path)
        print("- Globalized res:// path: " + global_res_path)
        print("- Globalized user:// path: " + global_user_path)
        
        # Print some common environment variables for debugging
        print("Environment variables:")
        var env_vars = ["PATH", "HOME", "USER", "TEMP", "GODOT_PATH"]
        for env_var in env_vars:
            if OS.has_environment(env_var):
                print("  " + env_var + " = " + OS.get_environment(env_var))
    
    # Normalize the scene path
    var full_scene_path = params.scene_path
    if not full_scene_path.begins_with("res://"):
        full_scene_path = "res://" + full_scene_path
    if debug_mode:
        print("Scene path (with res://): " + full_scene_path)
    
    # Convert resource path to an absolute path
    var absolute_scene_path = ProjectSettings.globalize_path(full_scene_path)
    if debug_mode:
        print("Absolute scene path: " + absolute_scene_path)
    
    # Get the scene directory paths
    var scene_dir_res = full_scene_path.get_base_dir()
    var scene_dir_abs = absolute_scene_path.get_base_dir()
    if debug_mode:
        print("Scene directory (resource path): " + scene_dir_res)
        print("Scene directory (absolute path): " + scene_dir_abs)
    
    # Only do extensive testing in debug mode
    if debug_mode:
        # Try to create a simple test file in the project root to verify write access
        var initial_test_file_path = "res://godot_mcp_test_write.tmp"
        var initial_test_file = FileAccess.open(initial_test_file_path, FileAccess.WRITE)
        if initial_test_file:
            initial_test_file.store_string("Test write access")
            initial_test_file.close()
            print("Successfully wrote test file to project root: " + initial_test_file_path)
            
            # Verify the test file exists
            var initial_test_file_exists = FileAccess.file_exists(initial_test_file_path)
            print("Test file exists check: " + str(initial_test_file_exists))
            
            # Clean up the test file
            if initial_test_file_exists:
                var remove_error = DirAccess.remove_absolute(ProjectSettings.globalize_path(initial_test_file_path))
                print("Test file removal result: " + str(remove_error))
        else:
            var write_error = FileAccess.get_open_error()
            printerr("Failed to write test file to project root: " + str(write_error))
            printerr("This indicates a serious permission issue with the project directory")
    
    # Use traditional if-else statement for better compatibility
    var root_node_type = "Node2D"  # Default value
    if params.has("root_node_type"):
        root_node_type = params.root_node_type
    if debug_mode:
        print("Root node type: " + root_node_type)
    
    # Create the root node
    var scene_root = instantiate_class(root_node_type)
    if not scene_root:
        printerr("Failed to instantiate node of type: " + root_node_type)
        printerr("Make sure the class exists and can be instantiated")
        printerr("Check if the class is registered in ClassDB or available as a script")
        quit(1)
    
    scene_root.name = "root"
    if debug_mode:
        print("Root node created with name: " + scene_root.name)
    
    # Set the owner of the root node to itself (important for scene saving)
    scene_root.owner = scene_root
    
    # Pack the scene
    var packed_scene = PackedScene.new()
    var result = packed_scene.pack(scene_root)
    if debug_mode:
        print("Pack result: " + str(result) + " (OK=" + str(OK) + ")")
    
    if result == OK:
        # Only do extensive testing in debug mode
        if debug_mode:
            # First, let's verify we can write to the project directory
            print("Testing write access to project directory...")
            var test_write_path = "res://test_write_access.tmp"
            var test_write_abs = ProjectSettings.globalize_path(test_write_path)
            var test_file = FileAccess.open(test_write_path, FileAccess.WRITE)
            
            if test_file:
                test_file.store_string("Write test")
                test_file.close()
                print("Successfully wrote test file to project directory")
                
                # Clean up test file
                if FileAccess.file_exists(test_write_path):
                    var remove_error = DirAccess.remove_absolute(test_write_abs)
                    print("Test file removal result: " + str(remove_error))
            else:
                var write_error = FileAccess.get_open_error()
                printerr("Failed to write test file to project directory: " + str(write_error))
                printerr("This may indicate permission issues with the project directory")
                # Continue anyway, as the scene directory might still be writable
        
        # Ensure the scene directory exists using DirAccess
        if debug_mode:
            print("Ensuring scene directory exists...")
        
        # Get the scene directory relative to res://
        var scene_dir_relative = scene_dir_res.substr(6)  # Remove "res://" prefix
        if debug_mode:
            print("Scene directory (relative to res://): " + scene_dir_relative)
        
        # Create the directory if needed
        if not scene_dir_relative.is_empty():
            # First check if it exists
            var dir_exists = DirAccess.dir_exists_absolute(scene_dir_abs)
            if debug_mode:
                print("Directory exists check (absolute): " + str(dir_exists))
            
            if not dir_exists:
                if debug_mode:
                    print("Directory doesn't exist, creating: " + scene_dir_relative)
                
                # Try to create the directory using DirAccess
                var dir = DirAccess.open("res://")
                if dir == null:
                    var open_error = DirAccess.get_open_error()
                    printerr("Failed to open res:// directory: " + str(open_error))
                    
                    # Try alternative approach with absolute path
                    if debug_mode:
                        print("Trying alternative directory creation approach...")
                    var make_dir_error = DirAccess.make_dir_recursive_absolute(scene_dir_abs)
                    if debug_mode:
                        print("Make directory result (absolute): " + str(make_dir_error))
                    
                    if make_dir_error != OK:
                        printerr("Failed to create directory using absolute path")
                        printerr("Error code: " + str(make_dir_error))
                        quit(1)
                else:
                    # Create the directory using the DirAccess instance
                    if debug_mode:
                        print("Creating directory using DirAccess: " + scene_dir_relative)
                    var make_dir_error = dir.make_dir_recursive(scene_dir_relative)
                    if debug_mode:
                        print("Make directory result: " + str(make_dir_error))
                    
                    if make_dir_error != OK:
                        printerr("Failed to create directory: " + scene_dir_relative)
                        printerr("Error code: " + str(make_dir_error))
                        quit(1)
                
                # Verify the directory was created
                dir_exists = DirAccess.dir_exists_absolute(scene_dir_abs)
                if debug_mode:
                    print("Directory exists check after creation: " + str(dir_exists))
                
                if not dir_exists:
                    printerr("Directory reported as created but does not exist: " + scene_dir_abs)
                    printerr("This may indicate a problem with path resolution or permissions")
                    quit(1)
            elif debug_mode:
                print("Directory already exists: " + scene_dir_abs)
        
        # Save the scene
        if debug_mode:
            print("Saving scene to: " + full_scene_path)
        var save_error = ResourceSaver.save(packed_scene, full_scene_path)
        if debug_mode:
            print("Save result: " + str(save_error) + " (OK=" + str(OK) + ")")
        
        if save_error == OK:
            # Only do extensive testing in debug mode
            if debug_mode:
                # Wait a moment to ensure file system has time to complete the write
                print("Waiting for file system to complete write operation...")
                OS.delay_msec(500)  # 500ms delay
                
                # Verify the file was actually created using multiple methods
                var file_check_abs = FileAccess.file_exists(absolute_scene_path)
                print("File exists check (absolute path): " + str(file_check_abs))
                
                var file_check_res = FileAccess.file_exists(full_scene_path)
                print("File exists check (resource path): " + str(file_check_res))
                
                var res_exists = ResourceLoader.exists(full_scene_path)
                print("Resource exists check: " + str(res_exists))
                
                # If file doesn't exist by absolute path, try to create a test file in the same directory
                if not file_check_abs and not file_check_res:
                    printerr("Scene file not found after save. Trying to diagnose the issue...")
                    
                    # Try to write a test file to the same directory
                    var test_scene_file_path = scene_dir_res + "/test_scene_file.tmp"
                    var test_scene_file = FileAccess.open(test_scene_file_path, FileAccess.WRITE)
                    
                    if test_scene_file:
                        test_scene_file.store_string("Test scene directory write")
                        test_scene_file.close()
                        print("Successfully wrote test file to scene directory: " + test_scene_file_path)
                        
                        # Check if the test file exists
                        var test_file_exists = FileAccess.file_exists(test_scene_file_path)
                        print("Test file exists: " + str(test_file_exists))
                        
                        if test_file_exists:
                            # Directory is writable, so the issue is with scene saving
                            printerr("Directory is writable but scene file wasn't created.")
                            printerr("This suggests an issue with ResourceSaver.save() or the packed scene.")
                            
                            # Try saving with a different approach
                            print("Trying alternative save approach...")
                            var alt_save_error = ResourceSaver.save(packed_scene, test_scene_file_path + ".tscn")
                            print("Alternative save result: " + str(alt_save_error))
                            
                            # Clean up test files
                            DirAccess.remove_absolute(ProjectSettings.globalize_path(test_scene_file_path))
                            if alt_save_error == OK:
                                DirAccess.remove_absolute(ProjectSettings.globalize_path(test_scene_file_path + ".tscn"))
                        else:
                            printerr("Test file couldn't be verified. This suggests filesystem access issues.")
                    else:
                        var write_error = FileAccess.get_open_error()
                        printerr("Failed to write test file to scene directory: " + str(write_error))
                        printerr("This confirms there are permission or path issues with the scene directory.")
                    
                    # Return error since we couldn't create the scene file
                    printerr("Failed to create scene: " + params.scene_path)
                    quit(1)
                
                # If we get here, at least one of our file checks passed
                if file_check_abs or file_check_res or res_exists:
                    print("Scene file verified to exist!")
                    
                    # Try to load the scene to verify it's valid
                    var test_load = ResourceLoader.load(full_scene_path)
                    if test_load:
                        print("Scene created and verified successfully at: " + params.scene_path)
                        print("Scene file can be loaded correctly.")
                    else:
                        print("Scene file exists but cannot be loaded. It may be corrupted or incomplete.")
                        # Continue anyway since the file exists
                    
                    print("Scene created successfully at: " + params.scene_path)
                else:
                    printerr("All file existence checks failed despite successful save operation.")
                    printerr("This indicates a serious issue with file system access or path resolution.")
                    quit(1)
            else:
                # In non-debug mode, just check if the file exists
                var file_exists = FileAccess.file_exists(full_scene_path)
                if file_exists:
                    print("Scene created successfully at: " + params.scene_path)
                else:
                    printerr("Failed to create scene: " + params.scene_path)
                    quit(1)
        else:
            # Handle specific error codes
            var error_message = "Failed to save scene. Error code: " + str(save_error)
            
            if save_error == ERR_CANT_CREATE:
                error_message += " (ERR_CANT_CREATE - Cannot create the scene file)"
            elif save_error == ERR_CANT_OPEN:
                error_message += " (ERR_CANT_OPEN - Cannot open the scene file for writing)"
            elif save_error == ERR_FILE_CANT_WRITE:
                error_message += " (ERR_FILE_CANT_WRITE - Cannot write to the scene file)"
            elif save_error == ERR_FILE_NO_PERMISSION:
                error_message += " (ERR_FILE_NO_PERMISSION - No permission to write the scene file)"
            
            printerr(error_message)
            quit(1)
    else:
        printerr("Failed to pack scene: " + str(result))
        printerr("Error code: " + str(result))
        quit(1)

# Add a node to an existing scene
func add_node(params):
    print("Adding node to scene: " + params.scene_path)
    
    var full_scene_path = params.scene_path
    if not full_scene_path.begins_with("res://"):
        full_scene_path = "res://" + full_scene_path
    if debug_mode:
        print("Scene path (with res://): " + full_scene_path)
    
    var absolute_scene_path = ProjectSettings.globalize_path(full_scene_path)
    if debug_mode:
        print("Absolute scene path: " + absolute_scene_path)
    
    if not FileAccess.file_exists(absolute_scene_path):
        printerr("Scene file does not exist at: " + absolute_scene_path)
        quit(1)
    
    var scene = load(full_scene_path)
    if not scene:
        printerr("Failed to load scene: " + full_scene_path)
        quit(1)
    
    if debug_mode:
        print("Scene loaded successfully")
    var scene_root = scene.instantiate()
    if debug_mode:
        print("Scene instantiated")
    
    # Use traditional if-else statement for better compatibility
    var parent_path = "root"  # Default value
    if params.has("parent_node_path"):
        parent_path = params.parent_node_path
    if debug_mode:
        print("Parent path: " + parent_path)
    
    var parent = scene_root
    if parent_path != "root":
        parent = scene_root.get_node(parent_path.replace("root/", ""))
        if not parent:
            printerr("Parent node not found: " + parent_path)
            quit(1)
    if debug_mode:
        print("Parent node found: " + parent.name)
    
    if debug_mode:
        print("Instantiating node of type: " + params.node_type)
    var new_node = instantiate_class(params.node_type)
    if not new_node:
        printerr("Failed to instantiate node of type: " + params.node_type)
        printerr("Make sure the class exists and can be instantiated")
        printerr("Check if the class is registered in ClassDB or available as a script")
        quit(1)
    new_node.name = params.node_name
    if debug_mode:
        print("New node created with name: " + new_node.name)
    
    if params.has("properties"):
        if debug_mode:
            print("Setting properties on node")
        var properties = params.properties
        for property in properties:
            if debug_mode:
                print("Setting property: " + property + " = " + str(properties[property]))
            new_node.set(property, properties[property])
    
    parent.add_child(new_node)
    new_node.owner = scene_root
    if debug_mode:
        print("Node added to parent and ownership set")
    
    var packed_scene = PackedScene.new()
    var result = packed_scene.pack(scene_root)
    if debug_mode:
        print("Pack result: " + str(result) + " (OK=" + str(OK) + ")")
    
    if result == OK:
        if debug_mode:
            print("Saving scene to: " + absolute_scene_path)
        var save_error = ResourceSaver.save(packed_scene, absolute_scene_path)
        if debug_mode:
            print("Save result: " + str(save_error) + " (OK=" + str(OK) + ")")
        if save_error == OK:
            if debug_mode:
                var file_check_after = FileAccess.file_exists(absolute_scene_path)
                print("File exists check after save: " + str(file_check_after))
                if file_check_after:
                    print("Node '" + params.node_name + "' of type '" + params.node_type + "' added successfully")
                else:
                    printerr("File reported as saved but does not exist at: " + absolute_scene_path)
            else:
                print("Node '" + params.node_name + "' of type '" + params.node_type + "' added successfully")
        else:
            printerr("Failed to save scene: " + str(save_error))
    else:
        printerr("Failed to pack scene: " + str(result))

# Load a sprite into a Sprite2D node
func load_sprite(params):
    print("Loading sprite into scene: " + params.scene_path)
    
    # Ensure the scene path starts with res:// for Godot's resource system
    var full_scene_path = params.scene_path
    if not full_scene_path.begins_with("res://"):
        full_scene_path = "res://" + full_scene_path
    
    if debug_mode:
        print("Full scene path (with res://): " + full_scene_path)
    
    # Check if the scene file exists
    var file_check = FileAccess.file_exists(full_scene_path)
    if debug_mode:
        print("Scene file exists check: " + str(file_check))
    
    if not file_check:
        printerr("Scene file does not exist at: " + full_scene_path)
        # Get the absolute path for reference
        var absolute_path = ProjectSettings.globalize_path(full_scene_path)
        printerr("Absolute file path that doesn't exist: " + absolute_path)
        quit(1)
    
    # Ensure the texture path starts with res:// for Godot's resource system
    var full_texture_path = params.texture_path
    if not full_texture_path.begins_with("res://"):
        full_texture_path = "res://" + full_texture_path
    
    if debug_mode:
        print("Full texture path (with res://): " + full_texture_path)
    
    # Load the scene
    var scene = load(full_scene_path)
    if not scene:
        printerr("Failed to load scene: " + full_scene_path)
        quit(1)
    
    if debug_mode:
        print("Scene loaded successfully")
    
    # Instance the scene
    var scene_root = scene.instantiate()
    if debug_mode:
        print("Scene instantiated")
    
    # Find the sprite node
    var node_path = params.node_path
    if debug_mode:
        print("Original node path: " + node_path)
    
    if node_path.begins_with("root/"):
        node_path = node_path.substr(5)  # Remove "root/" prefix
        if debug_mode:
            print("Node path after removing 'root/' prefix: " + node_path)
    
    var sprite_node = null
    if node_path == "":
        # If no node path, assume root is the sprite
        sprite_node = scene_root
        if debug_mode:
            print("Using root node as sprite node")
    else:
        sprite_node = scene_root.get_node(node_path)
        if sprite_node and debug_mode:
            print("Found sprite node: " + sprite_node.name)
    
    if not sprite_node:
        printerr("Node not found: " + params.node_path)
        quit(1)
    
    # Check if the node is a Sprite2D or compatible type
    if debug_mode:
        print("Node class: " + sprite_node.get_class())
    if not (sprite_node is Sprite2D or sprite_node is Sprite3D or sprite_node is TextureRect):
        printerr("Node is not a sprite-compatible type: " + sprite_node.get_class())
        quit(1)
    
    # Load the texture
    if debug_mode:
        print("Loading texture from: " + full_texture_path)
    var texture = load(full_texture_path)
    if not texture:
        printerr("Failed to load texture: " + full_texture_path)
        quit(1)
    
    if debug_mode:
        print("Texture loaded successfully")
    
    # Set the texture on the sprite
    if sprite_node is Sprite2D or sprite_node is Sprite3D:
        sprite_node.texture = texture
        if debug_mode:
            print("Set texture on Sprite2D/Sprite3D node")
    elif sprite_node is TextureRect:
        sprite_node.texture = texture
        if debug_mode:
            print("Set texture on TextureRect node")
    
    # Save the modified scene
    var packed_scene = PackedScene.new()
    var result = packed_scene.pack(scene_root)
    if debug_mode:
        print("Pack result: " + str(result) + " (OK=" + str(OK) + ")")
    
    if result == OK:
        if debug_mode:
            print("Saving scene to: " + full_scene_path)
        var error = ResourceSaver.save(packed_scene, full_scene_path)
        if debug_mode:
            print("Save result: " + str(error) + " (OK=" + str(OK) + ")")
        
        if error == OK:
            # Verify the file was actually updated
            if debug_mode:
                var file_check_after = FileAccess.file_exists(full_scene_path)
                print("File exists check after save: " + str(file_check_after))
                
                if file_check_after:
                    print("Sprite loaded successfully with texture: " + full_texture_path)
                    # Get the absolute path for reference
                    var absolute_path = ProjectSettings.globalize_path(full_scene_path)
                    print("Absolute file path: " + absolute_path)
                else:
                    printerr("File reported as saved but does not exist at: " + full_scene_path)
            else:
                print("Sprite loaded successfully with texture: " + full_texture_path)
        else:
            printerr("Failed to save scene: " + str(error))
    else:
        printerr("Failed to pack scene: " + str(result))

# Export a scene as a MeshLibrary resource
func export_mesh_library(params):
    print("Exporting MeshLibrary from scene: " + params.scene_path)
    
    # Ensure the scene path starts with res:// for Godot's resource system
    var full_scene_path = params.scene_path
    if not full_scene_path.begins_with("res://"):
        full_scene_path = "res://" + full_scene_path
    
    if debug_mode:
        print("Full scene path (with res://): " + full_scene_path)
    
    # Ensure the output path starts with res:// for Godot's resource system
    var full_output_path = params.output_path
    if not full_output_path.begins_with("res://"):
        full_output_path = "res://" + full_output_path
    
    if debug_mode:
        print("Full output path (with res://): " + full_output_path)
    
    # Check if the scene file exists
    var file_check = FileAccess.file_exists(full_scene_path)
    if debug_mode:
        print("Scene file exists check: " + str(file_check))
    
    if not file_check:
        printerr("Scene file does not exist at: " + full_scene_path)
        # Get the absolute path for reference
        var absolute_path = ProjectSettings.globalize_path(full_scene_path)
        printerr("Absolute file path that doesn't exist: " + absolute_path)
        quit(1)
    
    # Load the scene
    if debug_mode:
        print("Loading scene from: " + full_scene_path)
    var scene = load(full_scene_path)
    if not scene:
        printerr("Failed to load scene: " + full_scene_path)
        quit(1)
    
    if debug_mode:
        print("Scene loaded successfully")
    
    # Instance the scene
    var scene_root = scene.instantiate()
    if debug_mode:
        print("Scene instantiated")
    
    # Create a new MeshLibrary
    var mesh_library = MeshLibrary.new()
    if debug_mode:
        print("Created new MeshLibrary")
    
    # Get mesh item names if provided
    var mesh_item_names = params.mesh_item_names if params.has("mesh_item_names") else []
    var use_specific_items = mesh_item_names.size() > 0
    
    if debug_mode:
        if use_specific_items:
            print("Using specific mesh items: " + str(mesh_item_names))
        else:
            print("Using all mesh items in the scene")
    
    # Process all child nodes
    var item_id = 0
    if debug_mode:
        print("Processing child nodes...")
    
    for child in scene_root.get_children():
        if debug_mode:
            print("Checking child node: " + child.name)
        
        # Skip if not using all items and this item is not in the list
        if use_specific_items and not (child.name in mesh_item_names):
            if debug_mode:
                print("Skipping node " + child.name + " (not in specified items list)")
            continue
            
        # Check if the child has a mesh
        var mesh_instance = null
        if child is MeshInstance3D:
            mesh_instance = child
            if debug_mode:
                print("Node " + child.name + " is a MeshInstance3D")
        else:
            # Try to find a MeshInstance3D in the child's descendants
            if debug_mode:
                print("Searching for MeshInstance3D in descendants of " + child.name)
            for descendant in child.get_children():
                if descendant is MeshInstance3D:
                    mesh_instance = descendant
                    if debug_mode:
                        print("Found MeshInstance3D in descendant: " + descendant.name)
                    break
        
        if mesh_instance and mesh_instance.mesh:
            if debug_mode:
                print("Adding mesh: " + child.name)
            
            # Add the mesh to the library
            mesh_library.create_item(item_id)
            mesh_library.set_item_name(item_id, child.name)
            mesh_library.set_item_mesh(item_id, mesh_instance.mesh)
            if debug_mode:
                print("Added mesh to library with ID: " + str(item_id))
            
            # Add collision shape if available
            var collision_added = false
            for collision_child in child.get_children():
                if collision_child is CollisionShape3D and collision_child.shape:
                    mesh_library.set_item_shapes(item_id, [collision_child.shape])
                    if debug_mode:
                        print("Added collision shape from: " + collision_child.name)
                    collision_added = true
                    break
            
            if debug_mode and not collision_added:
                print("No collision shape found for mesh: " + child.name)
            
            # Add preview if available
            if mesh_instance.mesh:
                mesh_library.set_item_preview(item_id, mesh_instance.mesh)
                if debug_mode:
                    print("Added preview for mesh: " + child.name)
            
            item_id += 1
        elif debug_mode:
            print("Node " + child.name + " has no valid mesh")
    
    if debug_mode:
        print("Processed " + str(item_id) + " meshes")
    
    # Create directory if it doesn't exist
    var dir = DirAccess.open("res://")
    if dir == null:
        printerr("Failed to open res:// directory")
        printerr("DirAccess error: " + str(DirAccess.get_open_error()))
        quit(1)
        
    var output_dir = full_output_path.get_base_dir()
    if debug_mode:
        print("Output directory: " + output_dir)
    
    if output_dir != "res://" and not dir.dir_exists(output_dir.substr(6)):  # Remove "res://" prefix
        if debug_mode:
            print("Creating directory: " + output_dir)
        var error = dir.make_dir_recursive(output_dir.substr(6))  # Remove "res://" prefix
        if error != OK:
            printerr("Failed to create directory: " + output_dir + ", error: " + str(error))
            quit(1)
    
    # Save the mesh library
    if item_id > 0:
        if debug_mode:
            print("Saving MeshLibrary to: " + full_output_path)
        var error = ResourceSaver.save(mesh_library, full_output_path)
        if debug_mode:
            print("Save result: " + str(error) + " (OK=" + str(OK) + ")")
        
        if error == OK:
            # Verify the file was actually created
            if debug_mode:
                var file_check_after = FileAccess.file_exists(full_output_path)
                print("File exists check after save: " + str(file_check_after))
                
                if file_check_after:
                    print("MeshLibrary exported successfully with " + str(item_id) + " items to: " + full_output_path)
                    # Get the absolute path for reference
                    var absolute_path = ProjectSettings.globalize_path(full_output_path)
                    print("Absolute file path: " + absolute_path)
                else:
                    printerr("File reported as saved but does not exist at: " + full_output_path)
            else:
                print("MeshLibrary exported successfully with " + str(item_id) + " items to: " + full_output_path)
        else:
            printerr("Failed to save MeshLibrary: " + str(error))
    else:
        printerr("No valid meshes found in the scene")

# Find files with a specific extension recursively
func find_files(path, extension):
    var files = []
    var dir = DirAccess.open(path)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and not file_name.begins_with("."):
                files.append_array(find_files(path + file_name + "/", extension))
            elif file_name.ends_with(extension):
                files.append(path + file_name)
            
            file_name = dir.get_next()
    
    return files

# Get UID for a specific file
func get_uid(params):
    if not params.has("file_path"):
        printerr("File path is required")
        quit(1)
    
    # Ensure the file path starts with res:// for Godot's resource system
    var file_path = params.file_path
    if not file_path.begins_with("res://"):
        file_path = "res://" + file_path
    
    print("Getting UID for file: " + file_path)
    if debug_mode:
        print("Full file path (with res://): " + file_path)
    
    # Get the absolute path for reference
    var absolute_path = ProjectSettings.globalize_path(file_path)
    if debug_mode:
        print("Absolute file path: " + absolute_path)
    
    # Ensure the file exists
    var file_check = FileAccess.file_exists(file_path)
    if debug_mode:
        print("File exists check: " + str(file_check))
    
    if not file_check:
        printerr("File does not exist at: " + file_path)
        printerr("Absolute file path that doesn't exist: " + absolute_path)
        quit(1)
    
    # Check if the UID file exists
    var uid_path = file_path + ".uid"
    if debug_mode:
        print("UID file path: " + uid_path)
    
    var uid_check = FileAccess.file_exists(uid_path)
    if debug_mode:
        print("UID file exists check: " + str(uid_check))
    
    var f = FileAccess.open(uid_path, FileAccess.READ)
    
    if f:
        # Read the UID content
        var uid_content = f.get_as_text()
        f.close()
        if debug_mode:
            print("UID content read successfully")
        
        # Return the UID content
        var result = {
            "file": file_path,
            "absolutePath": absolute_path,
            "uid": uid_content.strip_edges(),
            "exists": true
        }
        if debug_mode:
            print("UID result: " + JSON.stringify(result))
        print(JSON.stringify(result))
    else:
        if debug_mode:
            print("UID file does not exist or could not be opened")
        
        # UID file doesn't exist
        var result = {
            "file": file_path,
            "absolutePath": absolute_path,
            "exists": false,
            "message": "UID file does not exist for this file. Use resave_resources to generate UIDs."
        }
        if debug_mode:
            print("UID result: " + JSON.stringify(result))
        print(JSON.stringify(result))

# Resave all resources to update UID references
func resave_resources(params):
    print("Resaving all resources to update UID references...")
    
    # Get project path if provided
    var project_path = "res://"
    if params.has("project_path"):
        project_path = params.project_path
        if not project_path.begins_with("res://"):
            project_path = "res://" + project_path
        if not project_path.ends_with("/"):
            project_path += "/"
    
    if debug_mode:
        print("Using project path: " + project_path)
    
    # Get all .tscn files
    if debug_mode:
        print("Searching for scene files in: " + project_path)
    var scenes = find_files(project_path, ".tscn")
    if debug_mode:
        print("Found " + str(scenes.size()) + " scenes")
    
    # Resave each scene
    var success_count = 0
    var error_count = 0
    
    for scene_path in scenes:
        if debug_mode:
            print("Processing scene: " + scene_path)
        
        # Check if the scene file exists
        var file_check = FileAccess.file_exists(scene_path)
        if debug_mode:
            print("Scene file exists check: " + str(file_check))
        
        if not file_check:
            printerr("Scene file does not exist at: " + scene_path)
            error_count += 1
            continue
        
        # Load the scene
        var scene = load(scene_path)
        if scene:
            if debug_mode:
                print("Scene loaded successfully, saving...")
            var error = ResourceSaver.save(scene, scene_path)
            if debug_mode:
                print("Save result: " + str(error) + " (OK=" + str(OK) + ")")
            
            if error == OK:
                success_count += 1
                if debug_mode:
                    print("Scene saved successfully: " + scene_path)
                
                    # Verify the file was actually updated
                    var file_check_after = FileAccess.file_exists(scene_path)
                    print("File exists check after save: " + str(file_check_after))
                
                    if not file_check_after:
                        printerr("File reported as saved but does not exist at: " + scene_path)
            else:
                error_count += 1
                printerr("Failed to save: " + scene_path + ", error: " + str(error))
        else:
            error_count += 1
            printerr("Failed to load: " + scene_path)
    
    # Get all .gd and .shader files
    if debug_mode:
        print("Searching for script and shader files in: " + project_path)
    var scripts = find_files(project_path, ".gd") + find_files(project_path, ".shader") + find_files(project_path, ".gdshader")
    if debug_mode:
        print("Found " + str(scripts.size()) + " scripts/shaders")
    
    # Check for missing .uid files
    var missing_uids = 0
    var generated_uids = 0
    
    for script_path in scripts:
        if debug_mode:
            print("Checking UID for: " + script_path)
        var uid_path = script_path + ".uid"
        
        var uid_check = FileAccess.file_exists(uid_path)
        if debug_mode:
            print("UID file exists check: " + str(uid_check))
        
        var f = FileAccess.open(uid_path, FileAccess.READ)
        if not f:
            missing_uids += 1
            if debug_mode:
                print("Missing UID file for: " + script_path + ", generating...")
            
            # Force a save to generate UID
            var res = load(script_path)
            if res:
                var error = ResourceSaver.save(res, script_path)
                if debug_mode:
                    print("Save result: " + str(error) + " (OK=" + str(OK) + ")")
                
                if error == OK:
                    generated_uids += 1
                    if debug_mode:
                        print("Generated UID for: " + script_path)
                    
                        # Verify the UID file was actually created
                        var uid_check_after = FileAccess.file_exists(uid_path)
                        print("UID file exists check after save: " + str(uid_check_after))
                    
                        if not uid_check_after:
                            printerr("UID file reported as generated but does not exist at: " + uid_path)
                else:
                    printerr("Failed to generate UID for: " + script_path + ", error: " + str(error))
            else:
                printerr("Failed to load resource: " + script_path)
        elif debug_mode:
            print("UID file already exists for: " + script_path)
    
    if debug_mode:
        print("Summary:")
        print("- Scenes processed: " + str(scenes.size()))
        print("- Scenes successfully saved: " + str(success_count))
        print("- Scenes with errors: " + str(error_count))
        print("- Scripts/shaders missing UIDs: " + str(missing_uids))
        print("- UIDs successfully generated: " + str(generated_uids))
    print("Resave operation complete")

# Save changes to a scene file
func save_scene(params):
    print("Saving scene: " + params.scene_path)
    
    # Ensure the scene path starts with res:// for Godot's resource system
    var full_scene_path = params.scene_path
    if not full_scene_path.begins_with("res://"):
        full_scene_path = "res://" + full_scene_path
    
    if debug_mode:
        print("Full scene path (with res://): " + full_scene_path)
    
    # Check if the scene file exists
    var file_check = FileAccess.file_exists(full_scene_path)
    if debug_mode:
        print("Scene file exists check: " + str(file_check))
    
    if not file_check:
        printerr("Scene file does not exist at: " + full_scene_path)
        # Get the absolute path for reference
        var absolute_path = ProjectSettings.globalize_path(full_scene_path)
        printerr("Absolute file path that doesn't exist: " + absolute_path)
        quit(1)
    
    # Load the scene
    var scene = load(full_scene_path)
    if not scene:
        printerr("Failed to load scene: " + full_scene_path)
        quit(1)
    
    if debug_mode:
        print("Scene loaded successfully")
    
    # Instance the scene
    var scene_root = scene.instantiate()
    if debug_mode:
        print("Scene instantiated")
    
    # Determine save path
    var save_path = params.new_path if params.has("new_path") else full_scene_path
    if params.has("new_path") and not save_path.begins_with("res://"):
        save_path = "res://" + save_path
    
    if debug_mode:
        print("Save path: " + save_path)
    
    # Create directory if it doesn't exist
    if params.has("new_path"):
        var dir = DirAccess.open("res://")
        if dir == null:
            printerr("Failed to open res:// directory")
            printerr("DirAccess error: " + str(DirAccess.get_open_error()))
            quit(1)
            
        var scene_dir = save_path.get_base_dir()
        if debug_mode:
            print("Scene directory: " + scene_dir)
        
        if scene_dir != "res://" and not dir.dir_exists(scene_dir.substr(6)):  # Remove "res://" prefix
            if debug_mode:
                print("Creating directory: " + scene_dir)
            var error = dir.make_dir_recursive(scene_dir.substr(6))  # Remove "res://" prefix
            if error != OK:
                printerr("Failed to create directory: " + scene_dir + ", error: " + str(error))
                quit(1)
    
    # Create a packed scene
    var packed_scene = PackedScene.new()
    var result = packed_scene.pack(scene_root)
    if debug_mode:
        print("Pack result: " + str(result) + " (OK=" + str(OK) + ")")
    
    if result == OK:
        if debug_mode:
            print("Saving scene to: " + save_path)
        var error = ResourceSaver.save(packed_scene, save_path)
        if debug_mode:
            print("Save result: " + str(error) + " (OK=" + str(OK) + ")")
        
        if error == OK:
            # Verify the file was actually created/updated
            if debug_mode:
                var file_check_after = FileAccess.file_exists(save_path)
                print("File exists check after save: " + str(file_check_after))
                
                if file_check_after:
                    print("Scene saved successfully to: " + save_path)
                    # Get the absolute path for reference
                    var absolute_path = ProjectSettings.globalize_path(save_path)
                    print("Absolute file path: " + absolute_path)
                else:
                    printerr("File reported as saved but does not exist at: " + save_path)
            else:
                print("Scene saved successfully to: " + save_path)
        else:
            printerr("Failed to save scene: " + str(error))
    else:
        printerr("Failed to pack scene: " + str(result))

# ============================================================================
# SceneBuilder Operations
# ============================================================================

# Get the SceneBuilder config root directory
func get_scene_builder_root_dir() -> String:
    # Default SceneBuilder data directory
    return "res://Data/SceneBuilder/"

# List all SceneBuilder collections
func list_collections(params):
    print("Listing SceneBuilder collections...")
    
    var root_dir = get_scene_builder_root_dir()
    if params.has("root_dir"):
        root_dir = params.root_dir
        if not root_dir.begins_with("res://"):
            root_dir = "res://" + root_dir
        if not root_dir.ends_with("/"):
            root_dir += "/"
    
    if debug_mode:
        print("SceneBuilder root directory: " + root_dir)
    
    var collections = []
    var dir = DirAccess.open(root_dir)
    
    if dir == null:
        var error = DirAccess.get_open_error()
        printerr("Failed to open SceneBuilder directory: " + root_dir)
        printerr("Error: " + str(error))
        var result = {
            "success": false,
            "error": "Failed to open SceneBuilder directory",
            "collections": []
        }
        print(JSON.stringify(result))
        return
    
    dir.list_dir_begin()
    var folder_name = dir.get_next()
    
    while folder_name != "":
        if dir.current_is_dir() and not folder_name.begins_with("."):
            if debug_mode:
                print("Found collection folder: " + folder_name)
            
            # Count items in the collection
            var collection_path = root_dir + folder_name + "/"
            var item_count = 0
            var items_dir = DirAccess.open(collection_path)
            
            if items_dir:
                items_dir.list_dir_begin()
                var item_name = items_dir.get_next()
                while item_name != "":
                    if not items_dir.current_is_dir() and item_name.ends_with(".tres"):
                        item_count += 1
                    item_name = items_dir.get_next()
                items_dir.list_dir_end()
            
            collections.append({
                "name": folder_name,
                "path": collection_path,
                "item_count": item_count
            })
        
        folder_name = dir.get_next()
    
    dir.list_dir_end()
    
    var result = {
        "success": true,
        "root_dir": root_dir,
        "collections": collections,
        "total_collections": collections.size()
    }
    
    print(JSON.stringify(result))

# List items in a specific collection
func list_collection_items(params):
    if not params.has("collection_name"):
        printerr("collection_name is required")
        quit(1)
    
    var collection_name = params.collection_name
    print("Listing items in collection: " + collection_name)
    
    var root_dir = get_scene_builder_root_dir()
    if params.has("root_dir"):
        root_dir = params.root_dir
        if not root_dir.begins_with("res://"):
            root_dir = "res://" + root_dir
        if not root_dir.ends_with("/"):
            root_dir += "/"
    
    var collection_path = root_dir + collection_name + "/"
    
    if debug_mode:
        print("Collection path: " + collection_path)
    
    var items = []
    var dir = DirAccess.open(collection_path)
    
    if dir == null:
        var error = DirAccess.get_open_error()
        printerr("Failed to open collection directory: " + collection_path)
        printerr("Error: " + str(error))
        var result = {
            "success": false,
            "error": "Collection not found: " + collection_name,
            "items": []
        }
        print(JSON.stringify(result))
        return
    
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if not dir.current_is_dir() and file_name.ends_with(".tres"):
            var item_path = collection_path + file_name
            if debug_mode:
                print("Found item: " + item_path)
            
            # Load the SceneBuilderItem resource
            var item = load(item_path)
            if item:
                var item_info = {
                    "name": item.item_name if item.get("item_name") else file_name.replace(".tres", ""),
                    "file": file_name,
                    "path": item_path,
                    "uid": item.uid if item.get("uid") else "",
                    "has_texture": item.texture != null if item.get("texture") else false
                }
                items.append(item_info)
            else:
                if debug_mode:
                    print("Failed to load item: " + item_path)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    var result = {
        "success": true,
        "collection_name": collection_name,
        "collection_path": collection_path,
        "items": items,
        "total_items": items.size()
    }
    
    print(JSON.stringify(result))

# Get detailed info about a specific SceneBuilderItem
func get_item_info(params):
    if not params.has("collection_name") or not params.has("item_name"):
        printerr("collection_name and item_name are required")
        quit(1)
    
    var collection_name = params.collection_name
    var item_name = params.item_name
    print("Getting info for item: " + collection_name + "/" + item_name)
    
    var root_dir = get_scene_builder_root_dir()
    if params.has("root_dir"):
        root_dir = params.root_dir
        if not root_dir.begins_with("res://"):
            root_dir = "res://" + root_dir
        if not root_dir.ends_with("/"):
            root_dir += "/"
    
    var item_path = root_dir + collection_name + "/" + item_name + ".tres"
    
    if debug_mode:
        print("Item path: " + item_path)
    
    if not FileAccess.file_exists(item_path):
        printerr("Item not found: " + item_path)
        var result = {
            "success": false,
            "error": "Item not found: " + item_name
        }
        print(JSON.stringify(result))
        return
    
    var item = load(item_path)
    if not item:
        printerr("Failed to load item: " + item_path)
        var result = {
            "success": false,
            "error": "Failed to load item resource"
        }
        print(JSON.stringify(result))
        return
    
    var result = {
        "success": true,
        "item_path": item_path,
        "collection_name": item.collection_name if item.get("collection_name") else collection_name,
        "item_name": item.item_name if item.get("item_name") else item_name,
        "uid": item.uid if item.get("uid") else "",
        "has_texture": item.texture != null if item.get("texture") else false,
        "use_random_vertical_offset": item.use_random_vertical_offset if item.get("use_random_vertical_offset") != null else false,
        "use_random_rotation": item.use_random_rotation if item.get("use_random_rotation") != null else false,
        "use_random_scale": item.use_random_scale if item.get("use_random_scale") != null else false,
        "random_offset_y_min": item.random_offset_y_min if item.get("random_offset_y_min") != null else 0.0,
        "random_offset_y_max": item.random_offset_y_max if item.get("random_offset_y_max") != null else 0.0,
        "random_rot_x": item.random_rot_x if item.get("random_rot_x") != null else 0.0,
        "random_rot_y": item.random_rot_y if item.get("random_rot_y") != null else 0.0,
        "random_rot_z": item.random_rot_z if item.get("random_rot_z") != null else 0.0,
        "random_scale_min": item.random_scale_min if item.get("random_scale_min") != null else 0.9,
        "random_scale_max": item.random_scale_max if item.get("random_scale_max") != null else 1.1
    }
    
    print(JSON.stringify(result))

# Create a new SceneBuilderItem from a scene
func create_scene_builder_item(params):
    if not params.has("collection_name") or not params.has("scene_path"):
        printerr("collection_name and scene_path are required")
        quit(1)
    
    var collection_name = params.collection_name
    var scene_path = params.scene_path
    
    if not scene_path.begins_with("res://"):
        scene_path = "res://" + scene_path
    
    print("Creating SceneBuilderItem from scene: " + scene_path)
    
    # Verify the scene exists
    if not FileAccess.file_exists(scene_path):
        printerr("Scene file not found: " + scene_path)
        var result = {
            "success": false,
            "error": "Scene file not found: " + scene_path
        }
        print(JSON.stringify(result))
        return
    
    var root_dir = get_scene_builder_root_dir()
    if params.has("root_dir"):
        root_dir = params.root_dir
        if not root_dir.begins_with("res://"):
            root_dir = "res://" + root_dir
        if not root_dir.ends_with("/"):
            root_dir += "/"
    
    # Create collection directory if it doesn't exist
    var collection_path = root_dir + collection_name + "/"
    var dir = DirAccess.open(root_dir)
    
    if dir == null:
        # Try to create the root directory
        var make_dir_error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(root_dir))
        if make_dir_error != OK:
            printerr("Failed to create SceneBuilder root directory: " + root_dir)
            var result = {
                "success": false,
                "error": "Failed to create directory"
            }
            print(JSON.stringify(result))
            return
        dir = DirAccess.open(root_dir)
    
    if not dir.dir_exists(collection_name):
        var make_dir_error = dir.make_dir(collection_name)
        if make_dir_error != OK:
            printerr("Failed to create collection directory: " + collection_path)
            var result = {
                "success": false,
                "error": "Failed to create collection directory"
            }
            print(JSON.stringify(result))
            return
    
    # Get the item name from the scene file name or params
    var item_name = params.item_name if params.has("item_name") else scene_path.get_file().replace(".tscn", "")
    
    if debug_mode:
        print("Item name: " + item_name)
        print("Collection path: " + collection_path)
    
    # Get the UID of the scene
    var scene_uid = ""
    var uid_path = scene_path + ".uid"
    if FileAccess.file_exists(uid_path):
        var f = FileAccess.open(uid_path, FileAccess.READ)
        if f:
            scene_uid = f.get_as_text().strip_edges()
            f.close()
    
    # If no .uid file, try to get UID from ResourceLoader
    if scene_uid.is_empty():
        var res_uid = ResourceLoader.get_resource_uid(scene_path)
        if res_uid != ResourceUID.INVALID_ID:
            scene_uid = ResourceUID.id_to_text(res_uid)
    
    if debug_mode:
        print("Scene UID: " + scene_uid)
    
    # Create the SceneBuilderItem resource
    # Since we can't instantiate custom Resource classes directly in headless mode,
    # we'll create a .tres file manually
    var item_file_path = collection_path + item_name + ".tres"
    
    # Build the .tres file content
    var tres_content = """[gd_resource type="Resource" script_class="SceneBuilderItem" load_steps=2 format=3]

[ext_resource type="Script" path="res://addons/SceneBuilder/scene_builder_item.gd" id="1"]

[resource]
script = ExtResource("1")
collection_name = "%s"
item_name = "%s"
uid = "%s"
use_random_vertical_offset = %s
use_random_rotation = %s
use_random_scale = %s
random_offset_y_min = %s
random_offset_y_max = %s
random_rot_x = %s
random_rot_y = %s
random_rot_z = %s
random_scale_min = %s
random_scale_max = %s
""" % [
        collection_name,
        item_name,
        scene_uid,
        "true" if params.get("use_random_vertical_offset", false) else "false",
        "true" if params.get("use_random_rotation", false) else "false",
        "true" if params.get("use_random_scale", false) else "false",
        str(params.get("random_offset_y_min", 0.0)),
        str(params.get("random_offset_y_max", 0.0)),
        str(params.get("random_rot_x", 0.0)),
        str(params.get("random_rot_y", 0.0)),
        str(params.get("random_rot_z", 0.0)),
        str(params.get("random_scale_min", 0.9)),
        str(params.get("random_scale_max", 1.1))
    ]
    
    var f = FileAccess.open(item_file_path, FileAccess.WRITE)
    if f == null:
        printerr("Failed to create item file: " + item_file_path)
        var result = {
            "success": false,
            "error": "Failed to create item file"
        }
        print(JSON.stringify(result))
        return
    
    f.store_string(tres_content)
    f.close()
    
    if debug_mode:
        print("Created item file: " + item_file_path)
    
    var result = {
        "success": true,
        "item_path": item_file_path,
        "collection_name": collection_name,
        "item_name": item_name,
        "scene_path": scene_path,
        "scene_uid": scene_uid
    }
    
    print(JSON.stringify(result))

# Place a SceneBuilder item at a specific position
func place_item(params):
    if not params.has("target_scene") or not params.has("collection_name") or not params.has("item_name"):
        printerr("target_scene, collection_name, and item_name are required")
        quit(1)
    
    var target_scene_path = params.target_scene
    if not target_scene_path.begins_with("res://"):
        target_scene_path = "res://" + target_scene_path
    
    var collection_name = params.collection_name
    var item_name = params.item_name
    
    print("Placing item: " + collection_name + "/" + item_name + " in " + target_scene_path)
    
    # Get position, rotation, scale from params
    var position = Vector3.ZERO
    if params.has("position"):
        var pos = params.position
        if pos is Dictionary:
            position = Vector3(pos.get("x", 0), pos.get("y", 0), pos.get("z", 0))
        elif pos is Array and pos.size() >= 3:
            position = Vector3(pos[0], pos[1], pos[2])
    
    var rotation = Vector3.ZERO
    if params.has("rotation"):
        var rot = params.rotation
        if rot is Dictionary:
            rotation = Vector3(rot.get("x", 0), rot.get("y", 0), rot.get("z", 0))
        elif rot is Array and rot.size() >= 3:
            rotation = Vector3(rot[0], rot[1], rot[2])
    
    var scale_val = Vector3.ONE
    if params.has("scale"):
        var scl = params.scale
        if scl is Dictionary:
            scale_val = Vector3(scl.get("x", 1), scl.get("y", 1), scl.get("z", 1))
        elif scl is Array and scl.size() >= 3:
            scale_val = Vector3(scl[0], scl[1], scl[2])
        elif scl is float or scl is int:
            scale_val = Vector3(scl, scl, scl)
    
    if debug_mode:
        print("Position: " + str(position))
        print("Rotation: " + str(rotation))
        print("Scale: " + str(scale_val))
    
    # Load the SceneBuilderItem to get the scene UID
    var root_dir = get_scene_builder_root_dir()
    var item_path = root_dir + collection_name + "/" + item_name + ".tres"
    
    if not FileAccess.file_exists(item_path):
        printerr("Item not found: " + item_path)
        var result = {
            "success": false,
            "error": "Item not found: " + item_name
        }
        print(JSON.stringify(result))
        return
    
    var item = load(item_path)
    if not item:
        printerr("Failed to load item: " + item_path)
        var result = {
            "success": false,
            "error": "Failed to load item"
        }
        print(JSON.stringify(result))
        return
    
    var scene_uid = item.uid if item.get("uid") else ""
    
    if scene_uid.is_empty():
        printerr("Item has no scene UID: " + item_path)
        var result = {
            "success": false,
            "error": "Item has no scene UID"
        }
        print(JSON.stringify(result))
        return
    
    # Load the scene to place the item
    var item_scene = load(scene_uid)
    if not item_scene:
        printerr("Failed to load item scene from UID: " + scene_uid)
        var result = {
            "success": false,
            "error": "Failed to load item scene"
        }
        print(JSON.stringify(result))
        return
    
    # Load the target scene
    if not FileAccess.file_exists(target_scene_path):
        printerr("Target scene not found: " + target_scene_path)
        var result = {
            "success": false,
            "error": "Target scene not found"
        }
        print(JSON.stringify(result))
        return
    
    var target_scene = load(target_scene_path)
    if not target_scene:
        printerr("Failed to load target scene: " + target_scene_path)
        var result = {
            "success": false,
            "error": "Failed to load target scene"
        }
        print(JSON.stringify(result))
        return
    
    var target_root = target_scene.instantiate()
    
    # Get parent node path
    var parent_path = params.get("parent_path", "")
    var parent_node = target_root
    if not parent_path.is_empty() and parent_path != "root":
        if parent_path.begins_with("root/"):
            parent_path = parent_path.substr(5)
        parent_node = target_root.get_node_or_null(parent_path)
        if parent_node == null:
            printerr("Parent node not found: " + parent_path)
            var result = {
                "success": false,
                "error": "Parent node not found: " + parent_path
            }
            print(JSON.stringify(result))
            return
    
    # Instance the item scene
    var instance = item_scene.instantiate()
    
    # Apply transform
    if instance is Node3D:
        instance.position = position
        instance.rotation_degrees = rotation
        instance.scale = scale_val
        
        # Apply random transform if enabled
        if params.get("apply_random_transform", false):
            if item.get("use_random_vertical_offset"):
                var offset = randf_range(item.random_offset_y_min, item.random_offset_y_max)
                instance.position.y += offset
            
            if item.get("use_random_rotation"):
                instance.rotation_degrees.x += randf_range(-item.random_rot_x, item.random_rot_x)
                instance.rotation_degrees.y += randf_range(-item.random_rot_y, item.random_rot_y)
                instance.rotation_degrees.z += randf_range(-item.random_rot_z, item.random_rot_z)
            
            if item.get("use_random_scale"):
                var random_scale = randf_range(item.random_scale_min, item.random_scale_max)
                instance.scale *= random_scale
    
    # Set instance name
    var instance_name = params.get("instance_name", item_name)
    instance.name = instance_name
    
    # Add to parent
    parent_node.add_child(instance)
    instance.owner = target_root
    
    # Note: Do NOT recursively set owner for descendants of an instanced scene.
    # The children are part of the PackedScene instance and should not have their
    # owner set to target_root, otherwise they will be saved as separate nodes
    # in the .tscn file, causing "node name clashes" errors when loading.
    
    if debug_mode:
        print("Added instance: " + instance.name + " to " + parent_node.name)
    
    # Save the scene
    var packed_scene = PackedScene.new()
    var pack_result = packed_scene.pack(target_root)
    
    if pack_result != OK:
        printerr("Failed to pack scene: " + str(pack_result))
        var result = {
            "success": false,
            "error": "Failed to pack scene"
        }
        print(JSON.stringify(result))
        return
    
    var save_error = ResourceSaver.save(packed_scene, target_scene_path)
    
    if save_error != OK:
        printerr("Failed to save scene: " + str(save_error))
        var result = {
            "success": false,
            "error": "Failed to save scene"
        }
        print(JSON.stringify(result))
        return
    
    var result = {
        "success": true,
        "target_scene": target_scene_path,
        "item_name": item_name,
        "instance_name": instance_name,
        "position": {"x": position.x, "y": position.y, "z": position.z},
        "rotation": {"x": rotation.x, "y": rotation.y, "z": rotation.z},
        "scale": {"x": scale_val.x, "y": scale_val.y, "z": scale_val.z}
    }
    
    print(JSON.stringify(result))

# Helper function to set owner recursively
func set_owner_recursive(node, owner):
    for child in node.get_children():
        child.owner = owner
        set_owner_recursive(child, owner)

# Place multiple items in batch
func place_items_batch(params):
    if not params.has("target_scene") or not params.has("placements"):
        printerr("target_scene and placements are required")
        quit(1)
    
    var target_scene_path = params.target_scene
    if not target_scene_path.begins_with("res://"):
        target_scene_path = "res://" + target_scene_path
    
    var placements = params.placements
    
    print("Batch placing " + str(placements.size()) + " items in " + target_scene_path)
    
    # Load the target scene
    if not FileAccess.file_exists(target_scene_path):
        printerr("Target scene not found: " + target_scene_path)
        var result = {
            "success": false,
            "error": "Target scene not found"
        }
        print(JSON.stringify(result))
        return
    
    var target_scene = load(target_scene_path)
    if not target_scene:
        printerr("Failed to load target scene: " + target_scene_path)
        var result = {
            "success": false,
            "error": "Failed to load target scene"
        }
        print(JSON.stringify(result))
        return
    
    var target_root = target_scene.instantiate()
    var root_dir = get_scene_builder_root_dir()
    
    var placed_count = 0
    var errors = []
    
    # Cache for loaded item scenes
    var scene_cache = {}
    var item_cache = {}
    
    for i in range(placements.size()):
        var placement = placements[i]
        
        var collection_name = placement.get("collection_name", "")
        var item_name = placement.get("item_name", "")
        
        if collection_name.is_empty() or item_name.is_empty():
            errors.append({"index": i, "error": "Missing collection_name or item_name"})
            continue
        
        var item_key = collection_name + "/" + item_name
        
        # Load item if not cached
        if not item_cache.has(item_key):
            var item_path = root_dir + collection_name + "/" + item_name + ".tres"
            if not FileAccess.file_exists(item_path):
                errors.append({"index": i, "error": "Item not found: " + item_key})
                continue
            
            var item = load(item_path)
            if not item:
                errors.append({"index": i, "error": "Failed to load item: " + item_key})
                continue
            
            item_cache[item_key] = item
            
            # Load the scene
            var scene_uid = item.uid if item.get("uid") else ""
            if scene_uid.is_empty():
                errors.append({"index": i, "error": "Item has no scene UID: " + item_key})
                continue
            
            var item_scene = load(scene_uid)
            if not item_scene:
                errors.append({"index": i, "error": "Failed to load scene: " + scene_uid})
                continue
            
            scene_cache[item_key] = item_scene
        
        if not scene_cache.has(item_key):
            continue
        
        var item_scene = scene_cache[item_key]
        var item = item_cache[item_key]
        
        # Get position, rotation, scale
        var position = Vector3.ZERO
        if placement.has("position"):
            var pos = placement.position
            if pos is Dictionary:
                position = Vector3(pos.get("x", 0), pos.get("y", 0), pos.get("z", 0))
            elif pos is Array and pos.size() >= 3:
                position = Vector3(pos[0], pos[1], pos[2])
        
        var rotation = Vector3.ZERO
        if placement.has("rotation"):
            var rot = placement.rotation
            if rot is Dictionary:
                rotation = Vector3(rot.get("x", 0), rot.get("y", 0), rot.get("z", 0))
            elif rot is Array and rot.size() >= 3:
                rotation = Vector3(rot[0], rot[1], rot[2])
        
        var scale_val = Vector3.ONE
        if placement.has("scale"):
            var scl = placement.scale
            if scl is Dictionary:
                scale_val = Vector3(scl.get("x", 1), scl.get("y", 1), scl.get("z", 1))
            elif scl is Array and scl.size() >= 3:
                scale_val = Vector3(scl[0], scl[1], scl[2])
            elif scl is float or scl is int:
                scale_val = Vector3(scl, scl, scl)
        
        # Get parent node
        var parent_path = placement.get("parent_path", "")
        var parent_node = target_root
        if not parent_path.is_empty() and parent_path != "root":
            if parent_path.begins_with("root/"):
                parent_path = parent_path.substr(5)
            parent_node = target_root.get_node_or_null(parent_path)
            if parent_node == null:
                errors.append({"index": i, "error": "Parent node not found: " + parent_path})
                continue
        
        # Instance and configure
        var instance = item_scene.instantiate()
        
        if instance is Node3D:
            instance.position = position
            instance.rotation_degrees = rotation
            instance.scale = scale_val
            
            # Apply random transform if enabled
            if placement.get("apply_random_transform", false):
                if item.get("use_random_vertical_offset"):
                    var offset = randf_range(item.random_offset_y_min, item.random_offset_y_max)
                    instance.position.y += offset
                
                if item.get("use_random_rotation"):
                    instance.rotation_degrees.x += randf_range(-item.random_rot_x, item.random_rot_x)
                    instance.rotation_degrees.y += randf_range(-item.random_rot_y, item.random_rot_y)
                    instance.rotation_degrees.z += randf_range(-item.random_rot_z, item.random_rot_z)
                
                if item.get("use_random_scale"):
                    var random_scale = randf_range(item.random_scale_min, item.random_scale_max)
                    instance.scale *= random_scale
        
        var instance_name = placement.get("instance_name", item_name + "_" + str(i))
        instance.name = instance_name
        
        parent_node.add_child(instance)
        instance.owner = target_root
        # Note: Do NOT recursively set owner for descendants of an instanced scene.
        # The children are part of the PackedScene instance and should not have their
        # owner set to target_root, otherwise they will be saved as separate nodes
        # in the .tscn file, causing "node name clashes" errors when loading.
        
        placed_count += 1
    
    # Save the scene
    var packed_scene = PackedScene.new()
    var pack_result = packed_scene.pack(target_root)
    
    if pack_result != OK:
        printerr("Failed to pack scene: " + str(pack_result))
        var result = {
            "success": false,
            "error": "Failed to pack scene"
        }
        print(JSON.stringify(result))
        return
    
    var save_error = ResourceSaver.save(packed_scene, target_scene_path)
    
    if save_error != OK:
        printerr("Failed to save scene: " + str(save_error))
        var result = {
            "success": false,
            "error": "Failed to save scene"
        }
        print(JSON.stringify(result))
        return
    
    var result = {
        "success": true,
        "target_scene": target_scene_path,
        "placed_count": placed_count,
        "total_requested": placements.size(),
        "errors": errors
    }
    
    print(JSON.stringify(result))
