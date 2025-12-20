# Godot_Docs - Api

**Pages:** 23

---

## AcceptDialog — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_acceptdialog.html

**Contents:**
- AcceptDialog
- Description
- Properties
- Methods
- Theme Properties
- Signals
- Property Descriptions
- Method Descriptions
- Theme Property Descriptions
- User-contributed notes

Inherits: Window < Viewport < Node < Object

Inherited By: ConfirmationDialog

A base dialog used for user notification.

The default use of AcceptDialog is to allow it to only be accepted or closed, with the same result. However, the confirmed and canceled signals allow to make the two actions different, and the add_button() method allows to add custom buttons and actions.

dialog_close_on_escape

true (overrides Window)

true (overrides Window)

true (overrides Window)

true (overrides Window)

"Alert!" (overrides Window)

true (overrides Window)

false (overrides Window)

true (overrides Window)

add_button(text: String, right: bool = false, action: String = "")

add_cancel_button(name: String)

register_text_enter(line_edit: LineEdit)

remove_button(button: Button)

Emitted when the dialog is closed or the button created with add_cancel_button() is pressed.

Emitted when the dialog is accepted, i.e. the OK button is pressed.

custom_action(action: StringName) 🔗

Emitted when a custom button with an action is pressed. See add_button().

bool dialog_autowrap = false 🔗

void set_autowrap(value: bool)

Sets autowrapping for the text in the dialog.

bool dialog_close_on_escape = true 🔗

void set_close_on_escape(value: bool)

bool get_close_on_escape()

If true, the dialog will be hidden when the ui_cancel action is pressed (by default, this action is bound to @GlobalScope.KEY_ESCAPE).

bool dialog_hide_on_ok = true 🔗

void set_hide_on_ok(value: bool)

bool get_hide_on_ok()

If true, the dialog is hidden when the OK button is pressed. You can set it to false if you want to do e.g. input validation when receiving the confirmed signal, and handle hiding the dialog in your own logic.

Note: Some nodes derived from this class can have a different default value, and potentially their own built-in logic overriding this setting. For example FileDialog defaults to false, and has its own input validation code that is called when you press OK, which eventually hides the dialog if the input is valid. As such, this property can't be used in FileDialog to disable hiding the dialog when pressing OK.

String dialog_text = "" 🔗

void set_text(value: String)

The text displayed by the dialog.

String ok_button_text = "" 🔗

void set_ok_button_text(value: String)

String get_ok_button_text()

The text displayed by the OK button (see get_ok_button()). If empty, a default text will be used.

Button add_button(text: String, right: bool = false, action: String = "") 🔗

Adds a button with label text and a custom action to the dialog and returns the created button.

If action is not empty, pressing the button will emit the custom_action signal with the specified action string.

If true, right will place the button to the right of any sibling buttons.

You can use remove_button() method to remove a button created with this method from the dialog.

Button add_cancel_button(name: String) 🔗

Adds a button with label name and a cancel action to the dialog and returns the created button.

You can use remove_button() method to remove a button created with this method from the dialog.

Returns the label used for built-in text.

Warning: This is a required internal node, removing and freeing it may cause a crash. If you wish to hide it or any of its children, use their CanvasItem.visible property.

Button get_ok_button() 🔗

Returns the OK Button instance.

Warning: This is a required internal node, removing and freeing it may cause a crash. If you wish to hide it or any of its children, use their CanvasItem.visible property.

void register_text_enter(line_edit: LineEdit) 🔗

Registers a LineEdit in the dialog. When the enter key is pressed, the dialog will be accepted.

void remove_button(button: Button) 🔗

Removes the button from the dialog. Does NOT free the button. The button must be a Button added with add_button() or add_cancel_button() method. After removal, pressing the button will no longer emit this dialog's custom_action or canceled signals.

int buttons_min_height = 0 🔗

The minimum height of each button in the bottom row (such as OK/Cancel) in pixels. This can be increased to make buttons with short texts easier to click/tap.

int buttons_min_width = 0 🔗

The minimum width of each button in the bottom row (such as OK/Cancel) in pixels. This can be increased to make buttons with short texts easier to click/tap.

int buttons_separation = 10 🔗

The size of the vertical space between the dialog's content and the button row.

The panel that fills the background of the window.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## All classes — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/index.html

**Contents:**
- All classes
- Globals
- Nodes
- Resources
- Other objects
- Editor-only
- Variant types

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Applying object-oriented principles in Godot — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/best_practices/what_are_godot_classes.html

**Contents:**
- Applying object-oriented principles in Godot
- How scripts work in the engine
- Scenes
- User-contributed notes

The engine offers two main ways to create reusable objects: scripts and scenes. Neither of these technically define classes under the hood.

Still, many best practices using Godot involve applying object-oriented programming principles to the scripts and scenes that compose your game. That is why it's useful to understand how we can think of them as classes.

This guide briefly explains how scripts and scenes work in the engine's core to help you understand how they work under the hood.

The engine provides built-in classes like Node. You can extend those to create derived types using a script.

These scripts are not technically classes. Instead, they are resources that tell the engine a sequence of initializations to perform on one of the engine's built-in classes.

Godot's internal classes have methods that register a class's data with a ClassDB. This database provides runtime access to class information. ClassDB contains information about classes like:

This ClassDB is what objects check against when performing an operation like accessing a property or calling a method. It checks the database's records and the object's base types' records to see if the object supports the operation.

Attaching a Script to your object extends the methods, properties, and signals available from the ClassDB.

Even scripts that don't use the extends keyword implicitly inherit from the engine's base RefCounted class. As a result, you can instantiate scripts without the extends keyword from code. Since they extend RefCounted though, you cannot attach them to a Node.

The behavior of scenes has many similarities to classes, so it can make sense to think of a scene as a class. Scenes are reusable, instantiable, and inheritable groups of nodes. Creating a scene is similar to having a script that creates nodes and adds them as children using add_child().

We often pair a scene with a scripted root node that makes use of the scene's nodes. As such, the script extends the scene by adding behavior through imperative code.

The content of a scene helps to define:

What nodes are available to the script.

How they are organized.

How they are initialized.

What signal connections they have with each other.

Why is any of this important to scene organization? Because instances of scenes are objects. As a result, many object-oriented principles that apply to written code also apply to scenes: single responsibility, encapsulation, and others.

The scene is always an extension of the script attached to its root node, so you can interpret it as part of a class.

Most of the techniques explained in this best practices series build on this point.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## AspectRatioContainer — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_aspectratiocontainer.html

**Contents:**
- AspectRatioContainer
- Description
- Tutorials
- Properties
- Enumerations
- Property Descriptions
- User-contributed notes

Inherits: Container < Control < CanvasItem < Node < Object

A container that preserves the proportions of its child controls.

A container type that arranges its child controls in a way that preserves their proportions automatically when the container is resized. Useful when a container has a dynamic size and the child nodes must adjust their sizes accordingly without losing their aspect ratios.

StretchMode STRETCH_WIDTH_CONTROLS_HEIGHT = 0

The height of child controls is automatically adjusted based on the width of the container.

StretchMode STRETCH_HEIGHT_CONTROLS_WIDTH = 1

The width of child controls is automatically adjusted based on the height of the container.

StretchMode STRETCH_FIT = 2

The bounding rectangle of child controls is automatically adjusted to fit inside the container while keeping the aspect ratio.

StretchMode STRETCH_COVER = 3

The width and height of child controls is automatically adjusted to make their bounding rectangle cover the entire area of the container while keeping the aspect ratio.

When the bounding rectangle of child controls exceed the container's size and Control.clip_contents is enabled, this allows to show only the container's area restricted by its own bounding rectangle.

enum AlignmentMode: 🔗

AlignmentMode ALIGNMENT_BEGIN = 0

Aligns child controls with the beginning (left or top) of the container.

AlignmentMode ALIGNMENT_CENTER = 1

Aligns child controls with the center of the container.

AlignmentMode ALIGNMENT_END = 2

Aligns child controls with the end (right or bottom) of the container.

AlignmentMode alignment_horizontal = 1 🔗

void set_alignment_horizontal(value: AlignmentMode)

AlignmentMode get_alignment_horizontal()

Specifies the horizontal relative position of child controls.

AlignmentMode alignment_vertical = 1 🔗

void set_alignment_vertical(value: AlignmentMode)

AlignmentMode get_alignment_vertical()

Specifies the vertical relative position of child controls.

void set_ratio(value: float)

The aspect ratio to enforce on child controls. This is the width divided by the height. The ratio depends on the stretch_mode.

StretchMode stretch_mode = 2 🔗

void set_stretch_mode(value: StretchMode)

StretchMode get_stretch_mode()

The stretch mode used to align child controls.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Binary serialization API — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/io/binary_serialization_api.html

**Contents:**
- Binary serialization API
- Introduction
- Full Objects vs Object instance IDs
- Packet specification
  - 0: null
  - 1: bool
  - 2: int
  - 3: float
  - 4: String
  - 5: Vector2

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

Godot has a serialization API based on Variant. It's used for converting data types to an array of bytes efficiently. This API is exposed via the global bytes_to_var() and var_to_bytes() functions, but it is also used in the get_var and store_var methods of FileAccess as well as the packet APIs for PacketPeer. This format is not used for binary scenes and resources.

If a variable is serialized with full_objects = true, then any Objects contained in the variable will be serialized and included in the result. This is recursive.

If full_objects = false, then only the instance IDs will be serialized for any Objects contained in the variable.

The packet is designed to be always padded to 4 bytes. All values are little-endian-encoded. All packets have a 4-byte header representing an integer, specifying the type of data.

The lowest value two bytes are used to determine the type, while the highest value two bytes contain flags:

Following this is the actual packet contents, which varies for each type of packet. Note that this assumes Godot is compiled with single-precision floats, which is the default. If Godot was compiled with double-precision floats, the length of "Float" fields within data structures should be 8, and the offset should be (offset - 4) * 2 + 4. The "float" type itself always uses double precision.

0 for False, 1 for True

If no flags are set (flags == 0), the integer is sent as a 32 bit integer:

32-bit signed integer

If flag ENCODE_FLAG_64 is set (flags & 1 == 1), the integer is sent as a 64-bit integer:

64-bit signed integer

If no flags are set (flags == 0), the float is sent as a 32 bit single precision:

IEEE 754 single-precision float

If flag ENCODE_FLAG_64 is set (flags & 1 == 1), the float is sent as a 64-bit double precision number:

IEEE 754 double-precision float

String length (in bytes)

This field is padded to 4 bytes.

The X component of the X column vector, accessed via [0][0]

The Y component of the X column vector, accessed via [0][1]

The X component of the Y column vector, accessed via [1][0]

The Y component of the Y column vector, accessed via [1][1]

The X component of the origin vector, accessed via [2][0]

The Y component of the origin vector, accessed via [2][1]

The X component of the X column vector, accessed via [0][0]

The Y component of the X column vector, accessed via [0][1]

The Z component of the X column vector, accessed via [0][2]

The X component of the Y column vector, accessed via [1][0]

The Y component of the Y column vector, accessed via [1][1]

The Z component of the Y column vector, accessed via [1][2]

The X component of the Z column vector, accessed via [2][0]

The Y component of the Z column vector, accessed via [2][1]

The Z component of the Z column vector, accessed via [2][2]

The X component of the X column vector, accessed via [0][0]

The Y component of the X column vector, accessed via [0][1]

The Z component of the X column vector, accessed via [0][2]

The X component of the Y column vector, accessed via [1][0]

The Y component of the Y column vector, accessed via [1][1]

The Z component of the Y column vector, accessed via [1][2]

The X component of the Z column vector, accessed via [2][0]

The Y component of the Z column vector, accessed via [2][1]

The Z component of the Z column vector, accessed via [2][2]

The X component of the origin vector, accessed via [3][0]

The Y component of the origin vector, accessed via [3][1]

The Z component of the origin vector, accessed via [3][2]

Red (typically 0..1, can be above 1 for overbright colors)

Green (typically 0..1, can be above 1 for overbright colors)

Blue (typically 0..1, can be above 1 for overbright colors)

String length, or new format (val&0x80000000!=0 and NameCount=val&0x7FFFFFFF)

Flags (absolute: val&1 != 0 )

For each Name and Sub-Name

Every name string is padded to 4 bytes.

An Object could be serialized in three different ways: as a null value, with full_objects = false, or with full_objects = true.

Zero (32-bit signed integer)

The Object instance ID (64-bit signed integer)

Class name (String length)

Class name (UTF-8 encoded string)

The number of properties that are serialized

Property name (String length)

Property name (UTF-8 encoded string)

Property value, using this same format

Not all properties are included. Only properties that are configured with the PROPERTY_USAGE_STORAGE flag set will be serialized. You can add a new usage flag to a property by overriding the _get_property_list method in your class. You can also check how property usage is configured by calling Object._get_property_list See PropertyUsageFlags for the possible usage flags.

val&0x7FFFFFFF = elements, val&0x80000000 = shared (bool)

Then what follows is, for amount of "elements", pairs of key and value, one after the other, using this same format.

val&0x7FFFFFFF = elements, val&0x80000000 = shared (bool)

Then what follows is, for amount of "elements", values one after the other, using this same format.

The array data is padded to 4 bytes.

Array length (Integers)

32-bit signed integer

Array length (Integers)

64-bit signed integer

Array length (Floats)

32-bit IEEE 754 single-precision float

Array length (Floats)

64-bit IEEE 754 double-precision float

Array length (Strings)

Every string is padded to 4 bytes.

Red (typically 0..1, can be above 1 for overbright colors)

Green (typically 0..1, can be above 1 for overbright colors)

Blue (typically 0..1, can be above 1 for overbright colors)

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
base_type = val & 0xFFFF;
flags = val >> 16;
```

---

## Class reference primer — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/class_reference/index.html

**Contents:**
- Class reference primer
- How to edit class XML
  - Improve formatting with BBCode style tags
    - Linking
    - Formatting text
    - Formatting code blocks
    - Formatting notes and warnings
  - Marking API as deprecated/experimental
- User-contributed notes

This page explains how to write the class reference. You will learn where to write new descriptions for the classes, methods, and properties for Godot's built-in node types.

To learn to submit your changes to the Godot project using the Git version control system, see Class reference contribution documentation.

The reference for each class is contained in an XML file like the one below:

It starts with brief and long descriptions. In the generated docs, the brief description is always at the top of the page, while the long description lies below the list of methods, variables, and constants. You can find methods, member variables, constants, and signals in separate XML nodes.

For each, you want to learn how they work in Godot's source code. Then, fill their documentation by completing or improving the text in these tags:

<method> (in its <description> tag; return types and arguments don't take separate documentation strings)

<signal> (in its <description> tag; arguments don't take separate documentation strings)

Write in a clear and simple language. Always follow the writing guidelines to keep your descriptions short and easy to read. Do not leave empty lines in the descriptions: each line in the XML file will result in a new paragraph, even if it is empty.

Edit the file for your chosen class in doc/classes/ to update the class reference. The folder contains an XML file for each class. The XML lists the constants and methods you will find in the class reference. Godot generates and updates the XML automatically.

For some modules in the engine's source code, you'll find the XML files in the modules/<module_name>/doc_classes/ directory instead.

Edit it using your favorite text editor. If you use a code editor, make sure that it doesn't change the indent style: you should use tabs for the XML and four spaces inside BBCode-style blocks. More on that below.

To check that the modifications you've made are correct in the generated documentation, navigate to the doc/ folder and run the command make rst. This will convert the XML files to the online documentation's format and output errors if anything's wrong.

Alternatively, you can build Godot and open the modified page in the built-in code reference. To learn how to compile the engine, read the compilation guide.

We recommend using a code editor that supports XML files like Vim, Atom, Visual Studio Code, Notepad++, or another to comfortably edit the file. You can also use their search feature to find classes and properties quickly.

If you use Visual Studio Code, you can install the vscode-xml extension to get linting for class reference XML files.

Godot's XML class reference supports BBCode-like tags for linking as well as formatting text and code. In the tables below you can find the available tags, usage examples and the results after conversion to reStructuredText.

Whenever you link to a member of another class, you need to specify the class name. For links to the same class, the class name is optional and can be omitted.

See [annotation @GDScript.@rpc].

See [constant Color.RED].

See [enum Mesh.ArrayType].

Get [member Node2D.scale].

Call [method Node3D.hide].

Use [constructor Color.Color].

Use [operator Color.operator *].

Use Color.operator *.

Emit [signal Node.renamed].

See [theme_item Label.font].

Takes [param size] for the size.

Takes size for the size.

Currently only @GDScript has annotations.

[lb]b[rb]text[lb]/b[rb]

Do [b]not[/b] call this method.

Do not call this method.

Returns the [i]global[/i] position.

Returns the global position.

[u]Always[/u] use this method.

[s]Outdated information.[/s]

[center]2 + 2 = 4[/center]

Press [kbd]Ctrl + C[/kbd].

Returns [code]true[/code].

Some supported tags like [color] and [font] are not listed here because they are not recommended in the engine documentation.

[kbd] disables BBCode until the parser encounters [/kbd].

[code] disables BBCode until the parser encounters [/code].

There are two options for formatting code blocks:

Use [codeblock] if you want to add an example for a specific language.

Use [codeblocks], [gdscript], and [csharp] if you want to add the same example for both languages, GDScript and C#.

By default, [codeblock] highlights GDScript syntax. You can change it using the lang attribute. Currently supported options are:

[codeblock lang=text] disables syntax highlighting;

[codeblock lang=gdscript] highlights GDScript syntax;

[codeblock lang=csharp] highlights C# syntax (only in .NET version).

[codeblock] disables BBCode until the parser encounters [/codeblock].

Use [codeblock] for pre-formatted code blocks. Since Godot 4.5, tabs should be used for indentation.

If you need to have different code version in GDScript and C#, use [codeblocks] instead. If you use [codeblocks], you also need to have at least one of the language-specific tags, [gdscript] and [csharp].

Always write GDScript code examples first! You can use this experimental code translation tool to speed up your workflow.

The above will display as:

To denote important information, add a paragraph starting with "[b]Note:[/b]" at the end of the description:

To denote crucial information that could cause security issues or loss of data if not followed carefully, add a paragraph starting with "[b]Warning:[/b]" at the end of the description:

In all the paragraphs described above, make sure the punctuation is part of the BBCode tags for consistency.

To mark an API as deprecated or experimental, you need to add the corresponding XML attribute. The attribute value must be a message explaining why the API is not recommended (BBCode markup is supported) or an empty string (the default message will be used). If an API element is marked as deprecated/experimental, then it is considered documented even if the description is empty.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
<class name="Node2D" inherits="CanvasItem" version="4.0">
    <brief_description>
        A 2D game object, inherited by all 2D-related nodes. Has a position, rotation, scale, and Z index.
    </brief_description>
    <description>
        A 2D game object, with a transform (position, rotation, and scale). All 2D nodes, including physics objects and sprites, inherit from Node2D. Use Node2D as a parent node to move, scale and rotate children in a 2D project. Also gives control of the node's render order.
    </description>
    <tutorials>
        <link title="Custom drawing in 2D">https://docs.godotengine.org/en/latest/tutorials/2d/custom_drawing_in_2d.html</link>
        <link title="All 2D Demos">https://github.com/godotengine/godot-demo-projects/tree/master/2d</link>
    </tutorials>
    <methods>
        <method name="apply_scale">
            <return type="void">
            </return>
            <argument index="0" name="ratio" type="Vector2">
            </argument>
            <description>
                Multiplies the current scale by the [code]ratio[/code] vector.
            </description>
        </method>
        [...]
        <method name="translate">
            <return type="void">
            </return>
            <argument index="0" name="offset" type="Vector2">
            </argument>
            <description>
                Translates the node by the given [code]offset[/code] in local coordinates.
            </description>
        </method>
    </methods>
    <members>
        <member name="global_position" type="Vector2" setter="set_global_position" getter="get_global_position">
            Global position.
        </member>
        [...]
        <member name="z_index" type="int" setter="set_z_index" getter="get_z_index" default="0">
            Z index. Controls the order in which the nodes render. A node with a higher Z index will display in front of others.
        </member>
    </members>
    <constants>
    </constants>
</class>
```

Example 2 (gdscript):
```gdscript
[codeblock]
func _ready():
    var sprite = get_node("Sprite2D")
    print(sprite.get_pos())
[/codeblock]
```

Example 3 (gdscript):
```gdscript
func _ready():
    var sprite = get_node("Sprite2D")
    print(sprite.get_pos())
```

Example 4 (gdscript):
```gdscript
[codeblocks]
[gdscript]
func _ready():
    var sprite = get_node("Sprite2D")
    print(sprite.get_pos())
[/gdscript]
[csharp]
public override void _Ready()
{
    var sprite = GetNode("Sprite2D");
    GD.Print(sprite.GetPos());
}
[/csharp]
[/codeblocks]
```

---

## Common engine methods and macros — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/common_engine_methods_and_macros.html

**Contents:**
- Common engine methods and macros
- Print text
- Format a string
- Convert an integer or float to a string
- Internationalize a string
- Clamp a value
- Microbenchmarking
- Get project/editor settings
- Error macros
- User-contributed notes

Godot's C++ codebase makes use of dozens of custom methods and macros which are used in almost every file. This page is geared towards beginner contributors, but it can also be useful for those writing custom C++ modules.

If you need to add placeholders in your messages, use format strings as described below.

The vformat() function returns a formatted String. It behaves in a way similar to C's sprintf():

In most cases, try to use vformat() instead of string concatenation as it makes for more readable code.

This is not needed when printing numbers using print_line(), but you may still need to perform manual conversion for some other use cases.

There are two types of internationalization in Godot's codebase:

TTR(): Editor ("tools") translations will only be processed in the editor. If a user uses the same text in one of their projects, it won't be translated if they provide a translation for it. When contributing to the engine, this is generally the macro you should use for localizable strings.

RTR(): Runtime translations will be automatically localized in projects if they provide a translation for the given string. This kind of translation shouldn't be used in editor-only code.

To insert placeholders in localizable strings, wrap the localization macro in a vformat() call as follows:

When using vformat() and a translation macro together, always wrap the translation macro in vformat(), not the other way around. Otherwise, the string will never match the translation as it will have the placeholder already replaced when it's passed to TranslationServer.

Godot provides macros for clamping a value with a lower bound (MAX), an upper bound (MIN) or both (CLAMP):

This works with any type that can be compared to other values (like int and float).

If you want to benchmark a piece of code but don't know how to use a profiler, use this snippet:

This will print the time spent between the begin declaration and the end declaration.

You may have to #include "core/os/time.h" if it's not present already.

When opening a pull request, make sure to remove this snippet as well as the include if it wasn't there previously.

There are four macros available for this:

If a default value has been specified elsewhere, don't specify it again to avoid repetition:

It's recommended to use GLOBAL_DEF/EDITOR_DEF only once per setting and use GLOBAL_GET/EDITOR_GET in all other places where it's referenced.

Godot features many error macros to make error reporting more convenient.

Conditions in error macros work in the opposite way of GDScript's built-in assert() function. An error is reached if the condition inside evaluates to true, not false.

Only variants with custom messages are documented here, as these should always be used in new contributions. Make sure the custom message provided includes enough information for people to diagnose the issue, even if they don't know C++. In case a method was passed invalid arguments, you can print the invalid value in question to ease debugging.

For internal error checking where displaying a human-readable message isn't necessary, remove _MSG at the end of the macro name and don't supply a message argument.

Also, always try to return processable data so the engine can keep running well.

See core/error/error_macros.h in Godot's codebase for more information about each error macro.

Some functions return an error code (materialized by a return type of Error). This value can be returned directly from an error macro. See the list of available error codes in core/error/error_list.h.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
// Prints a message to standard output.
print_line("Message");

// Non-String arguments are automatically converted to String for printing.
// If passing several arguments, they will be concatenated together with a
// space between each argument.
print_line("There are", 123, "nodes");

// Prints a message to standard output, but only when the engine
// is started with the `--verbose` command line argument.
print_verbose("Message");

// Prints a rich-formatted message using BBCode to standard output.
// This supports a subset of BBCode tags supported by RichTextLabel
// and will also appear formatted in the editor Output panel.
// On Windows, this requires Windows 10 or later to work in the terminal.
print_line_rich("[b]Bold[/b], [color=red]Red text[/color]")

// Prints a formatted error or warning message with a trace.
ERR_PRINT("Message");
WARN_PRINT("Message");

// Prints an error or warning message only once per session.
// This can be used to avoid spamming the console output.
ERR_PRINT_ONCE("Message");
WARN_PRINT_ONCE("Message");
```

Example 2 (javascript):
```javascript
vformat("My name is %s.", "Godette");
vformat("%d bugs on the wall!", 1234);
vformat("Pi is approximately %f.", 3.1416);

// Converts the resulting String into a `const char *`.
// You may need to do this if passing the result as an argument
// to a method that expects a `const char *` instead of a String.
vformat("My name is %s.", "Godette").c_str();
```

Example 3 (unknown):
```unknown
// Stores the string "42" using integer-to-string conversion.
String int_to_string = itos(42);

// Stores the string "123.45" using real-to-string conversion.
String real_to_string = rtos(123.45);
```

Example 4 (unknown):
```unknown
// Returns the translated string that matches the user's locale settings.
// Translations are located in `editor/translations`.
// The localization template is generated automatically; don't modify it.
TTR("Exit the editor?");
```

---

## Core types — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/core_types.html

**Contents:**
- Core types
- Definitions
- Memory model
- Allocating memory
- Containers
- Math types
- NodePath
- RID
- User-contributed notes

Godot has a rich set of classes and templates that compose its core, and everything is built upon them.

This reference will try to list them in order for their better understanding.

Godot uses the standard C99 datatypes, such as uint8_t, uint32_t, int64_t, etc. which are nowadays supported by every compiler. Reinventing the wheel for those is not fun, as it makes code more difficult to read.

In general, care is not taken to use the most efficient datatype for a given task unless using large structures or arrays. int is used through most of the code unless necessary. This is done because nowadays every device has at least a 32-bit bus and can do such operations in one cycle. It makes code more readable too.

For files or memory sizes, size_t is used, which is guaranteed to be 64-bit.

For Unicode characters, CharType instead of wchar_t is used, because many architectures have 4 bytes long wchar_t, where 2 bytes might be desired. However, by default, this has not been forced and CharType maps directly to wchar_t.

PC is a wonderful architecture. Computers often have gigabytes of RAM, terabytes of storage and gigahertz of CPU, and when an application needs more resources the OS will swap out the inactive ones. Other architectures (like mobile or consoles) are in general more limited.

The most common memory model is the heap, where an application will request a region of memory, and the underlying OS will try to fit it somewhere and return it. This often works best and is flexible, but over time and with abuse, this can lead to segmentation.

Segmentation slowly creates holes that are too small for most common allocations, so that memory is wasted. There is a lot of literature about heap and segmentation, so this topic will not be developed further here. Modern operating systems use paged memory, which helps mitigate the problem of segmentation but doesn't solve it.

However, in many studies and tests, it is shown that given enough memory, if the maximum allocation size is below a given threshold in proportion to the maximum heap size and proportion of memory intended to be unused, segmentation will not be a problem over time as it will remain constant. In other words, leave 10-20% of your memory free and perform all small allocations and you are fine.

Godot ensures that all objects that can be allocated dynamically are small (less than a few kB at most). But what happens if an allocation is too large (like an image or mesh geometry or large array)? In this case Godot has the option to use a dynamic memory pool. This memory needs to be locked to be accessed, and if an allocation runs out of memory, the pool will be rearranged and compacted on demand. Depending on the need of the game, the programmer can configure the dynamic memory pool size.

Godot has many tools for tracking memory usage in a game, especially during debug. Because of this, the regular C and C++ library calls should not be used. Instead, a few other ones are provided.

For C-style allocation, Godot provides a few macros:

These are equivalent to the usual malloc(), realloc(), and free() of the C standard library.

For C++-style allocation, special macros are provided:

These are equivalent to new, delete, new[], and delete[] respectively.

memnew/memdelete also use a little C++ magic and notify Objects right after they are created, and right before they are deleted.

For dynamic memory, use one of Godot's sequence types such as Vector<> or LocalVector<>. Vector<> behaves much like an STL std::vector<>, but is simpler and uses Copy-On-Write (CoW) semantics. CoW copies of Vector<> can safely access the same data from different threads, but several threads cannot access the same Vector<> instance safely. It can be safely passed via public API if it has a Packed alias.

The Packed*Array types are aliases for specific Vector<*> types (e.g., PackedByteArray, PackedInt32Array) that are accessible via GDScript. Outside of core, prefer using the Packed*Array aliases for functions exposed to scripts, and Vector<> for other occasions.

LocalVector<> is much more like std::vector than Vector<>. It is non-CoW, with less overhead. It is intended for internal use where the benefits of CoW are not needed. Note that neither LocalVector<> nor Vector<> are drop-in replacements for each other. They are two unrelated types with similar interfaces, both using a buffer as their storage strategy.

List<> is another Godot sequence type, using a doubly-linked list as its storage strategy. Prefer Vector<> (or LocalVector<>) over List<> unless you're sure you need it, as cache locality and memory fragmentation tend to be more important with small collections.

Godot provides its own set of containers, which means STL containers like std::string and std::vector are generally not used in the codebase. See Why does Godot not use STL (Standard Template Library)? for more information.

A 📜 icon denotes the type is part of Variant. This means it can be used as a parameter or return value of a method exposed to the scripting API.

Closest C++ STL datatype

Use this as the "default" string type. String uses UTF-32 encoding to simplify processing thanks to its fixed character size.

Use this as the "default" vector type. Uses copy-on-write (COW) semantics. This means it's generally slower but can be copied around almost for free. Use LocalVector instead where COW isn't needed and performance matters.

Use this as the "default" set type.

Use this as the "default" map type. Does not preserve insertion order. Note that pointers into the map, as well as iterators, are not stable under mutations. If either of these affordances are needed, use HashMap instead.

Uses string interning for fast comparisons. Use this for static strings that are referenced frequently and used in multiple locations in the engine.

Closer to std::vector in semantics, doesn't use copy-on-write (COW) thus it's faster than Vector. Prefer it over Vector when copying it cheaply is not needed.

Values can be of any Variant type. No static typing is imposed. Uses shared reference counting, similar to std::shared_ptr. Uses Vector<Variant> internally.

Subclass of Array but with static typing for its elements. Not to be confused with Packed*Array, which is internally a Vector.

Alias of Vector, e.g. PackedColorArray = Vector<Color>. Only a limited list of packed array types are available (use TypedArray otherwise).

Linked list type. Generally slower than other array/vector types. Prefer using other types in new code, unless using List avoids the need for type conversions.

Vector with a fixed capacity (more similar to boost::container::static_vector). This container type is more efficient than other vector-like types because it makes no heap allocations.

Represents read-only access to a contiguous array without needing to copy any data. Note that Span is designed to be a high performance API: It does not perform parameter correctness checks in the same way you might be used to with other Godot containers. Use with care. Span can be constructed from most array-like containers (e.g. vector.span()).

Uses a red-black tree for faster access.

Uses copy-on-write (COW) semantics. This means it's generally slower but can be copied around almost for free. The performance benefits of VSet aren't established, so prefer using other types.

Defensive (robust but slow) map type. Preserves insertion order. Pointers to keys and values, as well as iterators, are stable under mutation. Use this map type when either of these affordances are needed. Use AHashMap otherwise.

Map type that uses a red-black tree to find keys. The performance benefits of RBMap aren't established, so prefer using other types.

Keys and values can be of any Variant type. No static typing is imposed. Uses shared reference counting, similar to std::shared_ptr. Preserves insertion order. Uses HashMap<Variant> internally.

Subclass of Dictionary but with static typing for its keys and values.

Stores a single pair. See also KeyValue in the same file, which uses read-only keys.

There are several linear math types available in the core/math directory:

This is a special datatype used for storing paths in a scene tree and referencing them in an optimized manner:

core/string/node_path.h

RIDs are Resource IDs. Servers use these to reference data stored in them. RIDs are opaque, meaning that the data they reference can't be accessed directly. RIDs are unique, even for different types of referenced data:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
memalloc()
memrealloc()
memfree()
```

Example 2 (unknown):
```unknown
memnew(Class / Class(args))
memdelete(instance)

memnew_arr(Class, amount)
memdelete_arr(pointer_to_array)
```

---

## Custom AudioStreams — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/custom_audiostreams.html

**Contents:**
- Custom AudioStreams
- Introduction
  - References:
- What for?
- Create an AudioStream
  - References:
- Create an AudioStreamPlayback
  - Resampling
  - References:
- User-contributed notes

AudioStream is the base class of all audio emitting objects. AudioStreamPlayer binds onto an AudioStream to emit PCM data into an AudioServer which manages audio drivers.

All audio resources require two audio based classes: AudioStream and AudioStreamPlayback. As a data container, AudioStream contains the resource and exposes itself to GDScript. AudioStream references its own internal custom AudioStreamPlayback which translates AudioStream into PCM data.

This guide assumes the reader knows how to create C++ modules. If not, refer to this guide Custom modules in C++.

servers/audio/audio_stream.h

scene/audio/audio_stream_player.cpp

Binding external libraries (like Wwise, FMOD, etc).

Adding custom audio queues

Adding support for more audio formats

An AudioStream consists of three components: data container, stream name, and an AudioStreamPlayback friend class generator. Audio data can be loaded in a number of ways such as with an internal counter for a tone generator, internal/external buffer, or a file reference.

Some AudioStreams need to be stateless such as objects loaded from ResourceLoader. ResourceLoader loads once and references the same object regardless how many times load is called on a specific resource. Therefore, playback state must be self-contained in AudioStreamPlayback.

servers/audio/audio_stream.h

AudioStreamPlayer uses mix callback to obtain PCM data. The callback must match sample rate and fill the buffer.

Since AudioStreamPlayback is controlled by the audio thread, i/o and dynamic memory allocation are forbidden.

Godot's AudioServer currently uses 44100 Hz sample rate. When other sample rates are needed such as 48000, either provide one or use AudioStreamPlaybackResampled. Godot provides cubic interpolation for audio resampling.

Instead of overloading mix, AudioStreamPlaybackResampled uses _mix_internal to query AudioFrames and get_stream_sampling_rate to query current mix rate.

core/math/audio_frame.h

servers/audio/audio_stream.h

scene/audio/audio_stream_player.cpp

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (javascript):
```javascript
#include "core/reference.h"
#include "core/resource.h"
#include "servers/audio/audio_stream.h"

class AudioStreamMyTone : public AudioStream {
    GDCLASS(AudioStreamMyTone, AudioStream)

private:
    friend class AudioStreamPlaybackMyTone;
    uint64_t pos;
    int mix_rate;
    bool stereo;
    int hz;

public:
    void reset();
    void set_position(uint64_t pos);
    virtual Ref<AudioStreamPlayback> instance_playback();
    virtual String get_stream_name() const;
    void gen_tone(int16_t *pcm_buf, int size);
    virtual float get_length() const { return 0; } // if supported, otherwise return 0
    AudioStreamMyTone();

protected:
    static void _bind_methods();
};
```

Example 2 (javascript):
```javascript
#include "audiostream_mytone.h"

AudioStreamMyTone::AudioStreamMyTone()
        : mix_rate(44100), stereo(false), hz(639) {
}

Ref<AudioStreamPlayback> AudioStreamMyTone::instance_playback() {
    Ref<AudioStreamPlaybackMyTone> talking_tree;
    talking_tree.instantiate();
    talking_tree->base = Ref<AudioStreamMyTone>(this);
    return talking_tree;
}

String AudioStreamMyTone::get_stream_name() const {
    return "MyTone";
}
void AudioStreamMyTone::reset() {
    set_position(0);
}
void AudioStreamMyTone::set_position(uint64_t p) {
    pos = p;
}
void AudioStreamMyTone::gen_tone(int16_t *pcm_buf, int size) {
    for (int i = 0; i < size; i++) {
        pcm_buf[i] = 32767.0 * sin(2.0 * Math_PI * double(pos + i) / (double(mix_rate) / double(hz)));
    }
    pos += size;
}
void AudioStreamMyTone::_bind_methods() {
    ClassDB::bind_method(D_METHOD("reset"), &AudioStreamMyTone::reset);
    ClassDB::bind_method(D_METHOD("get_stream_name"), &AudioStreamMyTone::get_stream_name);
}
```

Example 3 (cpp):
```cpp
#include "core/reference.h"
#include "core/resource.h"
#include "servers/audio/audio_stream.h"

class AudioStreamPlaybackMyTone : public AudioStreamPlayback {
    GDCLASS(AudioStreamPlaybackMyTone, AudioStreamPlayback)
    friend class AudioStreamMyTone;

private:
    enum {
        PCM_BUFFER_SIZE = 4096
    };
    enum {
        MIX_FRAC_BITS = 13,
        MIX_FRAC_LEN = (1 << MIX_FRAC_BITS),
        MIX_FRAC_MASK = MIX_FRAC_LEN - 1,
    };
    void *pcm_buffer;
    Ref<AudioStreamMyTone> base;
    bool active;

public:
    virtual void start(float p_from_pos = 0.0);
    virtual void stop();
    virtual bool is_playing() const;
    virtual int get_loop_count() const; // times it looped
    virtual float get_playback_position() const;
    virtual void seek(float p_time);
    virtual void mix(AudioFrame *p_buffer, float p_rate_scale, int p_frames);
    virtual float get_length() const; // if supported, otherwise return 0
    AudioStreamPlaybackMyTone();
    ~AudioStreamPlaybackMyTone();
};
```

Example 4 (javascript):
```javascript
#include "audiostreamplayer_mytone.h"

#include "core/math/math_funcs.h"
#include "core/print_string.h"

AudioStreamPlaybackMyTone::AudioStreamPlaybackMyTone()
        : active(false) {
    AudioServer::get_singleton()->lock();
    pcm_buffer = AudioServer::get_singleton()->audio_data_alloc(PCM_BUFFER_SIZE);
    zeromem(pcm_buffer, PCM_BUFFER_SIZE);
    AudioServer::get_singleton()->unlock();
}
AudioStreamPlaybackMyTone::~AudioStreamPlaybackMyTone() {
    if(pcm_buffer) {
        AudioServer::get_singleton()->audio_data_free(pcm_buffer);
        pcm_buffer = NULL;
    }
}
void AudioStreamPlaybackMyTone::stop() {
    active = false;
    base->reset();
}
void AudioStreamPlaybackMyTone::start(float p_from_pos) {
    seek(p_from_pos);
    active = true;
}
void AudioStreamPlaybackMyTone::seek(float p_time) {
    float max = get_length();
    if (p_time < 0) {
            p_time = 0;
    }
    base->set_position(uint64_t(p_time * base->mix_rate) << MIX_FRAC_BITS);
}
void AudioStreamPlaybackMyTone::mix(AudioFrame *p_buffer, float p_rate, int p_frames) {
    ERR_FAIL_COND(!active);
    if (!active) {
            return;
    }
    zeromem(pcm_buffer, PCM_BUFFER_SIZE);
    int16_t *buf = (int16_t *)pcm_buffer;
    base->gen_tone(buf, p_frames);

    for(int i = 0; i < p_frames; i++) {
        float sample = float(buf[i]) / 32767.0;
        p_buffer[i] = AudioFrame(sample, sample);
    }
}
int AudioStreamPlaybackMyTone::get_loop_count() const {
    return 0;
}
float AudioStreamPlaybackMyTone::get_playback_position() const {
    return 0.0;
}
float AudioStreamPlaybackMyTone::get_length() const {
    return 0.0;
}
bool AudioStreamPlaybackMyTone::is_playing() const {
    return active;
}
```

---

## Data preferences — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html

**Contents:**
- Data preferences
- Array vs. Dictionary vs. Object
- Enumerations: int vs. string
- AnimatedTexture vs. AnimatedSprite2D vs. AnimationPlayer vs. AnimationTree
- User-contributed notes

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

Ever wondered whether one should approach problem X with data structure Y or Z? This article covers a variety of topics related to these dilemmas.

This article makes references to "[something]-time" operations. This terminology comes from algorithm analysis' Big O Notation.

Long-story short, it describes the worst-case scenario of runtime length. In laymen's terms:

"As the size of a problem domain increases, the runtime length of the algorithm..."

Constant-time, O(1): "...does not increase."

Logarithmic-time, O(log n): "...increases at a slow rate."

Linear-time, O(n): "...increases at the same rate."

Imagine if one had to process 3 million data points within a single frame. It would be impossible to craft the feature with a linear-time algorithm since the sheer size of the data would increase the runtime far beyond the time allotted. In comparison, using a constant-time algorithm could handle the operation without issue.

By and large, developers want to avoid engaging in linear-time operations as much as possible. But, if one keeps the scale of a linear-time operation small, and if one does not need to perform the operation often, then it may be acceptable. Balancing these requirements and choosing the right algorithm / data structure for the job is part of what makes programmers' skills valuable.

Godot stores all variables in the scripting API in the Variant class. Variants can store Variant-compatible data structures such as Array and Dictionary as well as Objects.

Godot implements Array as a Vector<Variant>. The engine stores the Array contents in a contiguous section of memory, i.e. they are in a row adjacent to each other.

For those unfamiliar with C++, a Vector is the name of the array object in traditional C++ libraries. It is a "templated" type, meaning that its records can only contain a particular type (denoted by angled brackets). So, for example, a PackedStringArray would be something like a Vector<String>.

Contiguous memory stores imply the following operation performance:

Iterate: Fastest. Great for loops.

Op: All it does is increment a counter to get to the next record.

Insert, Erase, Move: Position-dependent. Generally slow.

Op: Adding/removing/moving content involves moving the adjacent records over (to make room / fill space).

Fast add/remove from the end.

Slow add/remove from an arbitrary position.

Slowest add/remove from the front.

If doing many inserts/removals from the front, then...

do a loop which executes the Array changes at the end.

This makes only 2 copies of the array (still constant time, but slow) versus copying roughly 1/2 of the array, on average, N times (linear time).

Get, Set: Fastest by position. E.g. can request 0th, 2nd, 10th record, etc. but cannot specify which record you want.

Op: 1 addition operation from array start position up to desired index.

Find: Slowest. Identifies the index/position of a value.

Op: Must iterate through array and compare values until one finds a match.

Performance is also dependent on whether one needs an exhaustive search.

If kept ordered, custom search operations can bring it to logarithmic time (relatively fast). Laymen users won't be comfortable with this though. Done by re-sorting the Array after every edit and writing an ordered-aware search algorithm.

Godot implements Dictionary as a HashMap<Variant, Variant, VariantHasher, StringLikeVariantComparator>. The engine stores a small array (initialized to 2^3 or 8 records) of key-value pairs. When one attempts to access a value, they provide it a key. It then hashes the key, i.e. converts it into a number. The "hash" is used to calculate the index into the array. As an array, the HM then has a quick lookup within the "table" of keys mapped to values. When the HashMap becomes too full, it increases to the next power of 2 (so, 16 records, then 32, etc.) and rebuilds the structure.

Hashes are to reduce the chance of a key collision. If one occurs, the table must recalculate another index for the value that takes the previous position into account. In all, this results in constant-time access to all records at the expense of memory and some minor operational efficiency.

Hashing every key an arbitrary number of times.

Hash operations are constant-time, so even if an algorithm must do more than one, as long as the number of hash calculations doesn't become too dependent on the density of the table, things will stay fast. Which leads to...

Maintaining an ever-growing size for the table.

HashMaps maintain gaps of unused memory interspersed in the table on purpose to reduce hash collisions and maintain the speed of accesses. This is why it constantly increases in size exponentially by powers of 2.

As one might be able to tell, Dictionaries specialize in tasks that Arrays do not. An overview of their operational details is as follows:

Op: Iterate over the map's internal vector of hashes. Return each key. Afterwards, users then use the key to jump to and return the desired value.

Insert, Erase, Move: Fastest.

Op: Hash the given key. Do 1 addition operation to look up the appropriate value (array start + offset). Move is two of these (one insert, one erase). The map must do some maintenance to preserve its capabilities:

update ordered List of records.

determine if table density mandates a need to expand table capacity.

The Dictionary remembers in what order users inserted its keys. This enables it to execute reliable iterations.

Get, Set: Fastest. Same as a lookup by key.

Op: Same as insert/erase/move.

Find: Slowest. Identifies the key of a value.

Op: Must iterate through records and compare the value until a match is found.

Note that Godot does not provide this feature out-of-the-box (because they aren't meant for this task).

Godot implements Objects as stupid, but dynamic containers of data content. Objects query data sources when posed questions. For example, to answer the question, "do you have a property called, 'position'?", it might ask its script or the ClassDB. One can find more information about what objects are and how they work in the Applying object-oriented principles in Godot article.

The important detail here is the complexity of the Object's task. Every time it performs one of these multi-source queries, it runs through several iteration loops and HashMap lookups. What's more, the queries are linear-time operations dependent on the Object's inheritance hierarchy size. If the class the Object queries (its current class) doesn't find anything, the request defers to the next base class, all the way up until the original Object class. While these are each fast operations in isolation, the fact that it must make so many checks is what makes them slower than both of the alternatives for looking up data.

When developers mention how slow the scripting API is, it is this chain of queries they refer to. Compared to compiled C++ code where the application knows exactly where to go to find anything, it is inevitable that scripting API operations will take much longer. They must locate the source of any relevant data before they can attempt to access it.

The reason GDScript is slow is because every operation it performs passes through this system.

C# can process some content at higher speeds via more optimized bytecode. But, if the C# script calls into an engine class' content or if the script tries to access something external to it, it will go through this pipeline.

NativeScript C++ goes even further and keeps everything internal by default. Calls into external structures will go through the scripting API. In NativeScript C++, registering methods to expose them to the scripting API is a manual task. It is at this point that external, non-C++ classes will use the API to locate them.

So, assuming one extends from Reference to create a data structure, like an Array or Dictionary, why choose an Object over the other two options?

Control: With objects comes the ability to create more sophisticated structures. One can layer abstractions over the data to ensure the external API doesn't change in response to internal data structure changes. What's more, Objects can have signals, allowing for reactive behavior.

Clarity: Objects are a reliable data source when it comes to the data that scripts and engine classes define for them. Properties may not hold the values one expects, but one doesn't need to worry about whether the property exists in the first place.

Convenience: If one already has a similar data structure in mind, then extending from an existing class makes the task of building the data structure much easier. In comparison, Arrays and Dictionaries don't fulfill all use cases one might have.

Objects also give users the opportunity to create even more specialized data structures. With it, one can design their own List, Binary Search Tree, Heap, Splay Tree, Graph, Disjoint Set, and any host of other options.

"Why not use Node for tree structures?" one might ask. Well, the Node class contains things that won't be relevant to one's custom data structure. As such, it can be helpful to construct one's own node type when building tree structures.

From here, one can then create their own structures with specific features, limited only by their imagination.

Most languages offer an enumeration type option. GDScript is no different, but unlike most other languages, it allows one to use either integers or strings for the enum values (the latter only when using the @export_enum annotation in GDScript). The question then arises, "which should one use?"

The short answer is, "whichever you are more comfortable with." This is a feature specific to GDScript and not Godot scripting in general; The languages prioritizes usability over performance.

On a technical level, integer comparisons (constant-time) will happen faster than string comparisons (linear-time). If one wants to keep up other languages' conventions though, then one should use integers.

The primary issue with using integers comes up when one wants to print an enum value. As integers, attempting to print MY_ENUM will print 5 or what-have-you, rather than something like "MyEnum". To print an integer enum, one would have to write a Dictionary that maps the corresponding string value for each enum.

If the primary purpose of using an enum is for printing values and one wishes to group them together as related concepts, then it makes sense to use them as strings. That way, a separate data structure to execute on the printing is unnecessary.

Under what circumstances should one use each of Godot's animation classes? The answer may not be immediately clear to new Godot users.

AnimatedTexture is a texture that the engine draws as an animated loop rather than a static image. Users can manipulate...

the rate at which it moves across each section of the texture (FPS).

the number of regions contained within the texture (frames).

Godot's RenderingServer then draws the regions in sequence at the prescribed rate. The good news is that this involves no extra logic on the part of the engine. The bad news is that users have very little control.

Also note that AnimatedTexture is a Resource unlike the other Node objects discussed here. One might create a Sprite2D node that uses AnimatedTexture as its texture. Or (something the others can't do) one could add AnimatedTextures as tiles in a TileSet and integrate it with a TileMapLayer for many auto-animating backgrounds that all render in a single batched draw call.

The AnimatedSprite2D node, in combination with the SpriteFrames resource, allows one to create a variety of animation sequences through spritesheets, flip between animations, and control their speed, regional offset, and orientation. This makes them well-suited to controlling 2D frame-based animations.

If one needs to trigger other effects in relation to animation changes (for example, create particle effects, call functions, or manipulate other peripheral elements besides the frame-based animation), then one will need to use an AnimationPlayer node in conjunction with the AnimatedSprite2D.

AnimationPlayers are also the tool one will need to use if they wish to design more complex 2D animation systems, such as...

Cut-out animations: editing sprites' transforms at runtime.

2D Mesh animations: defining a region for the sprite's texture and rigging a skeleton to it. Then one animates the bones which stretch and bend the texture in proportion to the bones' relationships to each other.

While one needs an AnimationPlayer to design each of the individual animation sequences for a game, it can also be useful to combine animations for blending, i.e. enabling smooth transitions between these animations. There may also be a hierarchical structure between animations that one plans out for their object. These are the cases where the AnimationTree shines. One can find an in-depth guide on using the AnimationTree here.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
extends Object
class_name TreeNode

var _parent: TreeNode = null
var _children := []

func _notification(p_what):
    match p_what:
        NOTIFICATION_PREDELETE:
            # Destructor.
            for a_child in _children:
                a_child.free()
```

Example 2 (csharp):
```csharp
using Godot;
using System.Collections.Generic;

// Can decide whether to expose getters/setters for properties later
public partial class TreeNode : GodotObject
{
    private TreeNode _parent = null;

    private List<TreeNode> _children = [];

    public override void _Notification(int what)
    {
        switch (what)
        {
            case NotificationPredelete:
                foreach (TreeNode child in _children)
                {
                    node.Free();
                }
                break;
        }
    }
}
```

---

## Documentation changelog — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/about/docs_changelog.html

**Contents:**
- Documentation changelog
- New pages since version 4.3
  - 2D
  - 3D
  - Debug
  - Editor
  - Performance
  - Physics
  - Rendering
  - Shaders

The documentation is continually being improved. New releases include new pages, fixes and updates to existing pages, and many updates to the class reference. Below is a list of new pages added since version 3.0.

This document only contains new pages so not all changes are reflected, many pages have been substantially updated but are not reflected in this document.

Third-person camera with spring arm

Reducing stutter from shader (pipeline) compilations

Physics Interpolation

Using physics interpolation

Advanced physics interpolation

2D and 3D physics interpolation

Overview of renderers

Handling compatibility breakages

The .gdextension file

Upgrading from Godot 4.2 to Godot 4.3

A better XR start script

Where to go from here

OpenXR composition layers

2D coordinate systems and 2D transforms

Upgrading from Godot 4.1 to Godot 4.2

Runtime file loading and saving

Godot Android library

Internal rendering architecture

Upgrading from Godot 4.0 to Godot 4.1

Troubleshooting physics issues

Faking global illumination

Introduction to global illumination

Mesh level of detail (LOD)

Signed distance field global illumination (SDFGI)

Visibility ranges (HLOD)

Volumetric fog and fog volumes

Variable rate shading

Physical light and camera units

Retargeting 3D Skeletons

Custom platform ports

Upgrading from Godot 3 to Godot 4

Large world coordinates

Custom performance monitors

Using compute shaders

Managing editor features

GDScript documentation comments

3D rendering limitations

Version control systems

Configuring an IDE: Code::Blocks

Default editor shortcuts

Exporting for dedicated servers

Controllers, gamepads, and joysticks

Random number generation

HTML5 shell class reference

Collision shapes (2D)

Collision shapes (3D)

Creating script templates

Evaluating expressions

GDScript warning system (split from Static typing in GDScript)

Gradle builds for Android

Recording with microphone

Sync the gameplay with audio and music

Beziers, curves and paths

Localization using gettext (PO files)

Introduction to shaders

Your second 3D shader

Godot Android plugins

Visual Shader plugins

Using multiple threads

Using the SurfaceTool

Using the MeshDataTool

Optimization using MultiMeshes

Optimization using Servers

Complying with licenses

Static typing in GDScript

Applying object-oriented principles in Godot

When to use scenes versus scripts

Autoloads versus regular nodes

When and how to avoid using nodes for everything

2D lights and shadows

Prototyping levels with CSG

Animating thousands of fish with MultiMeshInstance3D

Controlling thousands of fish with Particles

Using a SubViewport as a texture

Custom post-processing

Converting GLSL to Godot shaders

Advanced post-processing

Introduction to shaders

Making main screen plugins

Custom HTML page for Web export

Fixing jitter, stutter and input lag

Running code in the editor

Change scenes manually

Optimizing a build for size

Compiling with PCK encryption key

Binding to external libraries

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## @GlobalScope — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_%40globalscope.html

**Contents:**
- @GlobalScope
- Description
- Tutorials
- Properties
- Methods
- Enumerations
- Property Descriptions
- Method Descriptions
- User-contributed notes

Global scope constants and functions.

A list of global scope enumerated constants and built-in functions. This is all that resides in the globals, constants regarding error codes, keycodes, property hints, etc.

Singletons are also documented here, since they can be accessed from anywhere.

For the entries that can only be accessed from scripts written in GDScript, see @GDScript.

There are notable differences when using this API with C#. See C# API differences to GDScript for more information.

Random number generation

NavigationMeshGenerator

NavigationMeshGenerator

PhysicsServer2DManager

PhysicsServer2DManager

PhysicsServer3DManager

PhysicsServer3DManager

angle_difference(from: float, to: float)

atan2(y: float, x: float)

bezier_derivative(start: float, control_1: float, control_2: float, end: float, t: float)

bezier_interpolate(start: float, control_1: float, control_2: float, end: float, t: float)

bytes_to_var(bytes: PackedByteArray)

bytes_to_var_with_objects(bytes: PackedByteArray)

clamp(value: Variant, min: Variant, max: Variant)

clampf(value: float, min: float, max: float)

clampi(value: int, min: int, max: int)

cos(angle_rad: float)

cubic_interpolate(from: float, to: float, pre: float, post: float, weight: float)

cubic_interpolate_angle(from: float, to: float, pre: float, post: float, weight: float)

cubic_interpolate_angle_in_time(from: float, to: float, pre: float, post: float, weight: float, to_t: float, pre_t: float, post_t: float)

cubic_interpolate_in_time(from: float, to: float, pre: float, post: float, weight: float, to_t: float, pre_t: float, post_t: float)

db_to_linear(db: float)

deg_to_rad(deg: float)

ease(x: float, curve: float)

error_string(error: int)

fmod(x: float, y: float)

fposmod(x: float, y: float)

hash(variable: Variant)

instance_from_id(instance_id: int)

inverse_lerp(from: float, to: float, weight: float)

is_equal_approx(a: float, b: float)

is_instance_id_valid(id: int)

is_instance_valid(instance: Variant)

is_same(a: Variant, b: Variant)

is_zero_approx(x: float)

lerp(from: Variant, to: Variant, weight: Variant)

lerp_angle(from: float, to: float, weight: float)

lerpf(from: float, to: float, weight: float)

linear_to_db(lin: float)

maxf(a: float, b: float)

minf(a: float, b: float)

move_toward(from: float, to: float, delta: float)

nearest_po2(value: int)

pingpong(value: float, length: float)

posmod(x: int, y: int)

pow(base: float, exp: float)

print_rich(...) vararg

print_verbose(...) vararg

push_error(...) vararg

push_warning(...) vararg

rad_to_deg(rad: float)

rand_from_seed(seed: int)

randf_range(from: float, to: float)

randfn(mean: float, deviation: float)

randi_range(from: int, to: int)

remap(value: float, istart: float, istop: float, ostart: float, ostop: float)

rid_from_int64(base: int)

rotate_toward(from: float, to: float, delta: float)

sin(angle_rad: float)

smoothstep(from: float, to: float, x: float)

snapped(x: Variant, step: Variant)

snappedf(x: float, step: float)

snappedi(x: float, step: int)

step_decimals(x: float)

str_to_var(string: String)

tan(angle_rad: float)

type_convert(variant: Variant, type: int)

type_string(type: int)

typeof(variable: Variant)

var_to_bytes(variable: Variant)

var_to_bytes_with_objects(variable: Variant)

var_to_str(variable: Variant)

weakref(obj: Variant)

wrap(value: Variant, min: Variant, max: Variant)

wrapf(value: float, min: float, max: float)

wrapi(value: int, min: int, max: int)

Left side, usually used for Control or StyleBox-derived classes.

Top side, usually used for Control or StyleBox-derived classes.

Right side, usually used for Control or StyleBox-derived classes.

Bottom side, usually used for Control or StyleBox-derived classes.

Corner CORNER_TOP_LEFT = 0

Corner CORNER_TOP_RIGHT = 1

Corner CORNER_BOTTOM_RIGHT = 2

Corner CORNER_BOTTOM_LEFT = 3

Orientation VERTICAL = 1

General vertical alignment, usually used for Separator, ScrollBar, Slider, etc.

Orientation HORIZONTAL = 0

General horizontal alignment, usually used for Separator, ScrollBar, Slider, etc.

enum ClockDirection: 🔗

ClockDirection CLOCKWISE = 0

Clockwise rotation. Used by some methods (e.g. Image.rotate_90()).

ClockDirection COUNTERCLOCKWISE = 1

Counter-clockwise rotation. Used by some methods (e.g. Image.rotate_90()).

enum HorizontalAlignment: 🔗

HorizontalAlignment HORIZONTAL_ALIGNMENT_LEFT = 0

Horizontal left alignment, usually for text-derived classes.

HorizontalAlignment HORIZONTAL_ALIGNMENT_CENTER = 1

Horizontal center alignment, usually for text-derived classes.

HorizontalAlignment HORIZONTAL_ALIGNMENT_RIGHT = 2

Horizontal right alignment, usually for text-derived classes.

HorizontalAlignment HORIZONTAL_ALIGNMENT_FILL = 3

Expand row to fit width, usually for text-derived classes.

enum VerticalAlignment: 🔗

VerticalAlignment VERTICAL_ALIGNMENT_TOP = 0

Vertical top alignment, usually for text-derived classes.

VerticalAlignment VERTICAL_ALIGNMENT_CENTER = 1

Vertical center alignment, usually for text-derived classes.

VerticalAlignment VERTICAL_ALIGNMENT_BOTTOM = 2

Vertical bottom alignment, usually for text-derived classes.

VerticalAlignment VERTICAL_ALIGNMENT_FILL = 3

Expand rows to fit height, usually for text-derived classes.

enum InlineAlignment: 🔗

InlineAlignment INLINE_ALIGNMENT_TOP_TO = 0

Aligns the top of the inline object (e.g. image, table) to the position of the text specified by INLINE_ALIGNMENT_TO_* constant.

InlineAlignment INLINE_ALIGNMENT_CENTER_TO = 1

Aligns the center of the inline object (e.g. image, table) to the position of the text specified by INLINE_ALIGNMENT_TO_* constant.

InlineAlignment INLINE_ALIGNMENT_BASELINE_TO = 3

Aligns the baseline (user defined) of the inline object (e.g. image, table) to the position of the text specified by INLINE_ALIGNMENT_TO_* constant.

InlineAlignment INLINE_ALIGNMENT_BOTTOM_TO = 2

Aligns the bottom of the inline object (e.g. image, table) to the position of the text specified by INLINE_ALIGNMENT_TO_* constant.

InlineAlignment INLINE_ALIGNMENT_TO_TOP = 0

Aligns the position of the inline object (e.g. image, table) specified by INLINE_ALIGNMENT_*_TO constant to the top of the text.

InlineAlignment INLINE_ALIGNMENT_TO_CENTER = 4

Aligns the position of the inline object (e.g. image, table) specified by INLINE_ALIGNMENT_*_TO constant to the center of the text.

InlineAlignment INLINE_ALIGNMENT_TO_BASELINE = 8

Aligns the position of the inline object (e.g. image, table) specified by INLINE_ALIGNMENT_*_TO constant to the baseline of the text.

InlineAlignment INLINE_ALIGNMENT_TO_BOTTOM = 12

Aligns inline object (e.g. image, table) to the bottom of the text.

InlineAlignment INLINE_ALIGNMENT_TOP = 0

Aligns top of the inline object (e.g. image, table) to the top of the text. Equivalent to INLINE_ALIGNMENT_TOP_TO | INLINE_ALIGNMENT_TO_TOP.

InlineAlignment INLINE_ALIGNMENT_CENTER = 5

Aligns center of the inline object (e.g. image, table) to the center of the text. Equivalent to INLINE_ALIGNMENT_CENTER_TO | INLINE_ALIGNMENT_TO_CENTER.

InlineAlignment INLINE_ALIGNMENT_BOTTOM = 14

Aligns bottom of the inline object (e.g. image, table) to the bottom of the text. Equivalent to INLINE_ALIGNMENT_BOTTOM_TO | INLINE_ALIGNMENT_TO_BOTTOM.

InlineAlignment INLINE_ALIGNMENT_IMAGE_MASK = 3

A bit mask for INLINE_ALIGNMENT_*_TO alignment constants.

InlineAlignment INLINE_ALIGNMENT_TEXT_MASK = 12

A bit mask for INLINE_ALIGNMENT_TO_* alignment constants.

EulerOrder EULER_ORDER_XYZ = 0

Specifies that Euler angles should be in XYZ order. When composing, the order is X, Y, Z. When decomposing, the order is reversed, first Z, then Y, and X last.

EulerOrder EULER_ORDER_XZY = 1

Specifies that Euler angles should be in XZY order. When composing, the order is X, Z, Y. When decomposing, the order is reversed, first Y, then Z, and X last.

EulerOrder EULER_ORDER_YXZ = 2

Specifies that Euler angles should be in YXZ order. When composing, the order is Y, X, Z. When decomposing, the order is reversed, first Z, then X, and Y last.

EulerOrder EULER_ORDER_YZX = 3

Specifies that Euler angles should be in YZX order. When composing, the order is Y, Z, X. When decomposing, the order is reversed, first X, then Z, and Y last.

EulerOrder EULER_ORDER_ZXY = 4

Specifies that Euler angles should be in ZXY order. When composing, the order is Z, X, Y. When decomposing, the order is reversed, first Y, then X, and Z last.

EulerOrder EULER_ORDER_ZYX = 5

Specifies that Euler angles should be in ZYX order. When composing, the order is Z, Y, X. When decomposing, the order is reversed, first X, then Y, and Z last.

Enum value which doesn't correspond to any key. This is used to initialize Key properties with a generic state.

Key KEY_SPECIAL = 4194304

Keycodes with this bit applied are non-printable.

Key KEY_ESCAPE = 4194305

Key KEY_TAB = 4194306

Key KEY_BACKTAB = 4194307

Key KEY_BACKSPACE = 4194308

Key KEY_ENTER = 4194309

Return key (on the main keyboard).

Key KEY_KP_ENTER = 4194310

Enter key on the numeric keypad.

Key KEY_INSERT = 4194311

Key KEY_DELETE = 4194312

Key KEY_PAUSE = 4194313

Key KEY_PRINT = 4194314

Key KEY_SYSREQ = 4194315

Key KEY_CLEAR = 4194316

Key KEY_HOME = 4194317

Key KEY_END = 4194318

Key KEY_LEFT = 4194319

Key KEY_RIGHT = 4194321

Key KEY_DOWN = 4194322

Key KEY_PAGEUP = 4194323

Key KEY_PAGEDOWN = 4194324

Key KEY_SHIFT = 4194325

Key KEY_CTRL = 4194326

Key KEY_META = 4194327

Key KEY_ALT = 4194328

Key KEY_CAPSLOCK = 4194329

Key KEY_NUMLOCK = 4194330

Key KEY_SCROLLLOCK = 4194331

Key KEY_F10 = 4194341

Key KEY_F11 = 4194342

Key KEY_F12 = 4194343

Key KEY_F13 = 4194344

Key KEY_F14 = 4194345

Key KEY_F15 = 4194346

Key KEY_F16 = 4194347

Key KEY_F17 = 4194348

Key KEY_F18 = 4194349

Key KEY_F19 = 4194350

Key KEY_F20 = 4194351

Key KEY_F21 = 4194352

Key KEY_F22 = 4194353

Key KEY_F23 = 4194354

Key KEY_F24 = 4194355

Key KEY_F25 = 4194356

F25 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F26 = 4194357

F26 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F27 = 4194358

F27 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F28 = 4194359

F28 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F29 = 4194360

F29 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F30 = 4194361

F30 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F31 = 4194362

F31 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F32 = 4194363

F32 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F33 = 4194364

F33 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F34 = 4194365

F34 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_F35 = 4194366

F35 key. Only supported on macOS and Linux due to a Windows limitation.

Key KEY_KP_MULTIPLY = 4194433

Multiply (*) key on the numeric keypad.

Key KEY_KP_DIVIDE = 4194434

Divide (/) key on the numeric keypad.

Key KEY_KP_SUBTRACT = 4194435

Subtract (-) key on the numeric keypad.

Key KEY_KP_PERIOD = 4194436

Period (.) key on the numeric keypad.

Key KEY_KP_ADD = 4194437

Add (+) key on the numeric keypad.

Key KEY_KP_0 = 4194438

Number 0 on the numeric keypad.

Key KEY_KP_1 = 4194439

Number 1 on the numeric keypad.

Key KEY_KP_2 = 4194440

Number 2 on the numeric keypad.

Key KEY_KP_3 = 4194441

Number 3 on the numeric keypad.

Key KEY_KP_4 = 4194442

Number 4 on the numeric keypad.

Key KEY_KP_5 = 4194443

Number 5 on the numeric keypad.

Key KEY_KP_6 = 4194444

Number 6 on the numeric keypad.

Key KEY_KP_7 = 4194445

Number 7 on the numeric keypad.

Key KEY_KP_8 = 4194446

Number 8 on the numeric keypad.

Key KEY_KP_9 = 4194447

Number 9 on the numeric keypad.

Key KEY_MENU = 4194370

Key KEY_HYPER = 4194371

Hyper key. (On Linux/X11 only).

Key KEY_HELP = 4194373

Key KEY_BACK = 4194376

Key KEY_FORWARD = 4194377

Key KEY_STOP = 4194378

Key KEY_REFRESH = 4194379

Key KEY_VOLUMEDOWN = 4194380

Key KEY_VOLUMEMUTE = 4194381

Key KEY_VOLUMEUP = 4194382

Key KEY_MEDIAPLAY = 4194388

Key KEY_MEDIASTOP = 4194389

Key KEY_MEDIAPREVIOUS = 4194390

Key KEY_MEDIANEXT = 4194391

Key KEY_MEDIARECORD = 4194392

Key KEY_HOMEPAGE = 4194393

Key KEY_FAVORITES = 4194394

Key KEY_SEARCH = 4194395

Key KEY_STANDBY = 4194396

Key KEY_OPENURL = 4194397

Open URL / Launch Browser key.

Key KEY_LAUNCHMAIL = 4194398

Key KEY_LAUNCHMEDIA = 4194399

Key KEY_LAUNCH0 = 4194400

Launch Shortcut 0 key.

Key KEY_LAUNCH1 = 4194401

Launch Shortcut 1 key.

Key KEY_LAUNCH2 = 4194402

Launch Shortcut 2 key.

Key KEY_LAUNCH3 = 4194403

Launch Shortcut 3 key.

Key KEY_LAUNCH4 = 4194404

Launch Shortcut 4 key.

Key KEY_LAUNCH5 = 4194405

Launch Shortcut 5 key.

Key KEY_LAUNCH6 = 4194406

Launch Shortcut 6 key.

Key KEY_LAUNCH7 = 4194407

Launch Shortcut 7 key.

Key KEY_LAUNCH8 = 4194408

Launch Shortcut 8 key.

Key KEY_LAUNCH9 = 4194409

Launch Shortcut 9 key.

Key KEY_LAUNCHA = 4194410

Launch Shortcut A key.

Key KEY_LAUNCHB = 4194411

Launch Shortcut B key.

Key KEY_LAUNCHC = 4194412

Launch Shortcut C key.

Key KEY_LAUNCHD = 4194413

Launch Shortcut D key.

Key KEY_LAUNCHE = 4194414

Launch Shortcut E key.

Key KEY_LAUNCHF = 4194415

Launch Shortcut F key.

Key KEY_GLOBE = 4194416

"Globe" key on Mac / iPad keyboard.

Key KEY_KEYBOARD = 4194417

"On-screen keyboard" key on iPad keyboard.

Key KEY_JIS_EISU = 4194418

英数 key on Mac keyboard.

Key KEY_JIS_KANA = 4194419

かな key on Mac keyboard.

Key KEY_UNKNOWN = 8388607

Exclamation mark (!) key.

Key KEY_QUOTEDBL = 34

Double quotation mark (") key.

Key KEY_NUMBERSIGN = 35

Number sign or hash (#) key.

Percent sign (%) key.

Key KEY_AMPERSAND = 38

Key KEY_APOSTROPHE = 39

Key KEY_PARENLEFT = 40

Left parenthesis (() key.

Key KEY_PARENRIGHT = 41

Right parenthesis (``)``) key.

Key KEY_ASTERISK = 42

Key KEY_SEMICOLON = 59

Less-than sign (<) key.

Greater-than sign (>) key.

Key KEY_QUESTION = 63

Question mark (?) key.

Key KEY_BRACKETLEFT = 91

Left bracket ([lb]) key.

Key KEY_BACKSLASH = 92

Key KEY_BRACKETRIGHT = 93

Right bracket ([rb]) key.

Key KEY_ASCIICIRCUM = 94

Key KEY_UNDERSCORE = 95

Key KEY_QUOTELEFT = 96

Key KEY_BRACELEFT = 123

Vertical bar or pipe (|) key.

Key KEY_BRACERIGHT = 125

Key KEY_ASCIITILDE = 126

Key KEY_SECTION = 167

Section sign (§) key.

flags KeyModifierMask: 🔗

KeyModifierMask KEY_CODE_MASK = 8388607

KeyModifierMask KEY_MODIFIER_MASK = 2130706432

KeyModifierMask KEY_MASK_CMD_OR_CTRL = 16777216

Automatically remapped to KEY_META on macOS and KEY_CTRL on other platforms, this mask is never set in the actual events, and should be used for key mapping only.

KeyModifierMask KEY_MASK_SHIFT = 33554432

KeyModifierMask KEY_MASK_ALT = 67108864

Alt or Option (on macOS) key mask.

KeyModifierMask KEY_MASK_META = 134217728

Command (on macOS) or Meta/Windows key mask.

KeyModifierMask KEY_MASK_CTRL = 268435456

KeyModifierMask KEY_MASK_KPAD = 536870912

KeyModifierMask KEY_MASK_GROUP_SWITCH = 1073741824

Group Switch key mask.

KeyLocation KEY_LOCATION_UNSPECIFIED = 0

Used for keys which only appear once, or when a comparison doesn't need to differentiate the LEFT and RIGHT versions.

For example, when using InputEvent.is_match(), an event which has KEY_LOCATION_UNSPECIFIED will match any KeyLocation on the passed event.

KeyLocation KEY_LOCATION_LEFT = 1

A key which is to the left of its twin.

KeyLocation KEY_LOCATION_RIGHT = 2

A key which is to the right of its twin.

MouseButton MOUSE_BUTTON_NONE = 0

Enum value which doesn't correspond to any mouse button. This is used to initialize MouseButton properties with a generic state.

MouseButton MOUSE_BUTTON_LEFT = 1

Primary mouse button, usually assigned to the left button.

MouseButton MOUSE_BUTTON_RIGHT = 2

Secondary mouse button, usually assigned to the right button.

MouseButton MOUSE_BUTTON_MIDDLE = 3

MouseButton MOUSE_BUTTON_WHEEL_UP = 4

Mouse wheel scrolling up.

MouseButton MOUSE_BUTTON_WHEEL_DOWN = 5

Mouse wheel scrolling down.

MouseButton MOUSE_BUTTON_WHEEL_LEFT = 6

Mouse wheel left button (only present on some mice).

MouseButton MOUSE_BUTTON_WHEEL_RIGHT = 7

Mouse wheel right button (only present on some mice).

MouseButton MOUSE_BUTTON_XBUTTON1 = 8

Extra mouse button 1. This is sometimes present, usually to the sides of the mouse.

MouseButton MOUSE_BUTTON_XBUTTON2 = 9

Extra mouse button 2. This is sometimes present, usually to the sides of the mouse.

flags MouseButtonMask: 🔗

MouseButtonMask MOUSE_BUTTON_MASK_LEFT = 1

Primary mouse button mask, usually for the left button.

MouseButtonMask MOUSE_BUTTON_MASK_RIGHT = 2

Secondary mouse button mask, usually for the right button.

MouseButtonMask MOUSE_BUTTON_MASK_MIDDLE = 4

Middle mouse button mask.

MouseButtonMask MOUSE_BUTTON_MASK_MB_XBUTTON1 = 128

Extra mouse button 1 mask.

MouseButtonMask MOUSE_BUTTON_MASK_MB_XBUTTON2 = 256

Extra mouse button 2 mask.

JoyButton JOY_BUTTON_INVALID = -1

An invalid game controller button.

JoyButton JOY_BUTTON_A = 0

Game controller SDL button A. Corresponds to the bottom action button: Sony Cross, Xbox A, Nintendo B.

JoyButton JOY_BUTTON_B = 1

Game controller SDL button B. Corresponds to the right action button: Sony Circle, Xbox B, Nintendo A.

JoyButton JOY_BUTTON_X = 2

Game controller SDL button X. Corresponds to the left action button: Sony Square, Xbox X, Nintendo Y.

JoyButton JOY_BUTTON_Y = 3

Game controller SDL button Y. Corresponds to the top action button: Sony Triangle, Xbox Y, Nintendo X.

JoyButton JOY_BUTTON_BACK = 4

Game controller SDL back button. Corresponds to the Sony Select, Xbox Back, Nintendo - button.

JoyButton JOY_BUTTON_GUIDE = 5

Game controller SDL guide button. Corresponds to the Sony PS, Xbox Home button.

JoyButton JOY_BUTTON_START = 6

Game controller SDL start button. Corresponds to the Sony Options, Xbox Menu, Nintendo + button.

JoyButton JOY_BUTTON_LEFT_STICK = 7

Game controller SDL left stick button. Corresponds to the Sony L3, Xbox L/LS button.

JoyButton JOY_BUTTON_RIGHT_STICK = 8

Game controller SDL right stick button. Corresponds to the Sony R3, Xbox R/RS button.

JoyButton JOY_BUTTON_LEFT_SHOULDER = 9

Game controller SDL left shoulder button. Corresponds to the Sony L1, Xbox LB button.

JoyButton JOY_BUTTON_RIGHT_SHOULDER = 10

Game controller SDL right shoulder button. Corresponds to the Sony R1, Xbox RB button.

JoyButton JOY_BUTTON_DPAD_UP = 11

Game controller D-pad up button.

JoyButton JOY_BUTTON_DPAD_DOWN = 12

Game controller D-pad down button.

JoyButton JOY_BUTTON_DPAD_LEFT = 13

Game controller D-pad left button.

JoyButton JOY_BUTTON_DPAD_RIGHT = 14

Game controller D-pad right button.

JoyButton JOY_BUTTON_MISC1 = 15

Game controller SDL miscellaneous button. Corresponds to Xbox share button, PS5 microphone button, Nintendo Switch capture button.

JoyButton JOY_BUTTON_PADDLE1 = 16

Game controller SDL paddle 1 button.

JoyButton JOY_BUTTON_PADDLE2 = 17

Game controller SDL paddle 2 button.

JoyButton JOY_BUTTON_PADDLE3 = 18

Game controller SDL paddle 3 button.

JoyButton JOY_BUTTON_PADDLE4 = 19

Game controller SDL paddle 4 button.

JoyButton JOY_BUTTON_TOUCHPAD = 20

Game controller SDL touchpad button.

JoyButton JOY_BUTTON_SDL_MAX = 21

The number of SDL game controller buttons.

JoyButton JOY_BUTTON_MAX = 128

The maximum number of game controller buttons supported by the engine. The actual limit may be lower on specific platforms:

Android: Up to 36 buttons.

Linux: Up to 80 buttons.

Windows and macOS: Up to 128 buttons.

JoyAxis JOY_AXIS_INVALID = -1

An invalid game controller axis.

JoyAxis JOY_AXIS_LEFT_X = 0

Game controller left joystick x-axis.

JoyAxis JOY_AXIS_LEFT_Y = 1

Game controller left joystick y-axis.

JoyAxis JOY_AXIS_RIGHT_X = 2

Game controller right joystick x-axis.

JoyAxis JOY_AXIS_RIGHT_Y = 3

Game controller right joystick y-axis.

JoyAxis JOY_AXIS_TRIGGER_LEFT = 4

Game controller left trigger axis.

JoyAxis JOY_AXIS_TRIGGER_RIGHT = 5

Game controller right trigger axis.

JoyAxis JOY_AXIS_SDL_MAX = 6

The number of SDL game controller axes.

JoyAxis JOY_AXIS_MAX = 10

The maximum number of game controller axes: OpenVR supports up to 5 Joysticks making a total of 10 axes.

MIDIMessage MIDI_MESSAGE_NONE = 0

Does not correspond to any MIDI message. This is the default value of InputEventMIDI.message.

MIDIMessage MIDI_MESSAGE_NOTE_OFF = 8

MIDI message sent when a note is released.

Note: Not all MIDI devices send this message; some may send MIDI_MESSAGE_NOTE_ON with InputEventMIDI.velocity set to 0.

MIDIMessage MIDI_MESSAGE_NOTE_ON = 9

MIDI message sent when a note is pressed.

MIDIMessage MIDI_MESSAGE_AFTERTOUCH = 10

MIDI message sent to indicate a change in pressure while a note is being pressed down, also called aftertouch.

MIDIMessage MIDI_MESSAGE_CONTROL_CHANGE = 11

MIDI message sent when a controller value changes. In a MIDI device, a controller is any input that doesn't play notes. These may include sliders for volume, balance, and panning, as well as switches and pedals. See the General MIDI specification for a small list.

MIDIMessage MIDI_MESSAGE_PROGRAM_CHANGE = 12

MIDI message sent when the MIDI device changes its current instrument (also called program or preset).

MIDIMessage MIDI_MESSAGE_CHANNEL_PRESSURE = 13

MIDI message sent to indicate a change in pressure for the whole channel. Some MIDI devices may send this instead of MIDI_MESSAGE_AFTERTOUCH.

MIDIMessage MIDI_MESSAGE_PITCH_BEND = 14

MIDI message sent when the value of the pitch bender changes, usually a wheel on the MIDI device.

MIDIMessage MIDI_MESSAGE_SYSTEM_EXCLUSIVE = 240

MIDI system exclusive (SysEx) message. This type of message is not standardized and it's highly dependent on the MIDI device sending it.

Note: Getting this message's data from InputEventMIDI is not implemented.

MIDIMessage MIDI_MESSAGE_QUARTER_FRAME = 241

MIDI message sent every quarter frame to keep connected MIDI devices synchronized. Related to MIDI_MESSAGE_TIMING_CLOCK.

Note: Getting this message's data from InputEventMIDI is not implemented.

MIDIMessage MIDI_MESSAGE_SONG_POSITION_POINTER = 242

MIDI message sent to jump onto a new position in the current sequence or song.

Note: Getting this message's data from InputEventMIDI is not implemented.

MIDIMessage MIDI_MESSAGE_SONG_SELECT = 243

MIDI message sent to select a sequence or song to play.

Note: Getting this message's data from InputEventMIDI is not implemented.

MIDIMessage MIDI_MESSAGE_TUNE_REQUEST = 246

MIDI message sent to request a tuning calibration. Used on analog synthesizers. Most modern MIDI devices do not need this message.

MIDIMessage MIDI_MESSAGE_TIMING_CLOCK = 248

MIDI message sent 24 times after MIDI_MESSAGE_QUARTER_FRAME, to keep connected MIDI devices synchronized.

MIDIMessage MIDI_MESSAGE_START = 250

MIDI message sent to start the current sequence or song from the beginning.

MIDIMessage MIDI_MESSAGE_CONTINUE = 251

MIDI message sent to resume from the point the current sequence or song was paused.

MIDIMessage MIDI_MESSAGE_STOP = 252

MIDI message sent to pause the current sequence or song.

MIDIMessage MIDI_MESSAGE_ACTIVE_SENSING = 254

MIDI message sent repeatedly while the MIDI device is idle, to tell the receiver that the connection is alive. Most MIDI devices do not send this message.

MIDIMessage MIDI_MESSAGE_SYSTEM_RESET = 255

MIDI message sent to reset a MIDI device to its default state, as if it was just turned on. It should not be sent when the MIDI device is being turned on.

Methods that return Error return OK when no error occurred.

Since OK has value 0, and all other error constants are positive integers, it can also be used in boolean checks.

Note: Many functions do not return an error code, but will print error messages to standard output.

Error ERR_UNAVAILABLE = 2

Error ERR_UNCONFIGURED = 3

Error ERR_UNAUTHORIZED = 4

Error ERR_PARAMETER_RANGE_ERROR = 5

Parameter range error.

Error ERR_OUT_OF_MEMORY = 6

Out of memory (OOM) error.

Error ERR_FILE_NOT_FOUND = 7

File: Not found error.

Error ERR_FILE_BAD_DRIVE = 8

File: Bad drive error.

Error ERR_FILE_BAD_PATH = 9

File: Bad path error.

Error ERR_FILE_NO_PERMISSION = 10

File: No permission error.

Error ERR_FILE_ALREADY_IN_USE = 11

File: Already in use error.

Error ERR_FILE_CANT_OPEN = 12

File: Can't open error.

Error ERR_FILE_CANT_WRITE = 13

File: Can't write error.

Error ERR_FILE_CANT_READ = 14

File: Can't read error.

Error ERR_FILE_UNRECOGNIZED = 15

File: Unrecognized error.

Error ERR_FILE_CORRUPT = 16

Error ERR_FILE_MISSING_DEPENDENCIES = 17

File: Missing dependencies error.

Error ERR_FILE_EOF = 18

File: End of file (EOF) error.

Error ERR_CANT_OPEN = 19

Error ERR_CANT_CREATE = 20

Error ERR_QUERY_FAILED = 21

Error ERR_ALREADY_IN_USE = 22

Already in use error.

Error ERR_LOCKED = 23

Error ERR_TIMEOUT = 24

Error ERR_CANT_CONNECT = 25

Error ERR_CANT_RESOLVE = 26

Error ERR_CONNECTION_ERROR = 27

Error ERR_CANT_ACQUIRE_RESOURCE = 28

Can't acquire resource error.

Error ERR_CANT_FORK = 29

Can't fork process error.

Error ERR_INVALID_DATA = 30

Error ERR_INVALID_PARAMETER = 31

Invalid parameter error.

Error ERR_ALREADY_EXISTS = 32

Already exists error.

Error ERR_DOES_NOT_EXIST = 33

Does not exist error.

Error ERR_DATABASE_CANT_READ = 34

Database: Read error.

Error ERR_DATABASE_CANT_WRITE = 35

Database: Write error.

Error ERR_COMPILATION_FAILED = 36

Compilation failed error.

Error ERR_METHOD_NOT_FOUND = 37

Method not found error.

Error ERR_LINK_FAILED = 38

Linking failed error.

Error ERR_SCRIPT_FAILED = 39

Error ERR_CYCLIC_LINK = 40

Cycling link (import cycle) error.

Error ERR_INVALID_DECLARATION = 41

Invalid declaration error.

Error ERR_DUPLICATE_SYMBOL = 42

Duplicate symbol error.

Error ERR_PARSE_ERROR = 43

Help error. Used internally when passing --version or --help as executable options.

Bug error, caused by an implementation issue in the method.

Note: If a built-in method returns this code, please open an issue on the GitHub Issue Tracker.

Error ERR_PRINTER_ON_FIRE = 48

Printer on fire error (This is an easter egg, no built-in methods return this error code).

PropertyHint PROPERTY_HINT_NONE = 0

The property has no hint for the editor.

PropertyHint PROPERTY_HINT_RANGE = 1

Hints that an int or float property should be within a range specified via the hint string "min,max" or "min,max,step". The hint string can optionally include "or_greater" and/or "or_less" to allow manual input going respectively above the max or below the min values.

Example: "-360,360,1,or_greater,or_less".

Additionally, other keywords can be included: "exp" for exponential range editing, "radians_as_degrees" for editing radian angles in degrees (the range values are also in degrees), "degrees" to hint at an angle and "hide_slider" to hide the slider.

PropertyHint PROPERTY_HINT_ENUM = 2

Hints that an int or String property is an enumerated value to pick in a list specified via a hint string.

The hint string is a comma separated list of names such as "Hello,Something,Else". Whitespaces are not removed from either end of a name. For integer properties, the first name in the list has value 0, the next 1, and so on. Explicit values can also be specified by appending :integer to the name, e.g. "Zero,One,Three:3,Four,Six:6".

PropertyHint PROPERTY_HINT_ENUM_SUGGESTION = 3

Hints that a String property can be an enumerated value to pick in a list specified via a hint string such as "Hello,Something,Else".

Unlike PROPERTY_HINT_ENUM, a property with this hint still accepts arbitrary values and can be empty. The list of values serves to suggest possible values.

PropertyHint PROPERTY_HINT_EXP_EASING = 4

Hints that a float property should be edited via an exponential easing function. The hint string can include "attenuation" to flip the curve horizontally and/or "positive_only" to exclude in/out easing and limit values to be greater than or equal to zero.

PropertyHint PROPERTY_HINT_LINK = 5

Hints that a vector property should allow its components to be linked. For example, this allows Vector2.x and Vector2.y to be edited together.

PropertyHint PROPERTY_HINT_FLAGS = 6

Hints that an int property is a bitmask with named bit flags.

The hint string is a comma separated list of names such as "Bit0,Bit1,Bit2,Bit3". Whitespaces are not removed from either end of a name. The first name in the list has value 1, the next 2, then 4, 8, 16 and so on. Explicit values can also be specified by appending :integer to the name, e.g. "A:4,B:8,C:16". You can also combine several flags ("A:4,B:8,AB:12,C:16").

Note: A flag value must be at least 1 and at most 2 ** 32 - 1.

Note: Unlike PROPERTY_HINT_ENUM, the previous explicit value is not taken into account. For the hint "A:16,B,C", A is 16, B is 2, C is 4.

PropertyHint PROPERTY_HINT_LAYERS_2D_RENDER = 7

Hints that an int property is a bitmask using the optionally named 2D render layers.

PropertyHint PROPERTY_HINT_LAYERS_2D_PHYSICS = 8

Hints that an int property is a bitmask using the optionally named 2D physics layers.

PropertyHint PROPERTY_HINT_LAYERS_2D_NAVIGATION = 9

Hints that an int property is a bitmask using the optionally named 2D navigation layers.

PropertyHint PROPERTY_HINT_LAYERS_3D_RENDER = 10

Hints that an int property is a bitmask using the optionally named 3D render layers.

PropertyHint PROPERTY_HINT_LAYERS_3D_PHYSICS = 11

Hints that an int property is a bitmask using the optionally named 3D physics layers.

PropertyHint PROPERTY_HINT_LAYERS_3D_NAVIGATION = 12

Hints that an int property is a bitmask using the optionally named 3D navigation layers.

PropertyHint PROPERTY_HINT_LAYERS_AVOIDANCE = 37

Hints that an integer property is a bitmask using the optionally named avoidance layers.

PropertyHint PROPERTY_HINT_FILE = 13

Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards like "*.png,*.jpg". By default the file will be stored as UID whenever available. You can use ResourceUID methods to convert it back to path. For storing a raw path, use PROPERTY_HINT_FILE_PATH.

PropertyHint PROPERTY_HINT_DIR = 14

Hints that a String property is a path to a directory. Editing it will show a file dialog for picking the path.

PropertyHint PROPERTY_HINT_GLOBAL_FILE = 15

Hints that a String property is an absolute path to a file outside the project folder. Editing it will show a file dialog for picking the path. The hint string can be a set of filters with wildcards, like "*.png,*.jpg".

PropertyHint PROPERTY_HINT_GLOBAL_DIR = 16

Hints that a String property is an absolute path to a directory outside the project folder. Editing it will show a file dialog for picking the path.

PropertyHint PROPERTY_HINT_RESOURCE_TYPE = 17

Hints that a property is an instance of a Resource-derived type, optionally specified via the hint string (e.g. "Texture2D"). Editing it will show a popup menu of valid resource types to instantiate.

PropertyHint PROPERTY_HINT_MULTILINE_TEXT = 18

Hints that a String property is text with line breaks. Editing it will show a text input field where line breaks can be typed.

PropertyHint PROPERTY_HINT_EXPRESSION = 19

Hints that a String property is an Expression.

PropertyHint PROPERTY_HINT_PLACEHOLDER_TEXT = 20

Hints that a String property should show a placeholder text on its input field, if empty. The hint string is the placeholder text to use.

PropertyHint PROPERTY_HINT_COLOR_NO_ALPHA = 21

Hints that a Color property should be edited without affecting its transparency (Color.a is not editable).

PropertyHint PROPERTY_HINT_OBJECT_ID = 22

Hints that the property's value is an object encoded as object ID, with its type specified in the hint string. Used by the debugger.

PropertyHint PROPERTY_HINT_TYPE_STRING = 23

If a property is String, hints that the property represents a particular type (class). This allows to select a type from the create dialog. The property will store the selected type as a string.

If a property is Array, hints the editor how to show elements. The hint_string must encode nested types using ":" and "/".

If a property is Dictionary, hints the editor how to show elements. The hint_string is the same as Array, with a ";" separating the key and value.

Note: The trailing colon is required for properly detecting built-in types.

PropertyHint PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE = 24

Deprecated: This hint is not used by the engine.

PropertyHint PROPERTY_HINT_OBJECT_TOO_BIG = 25

Hints that an object is too big to be sent via the debugger.

PropertyHint PROPERTY_HINT_NODE_PATH_VALID_TYPES = 26

Hints that the hint string specifies valid node types for property of type NodePath.

PropertyHint PROPERTY_HINT_SAVE_FILE = 27

Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path for the file to be saved at. The dialog has access to the project's directory. The hint string can be a set of filters with wildcards like "*.png,*.jpg". See also FileDialog.filters.

PropertyHint PROPERTY_HINT_GLOBAL_SAVE_FILE = 28

Hints that a String property is a path to a file. Editing it will show a file dialog for picking the path for the file to be saved at. The dialog has access to the entire filesystem. The hint string can be a set of filters with wildcards like "*.png,*.jpg". See also FileDialog.filters.

PropertyHint PROPERTY_HINT_INT_IS_OBJECTID = 29

Deprecated: This hint is not used by the engine.

PropertyHint PROPERTY_HINT_INT_IS_POINTER = 30

Hints that an int property is a pointer. Used by GDExtension.

PropertyHint PROPERTY_HINT_ARRAY_TYPE = 31

Hints that a property is an Array with the stored type specified in the hint string. The hint string contains the type of the array (e.g. "String").

Use the hint string format from PROPERTY_HINT_TYPE_STRING for more control over the stored type.

PropertyHint PROPERTY_HINT_DICTIONARY_TYPE = 38

Hints that a property is a Dictionary with the stored types specified in the hint string. The hint string contains the key and value types separated by a semicolon (e.g. "int;String").

Use the hint string format from PROPERTY_HINT_TYPE_STRING for more control over the stored types.

PropertyHint PROPERTY_HINT_LOCALE_ID = 32

Hints that a string property is a locale code. Editing it will show a locale dialog for picking language and country.

PropertyHint PROPERTY_HINT_LOCALIZABLE_STRING = 33

Hints that a dictionary property is string translation map. Dictionary keys are locale codes and, values are translated strings.

PropertyHint PROPERTY_HINT_NODE_TYPE = 34

Hints that a property is an instance of a Node-derived type, optionally specified via the hint string (e.g. "Node2D"). Editing it will show a dialog for picking a node from the scene.

PropertyHint PROPERTY_HINT_HIDE_QUATERNION_EDIT = 35

Hints that a quaternion property should disable the temporary euler editor.

PropertyHint PROPERTY_HINT_PASSWORD = 36

Hints that a string property is a password, and every character is replaced with the secret character.

PropertyHint PROPERTY_HINT_TOOL_BUTTON = 39

Hints that a Callable property should be displayed as a clickable button. When the button is pressed, the callable is called. The hint string specifies the button text and optionally an icon from the "EditorIcons" theme type.

Note: A Callable cannot be properly serialized and stored in a file, so it is recommended to use PROPERTY_USAGE_EDITOR instead of PROPERTY_USAGE_DEFAULT.

PropertyHint PROPERTY_HINT_ONESHOT = 40

Hints that a property will be changed on its own after setting, such as AudioStreamPlayer.playing or GPUParticles3D.emitting.

PropertyHint PROPERTY_HINT_GROUP_ENABLE = 42

Hints that a boolean property will enable the feature associated with the group that it occurs in. The property will be displayed as a checkbox on the group header. Only works within a group or subgroup.

By default, disabling the property hides all properties in the group. Use the optional hint string "checkbox_only" to disable this behavior.

PropertyHint PROPERTY_HINT_INPUT_NAME = 43

Hints that a String or StringName property is the name of an input action. This allows the selection of any action name from the Input Map in the Project Settings. The hint string may contain two options separated by commas:

If it contains "show_builtin", built-in input actions are included in the selection.

If it contains "loose_mode", loose mode is enabled. This allows inserting any action name even if it's not present in the input map.

PropertyHint PROPERTY_HINT_FILE_PATH = 44

Like PROPERTY_HINT_FILE, but the property is stored as a raw path, not UID. That means the reference will be broken if you move the file. Consider using PROPERTY_HINT_FILE when possible.

PropertyHint PROPERTY_HINT_MAX = 45

Represents the size of the PropertyHint enum.

flags PropertyUsageFlags: 🔗

PropertyUsageFlags PROPERTY_USAGE_NONE = 0

The property is not stored, and does not display in the editor. This is the default for non-exported properties.

PropertyUsageFlags PROPERTY_USAGE_STORAGE = 2

The property is serialized and saved in the scene file (default for exported properties).

PropertyUsageFlags PROPERTY_USAGE_EDITOR = 4

The property is shown in the EditorInspector (default for exported properties).

PropertyUsageFlags PROPERTY_USAGE_INTERNAL = 8

The property is excluded from the class reference.

PropertyUsageFlags PROPERTY_USAGE_CHECKABLE = 16

The property can be checked in the EditorInspector.

PropertyUsageFlags PROPERTY_USAGE_CHECKED = 32

The property is checked in the EditorInspector.

PropertyUsageFlags PROPERTY_USAGE_GROUP = 64

Used to group properties together in the editor. See EditorInspector.

PropertyUsageFlags PROPERTY_USAGE_CATEGORY = 128

Used to categorize properties together in the editor.

PropertyUsageFlags PROPERTY_USAGE_SUBGROUP = 256

Used to group properties together in the editor in a subgroup (under a group). See EditorInspector.

PropertyUsageFlags PROPERTY_USAGE_CLASS_IS_BITFIELD = 512

The property is a bitfield, i.e. it contains multiple flags represented as bits.

PropertyUsageFlags PROPERTY_USAGE_NO_INSTANCE_STATE = 1024

The property does not save its state in PackedScene.

PropertyUsageFlags PROPERTY_USAGE_RESTART_IF_CHANGED = 2048

Editing the property prompts the user for restarting the editor.

PropertyUsageFlags PROPERTY_USAGE_SCRIPT_VARIABLE = 4096

The property is a script variable. PROPERTY_USAGE_SCRIPT_VARIABLE can be used to distinguish between exported script variables from built-in variables (which don't have this usage flag). By default, PROPERTY_USAGE_SCRIPT_VARIABLE is not applied to variables that are created by overriding Object._get_property_list() in a script.

PropertyUsageFlags PROPERTY_USAGE_STORE_IF_NULL = 8192

The property value of type Object will be stored even if its value is null.

PropertyUsageFlags PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED = 16384

If this property is modified, all inspector fields will be refreshed.

PropertyUsageFlags PROPERTY_USAGE_SCRIPT_DEFAULT_VALUE = 32768

Deprecated: This flag is not used by the engine.

PropertyUsageFlags PROPERTY_USAGE_CLASS_IS_ENUM = 65536

The property is a variable of enum type, i.e. it only takes named integer constants from its associated enumeration.

PropertyUsageFlags PROPERTY_USAGE_NIL_IS_VARIANT = 131072

If property has nil as default value, its type will be Variant.

PropertyUsageFlags PROPERTY_USAGE_ARRAY = 262144

The property is an array.

PropertyUsageFlags PROPERTY_USAGE_ALWAYS_DUPLICATE = 524288

When duplicating a resource with Resource.duplicate(), and this flag is set on a property of that resource, the property should always be duplicated, regardless of the subresources bool parameter.

PropertyUsageFlags PROPERTY_USAGE_NEVER_DUPLICATE = 1048576

When duplicating a resource with Resource.duplicate(), and this flag is set on a property of that resource, the property should never be duplicated, regardless of the subresources bool parameter.

PropertyUsageFlags PROPERTY_USAGE_HIGH_END_GFX = 2097152

The property is only shown in the editor if modern renderers are supported (the Compatibility rendering method is excluded).

PropertyUsageFlags PROPERTY_USAGE_NODE_PATH_FROM_SCENE_ROOT = 4194304

The NodePath property will always be relative to the scene's root. Mostly useful for local resources.

PropertyUsageFlags PROPERTY_USAGE_RESOURCE_NOT_PERSISTENT = 8388608

Use when a resource is created on the fly, i.e. the getter will always return a different instance. ResourceSaver needs this information to properly save such resources.

PropertyUsageFlags PROPERTY_USAGE_KEYING_INCREMENTS = 16777216

Inserting an animation key frame of this property will automatically increment the value, allowing to easily keyframe multiple values in a row.

PropertyUsageFlags PROPERTY_USAGE_DEFERRED_SET_RESOURCE = 33554432

Deprecated: This flag is not used by the engine.

PropertyUsageFlags PROPERTY_USAGE_EDITOR_INSTANTIATE_OBJECT = 67108864

When this property is a Resource and base object is a Node, a resource instance will be automatically created whenever the node is created in the editor.

PropertyUsageFlags PROPERTY_USAGE_EDITOR_BASIC_SETTING = 134217728

The property is considered a basic setting and will appear even when advanced mode is disabled. Used for project settings.

PropertyUsageFlags PROPERTY_USAGE_READ_ONLY = 268435456

The property is read-only in the EditorInspector.

PropertyUsageFlags PROPERTY_USAGE_SECRET = 536870912

An export preset property with this flag contains confidential information and is stored separately from the rest of the export preset configuration.

PropertyUsageFlags PROPERTY_USAGE_DEFAULT = 6

Default usage (storage and editor).

PropertyUsageFlags PROPERTY_USAGE_NO_EDITOR = 2

Default usage but without showing the property in the editor (storage).

MethodFlags METHOD_FLAG_NORMAL = 1

Flag for a normal method.

MethodFlags METHOD_FLAG_EDITOR = 2

Flag for an editor method.

MethodFlags METHOD_FLAG_CONST = 4

Flag for a constant method.

MethodFlags METHOD_FLAG_VIRTUAL = 8

Flag for a virtual method.

MethodFlags METHOD_FLAG_VARARG = 16

Flag for a method with a variable number of arguments.

MethodFlags METHOD_FLAG_STATIC = 32

Flag for a static method.

MethodFlags METHOD_FLAG_OBJECT_CORE = 64

Used internally. Allows to not dump core virtual methods (such as Object._notification()) to the JSON API.

MethodFlags METHOD_FLAG_VIRTUAL_REQUIRED = 128

Flag for a virtual method that is required. In GDScript, this flag is set for abstract functions.

MethodFlags METHOD_FLAGS_DEFAULT = 1

Default method flags (normal).

Variant.Type TYPE_NIL = 0

Variant.Type TYPE_BOOL = 1

Variable is of type bool.

Variant.Type TYPE_INT = 2

Variable is of type int.

Variant.Type TYPE_FLOAT = 3

Variable is of type float.

Variant.Type TYPE_STRING = 4

Variable is of type String.

Variant.Type TYPE_VECTOR2 = 5

Variable is of type Vector2.

Variant.Type TYPE_VECTOR2I = 6

Variable is of type Vector2i.

Variant.Type TYPE_RECT2 = 7

Variable is of type Rect2.

Variant.Type TYPE_RECT2I = 8

Variable is of type Rect2i.

Variant.Type TYPE_VECTOR3 = 9

Variable is of type Vector3.

Variant.Type TYPE_VECTOR3I = 10

Variable is of type Vector3i.

Variant.Type TYPE_TRANSFORM2D = 11

Variable is of type Transform2D.

Variant.Type TYPE_VECTOR4 = 12

Variable is of type Vector4.

Variant.Type TYPE_VECTOR4I = 13

Variable is of type Vector4i.

Variant.Type TYPE_PLANE = 14

Variable is of type Plane.

Variant.Type TYPE_QUATERNION = 15

Variable is of type Quaternion.

Variant.Type TYPE_AABB = 16

Variable is of type AABB.

Variant.Type TYPE_BASIS = 17

Variable is of type Basis.

Variant.Type TYPE_TRANSFORM3D = 18

Variable is of type Transform3D.

Variant.Type TYPE_PROJECTION = 19

Variable is of type Projection.

Variant.Type TYPE_COLOR = 20

Variable is of type Color.

Variant.Type TYPE_STRING_NAME = 21

Variable is of type StringName.

Variant.Type TYPE_NODE_PATH = 22

Variable is of type NodePath.

Variant.Type TYPE_RID = 23

Variable is of type RID.

Variant.Type TYPE_OBJECT = 24

Variable is of type Object.

Variant.Type TYPE_CALLABLE = 25

Variable is of type Callable.

Variant.Type TYPE_SIGNAL = 26

Variable is of type Signal.

Variant.Type TYPE_DICTIONARY = 27

Variable is of type Dictionary.

Variant.Type TYPE_ARRAY = 28

Variable is of type Array.

Variant.Type TYPE_PACKED_BYTE_ARRAY = 29

Variable is of type PackedByteArray.

Variant.Type TYPE_PACKED_INT32_ARRAY = 30

Variable is of type PackedInt32Array.

Variant.Type TYPE_PACKED_INT64_ARRAY = 31

Variable is of type PackedInt64Array.

Variant.Type TYPE_PACKED_FLOAT32_ARRAY = 32

Variable is of type PackedFloat32Array.

Variant.Type TYPE_PACKED_FLOAT64_ARRAY = 33

Variable is of type PackedFloat64Array.

Variant.Type TYPE_PACKED_STRING_ARRAY = 34

Variable is of type PackedStringArray.

Variant.Type TYPE_PACKED_VECTOR2_ARRAY = 35

Variable is of type PackedVector2Array.

Variant.Type TYPE_PACKED_VECTOR3_ARRAY = 36

Variable is of type PackedVector3Array.

Variant.Type TYPE_PACKED_COLOR_ARRAY = 37

Variable is of type PackedColorArray.

Variant.Type TYPE_PACKED_VECTOR4_ARRAY = 38

Variable is of type PackedVector4Array.

Variant.Type TYPE_MAX = 39

Represents the size of the Variant.Type enum.

enum Variant.Operator: 🔗

Variant.Operator OP_EQUAL = 0

Equality operator (==).

Variant.Operator OP_NOT_EQUAL = 1

Inequality operator (!=).

Variant.Operator OP_LESS = 2

Less than operator (<).

Variant.Operator OP_LESS_EQUAL = 3

Less than or equal operator (<=).

Variant.Operator OP_GREATER = 4

Greater than operator (>).

Variant.Operator OP_GREATER_EQUAL = 5

Greater than or equal operator (>=).

Variant.Operator OP_ADD = 6

Addition operator (+).

Variant.Operator OP_SUBTRACT = 7

Subtraction operator (-).

Variant.Operator OP_MULTIPLY = 8

Multiplication operator (*).

Variant.Operator OP_DIVIDE = 9

Division operator (/).

Variant.Operator OP_NEGATE = 10

Unary negation operator (-).

Variant.Operator OP_POSITIVE = 11

Unary plus operator (+).

Variant.Operator OP_MODULE = 12

Remainder/modulo operator (%).

Variant.Operator OP_POWER = 13

Variant.Operator OP_SHIFT_LEFT = 14

Left shift operator (<<).

Variant.Operator OP_SHIFT_RIGHT = 15

Right shift operator (>>).

Variant.Operator OP_BIT_AND = 16

Bitwise AND operator (&).

Variant.Operator OP_BIT_OR = 17

Bitwise OR operator (|).

Variant.Operator OP_BIT_XOR = 18

Bitwise XOR operator (^).

Variant.Operator OP_BIT_NEGATE = 19

Bitwise NOT operator (~).

Variant.Operator OP_AND = 20

Logical AND operator (and or &&).

Variant.Operator OP_OR = 21

Logical OR operator (or or ||).

Variant.Operator OP_XOR = 22

Logical XOR operator (not implemented in GDScript).

Variant.Operator OP_NOT = 23

Logical NOT operator (not or !).

Variant.Operator OP_IN = 24

Logical IN operator (in).

Variant.Operator OP_MAX = 25

Represents the size of the Variant.Operator enum.

AudioServer AudioServer 🔗

The AudioServer singleton.

CameraServer CameraServer 🔗

The CameraServer singleton.

The ClassDB singleton.

DisplayServer DisplayServer 🔗

The DisplayServer singleton.

EditorInterface EditorInterface 🔗

The EditorInterface singleton.

Note: Only available in editor builds.

The Engine singleton.

EngineDebugger EngineDebugger 🔗

The EngineDebugger singleton.

GDExtensionManager GDExtensionManager 🔗

The GDExtensionManager singleton.

Geometry2D Geometry2D 🔗

The Geometry2D singleton.

Geometry3D Geometry3D 🔗

The Geometry3D singleton.

The InputMap singleton.

JavaClassWrapper JavaClassWrapper 🔗

The JavaClassWrapper singleton.

Note: Only implemented on Android.

JavaScriptBridge JavaScriptBridge 🔗

The JavaScriptBridge singleton.

Note: Only implemented on the Web platform.

Marshalls Marshalls 🔗

The Marshalls singleton.

NativeMenu NativeMenu 🔗

The NativeMenu singleton.

Note: Only implemented on macOS.

NavigationMeshGenerator NavigationMeshGenerator 🔗

The NavigationMeshGenerator singleton.

NavigationServer2D NavigationServer2D 🔗

The NavigationServer2D singleton.

NavigationServer3D NavigationServer3D 🔗

The NavigationServer3D singleton.

Performance Performance 🔗

The Performance singleton.

PhysicsServer2D PhysicsServer2D 🔗

The PhysicsServer2D singleton.

PhysicsServer2DManager PhysicsServer2DManager 🔗

The PhysicsServer2DManager singleton.

PhysicsServer3D PhysicsServer3D 🔗

The PhysicsServer3D singleton.

PhysicsServer3DManager PhysicsServer3DManager 🔗

The PhysicsServer3DManager singleton.

ProjectSettings ProjectSettings 🔗

The ProjectSettings singleton.

RenderingServer RenderingServer 🔗

The RenderingServer singleton.

ResourceLoader ResourceLoader 🔗

The ResourceLoader singleton.

ResourceSaver ResourceSaver 🔗

The ResourceSaver singleton.

ResourceUID ResourceUID 🔗

The ResourceUID singleton.

TextServerManager TextServerManager 🔗

The TextServerManager singleton.

The ThemeDB singleton.

TranslationServer TranslationServer 🔗

The TranslationServer singleton.

WorkerThreadPool WorkerThreadPool 🔗

The WorkerThreadPool singleton.

The XRServer singleton.

Variant abs(x: Variant) 🔗

Returns the absolute value of a Variant parameter x (i.e. non-negative value). Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

Note: For better type safety, use absf(), absi(), Vector2.abs(), Vector2i.abs(), Vector3.abs(), Vector3i.abs(), Vector4.abs(), or Vector4i.abs().

float absf(x: float) 🔗

Returns the absolute value of float parameter x (i.e. positive value).

Returns the absolute value of int parameter x (i.e. positive value).

float acos(x: float) 🔗

Returns the arc cosine of x in radians. Use to get the angle of cosine x. x will be clamped between -1.0 and 1.0 (inclusive), in order to prevent acos() from returning @GDScript.NAN.

float acosh(x: float) 🔗

Returns the hyperbolic arc (also called inverse) cosine of x, returning a value in radians. Use it to get the angle from an angle's cosine in hyperbolic space if x is larger or equal to 1. For values of x lower than 1, it will return 0, in order to prevent acosh() from returning @GDScript.NAN.

float angle_difference(from: float, to: float) 🔗

Returns the difference between the two angles (in radians), in the range of [-PI, +PI]. When from and to are opposite, returns -PI if from is smaller than to, or PI otherwise.

float asin(x: float) 🔗

Returns the arc sine of x in radians. Use to get the angle of sine x. x will be clamped between -1.0 and 1.0 (inclusive), in order to prevent asin() from returning @GDScript.NAN.

float asinh(x: float) 🔗

Returns the hyperbolic arc (also called inverse) sine of x, returning a value in radians. Use it to get the angle from an angle's sine in hyperbolic space.

float atan(x: float) 🔗

Returns the arc tangent of x in radians. Use it to get the angle from an angle's tangent in trigonometry.

The method cannot know in which quadrant the angle should fall. See atan2() if you have both y and x.

If x is between -PI / 2 and PI / 2 (inclusive), atan(tan(x)) is equal to x.

float atan2(y: float, x: float) 🔗

Returns the arc tangent of y/x in radians. Use to get the angle of tangent y/x. To compute the value, the method takes into account the sign of both arguments in order to determine the quadrant.

Important note: The Y coordinate comes first, by convention.

float atanh(x: float) 🔗

Returns the hyperbolic arc (also called inverse) tangent of x, returning a value in radians. Use it to get the angle from an angle's tangent in hyperbolic space if x is between -1 and 1 (non-inclusive).

In mathematics, the inverse hyperbolic tangent is only defined for -1 < x < 1 in the real set, so values equal or lower to -1 for x return negative @GDScript.INF and values equal or higher than 1 return positive @GDScript.INF in order to prevent atanh() from returning @GDScript.NAN.

float bezier_derivative(start: float, control_1: float, control_2: float, end: float, t: float) 🔗

Returns the derivative at the given t on a one-dimensional Bézier curve defined by the given control_1, control_2, and end points.

float bezier_interpolate(start: float, control_1: float, control_2: float, end: float, t: float) 🔗

Returns the point at the given t on a one-dimensional Bézier curve defined by the given control_1, control_2, and end points.

Variant bytes_to_var(bytes: PackedByteArray) 🔗

Decodes a byte array back to a Variant value, without decoding objects.

Note: If you need object deserialization, see bytes_to_var_with_objects().

Variant bytes_to_var_with_objects(bytes: PackedByteArray) 🔗

Decodes a byte array back to a Variant value. Decoding objects is allowed.

Warning: Deserialized object can contain code which gets executed. Do not use this option if the serialized object comes from untrusted sources to avoid potential security threats (remote code execution).

Variant ceil(x: Variant) 🔗

Rounds x upward (towards positive infinity), returning the smallest whole number that is not less than x. Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

See also floor(), round(), and snapped().

Note: For better type safety, use ceilf(), ceili(), Vector2.ceil(), Vector3.ceil(), or Vector4.ceil().

float ceilf(x: float) 🔗

Rounds x upward (towards positive infinity), returning the smallest whole number that is not less than x.

A type-safe version of ceil(), returning a float.

int ceili(x: float) 🔗

Rounds x upward (towards positive infinity), returning the smallest whole number that is not less than x.

A type-safe version of ceil(), returning an int.

Variant clamp(value: Variant, min: Variant, max: Variant) 🔗

Clamps the value, returning a Variant not less than min and not more than max. Any values that can be compared with the less than and greater than operators will work.

Note: For better type safety, use clampf(), clampi(), Vector2.clamp(), Vector2i.clamp(), Vector3.clamp(), Vector3i.clamp(), Vector4.clamp(), Vector4i.clamp(), or Color.clamp() (not currently supported by this method).

Note: When using this on vectors it will not perform component-wise clamping, and will pick min if value < min or max if value > max. To perform component-wise clamping use the methods listed above.

float clampf(value: float, min: float, max: float) 🔗

Clamps the value, returning a float not less than min and not more than max.

int clampi(value: int, min: int, max: int) 🔗

Clamps the value, returning an int not less than min and not more than max.

float cos(angle_rad: float) 🔗

Returns the cosine of angle angle_rad in radians.

float cosh(x: float) 🔗

Returns the hyperbolic cosine of x in radians.

float cubic_interpolate(from: float, to: float, pre: float, post: float, weight: float) 🔗

Cubic interpolates between two values by the factor defined in weight with pre and post values.

float cubic_interpolate_angle(from: float, to: float, pre: float, post: float, weight: float) 🔗

Cubic interpolates between two rotation values with shortest path by the factor defined in weight with pre and post values. See also lerp_angle().

float cubic_interpolate_angle_in_time(from: float, to: float, pre: float, post: float, weight: float, to_t: float, pre_t: float, post_t: float) 🔗

Cubic interpolates between two rotation values with shortest path by the factor defined in weight with pre and post values. See also lerp_angle().

It can perform smoother interpolation than cubic_interpolate() by the time values.

float cubic_interpolate_in_time(from: float, to: float, pre: float, post: float, weight: float, to_t: float, pre_t: float, post_t: float) 🔗

Cubic interpolates between two values by the factor defined in weight with pre and post values.

It can perform smoother interpolation than cubic_interpolate() by the time values.

float db_to_linear(db: float) 🔗

Converts from decibels to linear energy (audio).

float deg_to_rad(deg: float) 🔗

Converts an angle expressed in degrees to radians.

float ease(x: float, curve: float) 🔗

Returns an "eased" value of x based on an easing function defined with curve. This easing function is based on an exponent. The curve can be any floating-point number, with specific values leading to the following behaviors:

ease() curve values cheatsheet

See also smoothstep(). If you need to perform more advanced transitions, use Tween.interpolate_value().

String error_string(error: int) 🔗

Returns a human-readable name for the given Error code.

float exp(x: float) 🔗

The natural exponential function. It raises the mathematical constant e to the power of x and returns it.

e has an approximate value of 2.71828, and can be obtained with exp(1).

For exponents to other bases use the method pow().

Variant floor(x: Variant) 🔗

Rounds x downward (towards negative infinity), returning the largest whole number that is not more than x. Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

See also ceil(), round(), and snapped().

Note: For better type safety, use floorf(), floori(), Vector2.floor(), Vector3.floor(), or Vector4.floor().

float floorf(x: float) 🔗

Rounds x downward (towards negative infinity), returning the largest whole number that is not more than x.

A type-safe version of floor(), returning a float.

int floori(x: float) 🔗

Rounds x downward (towards negative infinity), returning the largest whole number that is not more than x.

A type-safe version of floor(), returning an int.

Note: This function is not the same as int(x), which rounds towards 0.

float fmod(x: float, y: float) 🔗

Returns the floating-point remainder of x divided by y, keeping the sign of x.

For the integer remainder operation, use the % operator.

float fposmod(x: float, y: float) 🔗

Returns the floating-point modulus of x divided by y, wrapping equally in positive and negative.

int hash(variable: Variant) 🔗

Returns the integer hash of the passed variable.

Object instance_from_id(instance_id: int) 🔗

Returns the Object that corresponds to instance_id. All Objects have a unique instance ID. See also Object.get_instance_id().

float inverse_lerp(from: float, to: float, weight: float) 🔗

Returns an interpolation or extrapolation factor considering the range specified in from and to, and the interpolated value specified in weight. The returned value will be between 0.0 and 1.0 if weight is between from and to (inclusive). If weight is located outside this range, then an extrapolation factor will be returned (return value lower than 0.0 or greater than 1.0). Use clamp() on the result of inverse_lerp() if this is not desired.

See also lerp(), which performs the reverse of this operation, and remap() to map a continuous series of values to another.

bool is_equal_approx(a: float, b: float) 🔗

Returns true if a and b are approximately equal to each other.

Here, "approximately equal" means that a and b are within a small internal epsilon of each other, which scales with the magnitude of the numbers.

Infinity values of the same sign are considered equal.

bool is_finite(x: float) 🔗

Returns whether x is a finite value, i.e. it is not @GDScript.NAN, positive infinity, or negative infinity. See also is_inf() and is_nan().

bool is_inf(x: float) 🔗

Returns true if x is either positive infinity or negative infinity. See also is_finite() and is_nan().

bool is_instance_id_valid(id: int) 🔗

Returns true if the Object that corresponds to id is a valid object (e.g. has not been deleted from memory). All Objects have a unique instance ID.

bool is_instance_valid(instance: Variant) 🔗

Returns true if instance is a valid Object (e.g. has not been deleted from memory).

bool is_nan(x: float) 🔗

Returns true if x is a NaN ("Not a Number" or invalid) value. This method is needed as @GDScript.NAN is not equal to itself, which means x == NAN can't be used to check whether a value is a NaN.

bool is_same(a: Variant, b: Variant) 🔗

Returns true, for value types, if a and b share the same value. Returns true, for reference types, if the references of a and b are the same.

These are Variant value types: null, bool, int, float, String, StringName, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i, Rect2, Rect2i, Transform2D, Transform3D, Plane, Quaternion, AABB, Basis, Projection, Color, NodePath, RID, Callable and Signal.

These are Variant reference types: Object, Dictionary, Array, PackedByteArray, PackedInt32Array, PackedInt64Array, PackedFloat32Array, PackedFloat64Array, PackedStringArray, PackedVector2Array, PackedVector3Array, PackedVector4Array, and PackedColorArray.

bool is_zero_approx(x: float) 🔗

Returns true if x is zero or almost zero. The comparison is done using a tolerance calculation with a small internal epsilon.

This function is faster than using is_equal_approx() with one value as zero.

Variant lerp(from: Variant, to: Variant, weight: Variant) 🔗

Linearly interpolates between two values by the factor defined in weight. To perform interpolation, weight should be between 0.0 and 1.0 (inclusive). However, values outside this range are allowed and can be used to perform extrapolation. If this is not desired, use clampf() to limit weight.

Both from and to must be the same type. Supported types: int, float, Vector2, Vector3, Vector4, Color, Quaternion, Basis, Transform2D, Transform3D.

See also inverse_lerp() which performs the reverse of this operation. To perform eased interpolation with lerp(), combine it with ease() or smoothstep(). See also remap() to map a continuous series of values to another.

Note: For better type safety, use lerpf(), Vector2.lerp(), Vector3.lerp(), Vector4.lerp(), Color.lerp(), Quaternion.slerp(), Basis.slerp(), Transform2D.interpolate_with(), or Transform3D.interpolate_with().

float lerp_angle(from: float, to: float, weight: float) 🔗

Linearly interpolates between two angles (in radians) by a weight value between 0.0 and 1.0.

Similar to lerp(), but interpolates correctly when the angles wrap around @GDScript.TAU. To perform eased interpolation with lerp_angle(), combine it with ease() or smoothstep().

Note: This function lerps through the shortest path between from and to. However, when these two angles are approximately PI + k * TAU apart for any integer k, it's not obvious which way they lerp due to floating-point precision errors. For example, lerp_angle(0, PI, weight) lerps counter-clockwise, while lerp_angle(0, PI + 5 * TAU, weight) lerps clockwise.

float lerpf(from: float, to: float, weight: float) 🔗

Linearly interpolates between two values by the factor defined in weight. To perform interpolation, weight should be between 0.0 and 1.0 (inclusive). However, values outside this range are allowed and can be used to perform extrapolation. If this is not desired, use clampf() on the result of this function.

See also inverse_lerp() which performs the reverse of this operation. To perform eased interpolation with lerp(), combine it with ease() or smoothstep().

float linear_to_db(lin: float) 🔗

Converts from linear energy to decibels (audio). Since volume is not normally linear, this can be used to implement volume sliders that behave as expected.

Example: Change the Master bus's volume through a Slider node, which ranges from 0.0 to 1.0:

float log(x: float) 🔗

Returns the natural logarithm of x (base [i]e[/i], with e being approximately 2.71828). This is the amount of time needed to reach a certain level of continuous growth.

Note: This is not the same as the "log" function on most calculators, which uses a base 10 logarithm. To use base 10 logarithm, use log(x) / log(10).

Note: The logarithm of 0 returns -inf, while negative values return -nan.

Variant max(...) vararg 🔗

Returns the maximum of the given numeric values. This function can take any number of arguments.

Note: When using this on vectors it will not perform component-wise maximum, and will pick the largest value when compared using x < y. To perform component-wise maximum, use Vector2.max(), Vector2i.max(), Vector3.max(), Vector3i.max(), Vector4.max(), and Vector4i.max().

float maxf(a: float, b: float) 🔗

Returns the maximum of two float values.

int maxi(a: int, b: int) 🔗

Returns the maximum of two int values.

Variant min(...) vararg 🔗

Returns the minimum of the given numeric values. This function can take any number of arguments.

Note: When using this on vectors it will not perform component-wise minimum, and will pick the smallest value when compared using x < y. To perform component-wise minimum, use Vector2.min(), Vector2i.min(), Vector3.min(), Vector3i.min(), Vector4.min(), and Vector4i.min().

float minf(a: float, b: float) 🔗

Returns the minimum of two float values.

int mini(a: int, b: int) 🔗

Returns the minimum of two int values.

float move_toward(from: float, to: float, delta: float) 🔗

Moves from toward to by the delta amount. Will not go past to.

Use a negative delta value to move away.

int nearest_po2(value: int) 🔗

Returns the smallest integer power of 2 that is greater than or equal to value.

Warning: Due to its implementation, this method returns 0 rather than 1 for values less than or equal to 0, with an exception for value being the smallest negative 64-bit integer (-9223372036854775808) in which case the value is returned unchanged.

float pingpong(value: float, length: float) 🔗

Wraps value between 0 and the length. If the limit is reached, the next value the function returns is decreased to the 0 side or increased to the length side (like a triangle wave). If length is less than zero, it becomes positive.

int posmod(x: int, y: int) 🔗

Returns the integer modulus of x divided by y that wraps equally in positive and negative.

float pow(base: float, exp: float) 🔗

Returns the result of base raised to the power of exp.

In GDScript, this is the equivalent of the ** operator.

void print(...) vararg 🔗

Converts one or more arguments of any type to string in the best way possible and prints them to the console.

Note: Consider using push_error() and push_warning() to print error and warning messages instead of print() or print_rich(). This distinguishes them from print messages used for debugging purposes, while also displaying a stack trace when an error or warning is printed. See also Engine.print_to_stdout and ProjectSettings.application/run/disable_stdout.

void print_rich(...) vararg 🔗

Converts one or more arguments of any type to string in the best way possible and prints them to the console.

The following BBCode tags are supported: b, i, u, s, indent, code, url, center, right, color, bgcolor, fgcolor.

URL tags only support URLs wrapped by a URL tag, not URLs with a different title.

When printing to standard output, the supported subset of BBCode is converted to ANSI escape codes for the terminal emulator to display. Support for ANSI escape codes varies across terminal emulators, especially for italic and strikethrough. In standard output, code is represented with faint text but without any font change. Unsupported tags are left as-is in standard output.

Note: Consider using push_error() and push_warning() to print error and warning messages instead of print() or print_rich(). This distinguishes them from print messages used for debugging purposes, while also displaying a stack trace when an error or warning is printed.

Note: Output displayed in the editor supports clickable [url=address]text[/url] tags. The [url] tag's address value is handled by OS.shell_open() when clicked.

void print_verbose(...) vararg 🔗

If verbose mode is enabled (OS.is_stdout_verbose() returning true), converts one or more arguments of any type to string in the best way possible and prints them to the console.

void printerr(...) vararg 🔗

Prints one or more arguments to strings in the best way possible to standard error line.

void printraw(...) vararg 🔗

Prints one or more arguments to strings in the best way possible to the OS terminal. Unlike print(), no newline is automatically added at the end.

Note: The OS terminal is not the same as the editor's Output dock. The output sent to the OS terminal can be seen when running Godot from a terminal. On Windows, this requires using the console.exe executable.

void prints(...) vararg 🔗

Prints one or more arguments to the console with a space between each argument.

void printt(...) vararg 🔗

Prints one or more arguments to the console with a tab between each argument.

void push_error(...) vararg 🔗

Pushes an error message to Godot's built-in debugger and to the OS terminal.

Note: This function does not pause project execution. To print an error message and pause project execution in debug builds, use assert(false, "test error") instead.

void push_warning(...) vararg 🔗

Pushes a warning message to Godot's built-in debugger and to the OS terminal.

float rad_to_deg(rad: float) 🔗

Converts an angle expressed in radians to degrees.

PackedInt64Array rand_from_seed(seed: int) 🔗

Given a seed, returns a PackedInt64Array of size 2, where its first element is the randomized int value, and the second element is the same as seed. Passing the same seed consistently returns the same array.

Note: "Seed" here refers to the internal state of the pseudo random number generator, currently implemented as a 64 bit integer.

Returns a random floating-point value between 0.0 and 1.0 (inclusive).

float randf_range(from: float, to: float) 🔗

Returns a random floating-point value between from and to (inclusive).

float randfn(mean: float, deviation: float) 🔗

Returns a normally-distributed, pseudo-random floating-point value from the specified mean and a standard deviation. This is also known as a Gaussian distribution.

Note: This method uses the Box-Muller transform algorithm.

Returns a random unsigned 32-bit integer. Use remainder to obtain a random value in the interval [0, N - 1] (where N is smaller than 2^32).

int randi_range(from: int, to: int) 🔗

Returns a random signed 32-bit integer between from and to (inclusive). If to is lesser than from, they are swapped.

Randomizes the seed (or the internal state) of the random number generator. The current implementation uses a number based on the device's time.

Note: This function is called automatically when the project is run. If you need to fix the seed to have consistent, reproducible results, use seed() to initialize the random number generator.

float remap(value: float, istart: float, istop: float, ostart: float, ostop: float) 🔗

Maps a value from range [istart, istop] to [ostart, ostop]. See also lerp() and inverse_lerp(). If value is outside [istart, istop], then the resulting value will also be outside [ostart, ostop]. If this is not desired, use clamp() on the result of this function.

For complex use cases where multiple ranges are needed, consider using Curve or Gradient instead.

Note: If istart == istop, the return value is undefined (most likely NaN, INF, or -INF).

int rid_allocate_id() 🔗

Allocates a unique ID which can be used by the implementation to construct an RID. This is used mainly from native extensions to implement servers.

RID rid_from_int64(base: int) 🔗

Creates an RID from a base. This is used mainly from native extensions to build servers.

float rotate_toward(from: float, to: float, delta: float) 🔗

Rotates from toward to by the delta amount. Will not go past to.

Similar to move_toward(), but interpolates correctly when the angles wrap around @GDScript.TAU.

If delta is negative, this function will rotate away from to, toward the opposite angle, and will not go past the opposite angle.

Variant round(x: Variant) 🔗

Rounds x to the nearest whole number, with halfway cases rounded away from 0. Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

See also floor(), ceil(), and snapped().

Note: For better type safety, use roundf(), roundi(), Vector2.round(), Vector3.round(), or Vector4.round().

float roundf(x: float) 🔗

Rounds x to the nearest whole number, with halfway cases rounded away from 0.

A type-safe version of round(), returning a float.

int roundi(x: float) 🔗

Rounds x to the nearest whole number, with halfway cases rounded away from 0.

A type-safe version of round(), returning an int.

void seed(base: int) 🔗

Sets the seed for the random number generator to base. Setting the seed manually can ensure consistent, repeatable results for most random functions.

Variant sign(x: Variant) 🔗

Returns the same type of Variant as x, with -1 for negative values, 1 for positive values, and 0 for zeros. For nan values it returns 0.

Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

Note: For better type safety, use signf(), signi(), Vector2.sign(), Vector2i.sign(), Vector3.sign(), Vector3i.sign(), Vector4.sign(), or Vector4i.sign().

float signf(x: float) 🔗

Returns -1.0 if x is negative, 1.0 if x is positive, and 0.0 if x is zero. For nan values of x it returns 0.0.

Returns -1 if x is negative, 1 if x is positive, and 0 if x is zero.

float sin(angle_rad: float) 🔗

Returns the sine of angle angle_rad in radians.

float sinh(x: float) 🔗

Returns the hyperbolic sine of x.

float smoothstep(from: float, to: float, x: float) 🔗

Returns a smooth cubic Hermite interpolation between 0 and 1.

For positive ranges (when from <= to) the return value is 0 when x <= from, and 1 when x >= to. If x lies between from and to, the return value follows an S-shaped curve that smoothly transitions from 0 to 1.

For negative ranges (when from > to) the function is mirrored and returns 1 when x <= to and 0 when x >= from.

This S-shaped curve is the cubic Hermite interpolator, given by f(y) = 3*y^2 - 2*y^3 where y = (x-from) / (to-from).

Compared to ease() with a curve value of -1.6521, smoothstep() returns the smoothest possible curve with no sudden changes in the derivative. If you need to perform more advanced transitions, use Tween or AnimationPlayer.

Comparison between smoothstep() and ease(x, -1.6521) return values

Smoothstep() return values with positive, zero, and negative ranges

Variant snapped(x: Variant, step: Variant) 🔗

Returns the multiple of step that is the closest to x. This can also be used to round a floating-point number to an arbitrary number of decimals.

The returned value is the same type of Variant as step. Supported types: int, float, Vector2, Vector2i, Vector3, Vector3i, Vector4, Vector4i.

See also ceil(), floor(), and round().

Note: For better type safety, use snappedf(), snappedi(), Vector2.snapped(), Vector2i.snapped(), Vector3.snapped(), Vector3i.snapped(), Vector4.snapped(), or Vector4i.snapped().

float snappedf(x: float, step: float) 🔗

Returns the multiple of step that is the closest to x. This can also be used to round a floating-point number to an arbitrary number of decimals.

A type-safe version of snapped(), returning a float.

int snappedi(x: float, step: int) 🔗

Returns the multiple of step that is the closest to x.

A type-safe version of snapped(), returning an int.

float sqrt(x: float) 🔗

Returns the square root of x, where x is a non-negative number.

Note: Negative values of x return NaN ("Not a Number"). In C#, if you need negative inputs, use System.Numerics.Complex.

int step_decimals(x: float) 🔗

Returns the position of the first non-zero digit, after the decimal point. Note that the maximum return value is 10, which is a design decision in the implementation.

String str(...) vararg 🔗

Converts one or more arguments of any Variant type to a String in the best way possible.

Variant str_to_var(string: String) 🔗

Converts a formatted string that was returned by var_to_str() to the original Variant.

float tan(angle_rad: float) 🔗

Returns the tangent of angle angle_rad in radians.

float tanh(x: float) 🔗

Returns the hyperbolic tangent of x.

Variant type_convert(variant: Variant, type: int) 🔗

Converts the given variant to the given type, using the Variant.Type values. This method is generous with how it handles types, it can automatically convert between array types, convert numeric Strings to int, and converting most things to String.

If the type conversion cannot be done, this method will return the default value for that type, for example converting Rect2 to Vector2 will always return Vector2.ZERO. This method will never show error messages as long as type is a valid Variant type.

The returned value is a Variant, but the data inside and its type will be the same as the requested type.

String type_string(type: int) 🔗

Returns a human-readable name of the given type, using the Variant.Type values.

int typeof(variable: Variant) 🔗

Returns the internal type of the given variable, using the Variant.Type values.

See also type_string().

PackedByteArray var_to_bytes(variable: Variant) 🔗

Encodes a Variant value to a byte array, without encoding objects. Deserialization can be done with bytes_to_var().

Note: If you need object serialization, see var_to_bytes_with_objects().

Note: Encoding Callable is not supported and will result in an empty value, regardless of the data.

PackedByteArray var_to_bytes_with_objects(variable: Variant) 🔗

Encodes a Variant value to a byte array. Encoding objects is allowed (and can potentially include executable code). Deserialization can be done with bytes_to_var_with_objects().

Note: Encoding Callable is not supported and will result in an empty value, regardless of the data.

String var_to_str(variable: Variant) 🔗

Converts a Variant variable to a formatted String that can then be parsed using str_to_var().

Note: Converting Signal or Callable is not supported and will result in an empty value for these types, regardless of their data.

Variant weakref(obj: Variant) 🔗

Returns a WeakRef instance holding a weak reference to obj. Returns an empty WeakRef instance if obj is null. Prints an error and returns null if obj is neither Object-derived nor null.

A weak reference to an object is not enough to keep the object alive: when the only remaining references to a referent are weak references, garbage collection is free to destroy the referent and reuse its memory for something else. However, until the object is actually destroyed the weak reference may return the object even if there are no strong references to it.

Variant wrap(value: Variant, min: Variant, max: Variant) 🔗

Wraps the Variant value between min and max. min is inclusive while max is exclusive. This can be used for creating loop-like behavior or infinite surfaces.

Variant types int and float are supported. If any of the arguments is float, this function returns a float, otherwise it returns an int.

float wrapf(value: float, min: float, max: float) 🔗

Wraps the float value between min and max. min is inclusive while max is exclusive. This can be used for creating loop-like behavior or infinite surfaces.

Note: If min is 0, this is equivalent to fposmod(), so prefer using that instead. wrapf() is more flexible than using the fposmod() approach by giving the user control over the minimum value.

int wrapi(value: int, min: int, max: int) 🔗

Wraps the integer value between min and max. min is inclusive while max is exclusive. This can be used for creating loop-like behavior or infinite surfaces.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
var error = method_that_returns_error()
if error != OK:
    printerr("Failure!")

# Or, alternatively:
if error:
    printerr("Still failing!")
```

Example 2 (unknown):
```unknown
# Array of elem_type.
hint_string = "%d:" % [elem_type]
hint_string = "%d/%d:%s" % [elem_type, elem_hint, elem_hint_string]
# Two-dimensional array of elem_type (array of arrays of elem_type).
hint_string = "%d:%d:" % [TYPE_ARRAY, elem_type]
hint_string = "%d:%d/%d:%s" % [TYPE_ARRAY, elem_type, elem_hint, elem_hint_string]
# Three-dimensional array of elem_type (array of arrays of arrays of elem_type).
hint_string = "%d:%d:%d:" % [TYPE_ARRAY, TYPE_ARRAY, elem_type]
hint_string = "%d:%d:%d/%d:%s" % [TYPE_ARRAY, TYPE_ARRAY, elem_type, elem_hint, elem_hint_string]
```

Example 3 (unknown):
```unknown
// Array of elemType.
hintString = $"{elemType:D}:";
hintString = $"{elemType:}/{elemHint:D}:{elemHintString}";
// Two-dimensional array of elemType (array of arrays of elemType).
hintString = $"{Variant.Type.Array:D}:{elemType:D}:";
hintString = $"{Variant.Type.Array:D}:{elemType:D}/{elemHint:D}:{elemHintString}";
// Three-dimensional array of elemType (array of arrays of arrays of elemType).
hintString = $"{Variant.Type.Array:D}:{Variant.Type.Array:D}:{elemType:D}:";
hintString = $"{Variant.Type.Array:D}:{Variant.Type.Array:D}:{elemType:D}/{elemHint:D}:{elemHintString}";
```

Example 4 (unknown):
```unknown
hint_string = "%d:" % [TYPE_INT] # Array of integers.
hint_string = "%d/%d:1,10,1" % [TYPE_INT, PROPERTY_HINT_RANGE] # Array of integers (in range from 1 to 10).
hint_string = "%d/%d:Zero,One,Two" % [TYPE_INT, PROPERTY_HINT_ENUM] # Array of integers (an enum).
hint_string = "%d/%d:Zero,One,Three:3,Six:6" % [TYPE_INT, PROPERTY_HINT_ENUM] # Array of integers (an enum).
hint_string = "%d/%d:*.png" % [TYPE_STRING, PROPERTY_HINT_FILE] # Array of strings (file paths).
hint_string = "%d/%d:Texture2D" % [TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE] # Array of textures.

hint_string = "%d:%d:" % [TYPE_ARRAY, TYPE_FLOAT] # Two-dimensional array of floats.
hint_string = "%d:%d/%d:" % [TYPE_ARRAY, TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT] # Two-dimensional array of multiline strings.
hint_string = "%d:%d/%d:-1,1,0.1" % [TYPE_ARRAY, TYPE_FLOAT, PROPERTY_HINT_RANGE] # Two-dimensional array of floats (in range from -1 to 1).
hint_string = "%d:%d/%d:Texture2D" % [TYPE_ARRAY, TYPE_OBJECT, PROPERTY_HINT_RESOURCE_TYPE] # Two-dimensional array of textures.
```

---

## Handling compatibility breakages — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/development/handling_compatibility_breakages.html

**Contents:**
- Handling compatibility breakages
- A practical example
- User-contributed notes

So you've added a new parameter to a method, changed the return type, changed the type of a parameter, or changed its default value, and now the automated testing is complaining about compatibility breakages?

Breaking compatibility should be avoided, but when necessary there are systems in place to handle this in a way that makes the transition as smooth as possible.

These changes are taken from pull request #88047, which added new pathing options to AStarGrid2D and other AStar classes. Among other changes, these methods were modified in core/math/a_star_grid_2d.h:

This meant adding new compatibility method bindings to the file, which should be in the protected section of the code, usually placed next to _bind_methods():

They should start with an _ to indicate that they are internal, and end with _bind_compat_ followed by the PR number that introduced the change (88047 in this example). These compatibility methods need to be implemented in a dedicated file, like core/math/a_star_grid_2d.compat.inc in this case:

Unless the change in compatibility is complex, the compatibility method should call the modified method directly, instead of duplicating that method. Make sure to match the default arguments for that method (in the example above this would be false).

This file should always be placed next to the original file, and have .compat.inc at the end instead of .cpp or .h. Next, this should be included in the .cpp file we're adding compatibility methods to, so core/math/a_star_grid_2d.cpp:

And finally, the changes reported by the API validation step should be added to the relevant validation file. Because this was done during the development of 4.3, this would be misc/extension_api_validation/4.2-stable.expected (including changes not shown in this example):

The instructions for how to add to that file are at the top of the file itself.

If you get a "Hash changed" error for a method, it means that the compatibility binding is missing or incorrect. Such lines shouldn't be added to the .expected file, but fixed by binding the proper compatibility method.

And that's it! You might run into a bit more complicated cases, like rearranging arguments, changing return types, etc., but this covers the basic on how to use this system.

For more information, see pull request #76446.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (javascript):
```javascript
Vector<Vector2> get_point_path(const Vector2i &p_from, const Vector2i &p_to);
TypedArray<Vector2i> get_id_path(const Vector2i &p_from, const Vector2i &p_to);
```

Example 2 (javascript):
```javascript
Vector<Vector2> get_point_path(const Vector2i &p_from, const Vector2i &p_to, bool p_allow_partial_path = false);
TypedArray<Vector2i> get_id_path(const Vector2i &p_from, const Vector2i &p_to, bool p_allow_partial_path = false);
```

Example 3 (javascript):
```javascript
#ifndef DISABLE_DEPRECATED
    TypedArray<Vector2i> _get_id_path_bind_compat_88047(const Vector2i &p_from, const Vector2i &p_to);
    Vector<Vector2> _get_point_path_bind_compat_88047(const Vector2i &p_from, const Vector2i &p_to);
    static void _bind_compatibility_methods();
#endif
```

Example 4 (javascript):
```javascript
/**************************************************************************/
/*  a_star_grid_2d.compat.inc                                             */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

#ifndef DISABLE_DEPRECATED

#include "core/variant/typed_array.h"

TypedArray<Vector2i> AStarGrid2D::_get_id_path_bind_compat_88047(const Vector2i &p_from_id, const Vector2i &p_to_id) {
    return get_id_path(p_from_id, p_to_id, false);
}

Vector<Vector2> AStarGrid2D::_get_point_path_bind_compat_88047(const Vector2i &p_from_id, const Vector2i &p_to_id) {
    return get_point_path(p_from_id, p_to_id, false);
}

void AStarGrid2D::_bind_compatibility_methods() {
    ClassDB::bind_compatibility_method(D_METHOD("get_id_path", "from_id", "to_id"), &AStarGrid2D::_get_id_path_bind_compat_88047);
    ClassDB::bind_compatibility_method(D_METHOD("get_point_path", "from_id", "to_id"), &AStarGrid2D::_get_point_path_bind_compat_88047);
}

#endif // DISABLE_DEPRECATED
```

---

## HTML5 shell class reference — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/platform/web/html5_shell_classref.html

**Contents:**
- HTML5 shell class reference
- Engine
  - Static Methods
  - Instance Methods
- Engine configuration
  - Properties
- User-contributed notes

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

Projects exported for the Web expose the Engine() class to the JavaScript environment, that allows fine control over the engine's start-up process.

This API is built in an asynchronous manner and requires basic understanding of Promises.

The Engine class provides methods for loading and starting exported projects on the Web. For default export settings, this is already part of the exported HTML page. To understand practical use of the Engine class, see Custom HTML page for Web export.

load ( string basePath )

isWebGLAvailable ( [ number majorVersion=1 ] )

init ( [ string basePath ] )

preloadFile ( string|ArrayBuffer file [, string path ] )

start ( EngineConfig override )

startGame ( EngineConfig override )

copyToFS ( string path, ArrayBuffer buffer )

Create a new Engine instance with the given configuration.

initConfig (EngineConfig()) -- The initial config for this instance.

Load the engine from the specified base path.

basePath (string()) -- Base path of the engine to load.

A Promise that resolves once the engine is loaded.

Unload the engine to free memory.

This method will be called automatically depending on the configuration. See unloadAfterInit.

Check whether WebGL is available. Optionally, specify a particular version of WebGL to check for.

majorVersion (number()) -- The major WebGL version to check for.

If the given major version of WebGL is available.

Initialize the engine instance. Optionally, pass the base path to the engine to load it, if it hasn't been loaded yet. See Engine.load().

basePath (string()) -- Base path of the engine to load.

A Promise that resolves once the engine is loaded and initialized.

Load a file so it is available in the instance's file system once it runs. Must be called before starting the instance.

If not provided, the path is derived from the URL of the loaded file.

file (string|ArrayBuffer()) -- The file to preload. If a string the file will be loaded from that path. If an ArrayBuffer or a view on one, the buffer will used as the content of the file.

If a string the file will be loaded from that path.

If an ArrayBuffer or a view on one, the buffer will used as the content of the file.

path (string()) -- Path by which the file will be accessible. Required, if file is not a string.

A Promise that resolves once the file is loaded.

Start the engine instance using the given override configuration (if any). startGame can be used in typical cases instead.

This will initialize the instance if it is not initialized. For manual initialization, see init. The engine must be loaded beforehand.

Fails if a canvas cannot be found on the page, or not specified in the configuration.

override (EngineConfig()) -- An optional configuration override.

Promise that resolves once the engine started.

Start the game instance using the given configuration override (if any).

This will initialize the instance if it is not initialized. For manual initialization, see init.

This will load the engine if it is not loaded, and preload the main pck.

This method expects the initial config (or the override) to have both the executable and mainPack properties set (normally done by the editor during export).

override (EngineConfig()) -- An optional configuration override.

Promise that resolves once the game started.

Create a file at the specified path with the passed as buffer in the instance's file system.

path (string()) -- The location where the file will be created.

buffer (ArrayBuffer()) -- The content of the file.

Request that the current instance quit.

This is akin the user pressing the close button in the window manager, and will have no effect if the engine has crashed, or is stuck in a loop.

An object used to configure the Engine instance based on godot export options, and to override those in custom HTML templates if needed.

The Engine configuration object. This is just a typedef, create it like a regular object, e.g.:

const MyConfig = { executable: 'godot', unloadAfterInit: false }

Property Descriptions

Whether the unload the engine automatically after the instance is initialized.

The HTML DOM Canvas object to use.

By default, the first canvas element in the document will be used is none is specified.

The name of the WASM file without the extension. (Set by Godot Editor export process).

An alternative name for the game pck to load. The executable name is used otherwise.

Specify a language code to select the proper localization for the game.

The browser locale will be used if none is specified. See complete list of supported locales.

The canvas resize policy determines how the canvas should be resized by Godot.

0 means Godot won't do any resizing. This is useful if you want to control the canvas size from javascript code in your template.

1 means Godot will resize the canvas on start, and when changing window size via engine functions.

2 means Godot will adapt the canvas size to match the whole browser window.

The arguments to be passed as command line arguments on startup.

See command line tutorial.

Note: startGame will always add the --main-pack argument.

A callback function for handling Godot's OS.execute calls.

This is for example used in the Web Editor template to switch between Project Manager and editor, and for running the game.

path (string()) -- The path that Godot's wants executed.

args (Array.) -- The arguments of the "command" to execute.

A callback function for being notified when the Godot instance quits.

Note: This function will not be called if the engine crashes or become unresponsive.

status_code (number()) -- The status code returned by Godot on exit.

A callback function for displaying download progress.

The function is called once per frame while downloading files, so the usage of requestAnimationFrame() is not necessary.

If the callback function receives a total amount of bytes as 0, this means that it is impossible to calculate. Possible reasons include:

Files are delivered with server-side chunked compression

Files are delivered with server-side compression on Chromium

Not all file downloads have started yet (usually on servers without multi-threading)

current (number()) -- The current amount of downloaded bytes so far.

total (number()) -- The total amount of bytes to be downloaded.

A callback function for handling the standard output stream. This method should usually only be used in debug pages.

By default, console.log() is used.

var_args (*()) -- A variadic number of arguments to be printed.

A callback function for handling the standard error stream. This method should usually only be used in debug pages.

By default, console.error() is used.

var_args (*()) -- A variadic number of arguments to be printed as errors.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## HTTP client class — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/networking/http_client_class.html

**Contents:**
- HTTP client class
- User-contributed notes

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

HTTPClient provides low-level access to HTTP communication. For a higher-level interface, you may want to take a look at HTTPRequest first, which has a tutorial available here.

When exporting to Android, make sure to enable the INTERNET permission in the Android export preset before exporting the project or using one-click deploy. Otherwise, network communication of any kind will be blocked by Android.

Here's an example of using the HTTPClient class. It's just a script, so it can be run by executing:

It will connect and fetch a website.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
c:\godot> godot -s http_test.gd
```

Example 2 (unknown):
```unknown
c:\godot> godot -s HTTPTest.cs
```

Example 3 (gdscript):
```gdscript
extends SceneTree

# HTTPClient demo
# This simple class can do HTTP requests; it will not block, but it needs to be polled.

func _init():
    var err = 0
    var http = HTTPClient.new() # Create the Client.

    err = http.connect_to_host("www.php.net", 80) # Connect to host/port.
    assert(err == OK) # Make sure connection is OK.

    # Wait until resolved and connected.
    while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
        http.poll()
        print("Connecting...")
        await get_tree().process_frame

    assert(http.get_status() == HTTPClient.STATUS_CONNECTED) # Check if the connection was made successfully.

    # Some headers
    var headers = [
        "User-Agent: Pirulo/1.0 (Godot)",
        "Accept: */*"
    ]

    err = http.request(HTTPClient.METHOD_GET, "/ChangeLog-5.php", headers) # Request a page from the site (this one was chunked..)
    assert(err == OK) # Make sure all is OK.

    while http.get_status() == HTTPClient.STATUS_REQUESTING:
        # Keep polling for as long as the request is being processed.
        http.poll()
        print("Requesting...")
        await get_tree().process_frame

    assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED) # Make sure request finished well.

    print("response? ", http.has_response()) # Site might not have a response.

    if http.has_response():
        # If there is a response...

        headers = http.get_response_headers_as_dictionary() # Get response headers.
        print("code: ", http.get_response_code()) # Show response code.
        print("**headers:\\n", headers) # Show headers.

        # Getting the HTTP Body

        if http.is_response_chunked():
            # Does it use chunks?
            print("Response is Chunked!")
        else:
            # Or just plain Content-Length
            var bl = http.get_response_body_length()
            print("Response Length: ", bl)

        # This method works for both anyway

        var rb = PackedByteArray() # Array that will hold the data.

        while http.get_status() == HTTPClient.STATUS_BODY:
            # While there is body left to be read
            http.poll()
            # Get a chunk.
            var chunk = http.read_response_body_chunk()
            if chunk.size() == 0:
                await get_tree().process_frame
            else:
                rb = rb + chunk # Append to read buffer.
        # Done!

        print("bytes got: ", rb.size())
        var text = rb.get_string_from_ascii()
        print("Text: ", text)

    quit()
```

Example 4 (unknown):
```unknown
using Godot;

public partial class HTTPTest : SceneTree
{
    // HTTPClient demo.
    // This simple class can make HTTP requests; it will not block, but it needs to be polled.
    public override async void _Initialize()
    {
        Error err;
        HTTPClient http = new HTTPClient(); // Create the client.

        err = http.ConnectToHost("www.php.net", 80); // Connect to host/port.
        Debug.Assert(err == Error.Ok); // Make sure the connection is OK.

        // Wait until resolved and connected.
        while (http.GetStatus() == HTTPClient.Status.Connecting || http.GetStatus() == HTTPClient.Status.Resolving)
        {
            http.Poll();
            GD.Print("Connecting...");
            OS.DelayMsec(500);
        }

        Debug.Assert(http.GetStatus() == HTTPClient.Status.Connected); // Check if the connection was made successfully.

        // Some headers.
        string[] headers =
        [
            "User-Agent: Pirulo/1.0 (Godot)",
            "Accept: */*",
        ];

        err = http.Request(HTTPClient.Method.Get, "/ChangeLog-5.php", headers); // Request a page from the site.
        Debug.Assert(err == Error.Ok); // Make sure all is OK.

        // Keep polling for as long as the request is being processed.
        while (http.GetStatus() == HTTPClient.Status.Requesting)
        {
            http.Poll();
            GD.Print("Requesting...");
            if (OS.HasFeature("web"))
            {
                // Synchronous HTTP requests are not supported on the web,
                // so wait for the next main loop iteration.
                await ToSignal(Engine.GetMainLoop(), "idle_frame");
            }
            else
            {
                OS.DelayMsec(500);
            }
        }

        Debug.Assert(http.GetStatus() == HTTPClient.Status.Body || http.GetStatus() == HTTPClient.Status.Connected); // Make sure the request finished well.

        GD.Print("Response? ", http.HasResponse()); // The site might not have a response.

        // If there is a response...
        if (http.HasResponse())
        {
            headers = http.GetResponseHeaders(); // Get response headers.
            GD.Print("Code: ", http.GetResponseCode()); // Show response code.
            GD.Print("Headers:");
            foreach (string header in headers)
            {
                // Show headers.
                GD.Print(header);
            }

            if (http.IsResponseChunked())
            {
                // Does it use chunks?
                GD.Print("Response is Chunked!");
            }
            else
            {
                // Or just Content-Length.
                GD.Print("Response Length: ", http.GetResponseBodyLength());
            }

            // This method works for both anyways.
            List<byte> rb = new List<byte>(); // List that will hold the data.

            // While there is data left to be read...
            while (http.GetStatus() == HTTPClient.Status.Body)
            {
                http.Poll();
                byte[] chunk = http.ReadResponseBodyChunk(); // Read a chunk.
                if (chunk.Length == 0)
                {
                    // If nothing was read, wait for the buffer to fill.
                    OS.DelayMsec(500);
                }
                else
                {
                    // Append the chunk to the read buffer.
                    rb.AddRange(chunk);
                }
            }

            // Done!
            GD.Print("Bytes Downloaded: ", rb.Count);
            string text = Encoding.ASCII.GetString(rb.ToArray());
            GD.Print(text);
        }
        Quit();
    }
}
```

---

## Inheritance class tree — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/inheritance_class_tree.html

**Contents:**
- Inheritance class tree
- Object
- Reference
- Control
- Node2D
- Node3D
- User-contributed notes

Source files: class_tree.zip.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Integrating with Android APIs — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/platform/android/javaclasswrapper_and_androidruntimeplugin.html

**Contents:**
- Integrating with Android APIs
- JavaClassWrapper (Godot singleton)
- AndroidRuntime plugin
  - Example: Show an Android toast
  - Example: Vibrate the device
  - Example: Accessing inner classes
  - Example: Calling a constructor
- User-contributed notes

The Android platform has numerous APIs as well as a rich ecosystem of third-party libraries with wide and diverse functionality, like push notifications, analytics, authentication, ads, etc...

These don't make sense in Godot core itself so Godot has long provided an Android plugin system. The Android plugin system enables developers to create Godot Android plugins using Java or Kotlin code, which provides an interface to access and use Android APIs or third-party libraries in Godot projects from GDScript, C# or GDExtension.

Writing an Android plugin however requires knowledge of Java or Kotlin code, which most Godot developers do not have. As such there are many Android APIs and third-party libraries that don't have a Godot plugin that developers can interface with. In fact, this is one of the main reasons that developers cite for not being able to switch to Godot from other game engines.

To address this, we've introduced a couple of tools in Godot 4.4 to simplify the process for developers to access Android APIs and third-party libraries.

JavaClassWrapper is a Godot singleton which allows creating instances of Java / Kotlin classes and calling methods on them using only GDScript, C# or GDExtension.

In the code snippet above, JavaClassWrapper is used from GDScript to access the Java LocalDateTime and DateTimeFormatter classes. Through JavaClassWrapper, we can call the Java classes methods directly from GDScript as if they were GDScript methods.

JavaClassWrapper is great, but to do many things on Android, you need access to various Android lifecycle / runtime objects. AndroidRuntime plugin is a built-in Godot Android plugin that allows you to do this.

Combining JavaClassWrapper and AndroidRuntime plugin allows developers to access and use Android APIs without switching away from GDScript, or using any tools aside from Godot itself. This is huge for the adoption of Godot for Android development:

If you need to do something simple, or only use a small part of a third-party library, you don't have to make a plugin

It allows developers to quickly integrate Android functionality

It allows developers to create Godot addons using only GDScript and JavaClassWrapper (no Java or Kotlin needed)

For exports using gradle, Godot will automatically include .jar or .aar files it find in the project addons directory. So to use a third-party library, you can just drop its .jar or .aar file in the addons directory, and call its method directly from GDScript using JavaClassWrapper.

Java inner classes can be accessed using the $ sign:

A constructor is invoked by calling a method with the same name as the class.

This example creates an intent to send a text:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
class MyAndroidSingleton(godot: Godot?) : GodotPlugin(godot) {
        @UsedByGodot
        fun doSomething(value: String) {
                // ...
        }
}
```

Example 2 (unknown):
```unknown
var LocalDateTime = JavaClassWrapper.wrap("java.time.LocalDateTime")
var DateTimeFormatter = JavaClassWrapper.wrap("java.time.format.DateTimeFormatter")

var datetime = LocalDateTime.now()
var formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss")

print(datetime.format(formatter))
```

Example 3 (unknown):
```unknown
# Retrieve the AndroidRuntime singleton.
var android_runtime = Engine.get_singleton("AndroidRuntime")
if android_runtime:
    # Retrieve the Android Activity instance.
    var activity = android_runtime.getActivity()

    # Create a Godot Callable to wrap the toast display logic.
    var toast_callable = func():
        # Use JavaClassWrapper to retrieve the android.widget.Toast class, then make and show a toast using the class APIs.
        var ToastClass = JavaClassWrapper.wrap("android.widget.Toast")
        ToastClass.makeText(activity, "This is a test", ToastClass.LENGTH_LONG).show()

    # Wrap the Callable in a Java Runnable and run it on the Android UI thread to show the toast.
    activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(toast_callable))
```

Example 4 (unknown):
```unknown
# Retrieve the AndroidRuntime singleton.
var android_runtime = Engine.get_singleton("AndroidRuntime")
if android_runtime:
    # Retrieve the Android Vibrator system service and check if the device supports it.
    var vibrator_service = android_runtime.getApplicationContext().getSystemService("vibrator")
    if vibrator_service and vibrator_service.hasVibrator():
        # Configure and run a VibrationEffect.
        var VibrationEffect = JavaClassWrapper.wrap("android.os.VibrationEffect")
        var effect = VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE)
        vibrator_service.vibrate(effect)
```

---

## Logic preferences — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/best_practices/logic_preferences.html

**Contents:**
- Logic preferences
- Adding nodes and changing properties: which first?
- Loading vs. preloading
- Large levels: static vs. dynamic
- User-contributed notes

Ever wondered whether one should approach problem X with strategy Y or Z? This article covers a variety of topics related to these dilemmas.

When initializing nodes from a script at runtime, you may need to change properties such as the node's name or position. A common dilemma is, when should you change those values?

It is the best practice to change values on a node before adding it to the scene tree. Some property's setters have code to update other corresponding values, and that code can be slow! For most cases, this code has no impact on your game's performance, but in heavy use cases such as procedural generation, it can bring your game to a crawl.

For these reasons, it is usually best practice to set the initial values of a node before adding it to the scene tree. There are some exceptions where values can't be set before being added to the scene tree, like setting global position.

In GDScript, there exists the global preload method. It loads resources as early as possible to front-load the "loading" operations and avoid loading resources while in the middle of performance-sensitive code.

Its counterpart, the load method, loads a resource only when it reaches the load statement. That is, it will load a resource in-place which can cause slowdowns when it occurs in the middle of sensitive processes. The load() function is also an alias for ResourceLoader.load(path) which is accessible to all scripting languages.

So, when exactly does preloading occur versus loading, and when should one use either? Let's see an example:

Preloading allows the script to handle all the loading the moment one loads the script. Preloading is useful, but there are also times when one doesn't wish for it. To distinguish these situations, there are a few things one can consider:

If one cannot determine when the script might load, then preloading a resource, especially a scene or script, could result in further loads one does not expect. This could lead to unintentional, variable-length load times on top of the original script's load operations.

If something else could replace the value (like a scene's exported initialization), then preloading the value has no meaning. This point isn't a significant factor if one intends to always create the script on its own.

If one wishes only to 'import' another class resource (script or scene), then using a preloaded constant is often the best course of action. However, in exceptional cases, one may wish not to do this:

If the 'imported' class is liable to change, then it should be a property instead, initialized either using an @export or a load() (and perhaps not even initialized until later).

If the script requires a great many dependencies, and one does not wish to consume so much memory, then one may wish to, load and unload various dependencies at runtime as circumstances change. If one preloads resources into constants, then the only way to unload these resources would be to unload the entire script. If they are instead loaded properties, then one can set them to null and remove all references to the resource entirely (which, as a RefCounted-extending type, will cause the resources to delete themselves from memory).

If one is creating a large level, which circumstances are most appropriate? Should they create the level as one static space? Or should they load the level in pieces and shift the world's content as needed?

Well, the simple answer is, "when the performance requires it." The dilemma associated with the two options is one of the age-old programming choices: does one optimize memory over speed, or vice versa?

The naive answer is to use a static level that loads everything at once. But, depending on the project, this could consume a large amount of memory. Wasting users' RAM leads to programs running slow or outright crashing from everything else the computer tries to do at the same time.

No matter what, one should break larger scenes into smaller ones (to aid in reusability of assets). Developers can then design a node that manages the creation/loading and deletion/unloading of resources and nodes in real-time. Games with large and varied environments or procedurally generated elements often implement these strategies to avoid wasting memory.

On the flip side, coding a dynamic system is more complex, i.e. uses more programmed logic, which results in opportunities for errors and bugs. If one isn't careful, they can develop a system that bloats the technical debt of the application.

As such, the best options would be...

To use a static level for smaller games.

If one has the time/resources on a medium/large game, create a library or plugin that can code the management of nodes and resources. If refined over time, so as to improve usability and stability, then it could evolve into a reliable tool across projects.

Code the dynamic logic for a medium/large game because one has the coding skills, but not the time or resources to refine the code (game's gotta get done). Could potentially refactor later to outsource the code into a plugin.

For an example of the various ways one can swap scenes around at runtime, please see the "Change scenes manually" documentation.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (javascript):
```javascript
# my_buildings.gd
extends Node

# Note how constant scripts/scenes have a different naming scheme than
# their property variants.

# This value is a constant, so it spawns when the Script object loads.
# The script is preloading the value. The advantage here is that the editor
# can offer autocompletion since it must be a static path.
const BuildingScn = preload("res://building.tscn")

# 1. The script preloads the value, so it will load as a dependency
#    of the 'my_buildings.gd' script file. But, because this is a
#    property rather than a constant, the object won't copy the preloaded
#    PackedScene resource into the property until the script instantiates
#    with .new().
#
# 2. The preloaded value is inaccessible from the Script object alone. As
#    such, preloading the value here actually does not benefit anyone.
#
# 3. Because the user exports the value, if this script stored on
#    a node in a scene file, the scene instantiation code will overwrite the
#    preloaded initial value anyway (wasting it). It's usually better to
#    provide null, empty, or otherwise invalid default values for exports.
#
# 4. It is when one instantiates this script on its own with .new() that
#    one will load "office.tscn" rather than the exported value.
@export var a_building : PackedScene = preload("office.tscn")

# Uh oh! This results in an error!
# One must assign constant values to constants. Because `load` performs a
# runtime lookup by its very nature, one cannot use it to initialize a
# constant.
const OfficeScn = load("res://office.tscn")

# Successfully loads and only when one instantiates the script! Yay!
var office_scn = load("res://office.tscn")
```

Example 2 (unknown):
```unknown
using Godot;

// C# and other languages have no concept of "preloading".
public partial class MyBuildings : Node
{
    //This is a read-only field, it can only be assigned when it's declared or during a constructor.
    public readonly PackedScene Building = ResourceLoader.Load<PackedScene>("res://building.tscn");

    public PackedScene ABuilding;

    public override void _Ready()
    {
        // Can assign the value during initialization.
        ABuilding = GD.Load<PackedScene>("res://Office.tscn");
    }
}
```

Example 3 (javascript):
```javascript
using namespace godot;

class MyBuildings : public Node {
    GDCLASS(MyBuildings, Node)

public:
    const Ref<PackedScene> building = ResourceLoader::get_singleton()->load("res://building.tscn");
    Ref<PackedScene> a_building;

    virtual void _ready() override {
        // Can assign the value during initialization.
        a_building = ResourceLoader::get_singleton()->load("res://office.tscn");
    }
};
```

---

## Making HTTP requests — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html

**Contents:**
- Making HTTP requests
- Why use HTTP?
- HTTP requests in Godot
- Preparing the scene
- Scripting the request
- Sending data to the server
- Setting custom HTTP headers
- User-contributed notes

HTTP requests are useful to communicate with web servers and other non-Godot programs.

Compared to Godot's other networking features (like High-level multiplayer), HTTP requests have more overhead and take more time to get going, so they aren't suited for real-time communication, and aren't great to send lots of small updates as is common for multiplayer gameplay.

HTTP, however, offers interoperability with external web resources and is great at sending and receiving large amounts of data, for example to transfer files like game assets. These assets can then be loaded using runtime file loading and saving.

So HTTP may be useful for your game's login system, lobby browser, to retrieve some information from the web or to download game assets.

The HTTPRequest node is the easiest way to make HTTP requests in Godot. It is backed by the more low-level HTTPClient, for which a tutorial is available here.

For this example, we will make an HTTP request to GitHub to retrieve the name of the latest Godot release.

When exporting to Android, make sure to enable the Internet permission in the Android export preset before exporting the project or using one-click deploy. Otherwise, network communication of any kind will be blocked by the Android OS.

Create a new empty scene, add a root Node and add a script to it. Then add an HTTPRequest node as a child.

When the project is started (so in _ready()), we're going to send an HTTP request to Github using our HTTPRequest node, and once the request completes, we're going to parse the returned JSON data, look for the name field and print that to console.

Save the script and the scene, and run the project. The name of the most recent Godot release on Github should be printed to the output log. For more information on parsing JSON, see the class references for JSON.

Note that you may want to check whether the result equals RESULT_SUCCESS and whether a JSON parsing error occurred, see the JSON class reference and HTTPRequest for more.

You have to wait for a request to finish before sending another one. Making multiple request at once requires you to have one node per request. A common strategy is to create and delete HTTPRequest nodes at runtime as necessary.

Until now, we have limited ourselves to requesting data from a server. But what if you need to send data to the server? Here is a common way of doing it:

Of course, you can also set custom HTTP headers. These are given as a string array, with each string containing a header in the format "header: value". For example, to set a custom user agent (the HTTP User-Agent header) you could use the following:

Be aware that someone might analyse and decompile your released application and thus may gain access to any embedded authorization information like tokens, usernames or passwords. That means it is usually not a good idea to embed things such as database access credentials inside your game. Avoid providing information useful to an attacker whenever possible.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
extends Node

func _ready():
    $HTTPRequest.request_completed.connect(_on_request_completed)
    $HTTPRequest.request("https://api.github.com/repos/godotengine/godot/releases/latest")

func _on_request_completed(result, response_code, headers, body):
    var json = JSON.parse_string(body.get_string_from_utf8())
    print(json["name"])
```

Example 2 (csharp):
```csharp
using Godot;
using System.Text;

public partial class MyNode : Node
{
    public override void _Ready()
    {
        HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
        httpRequest.RequestCompleted += OnRequestCompleted;
        httpRequest.Request("https://api.github.com/repos/godotengine/godot/releases/latest");
    }

    private void OnRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
    {
        Godot.Collections.Dictionary json = Json.ParseString(Encoding.UTF8.GetString(body)).AsGodotDictionary();
        GD.Print(json["name"]);
    }
}
```

Example 3 (unknown):
```unknown
var json = JSON.stringify(data_to_send)
var headers = ["Content-Type: application/json"]
$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)
```

Example 4 (unknown):
```unknown
string json = Json.Stringify(dataToSend);
string[] headers = ["Content-Type: application/json"];
HttpRequest httpRequest = GetNode<HttpRequest>("HTTPRequest");
httpRequest.Request(url, headers, HttpClient.Method.Post, json);
```

---

## Object class — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/object_class.html

**Contents:**
- Object class
- General definition
  - References:
- Registering an Object
  - References:
- Constants
- Properties (set/get)
- Binding properties using _set/_get/_get_property_list
- Dynamic casting
- Signals

This page describes the C++ implementation of objects in Godot. Looking for the Object class reference? Have a look here.

Object is the base class for almost everything. Most classes in Godot inherit directly or indirectly from it. Objects provide reflection and editable properties, and declaring them is a matter of using a single macro like this:

This adds a lot of functionality to Objects. For example:

ClassDB is a static class that holds the entire list of registered classes that inherit from Object, as well as dynamic bindings to all their methods properties and integer constants.

Classes are registered by calling:

Registering it will allow the class to be instanced by scripts, code, or creating them again when deserializing.

Registering as virtual is the same but it can't be instanced.

Object-derived classes can override the static function static void _bind_methods(). When one class is registered, this static function is called to register all the object methods, properties, constants, etc. It's only called once. If an Object derived class is instanced but has not been registered, it will be registered as virtual automatically.

Inside _bind_methods, there are a couple of things that can be done. Registering functions is one:

Default values for arguments can be passed as parameters at the end:

Default values must be provided in the same order as they are declared, skipping required arguments and then providing default values for the optional ones. This matches the syntax for declaring methods in C++.

D_METHOD is a macro that converts "methodname" to a StringName for more efficiency. Argument names are used for introspection, but when compiling on release, the macro ignores them, so the strings are unused and optimized away.

Check _bind_methods of Control or Object for more examples.

If just adding modules and functionality that is not expected to be documented as thoroughly, the D_METHOD() macro can safely be ignored and a string passing the name can be passed for brevity.

core/object/class_db.h

Classes often have enums such as:

For these to work when binding to methods, the enum must be declared convertible to int. A macro is provided to help with this:

The constants can also be bound inside _bind_methods, by using:

Objects export properties, properties are useful for the following:

Serializing and deserializing the object.

Creating a list of editable values for the Object derived class.

Properties are usually defined by the PropertyInfo() class and constructed as:

This is an integer property named "amount". The hint is a range, and the range goes from 0 to 49 in steps of 1 (integers). It is only usable for the editor (editing the value visually) but won't be serialized.

This is a string property, can take any string but the editor will only allow the defined hint ones. Since no usage flags were specified, the default ones are PROPERTY_USAGE_STORAGE and PROPERTY_USAGE_EDITOR.

There are plenty of hints and usage flags available in object.h, give them a check.

Properties can also work like C# properties and be accessed from script using indexing, but this usage is generally discouraged, as using functions is preferred for legibility. Many properties are also bound with categories, such as "animation/frame" which also make indexing impossible unless using operator [].

From _bind_methods(), properties can be created and bound as long as set/get functions exist. Example:

This creates the property using the setter and the getter.

An additional method of creating properties exists when more flexibility is desired (i.e. adding or removing properties on context).

The following functions can be overridden in an Object derived class, they are NOT virtual, DO NOT make them virtual, they are called for every override and the previous ones are not invalidated (multilevel call).

This is also a little less efficient since p_property must be compared against the desired names in serial order.

Godot provides dynamic casting between Object-derived classes, for example:

If cast fails, NULL is returned. This system uses RTTI, but it also works fine (although a bit slower) when RTTI is disabled. This is useful on platforms where a small binary size is ideal, such as HTML5 or consoles (with low memory footprint).

Objects can have a set of signals defined (similar to Delegates in other languages). This example shows how to connect to them:

The method _node_entered_tree must be registered to the class using ClassDB::bind_method (explained before).

Adding signals to a class is done in _bind_methods, using the ADD_SIGNAL macro, for example:

All objects in Godot have a _notification method that allows it to respond to engine level callbacks that may relate to it. More information can be found on the Godot notifications page.

RefCounted inherits from Object and holds a reference count. It is the base for reference counted object types. Declaring them must be done using Ref<> template. For example:

myref is reference counted. It will be freed when no more Ref<> templates point to it.

core/object/reference.h

Resource inherits from RefCounted, so all resources are reference counted. Resources can optionally contain a path, which reference a file on disk. This can be set with resource.set_path(path), though this is normally done by the resource loader. No two different resources can have the same path; attempting to do so will result in an error.

Resources without a path are fine too.

Resources can be loaded with the ResourceLoader API, like this:

If a reference to that resource has been loaded previously and is in memory, the resource loader will return that reference. This means that there can be only one resource loaded from a file referenced on disk at the same time.

resourceinteractiveloader (TODO)

core/io/resource_loader.h

Saving a resource can be done with the resource saver API:

The instance will be saved, and sub resources that have a path to a file will be saved as a reference to that resource. Sub resources without a path will be bundled with the saved resource and assigned sub-IDs, like res://someresource.res::1. This also helps to cache them when loaded.

core/io/resource_saver.h

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
class CustomObject : public Object {

    GDCLASS(CustomObject, Object); // this is required to inherit
};
```

Example 2 (unknown):
```unknown
obj = memnew(CustomObject);
print_line("Object class: ", obj->get_class()); // print object class

obj2 = Object::cast_to<OtherClass>(obj); // converting between classes, this also works without RTTI enabled.
```

Example 3 (unknown):
```unknown
ClassDB::register_class<MyCustomClass>()
```

Example 4 (unknown):
```unknown
ClassDB::register_virtual_class<MyCustomClass>()
```

---

## Thread-safe APIs — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/performance/thread_safe_apis.html

**Contents:**
- Thread-safe APIs
- Threads
- Global scope
- Scene tree
- Rendering
- GDScript arrays, dictionaries
- Resources
- User-contributed notes

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

Threads are used to balance processing power across CPUs and cores. Godot supports multithreading, but not in the whole engine.

Below is a list of ways multithreading can be used in different areas of Godot.

Global Scope singletons are all thread-safe. Accessing servers from threads is supported (for RenderingServer and Physics servers, ensure threaded or thread-safe operation is enabled in the project settings!).

This makes them ideal for code that creates dozens of thousands of instances in servers and controls them from threads. Of course, it requires a bit more code, as this is used directly and not within the scene tree.

Interacting with the active scene tree is NOT thread-safe. Make sure to use mutexes when sending data between threads. If you want to call functions from a thread, the call_deferred function may be used:

However, creating scene chunks (nodes in tree arrangement) outside the active tree is fine. This way, parts of a scene can be built or instantiated in a thread, then added in the main thread:

Still, this is only really useful if you have one thread loading data. Attempting to load or create scene chunks from multiple threads may work, but you risk resources (which are only loaded once in Godot) tweaked by the multiple threads, resulting in unexpected behaviors or crashes.

Only use more than one thread to generate scene data if you really know what you are doing and you are sure that a single resource is not being used or set in multiple ones. Otherwise, you are safer just using the servers API (which is fully thread-safe) directly and not touching scene or resources.

Instancing nodes that render anything in 2D or 3D (such as Sprite) is not thread-safe by default. To make rendering thread-safe, set the Rendering > Driver > Thread Model project setting to Multi-Threaded.

Note that the Multi-Threaded thread model has several known bugs, so it may not be usable in all scenarios.

You should avoid calling functions involving direct interaction with the GPU on other threads, such as creating new textures or modifying and retrieving image data, these operations can lead to performance stalls because they require synchronization with the RenderingServer, as data needs to be transmitted to or updated on the GPU.

In GDScript, reading and writing elements from multiple threads is OK, but anything that changes the container size (resizing, adding or removing elements) requires locking a mutex.

Modifying a unique resource from multiple threads is not supported. However handling references on multiple threads is supported, hence loading resources on a thread is as well - scenes, textures, meshes, etc - can be loaded and manipulated on a thread and then added to the active scene on the main thread. The limitation here is as described above, one must be careful not to load the same resource from multiple threads at once, therefore it is easiest to use one thread for loading and modifying resources, and then the main thread for adding them.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
# Unsafe:
node.add_child(child_node)
# Safe:
node.add_child.call_deferred(child_node)
```

Example 2 (unknown):
```unknown
// Unsafe:
node.AddChild(childNode);
// Safe:
node.CallDeferred(Node.MethodName.AddChild, childNode);
```

Example 3 (unknown):
```unknown
var enemy_scene = load("res://enemy_scene.scn")
var enemy = enemy_scene.instantiate()
enemy.add_child(weapon) # Set a weapon.
world.add_child.call_deferred(enemy)
```

Example 4 (unknown):
```unknown
PackedScene enemyScene = GD.Load<PackedScene>("res://EnemyScene.scn");
Node enemy = enemyScene.Instantiate<Node>();
enemy.AddChild(weapon);
world.CallDeferred(Node.MethodName.AddChild, enemy);
```

---

## Using multiple threads — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/performance/using_multiple_threads.html

**Contents:**
- Using multiple threads
- Threads
- Creating a Thread
- Mutexes
- Semaphores
- User-contributed notes

Threads allow simultaneous execution of code. It allows off-loading work from the main thread.

Godot supports threads and provides many handy functions to use them.

If using other languages (C#, C++), it may be easier to use the threading classes they support.

Before using a built-in class in a thread, read Thread-safe APIs first to check whether it can be safely used in a thread.

To create a thread, use the following code:

Your function will, then, run in a separate thread until it returns. Even if the function has returned already, the thread must collect it, so call Thread.wait_to_finish(), which will wait until the thread is done (if not done yet), then properly dispose of it.

Creating threads is a slow operation, especially on Windows. To avoid unnecessary performance overhead, make sure to create threads before heavy processing is needed instead of creating threads just-in-time.

For example, if you need multiple threads during gameplay, you can create threads while the level is loading and only actually start processing with them later on.

Additionally, locking and unlocking of mutexes can also be an expensive operation. Locking should be done carefully; avoid locking too often (or for too long).

Accessing objects or data from multiple threads is not always supported (if you do it, it will cause unexpected behaviors or crashes). Read the Thread-safe APIs documentation to understand which engine APIs support multiple thread access.

When processing your own data or calling your own functions, as a rule, try to avoid accessing the same data directly from different threads. You may run into synchronization problems, as the data is not always updated between CPU cores when modified. Always use a Mutex when accessing a piece of data from different threads.

When calling Mutex.lock(), a thread ensures that all other threads will be blocked (put on suspended state) if they try to lock the same mutex. When the mutex is unlocked by calling Mutex.unlock(), the other threads will be allowed to proceed with the lock (but only one at a time).

Here is an example of using a Mutex:

Sometimes you want your thread to work "on demand". In other words, tell it when to work and let it suspend when it isn't doing anything. For this, Semaphores are used. The function Semaphore.wait() is used in the thread to suspend it until some data arrives.

The main thread, instead, uses Semaphore.post() to signal that data is ready to be processed:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
var thread: Thread

# The thread will start here.
func _ready():
    thread = Thread.new()
    # You can bind multiple arguments to a function Callable.
    thread.start(_thread_function.bind("Wafflecopter"))


# Run here and exit.
# The argument is the bound data passed from start().
func _thread_function(userdata):
    # Print the userdata ("Wafflecopter")
    print("I'm a thread! Userdata is: ", userdata)


# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
    thread.wait_to_finish()
```

Example 2 (cpp):
```cpp
#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/thread.hpp>

namespace godot {
    class MultithreadingDemo : public Node {
        GDCLASS(MultithreadingDemo, Node);

    private:
        Ref<Thread> worker;

    protected:
        static void _bind_methods();
        void _notification(int p_what);

    public:
        MultithreadingDemo();
        ~MultithreadingDemo();

        void demo_threaded_function();
    };
} // namespace godot
```

Example 3 (cpp):
```cpp
#include "multithreading_demo.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void MultithreadingDemo::_bind_methods() {
    ClassDB::bind_method(D_METHOD("threaded_function"), &MultithreadingDemo::demo_threaded_function);
}

void MultithreadingDemo::_notification(int p_what) {
    // Prevents this from running in the editor, only during game mode. In Godot 4.3+ use Runtime classes.
    if (Engine::get_singleton()->is_editor_hint()) {
        return;
    }

    switch (p_what) {
        case NOTIFICATION_READY: {
            worker.instantiate();
            worker->start(callable_mp(this, &MultithreadingDemo::demo_threaded_function), Thread::PRIORITY_NORMAL);
        } break;
        case NOTIFICATION_EXIT_TREE: { // Thread must be disposed (or "joined"), for portability.
            // Wait until it exits.
            if (worker.is_valid()) {
                worker->wait_to_finish();
            }

            worker.unref();
        } break;
    }
}

MultithreadingDemo::MultithreadingDemo() {
    // Initialize any variables here.
}

MultithreadingDemo::~MultithreadingDemo() {
    // Add your cleanup here.
}

void MultithreadingDemo::demo_threaded_function() {
    UtilityFunctions::print("demo_threaded_function started!");
    int i = 0;
    uint64_t start = Time::get_singleton()->get_ticks_msec();
    while (Time::get_singleton()->get_ticks_msec() - start < 5000) {
        OS::get_singleton()->delay_msec(10);
        i++;
    }

    UtilityFunctions::print("demo_threaded_function counted to: ", i, ".");
}
```

Example 4 (gdscript):
```gdscript
var counter := 0
var mutex: Mutex
var thread: Thread


# The thread will start here.
func _ready():
    mutex = Mutex.new()
    thread = Thread.new()
    thread.start(_thread_function)

    # Increase value, protect it with Mutex.
    mutex.lock()
    counter += 1
    mutex.unlock()


# Increment the value from the thread, too.
func _thread_function():
    mutex.lock()
    counter += 1
    mutex.unlock()


# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
    thread.wait_to_finish()
    print("Counter is: ", counter) # Should be 2.
```

---

## Variant class — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/engine_details/architecture/variant_class.html

**Contents:**
- Variant class
- About
  - References
- List of variant types
- Containers: Array and Dictionary
  - References
- User-contributed notes

Variant is the most important datatype in Godot. A Variant takes up only 24 bytes on 64-bit platforms (20 bytes on 32-bit platforms) and can store almost any engine datatype inside of it. Variants are rarely used to hold information for long periods of time, instead they are used mainly for communication, editing, serialization and generally moving data around.

Store almost any datatype.

Perform operations between many variants (GDScript uses Variant as its atomic/native datatype).

Be hashed, so it can be compared quickly to other variants.

Be used to convert safely between datatypes.

Be used to abstract calling methods and their arguments (Godot exports all its functions through variants).

Be used to defer calls or move data between threads.

Be serialized as binary and stored to disk, or transferred via network.

Be serialized to text and use it for printing values and editable settings.

Work as an exported property, so the editor can edit it universally.

Be used for dictionaries, arrays, parsers, etc.

Basically, thanks to the Variant class, writing Godot itself was a much, much easier task, as it allows for highly dynamic constructs not common of C++ with little effort. Become a friend of Variant today.

All types within Variant except Nil and Object cannot be null and must always store a valid value. These types within Variant are therefore called non-nullable types.

One of the Variant types is Nil which can only store the value null. Therefore, it is possible for a Variant to contain the value null, even though all Variant types excluding Nil and Object are non-nullable.

core/variant/variant.h

These types are available in Variant:

Nil (can only store null)

2D counterpart of AABB

3D counterpart of Rect2

Both Array and Dictionary are implemented using variants. A Dictionary can match any datatype used as key to any other datatype. An Array just holds an array of Variants. Of course, a Variant can also hold a Dictionary or an Array inside, making it even more flexible.

Modifications to a container will modify all references to it. A Mutex should be created to lock it if multi-threaded access is desired.

core/variant/dictionary.h

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---
