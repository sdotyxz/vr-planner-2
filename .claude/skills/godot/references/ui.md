# Godot - Ui

**Pages:** 35

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

## Autoloads versus regular nodes — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_internal_nodes.html

**Contents:**
- Autoloads versus regular nodes
- The cutting audio issue
- Managing shared functionality or data
- When you should use an Autoload
- User-contributed notes

Godot offers a feature to automatically load nodes at the root of your project, allowing you to access them globally, that can fulfill the role of a Singleton: Singletons (Autoload). These autoloaded nodes are not freed when you change the scene from code with SceneTree.change_scene_to_file.

In this guide, you will learn when to use the Autoload feature, and techniques you can use to avoid it.

Other engines can encourage the use of creating manager classes, singletons that organize a lot of functionality into a globally accessible object. Godot offers many ways to avoid global state thanks to the node tree and signals.

For example, let's say we are building a platformer and want to collect coins that play a sound effect. There's a node for that: the AudioStreamPlayer. But if we call the AudioStreamPlayer while it is already playing a sound, the new sound interrupts the first.

A solution is to code a global, autoloaded sound manager class. It generates a pool of AudioStreamPlayer nodes that cycle through as each new request for sound effects comes in. Say we call that class Sound, you can use it from anywhere in your project by calling Sound.play("coin_pickup.ogg"). This solves the problem in the short term but causes more problems:

Global state: one object is now responsible for all objects' data. If the Sound class has errors or doesn't have an AudioStreamPlayer available, all the nodes calling it can break.

Global access: now that any object can call Sound.play(sound_path) from anywhere, there's no longer an easy way to find the source of a bug.

Global resource allocation: with a pool of AudioStreamPlayer nodes stored from the start, you can either have too few and face bugs, or too many and use more memory than you need.

About global access, the problem is that any code anywhere could pass wrong data to the Sound autoload in our example. As a result, the domain to explore to fix the bug spans the entire project.

When you keep code inside a scene, only one or two scripts may be involved in audio.

Contrast this with each scene keeping as many AudioStreamPlayer nodes as it needs within itself and all these problems go away:

Each scene manages its own state information. If there is a problem with the data, it will only cause issues in that one scene.

Each scene accesses only its own nodes. Now, if there is a bug, it's easy to find which node is at fault.

Each scene allocates exactly the amount of resources it needs.

Another reason to use an Autoload can be that you want to reuse the same method or data across many scenes.

In the case of functions, you can create a new type of Node that provides that feature for an individual scene using the class_name keyword in GDScript.

When it comes to data, you can either:

Create a new type of Resource to share the data.

Store the data in an object to which each node has access, for example using the owner property to access the scene's root node.

GDScript supports the creation of static functions using static func. When combined with class_name, this makes it possible to create libraries of helper functions without having to create an instance to call them. The limitation of static functions is that they can't reference member variables, non-static functions or self.

Since Godot 4.1, GDScript also supports static variables using static var. This means you can now share variables across instances of a class without having to create a separate autoload.

Still, autoloaded nodes can simplify your code for systems with a wide scope. If the autoload is managing its own information and not invading the data of other objects, then it's a great way to create systems that handle broad-scoped tasks. For example, a quest or a dialogue system.

An autoload is not necessarily a singleton. Nothing prevents you from instantiating copies of an autoloaded node. An autoload is only a tool that makes a node load automatically as a child of the root of your scene tree, regardless of your game's node structure or which scene you run, e.g. by pressing the F6 key.

As a result, you can get the autoloaded node, for example an autoload called Sound, by calling get_node("/root/Sound").

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## BaseButton — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_basebutton.html

**Contents:**
- BaseButton
- Description
- Properties
- Methods
- Signals
- Enumerations
- Property Descriptions
- Method Descriptions
- User-contributed notes

Inherits: Control < CanvasItem < Node < Object

Inherited By: Button, LinkButton, TextureButton

Abstract base class for GUI buttons.

BaseButton is an abstract base class for GUI buttons. It doesn't display anything by itself.

BitField[MouseButtonMask]

2 (overrides Control)

_toggled(toggled_on: bool) virtual

get_draw_mode() const

set_pressed_no_signal(pressed: bool)

Emitted when the button starts being held down.

Emitted when the button stops being held down.

Emitted when the button is toggled or pressed. This is on button_down if action_mode is ACTION_MODE_BUTTON_PRESS and on button_up otherwise.

If you need to know the button's pressed state (and toggle_mode is active), use toggled instead.

toggled(toggled_on: bool) 🔗

Emitted when the button was just toggled between pressed and normal states (only if toggle_mode is active). The new state is contained in the toggled_on argument.

DrawMode DRAW_NORMAL = 0

The normal state (i.e. not pressed, not hovered, not toggled and enabled) of buttons.

DrawMode DRAW_PRESSED = 1

The state of buttons are pressed.

DrawMode DRAW_HOVER = 2

The state of buttons are hovered.

DrawMode DRAW_DISABLED = 3

The state of buttons are disabled.

DrawMode DRAW_HOVER_PRESSED = 4

The state of buttons are both hovered and pressed.

ActionMode ACTION_MODE_BUTTON_PRESS = 0

Require just a press to consider the button clicked.

ActionMode ACTION_MODE_BUTTON_RELEASE = 1

Require a press and a subsequent release before considering the button clicked.

ActionMode action_mode = 1 🔗

void set_action_mode(value: ActionMode)

ActionMode get_action_mode()

Determines when the button is considered clicked.

ButtonGroup button_group 🔗

void set_button_group(value: ButtonGroup)

ButtonGroup get_button_group()

The ButtonGroup associated with the button. Not to be confused with node groups.

Note: The button will be configured as a radio button if a ButtonGroup is assigned to it.

BitField[MouseButtonMask] button_mask = 1 🔗

void set_button_mask(value: BitField[MouseButtonMask])

BitField[MouseButtonMask] get_button_mask()

Binary mask to choose which mouse buttons this button will respond to.

To allow both left-click and right-click, use MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT.

bool button_pressed = false 🔗

void set_pressed(value: bool)

If true, the button's state is pressed. Means the button is pressed down or toggled (if toggle_mode is active). Only works if toggle_mode is true.

Note: Changing the value of button_pressed will result in toggled to be emitted. If you want to change the pressed state without emitting that signal, use set_pressed_no_signal().

bool disabled = false 🔗

void set_disabled(value: bool)

If true, the button is in disabled state and can't be clicked or toggled.

Note: If the button is disabled while held down, button_up will be emitted.

bool keep_pressed_outside = false 🔗

void set_keep_pressed_outside(value: bool)

bool is_keep_pressed_outside()

If true, the button stays pressed when moving the cursor outside the button while pressing it.

Note: This property only affects the button's visual appearance. Signals will be emitted at the same moment regardless of this property's value.

void set_shortcut(value: Shortcut)

Shortcut get_shortcut()

Shortcut associated to the button.

bool shortcut_feedback = true 🔗

void set_shortcut_feedback(value: bool)

bool is_shortcut_feedback()

If true, the button will highlight for a short amount of time when its shortcut is activated. If false and toggle_mode is false, the shortcut will activate without any visual feedback.

bool shortcut_in_tooltip = true 🔗

void set_shortcut_in_tooltip(value: bool)

bool is_shortcut_in_tooltip_enabled()

If true, the button will add information about its shortcut in the tooltip.

Note: This property does nothing when the tooltip control is customized using Control._make_custom_tooltip().

bool toggle_mode = false 🔗

void set_toggle_mode(value: bool)

bool is_toggle_mode()

If true, the button is in toggle mode. Makes the button flip state between pressed and unpressed each time its area is clicked.

void _pressed() virtual 🔗

Called when the button is pressed. If you need to know the button's pressed state (and toggle_mode is active), use _toggled() instead.

void _toggled(toggled_on: bool) virtual 🔗

Called when the button is toggled (only if toggle_mode is active).

DrawMode get_draw_mode() const 🔗

Returns the visual state used to draw the button. This is useful mainly when implementing your own draw code by either overriding _draw() or connecting to "draw" signal. The visual state of the button is defined by the DrawMode enum.

bool is_hovered() const 🔗

Returns true if the mouse has entered the button and has not left it yet.

void set_pressed_no_signal(pressed: bool) 🔗

Changes the button_pressed state of the button, without emitting toggled. Use when you just want to change the state of the button without sending the pressed event (e.g. when initializing scene). Only works if toggle_mode is true.

Note: This method doesn't unpress other buttons in button_group.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## BBCode in RichTextLabel — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html

**Contents:**
- BBCode in RichTextLabel
- Introduction
- Using BBCode
- Handling user input safely
- Stripping BBCode tags
- Performance
- Using push_[tag]() and pop() functions instead of BBCode
- Reference
  - Paragraph options
  - Handling [url] tag clicks

Label nodes are great for displaying basic text, but they have limitations. If you want to change the color of the text, or its alignment, you can only do that to the entire label. You can't make a part of the text have another color, or have a part of the text centered. To get around these limitations, you would use a RichTextLabel.

RichTextLabel allows for complex formatting of text using a markup syntax or the built-in API. It uses BBCodes for the markup syntax, a system of tags that designate formatting rules for a part of the text. You may be familiar with them if you ever used forums (also known as bulletin boards, hence the "BB" in "BBCode").

Unlike Label, RichTextLabel also comes with its own vertical scrollbar. This scrollbar is automatically displayed if the text does not fit within the control's size. The scrollbar can be disabled by unchecking the Scroll Active property in the RichTextLabel inspector.

Note that the BBCode tags can also be used to some extent for other use cases:

BBCode can be used to format comments in the XML source of the class reference.

BBCode can be used in GDScript documentation comments.

BBCode can be used when printing rich text to the Output bottom panel.

You can see how BBCode in RichTextLabel works in action using the Rich Text Label with BBCode demo project.

By default, RichTextLabel functions like a normal Label. It has the property_text property, which you can edit to have uniformly formatted text. To be able to use BBCode for rich text formatting, you need to turn on the BBCode mode by setting bbcode_enabled. After that, you can edit the text property using available tags. Both properties are located at the top of the inspector after selecting a RichTextLabel node.

For example, BBCode [color=green]test[/color] would render the word "test" with a green color.

Most BBCodes consist of 3 parts: the opening tag, the content and the closing tag. The opening tag delimits the start of the formatted part, and can also carry some configuration options. Some opening tags, like the color one shown above, also require a value to work. Other opening tags may accept multiple options (separated by spaces within the opening tag). The closing tag delimits the end of the formatted part. In some cases, both the closing tag and the content can be omitted.

Unlike BBCode in HTML, leading/trailing whitespace is not removed by a RichTextLabel upon display. Duplicate spaces are also displayed as-is in the final output. This means that when displaying a code block in a RichTextLabel, you don't need to use a preformatted text tag.

RichTextLabel doesn't support entangled BBCode tags. For example, instead of using:

In a scenario where users may freely input text (such as chat in a multiplayer game), you should make sure users cannot use arbitrary BBCode tags that will be parsed by RichTextLabel. This is to avoid inappropriate use of formatting, which can be problematic if [url] tags are handled by your RichTextLabel (as players may be able to create clickable links to phishing sites or similar).

Using RichTextLabel's [lb] and/or [rb] tags, we can replace the opening and/or closing brackets of any BBCode tag in a message with those escaped tags. This prevents users from using BBCode that will be parsed as tags – instead, the BBCode will be displayed as text.

Example of unescaped user input resulting in BBCode injection (2nd line) and escaped user input (3rd line)

The above image was created using the following script:

For certain use cases, it can be desired to remove BBCode tags from the string. This is useful when displaying the RichTextLabel's text in another Control that does not support BBCode (such as a tooltip):

Removing BBCode tags entirely isn't advised for user input, as it can modify the displayed text without users understanding why part of their message was removed. Escaping user input should be preferred instead.

In most cases, you can use BBCode directly as-is since text formatting is rarely a heavy task. However, with particularly large RichTextLabels (such as console logs spanning thousands of lines), you may encounter stuttering during gameplay when the RichTextLabel's text is updated.

There are several ways to alleviate this:

Use the append_text() function instead of appending to the text property. This function will only parse BBCode for the added text, rather than parsing BBCode from the entire text property.

Use push_[tag]() and pop() functions to add tags to RichTextLabel instead of using BBCode.

Enable the Threading > Threaded property in RichTextLabel. This won't speed up processing, but it will prevent the main thread from blocking, which avoids stuttering during gameplay. Only enable threading if it's actually needed in your project, as threading has some overhead.

If you don't want to use BBCode for performance reasons, you can use functions provided by RichTextLabel to create formatting tags without writing BBCode in the text.

Every BBCode tag (including effects) has a push_[tag]() function (where [tag] is the tag's name). There are also a few convenience functions available, such as push_bold_italics() that combines both push_bold() and push_italics() into a single tag. See the RichTextLabel class reference for a complete list of push_[tag]() functions.

The pop() function is used to end any tag. Since BBCode is a tag stack, using pop() will close the most recently started tags first.

The following script will result in the same visual output as using BBCode [color=green]test [i]example[/i][/color]:

Do not set the text property directly when using formatting functions. Appending to the text property will erase all modifications made to the RichTextLabel using the append_text(), push_[tag]() and pop() functions.

Some of these BBCode tags can be used in tooltips for @export script variables as well as in the XML source of the class reference. For more information, see Class reference BBCode.

[center]{text}[/center]

[right]{text}[/right]

[indent]{text}[/indent]

[font_size={size}]{text}[/font_size]

[dropcap font={font} font_size={size} color={color} outline_size={size} outline_color={color} margins={left},{top},{right},{bottom}]{text}[/dropcap]

[lang={code}]{text}[/lang]

[color={code/name}]{text}[/color]

[bgcolor={code/name}]{text}[/bgcolor]

[fgcolor={code/name}]{text}[/fgcolor]

[ol type={type}]{items}[/ol]

Tags for bold ([b]) and italics ([i]) formatting work best if the appropriate custom fonts are set up in the RichTextLabelNode's theme overrides. If no custom bold or italic fonts are defined, faux bold and italic fonts will be generated by Godot. These fonts rarely look good in comparison to hand-made bold/italic font variants.

The monospaced ([code]) tag only works if a custom font is set up in the RichTextLabel node's theme overrides. Otherwise, monospaced text will use the regular font.

There are no BBCode tags to control vertical centering of text yet.

Options can be skipped for all tags.

left (or l), center (or c), right (or r), fill (or f)

Text horizontal alignment.

default (of d), uri (or u), file (or f), email (or e), list (or l), none (or n), custom (or c)

Structured text override.

justification_flags, jst

Comma-separated list of the following values (no space after each comma): kashida (or k), word (or w), trim (or tr), after_last_tab (or lt), skip_last (or sl), skip_last_with_chars (or sv), do_not_skip_single (or ns).

word,kashida,skip_last,do_not_skip_single

Justification (fill alignment) option. See TextServer for more details.

ltr (or l), rtl (or r), auto (or a)

ISO language codes. See Locale codes

Locale override. Some font files may contain script-specific substitutes, in which case they will be used.

List of floating-point numbers, e.g. 10.0,30.0

Width of the space character in the font

Overrides the horizontal offsets for each tab character. When the end of the list is reached, the tab stops will loop over. For example, if you set tab_stops to 10.0,30.0, the first tab will be at 10 pixels, the second tab will be at 10 + 30 = 40 pixels, and the third tab will be at 10 + 30 + 10 = 50 pixels from the origin of the RichTextLabel.

By default, [url] tags do nothing when clicked. This is to allow flexible use of [url] tags rather than limiting them to opening URLs in a web browser.

To handle clicked [url] tags, connect the RichTextLabel node's meta_clicked signal to a script function.

For example, the following method can be connected to meta_clicked to open clicked URLs using the user's default web browser:

For more advanced use cases, it's also possible to store JSON in a [url] tag's option and parse it in the function that handles the meta_clicked signal. For example:

Color name or color in HEX format

Color tint of the rule (modulation).

Target height of the rule in pixels, add % to the end of value to specify it as percentages of the control width instead of pixels.

Target width of the rule in pixels, add % to the end of value to specify it as percentages of the control width instead of pixels.

left (or l), center (or c), right (or r)

Horizontal alignment.

Color name or color in HEX format

Color tint of the image (modulation).

Target height of the image in pixels, add % to the end of value to specify it as percentages of the control width instead of pixels.

Target width of the image in pixels, add % to the end of value to specify it as percentages of the control width instead of pixels.

x,y,width,height in pixels

Region rect of the image. This can be used to display a single image from a spritesheet.

If set to true, and the image is smaller than the size specified by width and height, the image padding is added to match the size instead of upscaling.

When a vertical alignment value is provided with the [img] or [table] tag the image/table will try to align itself against the surrounding text. Alignment is performed using a vertical point of the image and a vertical point of the text. There are 3 possible points on the image (top, center, and bottom) and 4 possible points on the text and table (top, center, baseline, and bottom), which can be used in any combination.

To specify both points, use their full or short names as a value of the image/table tag:

You can also specify just one value (top, center, or bottom) to make use of a corresponding preset (top-top, center-center, and bottom-bottom respectively).

Short names for the values are t (top), c (center), l (baseline), and b (bottom).

A valid Font resource path.

Extra spacing for each glyph.

Extra spacing for the space character.

Extra spacing at the top of the line.

Extra spacing at the bottom of the line.

Floating-point number.

Font embolden strength, if it is not equal to zero, emboldens the font outlines. Negative values reduce the outline thickness.

An active face index in the TrueType / OpenType collection.

Floating-point number.

Font slant strength, positive values slant glyphs to the right. Negative values to the left.

opentype_variation, otv

Comma-separated list of the OpenType variation tags (no space after each comma).

Font OpenType variation coordinates. See OpenType variation tags.

Note: The value should be enclosed in " to allow using = inside it:

opentype_features, otf

Comma-separated list of the OpenType feature tags (no space after each comma).

Font OpenType features. See OpenType features tags.

Note: The value should be enclosed in " to allow using = inside it:

For tags that allow specifying a color by name, you can use names of the constants from the built-in Color class. Named classes can be specified in a number of styles using different casings: DARK_RED, DarkRed, and darkred will give the same exact result.

See this image for a list of color constants:

For opaque RGB colors, any valid 6-digit hexadecimal code is supported, e.g. [color=#ffffff]white[/color]. Shorthand RGB color codes such as #6f2 (equivalent to #66ff22) are also supported.

For transparent RGB colors, any RGBA 8-digit hexadecimal code can be used, e.g. [color=#ffffff88]translucent white[/color]. Note that the alpha channel is the last component of the color code, not the first one. Short RGBA color codes such as #6f28 (equivalent to #66ff2288) are supported as well.

Cell expansion ratio. This defines which cells will try to expand to proportionally to other cells and their expansion ratios.

Color name or color in HEX format

Color name or color in HEX format

Cell background color. For alternating odd/even row backgrounds, you can use bg=odd_color,even_color.

4 comma-separated floating-point numbers (no space after each comma)

Left, top, right, and bottom cell padding.

By default, the [ul] tag uses the U+2022 "Bullet" Unicode glyph as the bullet character. This behavior is similar to web browsers. The bullet character can be customized using [ul bullet={bullet}]. If provided, this {bullet} parameter must be a string with no enclosing quotes (for example, [bullet=*]). You can add trailing spaces after the bullet character to increase the spacing between the bullet and the list item text.

See Bullet (typography) on Wikipedia for a list of common bullet characters that you can paste directly in the bullet parameter.

Ordered lists can be used to automatically mark items with numbers or letters in ascending order. This tag supports the following type options:

1 - Numbers, using language specific numbering system if possible.

a, A - Lower and upper case Latin letters.

i, I - Lower and upper case Roman numerals.

BBCode can also be used to create different text effects that can optionally be animated. Five customizable effects are provided out of the box, and you can easily create your own. By default, animated effects will pause when the SceneTree is paused. You can change this behavior by adjusting the RichTextLabel's Process > Mode property.

All examples below mention the default values for options in the listed tag format.

Text effects that move characters' positions may result in characters being clipped by the RichTextLabel node bounds.

You can resolve this by disabling Control > Layout > Clip Contents in the inspector after selecting the RichTextLabel node, or ensuring there is enough margin added around the text by using line breaks above and below the line using the effect.

Pulse creates an animated pulsing effect that multiplies each character's opacity and color. It can be used to bring attention to specific text. Its tag format is [pulse freq=1.0 color=#ffffff40 ease=-2.0]{text}[/pulse].

freq controls the frequency of the half-pulsing cycle (higher is faster). A full pulsing cycle takes 2 * (1.0 / freq) seconds. color is the target color multiplier for blinking. The default mostly fades out text, but not entirely. ease is the easing function exponent to use. Negative values provide in-out easing, which is why the default is -2.0.

Wave makes the text go up and down. Its tag format is [wave amp=50.0 freq=5.0 connected=1]{text}[/wave].

amp controls how high and low the effect goes, and freq controls how fast the text goes up and down. A freq value of 0 will result in no visible waves, and negative freq values won't display any waves either. If connected is 1 (default), glyphs with ligatures will be moved together. If connected is 0, each glyph is moved individually even if they are joined by ligatures. This can work around certain rendering issues with font ligatures.

Tornado makes the text move around in a circle. Its tag format is [tornado radius=10.0 freq=1.0 connected=1]{text}[/tornado].

radius is the radius of the circle that controls the offset, freq is how fast the text moves in a circle. A freq value of 0 will pause the animation, while negative freq will play the animation backwards. If connected is 1 (default), glyphs with ligatures will be moved together. If connected is 0, each glyph is moved individually even if they are joined by ligatures. This can work around certain rendering issues with font ligatures.

Shake makes the text shake. Its tag format is [shake rate=20.0 level=5 connected=1]{text}[/shake].

rate controls how fast the text shakes, level controls how far the text is offset from the origin. If connected is 1 (default), glyphs with ligatures will be moved together. If connected is 0, each glyph is moved individually even if they are joined by ligatures. This can work around certain rendering issues with font ligatures.

Fade creates a static fade effect that multiplies each character's opacity. Its tag format is [fade start=4 length=14]{text}[/fade].

start controls the starting position of the falloff relative to where the fade command is inserted, length controls over how many characters should the fade out take place.

Rainbow gives the text a rainbow color that changes over time. Its tag format is [rainbow freq=1.0 sat=0.8 val=0.8 speed=1.0]{text}[/rainbow].

freq determines how many letters the rainbow extends over before it repeats itself, sat is the saturation of the rainbow, val is the value of the rainbow. speed is the number of full rainbow cycles per second. A positive speed value will play the animation forwards, a value of 0 will pause the animation, and a negative speed value will play the animation backwards.

Font outlines are not affected by the rainbow effect (they keep their original color). Existing font colors are overridden by the rainbow effect. However, CanvasItem's Modulate and Self Modulate properties will affect how the rainbow effect looks, as modulation multiplies its final colors.

You can extend the RichTextEffect resource type to create your own custom BBCode tags. Create a new script file that extends the RichTextEffect resource type and give the script a class_name so that the effect can be selected in the inspector. Add the @tool annotation to your GDScript file if you wish to have these custom effects run within the editor itself. The RichTextLabel does not need to have a script attached, nor does it need to be running in tool mode. The new effect can be registered in the Inspector by adding it to the Markup > Custom Effects array, or in code with the install_effect() method:

Selecting a custom RichTextEffect after saving a script that extends RichTextEffect with a class_name

If the custom effect is not registered within the RichTextLabel's Markup > Custom Effects property, no effect will be visible and the original tag will be left as-is.

There is only one function that you need to extend: _process_custom_fx(char_fx). Optionally, you can also provide a custom BBCode identifier by adding a member name bbcode. The code will check the bbcode property automatically or will use the name of the file to determine what the BBCode tag should be.

This is where the logic of each effect takes place and is called once per glyph during the draw phase of text rendering. This passes in a CharFXTransform object, which holds a few variables to control how the associated glyph is rendered:

outline is true if effect is called for drawing text outline.

range tells you how far into a given custom effect block you are in as an index.

elapsed_time is the total amount of time the text effect has been running.

visible will tell you whether the glyph is visible or not and will also allow you to hide a given portion of text.

offset is an offset position relative to where the given glyph should render under normal circumstances.

color is the color of a given glyph.

glyph_index and font is glyph being drawn and font data resource used to draw it.

Finally, env is a Dictionary of parameters assigned to a given custom effect. You can use get() with an optional default value to retrieve each parameter, if specified by the user. For example [custom_fx spread=0.5 color=#FFFF00]test[/custom_fx] would have a float spread and Color color parameters in its env Dictionary. See below for more usage examples.

The last thing to note about this function is that it is necessary to return a boolean true value to verify that the effect processed correctly. This way, if there's a problem with rendering a given glyph, it will back out of rendering custom effects entirely until the user fixes whatever error cropped up in their custom effect logic.

Here are some examples of custom effects:

This will add a few new BBCode commands, which can be used like so:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
[tag]content[/tag]
[tag=value]content[/tag]
[tag option1=value1 option2=value2]content[/tag]
[tag][/tag]
[tag]
```

Example 2 (unknown):
```unknown
[b]bold[i]bold italic[/b]italic[/i]
```

Example 3 (unknown):
```unknown
[b]bold[i]bold italic[/i][/b][i]italic[/i]
```

Example 4 (unknown):
```unknown
extends RichTextLabel

func _ready():
    append_chat_line("Player 1", "Hello world!")
    append_chat_line("Player 2", "Hello [color=red]BBCode injection[/color] (no escaping)!")
    append_chat_line_escaped("Player 2", "Hello [color=red]BBCode injection[/color] (with escaping)!")


# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
    # We only need to replace opening brackets to prevent tags from being parsed.
    return bbcode_text.replace("[", "[lb]")


# Appends the user's message as-is, without escaping. This is dangerous!
func append_chat_line(username, message):
    append_text("%s: [color=green]%s[/color]\n" % [username, message])


# Appends the user's message with escaping.
# Remember to escape both the player name and message contents.
func append_chat_line_escaped(username, message):
    append_text("%s: [color=green]%s[/color]\n" % [escape_bbcode(username), escape_bbcode(message)])
```

---

## Built-in functions — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shader_functions.html

**Contents:**
- Built-in functions
- Trigonometric functions
  - Trigonometric function descriptions
- Exponential and math functions
  - Exponential and math function descriptions
- Geometric functions
  - Geometric function descriptions
- Comparison functions
  - Comparison function descriptions
- Texture functions

Godot supports a large number of built-in functions, conforming roughly to the GLSL ES 3.0 specification.

The following type aliases only used in documentation to reduce repetitive function declarations. They can each refer to any of several actual types.

glsl documentation alias

float, vec2, vec3, or vec4

int, ivec2, ivec3, or ivec4

uint, uvec2, uvec3, or uvec4

bool, bvec2, bvec3, or bvec4

vec4, ivec4, or uvec4

sampler2D, isampler2D, or uSampler2D

sampler2DArray, isampler2DArray, or uSampler2DArray

sampler3D, isampler3D, or uSampler3D

If any of these are specified for multiple parameters, they must all be the same type unless otherwise noted.

Many functions that accept one or more vectors or matrices perform the described function on each component of the vector/matrix. Some examples:

Equivalent Scalar Operation

vec2(sqrt(4), sqrt(64))

vec2(min(3, 1), min(4, 1))

min(vec3(1, 2, 3),vec3(5, 1, 3))

vec3(min(1, 5), min(2, 1), min(3, 3))

pow(vec3(3, 8, 5 ), 2)

vec3(pow(3, 2), pow(8, 2), pow(5, 2))

pow(vec3(3, 8, 5), vec3(1, 2, 4))

vec3(pow(3, 1), pow(8, 2), pow(5, 4))

The GLSL Language Specification says under section 5.10 Vector and Matrix Operations:

With a few exceptions, operations are component-wise. Usually, when an operator operates on a vector or matrix, it is operating independently on each component of the vector or matrix, in a component-wise fashion. [...] The exceptions are matrix multiplied by vector, vector multiplied by matrix, and matrix multiplied by matrix. These do not operate component-wise, but rather perform the correct linear algebraic multiply.

These function descriptions are adapted and modified from official OpenGL documentation originally published by Khronos Group under the Open Publication License. Each function description links to the corresponding official OpenGL documentation. Modification history for this page can be found on GitHub.

Description / Return value

radians(vec_type degrees)

Convert degrees to radians.

degrees(vec_type radians)

Convert radians to degrees.

Arc hyperbolic cosine.

Arc hyperbolic tangent.

vec_type radians(vec_type degrees) 🔗

Component-wise Function.

Converts a quantity specified in degrees into radians, with the formula degrees * (PI / 180).

The quantity, in degrees, to be converted to radians.

The input degrees converted to radians.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/radians.xhtml

vec_type degrees(vec_type radians) 🔗

Component-wise Function.

Converts a quantity specified in radians into degrees, with the formula radians * (180 / PI)

The quantity, in radians, to be converted to degrees.

The input radians converted to degrees.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/degrees.xhtml

vec_type sin(vec_type angle) 🔗

Component-wise Function.

Returns the trigonometric sine of angle.

The quantity, in radians, of which to return the sine.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sin.xhtml

vec_type cos(vec_type angle) 🔗

Component-wise Function.

Returns the trigonometric cosine of angle.

The quantity, in radians, of which to return the cosine.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cos.xhtml

vec_type tan(vec_type angle) 🔗

Component-wise Function.

Returns the trigonometric tangent of angle.

The quantity, in radians, of which to return the tangent.

The tangent of angle.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/tan.xhtml

vec_type asin(vec_type x) 🔗

Component-wise Function.

Arc sine, or inverse sine. Calculates the angle whose sine is x and is in the range [-PI/2, PI/2]. The result is undefined if x < -1 or x > 1.

The value whose arc sine to return.

The angle whose trigonometric sine is x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/asin.xhtml

vec_type acos(vec_type x) 🔗

Component-wise Function.

Arc cosine, or inverse cosine. Calculates the angle whose cosine is x and is in the range [0, PI].

The result is undefined if x < -1 or x > 1.

The value whose arc cosine to return.

The angle whose trigonometric cosine is x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/acos.xhtml

vec_type atan(vec_type y_over_x) 🔗

Component-wise Function.

Calculates the arc tangent given a tangent value of y/x.

Because of the sign ambiguity, the function cannot determine with certainty in which quadrant the angle falls only by its tangent value. If you need to know the quadrant, use atan(vec_type y, vec_type x).

The fraction whose arc tangent to return.

The trigonometric arc-tangent of y_over_x and is in the range [-PI/2, PI/2].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atan.xhtml

vec_type atan(vec_type y, vec_type x) 🔗

Component-wise Function.

Calculates the arc tangent given a numerator and denominator. The signs of y and x are used to determine the quadrant that the angle lies in. The result is undefined if x == 0.

Equivalent to atan2() in GDScript.

The numerator of the fraction whose arc tangent to return.

The denominator of the fraction whose arc tangent to return.

The trigonometric arc tangent of y/x and is in the range [-PI, PI].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atan.xhtml

vec_type sinh(vec_type x) 🔗

Component-wise Function.

Calculates the hyperbolic sine using (e^x - e^-x)/2.

The value whose hyperbolic sine to return.

The hyperbolic sine of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sinh.xhtml

vec_type cosh(vec_type x) 🔗

Component-wise Function.

Calculates the hyperbolic cosine using (e^x + e^-x)/2.

The value whose hyperbolic cosine to return.

The hyperbolic cosine of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cosh.xhtml

vec_type tanh(vec_type x) 🔗

Component-wise Function.

Calculates the hyperbolic tangent using sinh(x)/cosh(x).

The value whose hyperbolic tangent to return.

The hyperbolic tangent of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/tanh.xhtml

vec_type asinh(vec_type x) 🔗

Component-wise Function.

Calculates the arc hyperbolic sine of x, or the inverse of sinh.

The value whose arc hyperbolic sine to return.

The arc hyperbolic sine of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/asinh.xhtml

vec_type acosh(vec_type x) 🔗

Component-wise Function.

Calculates the arc hyperbolic cosine of x, or the non-negative inverse of cosh. The result is undefined if x < 1.

The value whose arc hyperbolic cosine to return.

The arc hyperbolic cosine of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/acosh.xhtml

vec_type atanh(vec_type x) 🔗

Component-wise Function.

Calculates the arc hyperbolic tangent of x, or the inverse of tanh. The result is undefined if abs(x) > 1.

The value whose arc hyperbolic tangent to return.

The arc hyperbolic tangent of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atanh.xhtml

Description / Return value

pow(vec_type x, vec_type y)

Power (undefined if x < 0 or if x == 0 and y <= 0).

Natural (base-e) logarithm.

inversesqrt(vec_type x)

Absolute value (returns positive value if negative).

Returns 1.0 if positive, -1.0 if negative, 0.0 otherwise.

Returns 1 if positive, -1 if negative, 0 otherwise.

Rounds to the integer below.

Rounds to the nearest integer.

roundEven(vec_type x)

Rounds to the nearest even integer.

Rounds to the integer above.

Fractional (returns x - floor(x)).

Modulo (division remainder).

modf(vec_type x, out vec_type i)

Fractional of x, with i as integer part.

Lowest value between a and b.

Highest value between a and b.

Clamps x between min and max (inclusive).

Linear interpolate between a and b by c.

fma(vec_type a, vec_type b, vec_type c)

Fused multiply-add operation: (a * b + c)

Hermite interpolate between a and b by c.

Returns true if scalar or vector component is NaN.

Returns true if scalar or vector component is INF.

floatBitsToInt(vec_type x)

float to int bit copying, no conversion.

floatBitsToUint(vec_type x)

float to uint bit copying, no conversion.

intBitsToFloat(vec_int_type x)

int to float bit copying, no conversion.

uintBitsToFloat(vec_uint_type x)

uint to float bit copying, no conversion.

vec_type pow(vec_type x, vec_type y) 🔗

Component-wise Function.

Raises x to the power of y.

The result is undefined if x < 0 or if x == 0 and y <= 0.

The value to be raised to the power y.

The power to which x will be raised.

The value of x raised to the y power.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/pow.xhtml

vec_type exp(vec_type x) 🔗

Component-wise Function.

Raises e to the power of x, or the the natural exponentiation.

Equivalent to pow(e, x).

The value to exponentiate.

The natural exponentiation of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/exp.xhtml

vec_type exp2(vec_type x) 🔗

Component-wise Function.

Raises 2 to the power of x.

Equivalent to pow(2.0, x).

The value of the power to which 2 will be raised.

2 raised to the power of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/exp2.xhtml

vec_type log(vec_type x) 🔗

Component-wise Function.

Returns the natural logarithm of x, i.e. the value y which satisfies x == pow(e, y). The result is undefined if x <= 0.

The value of which to take the natural logarithm.

The natural logarithm of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/log.xhtml

vec_type log2(vec_type x) 🔗

Component-wise Function.

Returns the base-2 logarithm of x, i.e. the value y which satisfies x == pow(2, y). The result is undefined if x <= 0.

The value of which to take the base-2 logarithm.

The base-2 logarithm of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/log2.xhtml

vec_type sqrt(vec_type x) 🔗

Component-wise Function.

Returns the square root of x. The result is undefined if x < 0.

The value of which to take the square root.

The square root of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sqrt.xhtml

vec_type inversesqrt(vec_type x) 🔗

Component-wise Function.

Returns the inverse of the square root of x, or 1.0 / sqrt(x). The result is undefined if x <= 0.

The value of which to take the inverse of the square root.

The inverse of the square root of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/inversesqrt.xhtml

vec_type abs(vec_type x) 🔗

vec_int_type abs(vec_int_type x) 🔗

Component-wise Function.

Returns the absolute value of x. Returns x if x is positive, otherwise returns -1 * x.

The value of which to return the absolute.

The absolute value of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/abs.xhtml

vec_type sign(vec_type x) 🔗

vec_int_type sign(vec_int_type x) 🔗

Component-wise Function.

Returns -1 if x < 0, 0 if x == 0, and 1 if x > 0.

The value from which to extract the sign.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sign.xhtml

vec_type floor(vec_type x) 🔗

Component-wise Function.

Returns a value equal to the nearest integer that is less than or equal to x.

The nearest integer that is less than or equal to x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floor.xhtml

vec_type round(vec_type x) 🔗

Component-wise Function.

Rounds x to the nearest integer.

Rounding of values with a fractional part of 0.5 is implementation-dependent. This includes the possibility that round(x) returns the same value as roundEven(x)``for all values of ``x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/round.xhtml

vec_type roundEven(vec_type x) 🔗

Component-wise Function.

Rounds x to the nearest integer. A value with a fractional part of 0.5 will always round toward the nearest even integer. For example, both 3.5 and 4.5 will round to 4.0.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/roundEven.xhtml

vec_type trunc(vec_type x) 🔗

Component-wise Function.

Truncates x. Returns a value equal to the nearest integer to x whose absolute value is not larger than the absolute value of x.

The value to evaluate.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/trunc.xhtml

vec_type ceil(vec_type x) 🔗

Component-wise Function.

Returns a value equal to the nearest integer that is greater than or equal to x.

The value to evaluate.

The ceiling-ed value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/ceil.xhtml

vec_type fract(vec_type x) 🔗

Component-wise Function.

Returns the fractional part of x.

This is calculated as x - floor(x).

The value to evaluate.

The fractional part of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fract.xhtml

vec_type mod(vec_type x, vec_type y) 🔗

vec_type mod(vec_type x, float y) 🔗

Component-wise Function.

Returns the value of x modulo y. This is also sometimes called the remainder.

This is computed as x - y * floor(x/y).

The value to evaluate.

The value of x modulo y.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mod.xhtml

vec_type modf(vec_type x, out vec_type i) 🔗

Component-wise Function.

Separates a floating-point value x into its integer and fractional parts.

The fractional part of the number is returned from the function. The integer part (as a floating-point quantity) is returned in the output parameter i.

The value to separate.

A variable that receives the integer part of x.

The fractional part of the number.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/modf.xhtml

vec_type min(vec_type a, vec_type b) 🔗

vec_type min(vec_type a, float b) 🔗

vec_int_type min(vec_int_type a, vec_int_type b) 🔗

vec_int_type min(vec_int_type a, int b) 🔗

vec_uint_type min(vec_uint_type a, vec_uint_type b) 🔗

vec_uint_type min(vec_uint_type a, uint b) 🔗

Component-wise Function.

Returns the minimum of two values a and b.

Returns b if b < a, otherwise returns a.

The first value to compare.

The second value to compare.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/min.xhtml

vec_type max(vec_type a, vec_type b) 🔗

vec_type max(vec_type a, float b) 🔗

vec_uint_type max(vec_uint_type a, vec_uint_type b) 🔗

vec_uint_type max(vec_uint_type a, uint b) 🔗

vec_int_type max(vec_int_type a, vec_int_type b) 🔗

vec_int_type max(vec_int_type a, int b) 🔗

Component-wise Function.

Returns the maximum of two values a and b.

It returns b if b > a, otherwise it returns a.

The first value to compare.

The second value to compare.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/max.xhtml

vec_type clamp(vec_type x, vec_type minVal, vec_type maxVal) 🔗

vec_type clamp(vec_type x, float minVal, float maxVal) 🔗

vec_int_type clamp(vec_int_type x, vec_int_type minVal, vec_int_type maxVal) 🔗

vec_int_type clamp(vec_int_type x, int minVal, int maxVal) 🔗

vec_uint_type clamp(vec_uint_type x, vec_uint_type minVal, vec_uint_type maxVal) 🔗

vec_uint_type clamp(vec_uint_type x, uint minVal, uint maxVal) 🔗

Component-wise Function.

Returns the value of x constrained to the range minVal to maxVal.

The returned value is computed as min(max(x, minVal), maxVal).

The value to constrain.

The lower end of the range into which to constrain x.

The upper end of the range into which to constrain x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/clamp.xhtml

vec_type mix(vec_type a, vec_type b, vec_type c) 🔗

vec_type mix(vec_type a, vec_type b, float c) 🔗

Component-wise Function.

Performs a linear interpolation between a and b using c to weight between them.

Computed as a * (1 - c) + b * c.

Equivalent to lerp() in GDScript.

The start of the range in which to interpolate.

The end of the range in which to interpolate.

The value to use to interpolate between a and b.

The interpolated value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mix.xhtml

vec_type mix(vec_type a, vec_type b, vec_bool_type c) 🔗

Selects either value a or value b based on the value of c. For a component of c that is false, the corresponding component of a is returned. For a component of c that is true, the corresponding component of b is returned. Components of a and b that are not selected are allowed to be invalid floating-point values and will have no effect on the results.

If a, b, and c are vector types the operation is performed component-wise. ie. mix(vec2(42, 314), vec2(9.8, 6e23), bvec2(true, false))) will return vec2(9.8, 314).

Value returned when c is false.

Value returned when c is true.

The value used to select between a and b.

The interpolated value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mix.xhtml

vec_type fma(vec_type a, vec_type b, vec_type c) 🔗

Component-wise Function.

Performs, where possible, a fused multiply-add operation, returning a * b + c. In use cases where the return value is eventually consumed by a variable declared as precise:

fma() is considered a single operation, whereas the expression a * b + c consumed by a variable declared as precise is considered two operations.

The precision of fma() can differ from the precision of the expression a * b + c.

fma() will be computed with the same precision as any other fma() consumed by a precise variable, giving invariant results for the same input values of a, b and c.

Otherwise, in the absence of precise consumption, there are no special constraints on the number of operations or difference in precision between fma() and the expression a * b + c.

The first value to be multiplied.

The second value to be multiplied.

The value to be added to the result.

The value of a * b + c.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fma.xhtml

vec_type step(vec_type a, vec_type b) 🔗

vec_type step(float a, vec_type b) 🔗

Component-wise Function.

Generates a step function by comparing b to a.

Equivalent to if (b < a) { return 0.0; } else { return 1.0; }. For element i of the return value, 0.0 is returned if b[i] < a[i], and 1.0 is returned otherwise.

The location of the edge of the step function.

The value to be used to generate the step function.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/step.xhtml

vec_type smoothstep(vec_type a, vec_type b, vec_type c) 🔗

vec_type smoothstep(float a, float b, vec_type c) 🔗

Component-wise Function.

Performs smooth Hermite interpolation between 0 and 1 when a < c < b. This is useful in cases where a threshold function with a smooth transition is desired.

Smoothstep is equivalent to:

Results are undefined if a >= b.

The value of the lower edge of the Hermite function.

The value of the upper edge of the Hermite function.

The source value for interpolation.

The interpolated value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/smoothstep.xhtml

vec_bool_type isnan(vec_type x) 🔗

Component-wise Function.

For each element i of the result, returns true if x[i] is positive or negative floating-point NaN (Not a Number) and false otherwise.

The value to test for NaN.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/isnan.xhtml

vec_bool_type isinf(vec_type x) 🔗

Component-wise Function.

For each element i of the result, returns true if x[i] is positive or negative floating-point infinity and false otherwise.

The value to test for infinity.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/isinf.xhtml

vec_int_type floatBitsToInt(vec_type x) 🔗

Component-wise Function.

Returns the encoding of the floating-point parameters as int.

The floating-point bit-level representation is preserved.

The value whose floating-point encoding to return.

The floating-point encoding of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floatBitsToInt.xhtml

vec_uint_type floatBitsToUint(vec_type x) 🔗

Component-wise Function.

Returns the encoding of the floating-point parameters as uint.

The floating-point bit-level representation is preserved.

The value whose floating-point encoding to return.

The floating-point encoding of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floatBitsToInt.xhtml

vec_type intBitsToFloat(vec_int_type x) 🔗

Component-wise Function.

Converts a bit encoding to a floating-point value. Opposite of floatBitsToInt<shader_func_floatBitsToInt>

If the encoding of a NaN is passed in x, it will not signal and the resulting value will be undefined.

If the encoding of a floating-point infinity is passed in parameter x, the resulting floating-point value is the corresponding (positive or negative) floating-point infinity.

The bit encoding to return as a floating-point value.

A floating-point value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/intBitsToFloat.xhtml

vec_type uintBitsToFloat(vec_uint_type x) 🔗

Component-wise Function.

Converts a bit encoding to a floating-point value. Opposite of floatBitsToUint<shader_func_floatBitsToUint>

If the encoding of a NaN is passed in x, it will not signal and the resulting value will be undefined.

If the encoding of a floating-point infinity is passed in parameter x, the resulting floating-point value is the corresponding (positive or negative) floating-point infinity.

The bit encoding to return as a floating-point value.

A floating-point value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/intBitsToFloat.xhtml

distance(vec_type a, vec_type b)

Distance between vectors i.e length(a - b).

dot(vec_type a, vec_type b)

cross(vec3 a, vec3 b)

normalize(vec_type x)

Normalize to unit length.

reflect(vec3 I, vec3 N)

refract(vec3 I, vec3 N, float eta)

faceforward(vec_type N, vec_type I, vec_type Nref)

If dot(Nref, I) < 0, return N, otherwise -N.

matrixCompMult(mat_type x, mat_type y)

Matrix component multiplication.

outerProduct(vec_type column, vec_type row)

Matrix outer product.

transpose(mat_type m)

determinant(mat_type m)

float length(vec_type x) 🔗

Returns the length of the vector. ie. sqrt(x[0] * x[0] + x[1] * x[1] + ... + x[n] * x[n])

The length of the vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/length.xhtml

float distance(vec_type a, vec_type b) 🔗

Returns the distance between the two points a and b.

The scalar distance between the points

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/distance.xhtml

float dot(vec_type a, vec_type b) 🔗

Returns the dot product of two vectors, a and b. i.e., a.x * b.x + a.y * b.y + ...

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/dot.xhtml

vec3 cross(vec3 a, vec3 b) 🔗

Returns the cross product of two vectors. i.e.:

The cross product of a and b.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cross.xhtml

vec_type normalize(vec_type x) 🔗

Returns a vector with the same direction as x but with length 1.0.

The vector to normalize.

The normalized vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/normalize.xhtml

vec3 reflect(vec3 I, vec3 N) 🔗

Calculate the reflection direction for an incident vector.

For a given incident vector I and surface normal N reflect returns the reflection direction calculated as I - 2.0 * dot(N, I) * N.

N should be normalized in order to achieve the desired result.

The reflection vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/reflect.xhtml

vec3 refract(vec3 I, vec3 N, float eta) 🔗

Calculate the refraction direction for an incident vector.

For a given incident vector I, surface normal N and ratio of indices of refraction, eta, refract returns the refraction vector, R.

The input parameters I and N should be normalized in order to achieve the desired result.

The ratio of indices of refraction.

The refraction vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/refract.xhtml

vec_type faceforward(vec_type N, vec_type I, vec_type Nref) 🔗

Returns a vector pointing in the same direction as another.

Orients a vector to point away from a surface as defined by its normal. If dot(Nref, I) < 0 faceforward returns N, otherwise it returns -N.

The vector to orient.

The reference vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/faceforward.xhtml

mat_type matrixCompMult(mat_type x, mat_type y) 🔗

Perform a component-wise multiplication of two matrices.

Performs a component-wise multiplication of two matrices, yielding a result matrix where each component, result[i][j] is computed as the scalar product of x[i][j] and y[i][j].

The first matrix multiplicand.

The second matrix multiplicand.

The resultant matrix.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/matrixCompMult.xhtml

mat_type outerProduct(vec_type column, vec_type row) 🔗

Calculate the outer product of a pair of vectors.

Does a linear algebraic matrix multiply column * row, yielding a matrix whose number of rows is the number of components in column and whose number of columns is the number of components in row.

The column vector for multiplication.

The row vector for multiplication.

The outer product matrix.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/outerProduct.xhtml

mat_type transpose(mat_type m) 🔗

Calculate the transpose of a matrix.

The matrix to transpose.

A new matrix that is the transpose of the input matrix m.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/transpose.xhtml

float determinant(mat_type m) 🔗

Calculate the determinant of a matrix.

The determinant of the input matrix m.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/determinant.xhtml

mat_type inverse(mat_type m) 🔗

Calculate the inverse of a matrix.

The values in the returned matrix are undefined if m is singular or poorly-conditioned (nearly singular).

The matrix of which to take the inverse.

A new matrix which is the inverse of the input matrix m.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/inverse.xhtml

lessThan(vec_type x, vec_type y)

Bool vector comparison on < int/uint/float vectors.

greaterThan(vec_type x, vec_type y)

Bool vector comparison on > int/uint/float vectors.

lessThanEqual(vec_type x, vec_type y)

Bool vector comparison on <= int/uint/float vectors.

greaterThanEqual( vec_type x, vec_type y)

Bool vector comparison on >= int/uint/float vectors.

equal(vec_type x, vec_type y)

Bool vector comparison on == int/uint/float vectors.

notEqual(vec_type x, vec_type y)

Bool vector comparison on != int/uint/float vectors.

true if any component is true, false otherwise.

true if all components are true, false otherwise.

Invert boolean vector.

vec_bool_type lessThan(vec_type x, vec_type y) 🔗

Performs a component-wise less-than comparison of two vectors.

The first vector to compare.

The second vector to compare.

A boolean vector in which each element i is computed as x[i] < y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/lessThan.xhtml

vec_bool_type greaterThan(vec_type x, vec_type y) 🔗

Performs a component-wise greater-than comparison of two vectors.

The first vector to compare.

The second vector to compare.

A boolean vector in which each element i is computed as x[i] > y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/greaterThan.xhtml

vec_bool_type lessThanEqual(vec_type x, vec_type y) 🔗

Performs a component-wise less-than-or-equal comparison of two vectors.

The first vector to compare.

The second vector to compare.

A boolean vector in which each element i is computed as x[i] <= y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/lessThanEqual.xhtml

vec_bool_type greaterThanEqual(vec_type x, vec_type y) 🔗

Performs a component-wise greater-than-or-equal comparison of two vectors.

The first vector to compare.

The second vector to compare.

A boolean vector in which each element i is computed as x[i] >= y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/greaterThanEqual.xhtml

vec_bool_type equal(vec_type x, vec_type y) 🔗

Performs a component-wise equal-to comparison of two vectors.

The first vector to compare.

The second vector to compare.

A boolean vector in which each element i is computed as x[i] == y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/equal.xhtml

vec_bool_type notEqual(vec_type x, vec_type y) 🔗

Performs a component-wise not-equal-to comparison of two vectors.

The first vector for comparison.

The second vector for comparison.

A boolean vector in which each element i is computed as x[i] != y[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/notEqual.xhtml

bool any(vec_bool_type x) 🔗

Returns true if any element of a boolean vector is true, false otherwise.

Functionally equivalent to:

The vector to be tested for truth.

True if any element of x is true and false otherwise.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/any.xhtml

bool all(vec_bool_type x) 🔗

Returns true if all elements of a boolean vector are true, false otherwise.

Functionally equivalent to:

The vector to be tested for truth.

true if all elements of x are true and false otherwise.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/all.xhtml

vec_bool_type not(vec_bool_type x) 🔗

Logically invert a boolean vector.

The vector to be inverted.

A new boolean vector for which each element i is computed as !x[i].

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/not.xhtml

Get the size of a texture.

Compute the level-of-detail that would be used to sample from a texture.

Get the number of accessible mipmap levels of a texture.

Performs a texture read.

Performs a texture read with projection.

Performs a texture read at custom mipmap.

Performs a texture read with projection/LOD.

Performs a texture read with explicit gradients.

Performs a texture read with projection/LOD and with explicit

Fetches a single texel using integer coordinates.

Gathers four texels from a texture.

Derivative with respect to x window coordinate, automatic granularity.

dFdxCoarse(vec_type p)

Derivative with respect to x window coordinate, course granularity.

Not available when using the Compatibility renderer.

Derivative with respect to x window coordinate, fine granularity.

Not available when using the Compatibility renderer.

Derivative with respect to y window coordinate, automatic granularity.

dFdyCoarse(vec_type p)

Derivative with respect to y window coordinate, course granularity.

Not available when using the Compatibility renderer.

Derivative with respect to y window coordinate, fine granularity.

Not available when using the Compatibility renderer.

Sum of absolute derivative in x and y.

fwidthCoarse(vec_type p)

Sum of absolute derivative in x and y.

Not available when using the Compatibility renderer.

fwidthFine(vec_type p)

Sum of absolute derivative in x and y.

Not available when using the Compatibility renderer.

ivec2 textureSize(gsampler2D s, int lod) 🔗

ivec2 textureSize(samplerCube s, int lod) 🔗

ivec2 textureSize(samplerCubeArray s, int lod) 🔗

ivec3 textureSize(gsampler2DArray s, int lod) 🔗

ivec3 textureSize(gsampler3D s, int lod) 🔗

Retrieves the dimensions of a level of a texture.

Returns the dimensions of level lod (if present) of the texture bound to sampler.

The components in the return value are filled in, in order, with the width, height and depth of the texture. For the array forms, the last component of the return value is the number of layers in the texture array.

The sampler to which the texture whose dimensions to retrieve is bound.

The level of the texture for which to retrieve the dimensions.

The dimensions of level lod (if present) of the texture bound to sampler.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureSize.xhtml

vec2 textureQueryLod(gsampler2D s, vec2 p) 🔗

vec2 textureQueryLod(gsampler2DArray s, vec2 p) 🔗

vec2 textureQueryLod(gsampler3D s, vec3 p) 🔗

vec2 textureQueryLod(samplerCube s, vec3 p) 🔗

Available only in the fragment shader.

Compute the level-of-detail that would be used to sample from a texture.

The mipmap array(s) that would be accessed is returned in the x component of the return value. The computed level-of-detail relative to the base level is returned in the y component of the return value.

If called on an incomplete texture, the result of the operation is undefined.

The sampler to which the texture whose level-of-detail will be queried is bound.

The texture coordinates at which the level-of-detail will be queried.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureQueryLod.xhtml

int textureQueryLevels(gsampler2D s) 🔗

int textureQueryLevels(gsampler2DArray s) 🔗

int textureQueryLevels(gsampler3D s) 🔗

int textureQueryLevels(samplerCube s) 🔗

Compute the number of accessible mipmap levels of a texture.

If called on an incomplete texture, or if no texture is associated with sampler, 0 is returned.

The sampler to which the texture whose mipmap level count will be queried is bound.

The number of accessible mipmap levels in the texture, or 0.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureQueryLevels.xhtml

gvec4_type texture(gsampler2D s, vec2 p [, float bias] ) 🔗

gvec4_type texture(gsampler2DArray s, vec3 p [, float bias] ) 🔗

gvec4_type texture(gsampler3D s, vec3 p [, float bias] ) 🔗

vec4 texture(samplerCube s, vec3 p [, float bias] ) 🔗

vec4 texture(samplerCubeArray s, vec4 p [, float bias] ) 🔗

vec4 texture(samplerExternalOES s, vec2 p [, float bias] ) 🔗

Retrieves texels from a texture.

Samples texels from the texture bound to s at texture coordinate p. An optional bias, specified in bias is included in the level-of-detail computation that is used to choose mipmap(s) from which to sample.

For shadow forms, the last component of p is used as Dsub and the array layer is specified in the second to last component of p. (The second component of p is unused for 1D shadow lookups.)

For non-shadow variants, the array layer comes from the last component of P.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

An optional bias to be applied during level-of-detail computation.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/texture.xhtml

gvec4_type textureProj(gsampler2D s, vec3 p [, float bias] ) 🔗

gvec4_type textureProj(gsampler2D s, vec4 p [, float bias] ) 🔗

gvec4_type textureProj(gsampler3D s, vec4 p [, float bias] ) 🔗

Perform a texture lookup with projection.

The texture coordinates consumed from p, not including the last component of p, are divided by the last component of p. The resulting 3rd component of p in the shadow forms is used as Dref. After these values are computed, the texture lookup proceeds as in texture.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

Optional bias to be applied during level-of-detail computation.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProj.xhtml

gvec4_type textureLod(gsampler2D s, vec2 p, float lod) 🔗

gvec4_type textureLod(gsampler2DArray s, vec3 p, float lod) 🔗

gvec4_type textureLod(gsampler3D s, vec3 p, float lod) 🔗

vec4 textureLod(samplerCube s, vec3 p, float lod) 🔗

vec4 textureLod(samplerCubeArray s, vec4 p, float lod) 🔗

Performs a texture lookup at coordinate p from the texture bound to sampler with an explicit level-of-detail as specified in lod. lod specifies λbase and sets the partial derivatives as follows:

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

The explicit level-of-detail.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureLod.xhtml

gvec4_type textureProjLod(gsampler2D s, vec3 p, float lod) 🔗

gvec4_type textureProjLod(gsampler2D s, vec4 p, float lod) 🔗

gvec4_type textureProjLod(gsampler3D s, vec4 p, float lod) 🔗

Performs a texture lookup with projection from an explicitly specified level-of-detail.

The texture coordinates consumed from P, not including the last component of p, are divided by the last component of p. The resulting 3rd component of p in the shadow forms is used as Dref. After these values are computed, the texture lookup proceeds as in textureLod<shader_func_textureLod>, with lod used to specify the level-of-detail from which the texture will be sampled.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

The explicit level-of-detail from which to fetch texels.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProjLod.xhtml

gvec4_type textureGrad(gsampler2D s, vec2 p, vec2 dPdx, vec2 dPdy) 🔗

gvec4_type textureGrad(gsampler2DArray s, vec3 p, vec2 dPdx, vec2 dPdy) 🔗

gvec4_type textureGrad(gsampler3D s, vec3 p, vec2 dPdx, vec2 dPdy) 🔗

vec4 textureGrad(samplerCube s, vec3 p, vec3 dPdx, vec3 dPdy) 🔗

vec4 textureGrad(samplerCubeArray s, vec3 p, vec3 dPdx, vec3 dPdy) 🔗

δs/δx=δp/δx for a 1D texture, δp.s/δx otherwise

δs/δy=δp/δy for a 1D texture, δp.s/δy otherwise

δt/δx=0.0 for a 1D texture, δp.t/δx otherwise

δt/δy=0.0 for a 1D texture, δp.t/δy otherwise

δr/δx=0.0 for a 1D or 2D texture, δp.p/δx otherwise

δr/δy=0.0 for a 1D or 2D texture, δp.p/δy otherwise

For the cube version, the partial derivatives of p are assumed to be in the coordinate system used before texture coordinates are projected onto the appropriate cube face.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

The partial derivative of P with respect to window x.

The partial derivative of P with respect to window y.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureGrad.xhtml

gvec4_type textureProjGrad(gsampler2D s, vec3 p, vec2 dPdx, vec2 dPdy) 🔗

gvec4_type textureProjGrad(gsampler2D s, vec4 p, vec2 dPdx, vec2 dPdy) 🔗

gvec4_type textureProjGrad(gsampler3D s, vec4 p, vec3 dPdx, vec3 dPdy) 🔗

Perform a texture lookup with projection and explicit gradients.

The texture coordinates consumed from p, not including the last component of p, are divided by the last component of p. After these values are computed, the texture lookup proceeds as in textureGrad<shader_func_textureGrad>, passing dPdx and dPdy as gradients.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

The partial derivative of p with respect to window x.

The partial derivative of p with respect to window y.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProjGrad.xhtml

gvec4_type texelFetch(gsampler2D s, ivec2 p, int lod) 🔗

gvec4_type texelFetch(gsampler2DArray s, ivec3 p, int lod) 🔗

gvec4_type texelFetch(gsampler3D s, ivec3 p, int lod) 🔗

Performs a lookup of a single texel from texture coordinate p in the texture bound to sampler.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

Specifies the level-of-detail within the texture from which the texel will be fetched.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/texelFetch.xhtml

gvec4_type textureGather(gsampler2D s, vec2 p [, int comps] ) 🔗

gvec4_type textureGather(gsampler2DArray s, vec3 p [, int comps] ) 🔗

vec4 textureGather(samplerCube s, vec3 p [, int comps] ) 🔗

Gathers four texels from a texture.

The sampler to which the texture from which texels will be retrieved is bound.

The texture coordinates at which texture will be sampled.

optional the component of the source texture (0 -> x, 1 -> y, 2 -> z, 3 -> w) that will be used to generate the resulting vector. Zero if not specified.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureGather.xhtml

vec_type dFdx(vec_type p) 🔗

Available only in the fragment shader.

Returns the partial derivative of p with respect to the window x coordinate using local differencing.

Returns either dFdxCoarse or dFdxFine. The implementation may choose which calculation to perform based upon factors such as performance or the value of the API GL_FRAGMENT_SHADER_DERIVATIVE_HINT hint.

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type dFdxCoarse(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the partial derivative of p with respect to the window x coordinate.

Calculates derivatives using local differencing based on the value of p for the current fragment's neighbors, and will possibly, but not necessarily, include the value for the current fragment. That is, over a given area, the implementation can compute derivatives in fewer unique locations than would be allowed for the corresponding dFdxFine function.

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type dFdxFine(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the partial derivative of p with respect to the window x coordinate.

Calculates derivatives using local differencing based on the value of p for the current fragment and its immediate neighbor(s).

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type dFdy(vec_type p) 🔗

Available only in the fragment shader.

Returns the partial derivative of p with respect to the window y coordinate using local differencing.

Returns either dFdyCoarse or dFdyFine. The implementation may choose which calculation to perform based upon factors such as performance or the value of the API GL_FRAGMENT_SHADER_DERIVATIVE_HINT hint.

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type dFdyCoarse(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the partial derivative of p with respect to the window y coordinate.

Calculates derivatives using local differencing based on the value of p for the current fragment's neighbors, and will possibly, but not necessarily, include the value for the current fragment. That is, over a given area, the implementation can compute derivatives in fewer unique locations than would be allowed for the corresponding dFdyFine and dFdyFine functions.

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type dFdyFine(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the partial derivative of p with respect to the window y coordinate.

Calculates derivatives using local differencing based on the value of p for the current fragment and its immediate neighbor(s).

Expressions that imply higher order derivatives such as dFdx(dFdx(n)) have undefined results, as do mixed-order derivatives such as dFdx(dFdy(n)).

The expression of which to take the partial derivative.

It is assumed that the expression p is continuous and therefore expressions evaluated via non-uniform control flow may be undefined.

The partial derivative of p.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/dFdx.xhtml

vec_type fwidth(vec_type p) 🔗

Returns the sum of the absolute value of derivatives in x and y.

Uses local differencing for the input argument p.

Equivalent to abs(dFdx(p)) + abs(dFdy(p)).

The expression of which to take the partial derivative.

The partial derivative.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fwidth.xhtml

vec_type fwidthCoarse(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the sum of the absolute value of derivatives in x and y.

Uses local differencing for the input argument p.

Equivalent to abs(dFdxCoarse(p)) + abs(dFdyCoarse(p)).

The expression of which to take the partial derivative.

The partial derivative.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fwidth.xhtml

vec_type fwidthFine(vec_type p) 🔗

Available only in the fragment shader. Not available when using the Compatibility renderer.

Returns the sum of the absolute value of derivatives in x and y.

Uses local differencing for the input argument p.

Equivalent to abs(dFdxFine(p)) + abs(dFdyFine(p)).

The expression of which to take the partial derivative.

The partial derivative.

https://registry.khronos.org/OpenGL-Refpages/gl4/html/fwidth.xhtml

These functions convert floating-point numbers into various sized integers and then pack those integers into a single 32bit unsigned integer. The 'unpack' functions perform the opposite operation, returning the original floating-point numbers.

Convert two 32-bit floats to 16 bit floats and pack them.

Convert two normalized (range 0..1) 32-bit floats to 16-bit unsigned ints and pack them.

Convert two signed normalized (range -1..1) 32-bit floats to 16-bit signed ints and pack them.

Convert four normalized (range 0..1) 32-bit floats into 8-bit unsigned ints and pack them.

Convert four signed normalized (range -1..1) 32-bit floats into 8-bit signed ints and pack them.

uint packHalf2x16(vec2 v) 🔗

Converts two 32-bit floating-point quantities to 16-bit floating-point quantities and packs them into a single 32-bit integer.

Returns an unsigned integer obtained by converting the components of a two-component floating-point vector to the 16-bit floating-point representation found in the OpenGL Specification, and then packing these two 16-bit integers into a 32-bit unsigned integer. The first vector component specifies the 16 least-significant bits of the result; the second component specifies the 16 most-significant bits.

A vector of two 32-bit floating-point values that are to be converted to 16-bit representation and packed into the result.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packHalf2x16.xhtml

vec2 unpackHalf2x16(uint v) 🔗

Inverse of packHalf2x16.

Unpacks a 32-bit integer into two 16-bit floating-point values, converts them to 32-bit floating-point values, and puts them into a vector. The first component of the vector is obtained from the 16 least-significant bits of v; the second component is obtained from the 16 most-significant bits of v.

A single 32-bit unsigned integer containing 2 packed 16-bit floating-point values.

Two unpacked floating-point values.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackHalf2x16.xhtml

uint packUnorm2x16(vec2 v) 🔗

Pack floating-point values into an unsigned integer.

Converts each component of the normalized floating-point value v into 16-bit integer values and then packs the results into a 32-bit unsigned integer.

The conversion for component c of v to fixed-point is performed as follows:

The first component of the vector will be written to the least significant bits of the output; the last component will be written to the most significant bits.

A vector of values to be packed into an unsigned integer.

Unsigned 32 bit integer containing the packed encoding of the vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packUnorm.xhtml

vec2 unpackUnorm2x16(uint v) 🔗

Unpack floating-point values from an unsigned integer.

Unpack single 32-bit unsigned integers into a pair of 16-bit unsigned integers. Then, each component is converted to a normalized floating-point value to generate the returned two-component vector.

The conversion for unpacked fixed point value f to floating-point is performed as follows:

The first component of the returned vector will be extracted from the least significant bits of the input; the last component will be extracted from the most significant bits.

An unsigned integer containing packed floating-point values.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackUnorm.xhtml

uint packSnorm2x16(vec2 v) 🔗

Packs floating-point values into an unsigned integer.

Convert each component of the normalized floating-point value v into 16-bit integer values and then packs the results into a 32-bit unsigned integer.

The conversion for component c of v to fixed-point is performed as follows:

The first component of the vector will be written to the least significant bits of the output; the last component will be written to the most significant bits.

A vector of values to be packed into an unsigned integer.

Unsigned 32 bit integer containing the packed encoding of the vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packUnorm.xhtml

vec2 unpackSnorm2x16(uint v) 🔗

Unpacks floating-point values from an unsigned integer.

Unpacks single 32-bit unsigned integers into a pair of 16-bit signed integers. Then, each component is converted to a normalized floating-point value to generate the returned two-component vector.

The conversion for unpacked fixed point value f to floating-point is performed as follows:

clamp(f / 32727.0, -1.0, 1.0)

The first component of the returned vector will be extracted from the least significant bits of the input; the last component will be extracted from the most significant bits.

An unsigned integer containing packed floating-point values.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackUnorm.xhtml

uint packUnorm4x8(vec4 v) 🔗

Packs floating-point values into an unsigned integer.

Converts each component of the normalized floating-point value v into 16-bit integer values and then packs the results into a 32-bit unsigned integer.

The conversion for component c of v to fixed-point is performed as follows:

The first component of the vector will be written to the least significant bits of the output; the last component will be written to the most significant bits.

A vector of values to be packed into an unsigned integer.

Unsigned 32 bit integer containing the packed encoding of the vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packUnorm.xhtml

vec4 unpackUnorm4x8(uint v) 🔗

Unpacks floating-point values from an unsigned integer.

Unpacks single 32-bit unsigned integers into four 8-bit unsigned integers. Then, each component is converted to a normalized floating-point value to generate the returned four-component vector.

The conversion for unpacked fixed point value f to floating-point is performed as follows:

The first component of the returned vector will be extracted from the least significant bits of the input; the last component will be extracted from the most significant bits.

An unsigned integer containing packed floating-point values.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackUnorm.xhtml

uint packSnorm4x8(vec4 v) 🔗

Packs floating-point values into an unsigned integer.

Convert each component of the normalized floating-point value v into 16-bit integer values and then packs the results into a 32-bit unsigned integer.

The conversion for component c of v to fixed-point is performed as follows:

The first component of the vector will be written to the least significant bits of the output; the last component will be written to the most significant bits.

A vector of values to be packed into an unsigned integer.

Unsigned 32 bit integer containing the packed encoding of the vector.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packUnorm.xhtml

vec4 unpackSnorm4x8(uint v) 🔗

Unpack floating-point values from an unsigned integer.

Unpack single 32-bit unsigned integers into four 8-bit signed integers. Then, each component is converted to a normalized floating-point value to generate the returned four-component vector.

The conversion for unpacked fixed point value f to floating-point is performed as follows:

clamp(f / 127.0, -1.0, 1.0)

The first component of the returned vector will be extracted from the least significant bits of the input; the last component will be extracted from the most significant bits.

An unsigned integer containing packed floating-point values.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackUnorm.xhtml

Extracts a range of bits from an integer.

Insert a range of bits into an integer.

Reverse the order of bits in an integer.

Counts the number of 1 bits in an integer.

Find the index of the least significant bit set to 1 in an integer.

Find the index of the most significant bit set to 1 in an integer.

Multiplies two 32-bit numbers and produce a 64-bit result.

uaddCarry(vec_uint_type x, vec_uint_type y, out vec_uint_type carry)

Adds two unsigned integers and generates carry.

usubBorrow(vec_uint_type x, vec_uint_type y, out vec_uint_type borrow)

Subtracts two unsigned integers and generates borrow.

ldexp(vec_type x, out vec_int_type exp)

Assemble a floating-point number from a value and exponent.

frexp(vec_type x, out vec_int_type exp)

Splits a floating-point number (x) into significand integral components

vec_int_type bitfieldExtract(vec_int_type value, int offset, int bits) 🔗

Extracts a subset of the bits of value and returns it in the least significant bits of the result. The range of bits extracted is [offset, offset + bits - 1].

The most significant bits of the result will be set to zero.

If bits is zero, the result will be zero.

The result will be undefined if:

offset or bits is negative.

if the sum of offset and bits is greater than the number of bits used to store the operand.

The integer from which to extract bits.

The index of the first bit to extract.

The number of bits to extract.

Integer with the requested bits.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/bitfieldExtract.xhtml

vec_uint_type bitfieldExtract(vec_uint_type value, int offset, int bits) 🔗

Component-wise Function.

Extracts a subset of the bits of value and returns it in the least significant bits of the result. The range of bits extracted is [offset, offset + bits - 1].

The most significant bits will be set to the value of offset + base - 1 (i.e., it is sign extended to the width of the return type).

If bits is zero, the result will be zero.

The result will be undefined if:

offset or bits is negative.

if the sum of offset and bits is greater than the number of bits used to store the operand.

The integer from which to extract bits.

The index of the first bit to extract.

The number of bits to extract.

Integer with the requested bits.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/bitfieldExtract.xhtml

vec_uint_type bitfieldExtract(vec_uint_type value, int offset, int bits) 🔗

vec_uint_type bitfieldInsert(vec_uint_type base, vec_uint_type insert, int offset, int bits) 🔗

Component-wise Function.

Inserts the bits least significant bits of insert into base at offset offset.

The returned value will have bits [offset, offset + bits + 1] taken from [0, bits - 1] of insert and all other bits taken directly from the corresponding bits of base.

If bits is zero, the result will be the original value of base.

The result will be undefined if:

offset or bits is negative.

if the sum of offset and bits is greater than the number of bits used to store the operand.

The integer into which to insert insert.

The value of the bits to insert.

The index of the first bit to insert.

The number of bits to insert.

base with inserted bits.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/bitfieldInsert.xhtml

vec_int_type bitfieldReverse(vec_int_type value) 🔗

vec_uint_type bitfieldReverse(vec_uint_type value) 🔗

Component-wise Function.

Reverse the order of bits in an integer.

The bit numbered n will be taken from bit (bits - 1) - n of value, where bits is the total number of bits used to represent value.

The value whose bits to reverse.

value but with its bits reversed.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/bitfieldReverse.xhtml

vec_int_type bitCount(vec_int_type value) 🔗

vec_uint_type bitCount(vec_uint_type value) 🔗

Component-wise Function.

Counts the number of 1 bits in an integer.

The value whose bits to count.

The number of bits that are set to 1 in the binary representation of value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/bitCount.xhtml

vec_int_type findLSB(vec_int_type value) 🔗

vec_uint_type findLSB(vec_uint_type value) 🔗

Component-wise Function.

Find the index of the least significant bit set to 1.

If value is zero, -1 will be returned.

The value whose bits to scan.

The bit number of the least significant bit that is set to 1 in the binary representation of value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/findLSB.xhtml

vec_int_type findMSB(vec_int_type value) 🔗

vec_uint_type findMSB(vec_uint_type value) 🔗

Component-wise Function.

Find the index of the most significant bit set to 1.

For positive integers, the result will be the bit number of the most significant bit that is set to 1.

For negative integers, the result will be the bit number of the most significant bit set to 0.

For a value of zero or negative 1, -1 will be returned.

The value whose bits to scan.

The bit number of the most significant bit that is set to 1 in the binary representation of value.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/findMSB.xhtml

void imulExtended(vec_int_type x, vec_int_type y, out vec_int_type msb, out vec_int_type lsb) 🔗

Component-wise Function.

Perform 32-bit by 32-bit signed multiplication to produce a 64-bit result.

The 32 least significant bits of this product are returned in lsb and the 32 most significant bits are returned in msb.

The first multiplicand.

The second multiplicand.

The variable to receive the most significant word of the product.

The variable to receive the least significant word of the product.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/umulExtended.xhtml

void umulExtended(vec_uint_type x, vec_uint_type y, out vec_uint_type msb, out vec_uint_type lsb) 🔗

Component-wise Function.

Perform 32-bit by 32-bit unsigned multiplication to produce a 64-bit result.

The 32 least significant bits of this product are returned in lsb and the 32 most significant bits are returned in msb.

The first multiplicand.

The second multiplicand.

The variable to receive the most significant word of the product.

The variable to receive the least significant word of the product.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/umulExtended.xhtml

vec_uint_type uaddCarry(vec_uint_type x, vec_uint_type y, out vec_uint_type carry) 🔗

Component-wise Function.

Add unsigned integers and generate carry.

adds two 32-bit unsigned integer variables (scalars or vectors) and generates a 32-bit unsigned integer result, along with a carry output. The value carry is .

0 if the sum is less than 232, otherwise 1.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/uaddCarry.xhtml

vec_uint_type usubBorrow(vec_uint_type x, vec_uint_type y, out vec_uint_type borrow) 🔗

Component-wise Function.

Subtract unsigned integers and generate borrow.

0 if x >= y, otherwise 1.

The difference of x and y if non-negative, or 232 plus that difference otherwise.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/usubBorrow.xhtml

vec_type ldexp(vec_type x, out vec_int_type exp) 🔗

Component-wise Function.

Assembles a floating-point number from a value and exponent.

If this product is too large to be represented in the floating-point type, the result is undefined.

The value to be used as a source of significand.

The value to be used as a source of exponent.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/ldexp.xhtml

vec_type frexp(vec_type x, out vec_int_type exp) 🔗

Component-wise Function.

Extracts x into a floating-point significand in the range [0.5, 1.0) and in integral exponent of two, such that:

For a floating-point value of zero, the significand and exponent are both zero.

For a floating-point value that is an infinity or a floating-point NaN, the results are undefined.

The value from which significand and exponent are to be extracted.

The variable into which to place the exponent of x.

The significand of x.

https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/frexp.xhtml

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
vec_type t;
t = clamp((c - a) / (b - a), 0.0, 1.0);
return t * t * (3.0 - 2.0 * t);
```

Example 2 (unknown):
```unknown
vec2( a.y * b.z - b.y * a.z,
      a.z * b.x - b.z * a.x,
      a.x * b.z - b.x * a.y)
```

Example 3 (unknown):
```unknown
k = 1.0 - eta * eta * (1.0 - dot(N, I) * dot(N, I));
if (k < 0.0)
    R = genType(0.0);       // or genDType(0.0)
else
    R = eta * I - (eta * dot(N, I) + sqrt(k)) * N;
```

Example 4 (unknown):
```unknown
bool any(bvec x) {     // bvec can be bvec2, bvec3 or bvec4
    bool result = false;
    int i;
    for (i = 0; i < x.length(); ++i) {
        result |= x[i];
    }
    return result;
}
```

---

## Button — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_button.html

**Contents:**
- Button
- Description
- Tutorials
- Properties
- Theme Properties
- Property Descriptions
- Theme Property Descriptions
- User-contributed notes

Inherits: BaseButton < Control < CanvasItem < Node < Object

Inherited By: CheckBox, CheckButton, ColorPickerButton, MenuButton, OptionButton

A themed button that can contain text and an icon.

Button is the standard themed button. It can contain text and an icon, and it will display them according to the current Theme.

Example: Create a button and connect a method that will be called when the button is pressed:

See also BaseButton which contains common properties and methods associated with this node.

Note: Buttons do not detect touch input and therefore don't support multitouch, since mouse emulation can only press one button at a given time. Use TouchScreenButton for buttons that trigger gameplay movement or actions.

2D Dodge The Creeps Demo

Operating System Testing Demo

BitField[LineBreakFlag]

text_overrun_behavior

vertical_icon_alignment

Color(0.875, 0.875, 0.875, 1)

Color(0.875, 0.875, 0.875, 0.5)

Color(0.95, 0.95, 0.95, 1)

Color(0.95, 0.95, 0.95, 1)

font_hover_pressed_color

icon_hover_pressed_color

align_to_largest_stylebox

hover_pressed_mirrored

HorizontalAlignment alignment = 1 🔗

void set_text_alignment(value: HorizontalAlignment)

HorizontalAlignment get_text_alignment()

Text alignment policy for the button's text.

AutowrapMode autowrap_mode = 0 🔗

void set_autowrap_mode(value: AutowrapMode)

AutowrapMode get_autowrap_mode()

If set to something other than TextServer.AUTOWRAP_OFF, the text gets wrapped inside the node's bounding rectangle.

BitField[LineBreakFlag] autowrap_trim_flags = 128 🔗

void set_autowrap_trim_flags(value: BitField[LineBreakFlag])

BitField[LineBreakFlag] get_autowrap_trim_flags()

Autowrap space trimming flags. See TextServer.BREAK_TRIM_START_EDGE_SPACES and TextServer.BREAK_TRIM_END_EDGE_SPACES for more info.

bool clip_text = false 🔗

void set_clip_text(value: bool)

If true, text that is too large to fit the button is clipped horizontally. If false, the button will always be wide enough to hold the text. The text is not vertically clipped, and the button's height is not affected by this property.

bool expand_icon = false 🔗

void set_expand_icon(value: bool)

bool is_expand_icon()

When enabled, the button's icon will expand/shrink to fit the button's size while keeping its aspect. See also icon_max_width.

void set_flat(value: bool)

Flat buttons don't display decoration.

void set_button_icon(value: Texture2D)

Texture2D get_button_icon()

Button's icon, if text is present the icon will be placed before the text.

To edit margin and spacing of the icon, use h_separation theme property and content_margin_* properties of the used StyleBoxes.

HorizontalAlignment icon_alignment = 0 🔗

void set_icon_alignment(value: HorizontalAlignment)

HorizontalAlignment get_icon_alignment()

Specifies if the icon should be aligned horizontally to the left, right, or center of a button. Uses the same HorizontalAlignment constants as the text alignment. If centered horizontally and vertically, text will draw on top of the icon.

String language = "" 🔗

void set_language(value: String)

String get_language()

Language code used for line-breaking and text shaping algorithms, if left empty current locale is used instead.

void set_text(value: String)

The button's text that will be displayed inside the button's area.

TextDirection text_direction = 0 🔗

void set_text_direction(value: TextDirection)

TextDirection get_text_direction()

Base text writing direction.

OverrunBehavior text_overrun_behavior = 0 🔗

void set_text_overrun_behavior(value: OverrunBehavior)

OverrunBehavior get_text_overrun_behavior()

Sets the clipping behavior when the text exceeds the node's bounding rectangle.

VerticalAlignment vertical_icon_alignment = 1 🔗

void set_vertical_icon_alignment(value: VerticalAlignment)

VerticalAlignment get_vertical_icon_alignment()

Specifies if the icon should be aligned vertically to the top, bottom, or center of a button. Uses the same VerticalAlignment constants as the text alignment. If centered horizontally and vertically, text will draw on top of the icon.

Color font_color = Color(0.875, 0.875, 0.875, 1) 🔗

Default text Color of the Button.

Color font_disabled_color = Color(0.875, 0.875, 0.875, 0.5) 🔗

Text Color used when the Button is disabled.

Color font_focus_color = Color(0.95, 0.95, 0.95, 1) 🔗

Text Color used when the Button is focused. Only replaces the normal text color of the button. Disabled, hovered, and pressed states take precedence over this color.

Color font_hover_color = Color(0.95, 0.95, 0.95, 1) 🔗

Text Color used when the Button is being hovered.

Color font_hover_pressed_color = Color(1, 1, 1, 1) 🔗

Text Color used when the Button is being hovered and pressed.

Color font_outline_color = Color(0, 0, 0, 1) 🔗

The tint of text outline of the Button.

Color font_pressed_color = Color(1, 1, 1, 1) 🔗

Text Color used when the Button is being pressed.

Color icon_disabled_color = Color(1, 1, 1, 0.4) 🔗

Icon modulate Color used when the Button is disabled.

Color icon_focus_color = Color(1, 1, 1, 1) 🔗

Icon modulate Color used when the Button is focused. Only replaces the normal modulate color of the button. Disabled, hovered, and pressed states take precedence over this color.

Color icon_hover_color = Color(1, 1, 1, 1) 🔗

Icon modulate Color used when the Button is being hovered.

Color icon_hover_pressed_color = Color(1, 1, 1, 1) 🔗

Icon modulate Color used when the Button is being hovered and pressed.

Color icon_normal_color = Color(1, 1, 1, 1) 🔗

Default icon modulate Color of the Button.

Color icon_pressed_color = Color(1, 1, 1, 1) 🔗

Icon modulate Color used when the Button is being pressed.

int align_to_largest_stylebox = 0 🔗

This constant acts as a boolean. If true, the minimum size of the button and text/icon alignment is always based on the largest stylebox margins, otherwise it's based on the current button state stylebox margins.

int h_separation = 4 🔗

The horizontal space between Button's icon and text. Negative values will be treated as 0 when used.

int icon_max_width = 0 🔗

The maximum allowed width of the Button's icon. This limit is applied on top of the default size of the icon, or its expanded size if expand_icon is true. The height is adjusted according to the icon's ratio. If the button has additional icons (e.g. CheckBox), they will also be limited.

int line_spacing = 0 🔗

Additional vertical spacing between lines (in pixels), spacing is added to line descent. This value can be negative.

int outline_size = 0 🔗

The size of the text outline.

Note: If using a font with FontFile.multichannel_signed_distance_field enabled, its FontFile.msdf_pixel_range must be set to at least twice the value of outline_size for outline rendering to look correct. Otherwise, the outline may appear to be cut off earlier than intended.

Font of the Button's text.

Font size of the Button's text.

Default icon for the Button. Appears only if icon is not assigned.

StyleBox used when the Button is disabled.

StyleBox disabled_mirrored 🔗

StyleBox used when the Button is disabled (for right-to-left layouts).

StyleBox used when the Button is focused. The focus StyleBox is displayed over the base StyleBox, so a partially transparent StyleBox should be used to ensure the base StyleBox remains visible. A StyleBox that represents an outline or an underline works well for this purpose. To disable the focus visual effect, assign a StyleBoxEmpty resource. Note that disabling the focus visual effect will harm keyboard/controller navigation usability, so this is not recommended for accessibility reasons.

StyleBox used when the Button is being hovered.

StyleBox hover_mirrored 🔗

StyleBox used when the Button is being hovered (for right-to-left layouts).

StyleBox hover_pressed 🔗

StyleBox used when the Button is being pressed and hovered at the same time.

StyleBox hover_pressed_mirrored 🔗

StyleBox used when the Button is being pressed and hovered at the same time (for right-to-left layouts).

Default StyleBox for the Button.

StyleBox normal_mirrored 🔗

Default StyleBox for the Button (for right-to-left layouts).

StyleBox used when the Button is being pressed.

StyleBox pressed_mirrored 🔗

StyleBox used when the Button is being pressed (for right-to-left layouts).

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
func _ready():
    var button = Button.new()
    button.text = "Click me"
    button.pressed.connect(_button_pressed)
    add_child(button)

func _button_pressed():
    print("Hello world!")
```

Example 2 (unknown):
```unknown
public override void _Ready()
{
    var button = new Button();
    button.Text = "Click me";
    button.Pressed += ButtonPressed;
    AddChild(button);
}

private void ButtonPressed()
{
    GD.Print("Hello world!");
}
```

---

## Container — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_container.html

**Contents:**
- Container
- Description
- Tutorials
- Properties
- Methods
- Signals
- Constants
- Method Descriptions
- User-contributed notes

Inherits: Control < CanvasItem < Node < Object

Inherited By: AspectRatioContainer, BoxContainer, CenterContainer, EditorProperty, FlowContainer, FoldableContainer, GraphElement, GridContainer, MarginContainer, PanelContainer, ScrollContainer, SplitContainer, SubViewportContainer, TabContainer

Base class for all GUI containers.

Base class for all GUI containers. A Container automatically arranges its child controls in a certain way. This class can be inherited to make custom container types.

1 (overrides Control)

_get_allowed_size_flags_horizontal() virtual const

_get_allowed_size_flags_vertical() virtual const

fit_child_in_rect(child: Control, rect: Rect2)

pre_sort_children() 🔗

Emitted when children are going to be sorted.

Emitted when sorting the children is needed.

NOTIFICATION_PRE_SORT_CHILDREN = 50 🔗

Notification just before children are going to be sorted, in case there's something to process beforehand.

NOTIFICATION_SORT_CHILDREN = 51 🔗

Notification for when sorting the children, it must be obeyed immediately.

PackedInt32Array _get_allowed_size_flags_horizontal() virtual const 🔗

Implement to return a list of allowed horizontal SizeFlags for child nodes. This doesn't technically prevent the usages of any other size flags, if your implementation requires that. This only limits the options available to the user in the Inspector dock.

Note: Having no size flags is equal to having Control.SIZE_SHRINK_BEGIN. As such, this value is always implicitly allowed.

PackedInt32Array _get_allowed_size_flags_vertical() virtual const 🔗

Implement to return a list of allowed vertical SizeFlags for child nodes. This doesn't technically prevent the usages of any other size flags, if your implementation requires that. This only limits the options available to the user in the Inspector dock.

Note: Having no size flags is equal to having Control.SIZE_SHRINK_BEGIN. As such, this value is always implicitly allowed.

void fit_child_in_rect(child: Control, rect: Rect2) 🔗

Fit a child control in a given rect. This is mainly a helper for creating custom container classes.

Queue resort of the contained children. This is called automatically anyway, but can be called upon request.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Controllers, gamepads, and joysticks — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html

**Contents:**
- Controllers, gamepads, and joysticks
- Supporting universal input
  - Which Input singleton method should I use?
- Vibration
- Differences between keyboard/mouse and controller input
  - Dead zone
  - "Echo" events
  - Window focus
  - Power saving prevention
- Troubleshooting

Godot supports hundreds of controller models out of the box. Controllers are supported on Windows, macOS, Linux, Android, iOS, and Web.

Since Godot 4.5, the engine relies on SDL 3 for controller support on Windows, macOS, and Linux. This means the list of supported controllers and their behavior should closely match what is available in other games and engines using SDL 3. Note that SDL is only used for input, not for windowing or sound.

Prior to Godot 4.5, the engine used its own controller support code. This can cause certain controllers to behave incorrectly. This custom code is still used to support controllers on Android, iOS, and Web, so it may result in issues appearing only on those platforms.

Note that more specialized devices such as steering wheels, rudder pedals and HOTAS are less tested and may not always work as expected. Overriding force feedback for those devices is also not implemented yet. If you have access to one of those devices, don't hesitate to report bugs on GitHub.

In this guide, you will learn:

How to write your input logic to support both keyboard and controller inputs.

How controllers can behave differently from keyboard/mouse input.

Troubleshooting issues with controllers in Godot.

Thanks to Godot's input action system, Godot makes it possible to support both keyboard and controller input without having to write separate code paths. Instead of hardcoding keys or controller buttons in your scripts, you should create input actions in the Project Settings which will then refer to specified key and controller inputs.

Input actions are explained in detail on the Using InputEvent page.

Unlike keyboard input, supporting both mouse and controller input for an action (such as looking around in a first-person game) will require different code paths since these have to be handled separately.

There are 3 ways to get input in an analog-aware way:

When you have two axes (such as joystick or WASD movement) and want both axes to behave as a single input, use Input.get_vector():

When you have one axis that can go both ways (such as a throttle on a flight stick), or when you want to handle separate axes individually, use Input.get_axis():

For other types of analog input, such as handling a trigger or handling one direction at a time, use Input.get_action_strength():

For non-analog digital/boolean input (only "pressed" or "not pressed" values), such as controller buttons, mouse buttons or keyboard keys, use Input.is_action_pressed():

If you need to know whether an input was just pressed in the previous frame, use Input.is_action_just_pressed() instead of Input.is_action_pressed(). Unlike Input.is_action_pressed() which returns true as long as the input is held, Input.is_action_just_pressed() will only return true for one frame after the button has been pressed.

Vibration (also called haptic feedback) can be used to enhance the feel of a game. For instance, in a racing game, you can convey the surface the car is currently driving on through vibration, or create a sudden vibration on a crash.

Use the Input singleton's start_joy_vibration method to start vibrating a gamepad. Use stop_joy_vibration to stop vibration early (useful if no duration was specified when starting).

On mobile devices, you can also use vibrate_handheld to vibrate the device itself (independently from the gamepad). On Android, this requires the VIBRATE permission to be enabled in the Android export preset before exporting the project.

Vibration can be uncomfortable for certain players. Make sure to provide an in-game slider to disable vibration or reduce its intensity.

If you're used to handling keyboard and mouse input, you may be surprised by how controllers handle specific situations.

Unlike keyboards and mice, controllers offer axes with analog inputs. The upside of analog inputs is that they offer additional flexibility for actions. Unlike digital inputs which can only provide strengths of 0.0 and 1.0, an analog input can provide any strength between 0.0 and 1.0. The downside is that without a deadzone system, an analog axis' strength will never be equal to 0.0 due to how the controller is physically built. Instead, it will linger at a low value such as 0.062. This phenomenon is known as drifting and can be more noticeable on old or faulty controllers.

Let's take a racing game as a real-world example. Thanks to analog inputs, we can steer the car slowly in one direction or another. However, without a deadzone system, the car would slowly steer by itself even if the player isn't touching the joystick. This is because the directional axis strength won't be equal to 0.0 when we expect it to. Since we don't want our car to steer by itself in this case, we define a "dead zone" value of 0.2 which will ignore all input whose strength is lower than 0.2. An ideal dead zone value is high enough to ignore the input caused by joystick drifting, but is low enough to not ignore actual input from the player.

Godot features a built-in deadzone system to tackle this problem. The default value is 0.5, but you can adjust it on a per-action basis in the Project Settings' Input Map tab. For Input.get_vector(), the deadzone can be specified as an optional 5th parameter. If not specified, it will calculate the average deadzone value from all of the actions in the vector.

Unlike keyboard input, holding down a controller button such as a D-pad direction will not generate repeated input events at fixed intervals (also known as "echo" events). This is because the operating system never sends "echo" events for controller input in the first place.

If you want controller buttons to send echo events, you will have to generate InputEvent objects by code and parse them using Input.parse_input_event() at regular intervals. This can be accomplished with the help of a Timer node.

Unlike keyboard input, controller inputs can be seen by all windows on the operating system, including unfocused windows.

While this is useful for third-party split screen functionality, it can also have adverse effects. Players may accidentally send controller inputs to the running project while interacting with another window.

If you wish to ignore events when the project window isn't focused, you will need to create an autoload called Focus with the following script and use it to check all your inputs:

Then, instead of using Input.is_action_pressed(action), use Focus.input_is_action_pressed(action) where action is the name of the input action. Also, instead of using event.is_action_pressed(action), use Focus.event_is_action_pressed(event, action) where event is an InputEvent reference and action is the name of the input action.

Unlike keyboard and mouse input, controller inputs do not inhibit sleep and power saving measures (such as turning off the screen after a certain amount of time has passed).

To combat this, Godot enables power saving prevention by default when a project is running. If you notice the system is turning off its display when playing with a gamepad, check the value of Display > Window > Energy Saving > Keep Screen On in the Project Settings.

On Linux, power saving prevention requires the engine to be able to use D-Bus. Check whether D-Bus is installed and reachable if running the project within a Flatpak, as sandboxing restrictions may make this impossible by default.

You can view a list of known issues with controller support on GitHub.

First, check that your controller is recognized by other applications. You can use the Gamepad Tester website to confirm that your controller is recognized.

On Windows Godot only supports up to 4 controllers at a time. This is because Godot uses the XInput API, which is limited to supporting 4 controllers at once. Additional controllers above this limit are ignored by Godot.

First, if your controller provides some kind of firmware update utility, make sure to run it to get the latest fixes from the manufacturer. For instance, Xbox One and Xbox Series controllers can have their firmware updated using the Xbox Accessories app. (This application only runs on Windows, so you have to use a Windows machine or a Windows virtual machine with USB support to update the controller's firmware.) After updating the controller's firmware, unpair the controller and pair it again with your PC if you are using the controller in wireless mode.

If buttons are incorrectly mapped, this may be due to an erroneous mapping from the SDL game controller database used by Godot or the Godot game controller database. In this case, you will need to create a custom mapping for your controller.

There are many ways to create mappings. One option is to use the mapping wizard in the official Joypads demo. Once you have a working mapping for your controller, you can test it by defining the SDL_GAMECONTROLLERCONFIG environment variable before running Godot:

To test mappings on non-desktop platforms or to distribute your project with additional controller mappings, you can add them by calling Input.add_joy_mapping() as early as possible in a script's _ready() function.

Once you are satisfied with the custom mapping, you can contribute it for the next Godot version by opening a pull request on the Godot game controller database.

If you're using a self-compiled engine binary, make sure it was compiled with udev support. This is enabled by default, but it is possible to disable udev support by specifying udev=no on the SCons command line. If you're using an engine binary supplied by a Linux distribution, double-check whether it was compiled with udev support.

Controllers can still work without udev support, but it is less reliable as regular polling must be used to check for controllers being connected or disconnected during gameplay (hotplugging).

As described at the top of the page, controller support on mobile platforms relies on a custom implementation instead of using SDL for input. This means controller support may be less reliable than on desktop platforms.

Support for SDL-based controller input on mobile platforms is planned in a future release.

Web controller support is often less reliable compared to "native" platforms. The quality of controller support tends to vary wildly across browsers. As a result, you may have to instruct your players to use a different browser if they can't get their controller to work.

Like for mobile platforms, support for SDL-based controller input on the web platform is planned in a future release.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
# `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`.
# This handles deadzone in a correct way for most use cases.
# The resulting deadzone will have a circular shape as it generally should.
var velocity = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

# The line below is similar to `get_vector()`, except that it handles
# the deadzone in a less optimal way. The resulting deadzone will have
# a square-ish shape when it should ideally have a circular shape.
var velocity = Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
).limit_length(1.0)
```

Example 2 (unknown):
```unknown
// `velocity` will be a Vector2 between `Vector2(-1.0, -1.0)` and `Vector2(1.0, 1.0)`.
// This handles deadzone in a correct way for most use cases.
// The resulting deadzone will have a circular shape as it generally should.
Vector2 velocity = Input.GetVector("move_left", "move_right", "move_forward", "move_back");

// The line below is similar to `get_vector()`, except that it handles
// the deadzone in a less optimal way. The resulting deadzone will have
// a square-ish shape when it should ideally have a circular shape.
Vector2 velocity = new Vector2(
        Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left"),
        Input.GetActionStrength("move_back") - Input.GetActionStrength("move_forward")
).LimitLength(1.0);
```

Example 3 (unknown):
```unknown
# `walk` will be a floating-point number between `-1.0` and `1.0`.
var walk = Input.get_axis("move_left", "move_right")

# The line above is a shorter form of:
var walk = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
```

Example 4 (unknown):
```unknown
// `walk` will be a floating-point number between `-1.0` and `1.0`.
float walk = Input.GetAxis("move_left", "move_right");

// The line above is a shorter form of:
float walk = Input.GetActionStrength("move_right") - Input.GetActionStrength("move_left");
```

---

## Control — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_control.html

**Contents:**
- Control
- Description
- Tutorials
- Properties
- Methods
- Signals
- Enumerations
- Constants
- Property Descriptions
- Method Descriptions

Inherits: CanvasItem < Node < Object

Inherited By: BaseButton, ColorRect, Container, GraphEdit, ItemList, Label, LineEdit, MenuBar, NinePatchRect, Panel, Range, ReferenceRect, RichTextLabel, Separator, TabBar, TextEdit, TextureRect, Tree, VideoStreamPlayer

Base class for all GUI controls. Adapts its position and size based on its parent control.

Base class for all UI-related nodes. Control features a bounding rectangle that defines its extents, an anchor position relative to its parent control or the current viewport, and offsets relative to the anchor. The offsets update automatically when the node, any of its parents, or the screen size change.

For more information on Godot's UI system, anchors, offsets, and containers, see the related tutorials in the manual. To build flexible UIs, you'll need a mix of UI elements that inherit from Control and Container nodes.

Note: Since both Node2D and Control inherit from CanvasItem, they share several concepts from the class such as the CanvasItem.z_index and CanvasItem.visible properties.

User Interface nodes and input

Godot propagates input events via viewports. Each Viewport is responsible for propagating InputEvents to their child nodes. As the SceneTree.root is a Window, this already happens automatically for all UI elements in your game.

Input events are propagated through the SceneTree from the root node to all child nodes by calling Node._input(). For UI elements specifically, it makes more sense to override the virtual method _gui_input(), which filters out unrelated input events, such as by checking z-order, mouse_filter, focus, or if the event was inside of the control's bounding box.

Call accept_event() so no other node receives the event. Once you accept an input, it becomes handled so Node._unhandled_input() will not process it.

Only one Control node can be in focus. Only the node in focus will receive events. To get the focus, call grab_focus(). Control nodes lose focus when another node grabs it, or if you hide the node in focus.

Sets mouse_filter to MOUSE_FILTER_IGNORE to tell a Control node to ignore mouse or touch events. You'll need it if you place an icon on top of a button.

Theme resources change the control's appearance. The theme of a Control node affects all of its direct and indirect children (as long as a chain of controls is uninterrupted). To override some of the theme items, call one of the add_theme_*_override methods, like add_theme_font_override(). You can also override theme items in the Inspector.

Note: Theme items are not Object properties. This means you can't access their values using Object.get() and Object.set(). Instead, use the get_theme_* and add_theme_*_override methods provided by this class.

GUI documentation index

accessibility_controls_nodes

accessibility_described_by_nodes

accessibility_description

accessibility_flow_to_nodes

accessibility_labeled_by_nodes

AccessibilityLiveMode

FocusBehaviorRecursive

focus_behavior_recursive

focus_neighbor_bottom

localize_numeral_system

MouseBehaviorRecursive

mouse_behavior_recursive

mouse_default_cursor_shape

mouse_force_pass_scroll_events

PhysicsInterpolationMode

physics_interpolation_mode

size_flags_horizontal

size_flags_stretch_ratio

tooltip_auto_translate_mode

_accessibility_get_contextual_info() virtual const

_can_drop_data(at_position: Vector2, data: Variant) virtual const

_drop_data(at_position: Vector2, data: Variant) virtual

_get_accessibility_container_name(node: Node) virtual const

_get_drag_data(at_position: Vector2) virtual

_get_minimum_size() virtual const

_get_tooltip(at_position: Vector2) virtual const

_gui_input(event: InputEvent) virtual

_has_point(point: Vector2) virtual const

_make_custom_tooltip(for_text: String) virtual const

_structured_text_parser(args: Array, text: String) virtual const

add_theme_color_override(name: StringName, color: Color)

add_theme_constant_override(name: StringName, constant: int)

add_theme_font_override(name: StringName, font: Font)

add_theme_font_size_override(name: StringName, font_size: int)

add_theme_icon_override(name: StringName, texture: Texture2D)

add_theme_stylebox_override(name: StringName, stylebox: StyleBox)

begin_bulk_theme_override()

end_bulk_theme_override()

find_next_valid_focus() const

find_prev_valid_focus() const

find_valid_focus_neighbor(side: Side) const

force_drag(data: Variant, preview: Control)

get_anchor(side: Side) const

get_combined_minimum_size() const

get_cursor_shape(position: Vector2 = Vector2(0, 0)) const

get_focus_mode_with_override() const

get_focus_neighbor(side: Side) const

get_global_rect() const

get_minimum_size() const

get_mouse_filter_with_override() const

get_offset(offset: Side) const

get_parent_area_size() const

get_parent_control() const

get_screen_position() const

get_theme_color(name: StringName, theme_type: StringName = &"") const

get_theme_constant(name: StringName, theme_type: StringName = &"") const

get_theme_default_base_scale() const

get_theme_default_font() const

get_theme_default_font_size() const

get_theme_font(name: StringName, theme_type: StringName = &"") const

get_theme_font_size(name: StringName, theme_type: StringName = &"") const

get_theme_icon(name: StringName, theme_type: StringName = &"") const

get_theme_stylebox(name: StringName, theme_type: StringName = &"") const

get_tooltip(at_position: Vector2 = Vector2(0, 0)) const

has_theme_color(name: StringName, theme_type: StringName = &"") const

has_theme_color_override(name: StringName) const

has_theme_constant(name: StringName, theme_type: StringName = &"") const

has_theme_constant_override(name: StringName) const

has_theme_font(name: StringName, theme_type: StringName = &"") const

has_theme_font_override(name: StringName) const

has_theme_font_size(name: StringName, theme_type: StringName = &"") const

has_theme_font_size_override(name: StringName) const

has_theme_icon(name: StringName, theme_type: StringName = &"") const

has_theme_icon_override(name: StringName) const

has_theme_stylebox(name: StringName, theme_type: StringName = &"") const

has_theme_stylebox_override(name: StringName) const

is_drag_successful() const

is_layout_rtl() const

remove_theme_color_override(name: StringName)

remove_theme_constant_override(name: StringName)

remove_theme_font_override(name: StringName)

remove_theme_font_size_override(name: StringName)

remove_theme_icon_override(name: StringName)

remove_theme_stylebox_override(name: StringName)

set_anchor(side: Side, anchor: float, keep_offset: bool = false, push_opposite_anchor: bool = true)

set_anchor_and_offset(side: Side, anchor: float, offset: float, push_opposite_anchor: bool = false)

set_anchors_and_offsets_preset(preset: LayoutPreset, resize_mode: LayoutPresetMode = 0, margin: int = 0)

set_anchors_preset(preset: LayoutPreset, keep_offsets: bool = false)

set_begin(position: Vector2)

set_drag_forwarding(drag_func: Callable, can_drop_func: Callable, drop_func: Callable)

set_drag_preview(control: Control)

set_end(position: Vector2)

set_focus_neighbor(side: Side, neighbor: NodePath)

set_global_position(position: Vector2, keep_offsets: bool = false)

set_offset(side: Side, offset: float)

set_offsets_preset(preset: LayoutPreset, resize_mode: LayoutPresetMode = 0, margin: int = 0)

set_position(position: Vector2, keep_offsets: bool = false)

set_size(size: Vector2, keep_offsets: bool = false)

update_minimum_size()

warp_mouse(position: Vector2)

Emitted when the node gains focus.

Emitted when the node loses focus.

gui_input(event: InputEvent) 🔗

Emitted when the node receives an InputEvent.

minimum_size_changed() 🔗

Emitted when the node's minimum size changes.

Emitted when the mouse cursor enters the control's (or any child control's) visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect, which Control receives the signal.

Emitted when the mouse cursor leaves the control's (and all child control's) visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect, which Control receives the signal.

Note: If you want to check whether the mouse truly left the area, ignoring any top nodes, you can use code like this:

Emitted when the control changes size.

size_flags_changed() 🔗

Emitted when one of the size flags changes. See size_flags_horizontal and size_flags_vertical.

Emitted when the NOTIFICATION_THEME_CHANGED notification is sent.

FocusMode FOCUS_NONE = 0

The node cannot grab focus. Use with focus_mode.

FocusMode FOCUS_CLICK = 1

The node can only grab focus on mouse clicks. Use with focus_mode.

FocusMode FOCUS_ALL = 2

The node can grab focus on mouse click, using the arrows and the Tab keys on the keyboard, or using the D-pad buttons on a gamepad. Use with focus_mode.

FocusMode FOCUS_ACCESSIBILITY = 3

The node can grab focus only when screen reader is active. Use with focus_mode.

enum FocusBehaviorRecursive: 🔗

FocusBehaviorRecursive FOCUS_BEHAVIOR_INHERITED = 0

Inherits the focus_behavior_recursive from the parent control. If there is no parent control, this is the same as FOCUS_BEHAVIOR_ENABLED.

FocusBehaviorRecursive FOCUS_BEHAVIOR_DISABLED = 1

Prevents the control from getting focused. get_focus_mode_with_override() will return FOCUS_NONE.

FocusBehaviorRecursive FOCUS_BEHAVIOR_ENABLED = 2

Allows the control to be focused, depending on the focus_mode. This can be used to ignore the parent's focus_behavior_recursive. get_focus_mode_with_override() will return the focus_mode.

enum MouseBehaviorRecursive: 🔗

MouseBehaviorRecursive MOUSE_BEHAVIOR_INHERITED = 0

Inherits the mouse_behavior_recursive from the parent control. If there is no parent control, this is the same as MOUSE_BEHAVIOR_ENABLED.

MouseBehaviorRecursive MOUSE_BEHAVIOR_DISABLED = 1

Prevents the control from receiving mouse input. get_mouse_filter_with_override() will return MOUSE_FILTER_IGNORE.

MouseBehaviorRecursive MOUSE_BEHAVIOR_ENABLED = 2

Allows the control to be receive mouse input, depending on the mouse_filter. This can be used to ignore the parent's mouse_behavior_recursive. get_mouse_filter_with_override() will return the mouse_filter.

CursorShape CURSOR_ARROW = 0

Show the system's arrow mouse cursor when the user hovers the node. Use with mouse_default_cursor_shape.

CursorShape CURSOR_IBEAM = 1

Show the system's I-beam mouse cursor when the user hovers the node. The I-beam pointer has a shape similar to "I". It tells the user they can highlight or insert text.

CursorShape CURSOR_POINTING_HAND = 2

Show the system's pointing hand mouse cursor when the user hovers the node.

CursorShape CURSOR_CROSS = 3

Show the system's cross mouse cursor when the user hovers the node.

CursorShape CURSOR_WAIT = 4

Show the system's wait mouse cursor when the user hovers the node. Often an hourglass.

CursorShape CURSOR_BUSY = 5

Show the system's busy mouse cursor when the user hovers the node. Often an arrow with a small hourglass.

CursorShape CURSOR_DRAG = 6

Show the system's drag mouse cursor, often a closed fist or a cross symbol, when the user hovers the node. It tells the user they're currently dragging an item, like a node in the Scene dock.

CursorShape CURSOR_CAN_DROP = 7

Show the system's drop mouse cursor when the user hovers the node. It can be an open hand. It tells the user they can drop an item they're currently grabbing, like a node in the Scene dock.

CursorShape CURSOR_FORBIDDEN = 8

Show the system's forbidden mouse cursor when the user hovers the node. Often a crossed circle.

CursorShape CURSOR_VSIZE = 9

Show the system's vertical resize mouse cursor when the user hovers the node. A double-headed vertical arrow. It tells the user they can resize the window or the panel vertically.

CursorShape CURSOR_HSIZE = 10

Show the system's horizontal resize mouse cursor when the user hovers the node. A double-headed horizontal arrow. It tells the user they can resize the window or the panel horizontally.

CursorShape CURSOR_BDIAGSIZE = 11

Show the system's window resize mouse cursor when the user hovers the node. The cursor is a double-headed arrow that goes from the bottom left to the top right. It tells the user they can resize the window or the panel both horizontally and vertically.

CursorShape CURSOR_FDIAGSIZE = 12

Show the system's window resize mouse cursor when the user hovers the node. The cursor is a double-headed arrow that goes from the top left to the bottom right, the opposite of CURSOR_BDIAGSIZE. It tells the user they can resize the window or the panel both horizontally and vertically.

CursorShape CURSOR_MOVE = 13

Show the system's move mouse cursor when the user hovers the node. It shows 2 double-headed arrows at a 90 degree angle. It tells the user they can move a UI element freely.

CursorShape CURSOR_VSPLIT = 14

Show the system's vertical split mouse cursor when the user hovers the node. On Windows, it's the same as CURSOR_VSIZE.

CursorShape CURSOR_HSPLIT = 15

Show the system's horizontal split mouse cursor when the user hovers the node. On Windows, it's the same as CURSOR_HSIZE.

CursorShape CURSOR_HELP = 16

Show the system's help mouse cursor when the user hovers the node, a question mark.

LayoutPreset PRESET_TOP_LEFT = 0

Snap all 4 anchors to the top-left of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_TOP_RIGHT = 1

Snap all 4 anchors to the top-right of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_BOTTOM_LEFT = 2

Snap all 4 anchors to the bottom-left of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_BOTTOM_RIGHT = 3

Snap all 4 anchors to the bottom-right of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_CENTER_LEFT = 4

Snap all 4 anchors to the center of the left edge of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_CENTER_TOP = 5

Snap all 4 anchors to the center of the top edge of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_CENTER_RIGHT = 6

Snap all 4 anchors to the center of the right edge of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_CENTER_BOTTOM = 7

Snap all 4 anchors to the center of the bottom edge of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_CENTER = 8

Snap all 4 anchors to the center of the parent control's bounds. Use with set_anchors_preset().

LayoutPreset PRESET_LEFT_WIDE = 9

Snap all 4 anchors to the left edge of the parent control. The left offset becomes relative to the left edge and the top offset relative to the top left corner of the node's parent. Use with set_anchors_preset().

LayoutPreset PRESET_TOP_WIDE = 10

Snap all 4 anchors to the top edge of the parent control. The left offset becomes relative to the top left corner, the top offset relative to the top edge, and the right offset relative to the top right corner of the node's parent. Use with set_anchors_preset().

LayoutPreset PRESET_RIGHT_WIDE = 11

Snap all 4 anchors to the right edge of the parent control. The right offset becomes relative to the right edge and the top offset relative to the top right corner of the node's parent. Use with set_anchors_preset().

LayoutPreset PRESET_BOTTOM_WIDE = 12

Snap all 4 anchors to the bottom edge of the parent control. The left offset becomes relative to the bottom left corner, the bottom offset relative to the bottom edge, and the right offset relative to the bottom right corner of the node's parent. Use with set_anchors_preset().

LayoutPreset PRESET_VCENTER_WIDE = 13

Snap all 4 anchors to a vertical line that cuts the parent control in half. Use with set_anchors_preset().

LayoutPreset PRESET_HCENTER_WIDE = 14

Snap all 4 anchors to a horizontal line that cuts the parent control in half. Use with set_anchors_preset().

LayoutPreset PRESET_FULL_RECT = 15

Snap all 4 anchors to the respective corners of the parent control. Set all 4 offsets to 0 after you applied this preset and the Control will fit its parent control. Use with set_anchors_preset().

enum LayoutPresetMode: 🔗

LayoutPresetMode PRESET_MODE_MINSIZE = 0

The control will be resized to its minimum size.

LayoutPresetMode PRESET_MODE_KEEP_WIDTH = 1

The control's width will not change.

LayoutPresetMode PRESET_MODE_KEEP_HEIGHT = 2

The control's height will not change.

LayoutPresetMode PRESET_MODE_KEEP_SIZE = 3

The control's size will not change.

SizeFlags SIZE_SHRINK_BEGIN = 0

Tells the parent Container to align the node with its start, either the top or the left edge. It is mutually exclusive with SIZE_FILL and other shrink size flags, but can be used with SIZE_EXPAND in some containers. Use with size_flags_horizontal and size_flags_vertical.

Note: Setting this flag is equal to not having any size flags.

SizeFlags SIZE_FILL = 1

Tells the parent Container to expand the bounds of this node to fill all the available space without pushing any other node. It is mutually exclusive with shrink size flags. Use with size_flags_horizontal and size_flags_vertical.

SizeFlags SIZE_EXPAND = 2

Tells the parent Container to let this node take all the available space on the axis you flag. If multiple neighboring nodes are set to expand, they'll share the space based on their stretch ratio. See size_flags_stretch_ratio. Use with size_flags_horizontal and size_flags_vertical.

SizeFlags SIZE_EXPAND_FILL = 3

Sets the node's size flags to both fill and expand. See SIZE_FILL and SIZE_EXPAND for more information.

SizeFlags SIZE_SHRINK_CENTER = 4

Tells the parent Container to center the node in the available space. It is mutually exclusive with SIZE_FILL and other shrink size flags, but can be used with SIZE_EXPAND in some containers. Use with size_flags_horizontal and size_flags_vertical.

SizeFlags SIZE_SHRINK_END = 8

Tells the parent Container to align the node with its end, either the bottom or the right edge. It is mutually exclusive with SIZE_FILL and other shrink size flags, but can be used with SIZE_EXPAND in some containers. Use with size_flags_horizontal and size_flags_vertical.

MouseFilter MOUSE_FILTER_STOP = 0

The control will receive mouse movement input events and mouse button input events if clicked on through _gui_input(). The control will also receive the mouse_entered and mouse_exited signals. These events are automatically marked as handled, and they will not propagate further to other controls. This also results in blocking signals in other controls.

MouseFilter MOUSE_FILTER_PASS = 1

The control will receive mouse movement input events and mouse button input events if clicked on through _gui_input(). The control will also receive the mouse_entered and mouse_exited signals.

If this control does not handle the event, the event will propagate up to its parent control if it has one. The event is bubbled up the node hierarchy until it reaches a non-CanvasItem, a control with MOUSE_FILTER_STOP, or a CanvasItem with CanvasItem.top_level enabled. This will allow signals to fire in all controls it reaches. If no control handled it, the event will be passed to Node._shortcut_input() for further processing.

MouseFilter MOUSE_FILTER_IGNORE = 2

The control will not receive any mouse movement input events nor mouse button input events through _gui_input(). The control will also not receive the mouse_entered nor mouse_exited signals. This will not block other controls from receiving these events or firing the signals. Ignored events will not be handled automatically. If a child has MOUSE_FILTER_PASS and an event was passed to this control, the event will further propagate up to the control's parent.

Note: If the control has received mouse_entered but not mouse_exited, changing the mouse_filter to MOUSE_FILTER_IGNORE will cause mouse_exited to be emitted.

enum GrowDirection: 🔗

GrowDirection GROW_DIRECTION_BEGIN = 0

The control will grow to the left or top to make up if its minimum size is changed to be greater than its current size on the respective axis.

GrowDirection GROW_DIRECTION_END = 1

The control will grow to the right or bottom to make up if its minimum size is changed to be greater than its current size on the respective axis.

GrowDirection GROW_DIRECTION_BOTH = 2

The control will grow in both directions equally to make up if its minimum size is changed to be greater than its current size.

Anchor ANCHOR_BEGIN = 0

Snaps one of the 4 anchor's sides to the origin of the node's Rect, in the top left. Use it with one of the anchor_* member variables, like anchor_left. To change all 4 anchors at once, use set_anchors_preset().

Anchor ANCHOR_END = 1

Snaps one of the 4 anchor's sides to the end of the node's Rect, in the bottom right. Use it with one of the anchor_* member variables, like anchor_left. To change all 4 anchors at once, use set_anchors_preset().

enum LayoutDirection: 🔗

LayoutDirection LAYOUT_DIRECTION_INHERITED = 0

Automatic layout direction, determined from the parent control layout direction.

LayoutDirection LAYOUT_DIRECTION_APPLICATION_LOCALE = 1

Automatic layout direction, determined from the current locale. Right-to-left layout direction is automatically used for languages that require it such as Arabic and Hebrew, but only if a valid translation file is loaded for the given language (unless said language is configured as a fallback in ProjectSettings.internationalization/locale/fallback). For all other languages (or if no valid translation file is found by Godot), left-to-right layout direction is used. If using TextServerFallback (ProjectSettings.internationalization/rendering/text_driver), left-to-right layout direction is always used regardless of the language. Right-to-left layout direction can also be forced using ProjectSettings.internationalization/rendering/force_right_to_left_layout_direction.

LayoutDirection LAYOUT_DIRECTION_LTR = 2

Left-to-right layout direction.

LayoutDirection LAYOUT_DIRECTION_RTL = 3

Right-to-left layout direction.

LayoutDirection LAYOUT_DIRECTION_SYSTEM_LOCALE = 4

Automatic layout direction, determined from the system locale. Right-to-left layout direction is automatically used for languages that require it such as Arabic and Hebrew, but only if a valid translation file is loaded for the given language. For all other languages (or if no valid translation file is found by Godot), left-to-right layout direction is used. If using TextServerFallback (ProjectSettings.internationalization/rendering/text_driver), left-to-right layout direction is always used regardless of the language.

LayoutDirection LAYOUT_DIRECTION_MAX = 5

Represents the size of the LayoutDirection enum.

LayoutDirection LAYOUT_DIRECTION_LOCALE = 1

Deprecated: Use LAYOUT_DIRECTION_APPLICATION_LOCALE instead.

enum TextDirection: 🔗

TextDirection TEXT_DIRECTION_INHERITED = 3

Text writing direction is the same as layout direction.

TextDirection TEXT_DIRECTION_AUTO = 0

Automatic text writing direction, determined from the current locale and text content.

TextDirection TEXT_DIRECTION_LTR = 1

Left-to-right text writing direction.

TextDirection TEXT_DIRECTION_RTL = 2

Right-to-left text writing direction.

NOTIFICATION_RESIZED = 40 🔗

Sent when the node changes size. Use size to get the new size.

NOTIFICATION_MOUSE_ENTER = 41 🔗

Sent when the mouse cursor enters the control's (or any child control's) visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect which Control receives the notification.

See also NOTIFICATION_MOUSE_ENTER_SELF.

NOTIFICATION_MOUSE_EXIT = 42 🔗

Sent when the mouse cursor leaves the control's (and all child control's) visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect which Control receives the notification.

See also NOTIFICATION_MOUSE_EXIT_SELF.

NOTIFICATION_MOUSE_ENTER_SELF = 60 🔗

Experimental: The reason this notification is sent may change in the future.

Sent when the mouse cursor enters the control's visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect which Control receives the notification.

See also NOTIFICATION_MOUSE_ENTER.

NOTIFICATION_MOUSE_EXIT_SELF = 61 🔗

Experimental: The reason this notification is sent may change in the future.

Sent when the mouse cursor leaves the control's visible area, that is not occluded behind other Controls or Windows, provided its mouse_filter lets the event reach it and regardless if it's currently focused or not.

Note: CanvasItem.z_index doesn't affect which Control receives the notification.

See also NOTIFICATION_MOUSE_EXIT.

NOTIFICATION_FOCUS_ENTER = 43 🔗

Sent when the node grabs focus.

NOTIFICATION_FOCUS_EXIT = 44 🔗

Sent when the node loses focus.

NOTIFICATION_THEME_CHANGED = 45 🔗

Sent when the node needs to refresh its theme items. This happens in one of the following cases:

The theme property is changed on this node or any of its ancestors.

The theme_type_variation property is changed on this node.

One of the node's theme property overrides is changed.

The node enters the scene tree.

Note: As an optimization, this notification won't be sent from changes that occur while this node is outside of the scene tree. Instead, all of the theme item updates can be applied at once when the node enters the scene tree.

Note: This notification is received alongside Node.NOTIFICATION_ENTER_TREE, so if you are instantiating a scene, the child nodes will not be initialized yet. You can use it to setup theming for this node, child nodes created from script, or if you want to access child nodes added in the editor, make sure the node is ready using Node.is_node_ready().

NOTIFICATION_SCROLL_BEGIN = 47 🔗

Sent when this node is inside a ScrollContainer which has begun being scrolled when dragging the scrollable area with a touch event. This notification is not sent when scrolling by dragging the scrollbar, scrolling with the mouse wheel or scrolling with keyboard/gamepad events.

Note: This signal is only emitted on Android or iOS, or on desktop/web platforms when ProjectSettings.input_devices/pointing/emulate_touch_from_mouse is enabled.

NOTIFICATION_SCROLL_END = 48 🔗

Sent when this node is inside a ScrollContainer which has stopped being scrolled when dragging the scrollable area with a touch event. This notification is not sent when scrolling by dragging the scrollbar, scrolling with the mouse wheel or scrolling with keyboard/gamepad events.

Note: This signal is only emitted on Android or iOS, or on desktop/web platforms when ProjectSettings.input_devices/pointing/emulate_touch_from_mouse is enabled.

NOTIFICATION_LAYOUT_DIRECTION_CHANGED = 49 🔗

Sent when the control layout direction is changed from LTR or RTL or vice versa. This notification is propagated to child Control nodes as result of a change to layout_direction.

Array[NodePath] accessibility_controls_nodes = [] 🔗

void set_accessibility_controls_nodes(value: Array[NodePath])

Array[NodePath] get_accessibility_controls_nodes()

The paths to the nodes which are controlled by this node.

Array[NodePath] accessibility_described_by_nodes = [] 🔗

void set_accessibility_described_by_nodes(value: Array[NodePath])

Array[NodePath] get_accessibility_described_by_nodes()

The paths to the nodes which are describing this node.

String accessibility_description = "" 🔗

void set_accessibility_description(value: String)

String get_accessibility_description()

The human-readable node description that is reported to assistive apps.

Array[NodePath] accessibility_flow_to_nodes = [] 🔗

void set_accessibility_flow_to_nodes(value: Array[NodePath])

Array[NodePath] get_accessibility_flow_to_nodes()

The paths to the nodes which this node flows into.

Array[NodePath] accessibility_labeled_by_nodes = [] 🔗

void set_accessibility_labeled_by_nodes(value: Array[NodePath])

Array[NodePath] get_accessibility_labeled_by_nodes()

The paths to the nodes which label this node.

AccessibilityLiveMode accessibility_live = 0 🔗

void set_accessibility_live(value: AccessibilityLiveMode)

AccessibilityLiveMode get_accessibility_live()

The mode with which a live region updates. A live region is a Node that is updated as a result of an external event when the user's focus may be elsewhere.

String accessibility_name = "" 🔗

void set_accessibility_name(value: String)

String get_accessibility_name()

The human-readable node name that is reported to assistive apps.

float anchor_bottom = 0.0 🔗

float get_anchor(side: Side) const

Anchors the bottom edge of the node to the origin, the center, or the end of its parent control. It changes how the bottom offset updates when the node moves or changes size. You can use one of the Anchor constants for convenience.

float anchor_left = 0.0 🔗

float get_anchor(side: Side) const

Anchors the left edge of the node to the origin, the center or the end of its parent control. It changes how the left offset updates when the node moves or changes size. You can use one of the Anchor constants for convenience.

float anchor_right = 0.0 🔗

float get_anchor(side: Side) const

Anchors the right edge of the node to the origin, the center or the end of its parent control. It changes how the right offset updates when the node moves or changes size. You can use one of the Anchor constants for convenience.

float anchor_top = 0.0 🔗

float get_anchor(side: Side) const

Anchors the top edge of the node to the origin, the center or the end of its parent control. It changes how the top offset updates when the node moves or changes size. You can use one of the Anchor constants for convenience.

bool auto_translate 🔗

void set_auto_translate(value: bool)

bool is_auto_translating()

Deprecated: Use Node.auto_translate_mode and Node.can_auto_translate() instead.

Toggles if any text should automatically change to its translated version depending on the current locale.

bool clip_contents = false 🔗

void set_clip_contents(value: bool)

bool is_clipping_contents()

Enables whether rendering of CanvasItem based children should be clipped to this control's rectangle. If true, parts of a child which would be visibly outside of this control's rectangle will not be rendered and won't receive input.

Vector2 custom_minimum_size = Vector2(0, 0) 🔗

void set_custom_minimum_size(value: Vector2)

Vector2 get_custom_minimum_size()

The minimum size of the node's bounding rectangle. If you set it to a value greater than (0, 0), the node's bounding rectangle will always have at least this size. Note that Control nodes have their internal minimum size returned by get_minimum_size(). It depends on the control's contents, like text, textures, or style boxes. The actual minimum size is the maximum value of this property and the internal minimum size (see get_combined_minimum_size()).

FocusBehaviorRecursive focus_behavior_recursive = 0 🔗

void set_focus_behavior_recursive(value: FocusBehaviorRecursive)

FocusBehaviorRecursive get_focus_behavior_recursive()

Determines which controls can be focused together with focus_mode. See get_focus_mode_with_override(). Since the default behavior is FOCUS_BEHAVIOR_INHERITED, this can be used to prevent all children controls from getting focused.

FocusMode focus_mode = 0 🔗

void set_focus_mode(value: FocusMode)

FocusMode get_focus_mode()

Determines which controls can be focused. Only one control can be focused at a time, and the focused control will receive keyboard, gamepad, and mouse events in _gui_input(). Use get_focus_mode_with_override() to determine if a control can grab focus, since focus_behavior_recursive also affects it. See also grab_focus().

NodePath focus_neighbor_bottom = NodePath("") 🔗

void set_focus_neighbor(side: Side, neighbor: NodePath)

NodePath get_focus_neighbor(side: Side) const

Tells Godot which node it should give focus to if the user presses the down arrow on the keyboard or down on a gamepad by default. You can change the key by editing the ProjectSettings.input/ui_down input action. The node must be a Control. If this property is not set, Godot will give focus to the closest Control to the bottom of this one.

NodePath focus_neighbor_left = NodePath("") 🔗

void set_focus_neighbor(side: Side, neighbor: NodePath)

NodePath get_focus_neighbor(side: Side) const

Tells Godot which node it should give focus to if the user presses the left arrow on the keyboard or left on a gamepad by default. You can change the key by editing the ProjectSettings.input/ui_left input action. The node must be a Control. If this property is not set, Godot will give focus to the closest Control to the left of this one.

NodePath focus_neighbor_right = NodePath("") 🔗

void set_focus_neighbor(side: Side, neighbor: NodePath)

NodePath get_focus_neighbor(side: Side) const

Tells Godot which node it should give focus to if the user presses the right arrow on the keyboard or right on a gamepad by default. You can change the key by editing the ProjectSettings.input/ui_right input action. The node must be a Control. If this property is not set, Godot will give focus to the closest Control to the right of this one.

NodePath focus_neighbor_top = NodePath("") 🔗

void set_focus_neighbor(side: Side, neighbor: NodePath)

NodePath get_focus_neighbor(side: Side) const

Tells Godot which node it should give focus to if the user presses the top arrow on the keyboard or top on a gamepad by default. You can change the key by editing the ProjectSettings.input/ui_up input action. The node must be a Control. If this property is not set, Godot will give focus to the closest Control to the top of this one.

NodePath focus_next = NodePath("") 🔗

void set_focus_next(value: NodePath)

NodePath get_focus_next()

Tells Godot which node it should give focus to if the user presses Tab on a keyboard by default. You can change the key by editing the ProjectSettings.input/ui_focus_next input action.

If this property is not set, Godot will select a "best guess" based on surrounding nodes in the scene tree.

NodePath focus_previous = NodePath("") 🔗

void set_focus_previous(value: NodePath)

NodePath get_focus_previous()

Tells Godot which node it should give focus to if the user presses Shift + Tab on a keyboard by default. You can change the key by editing the ProjectSettings.input/ui_focus_prev input action.

If this property is not set, Godot will select a "best guess" based on surrounding nodes in the scene tree.

Vector2 global_position 🔗

Vector2 get_global_position()

The node's global position, relative to the world (usually to the CanvasLayer).

GrowDirection grow_horizontal = 1 🔗

void set_h_grow_direction(value: GrowDirection)

GrowDirection get_h_grow_direction()

Controls the direction on the horizontal axis in which the control should grow if its horizontal minimum size is changed to be greater than its current size, as the control always has to be at least the minimum size.

GrowDirection grow_vertical = 1 🔗

void set_v_grow_direction(value: GrowDirection)

GrowDirection get_v_grow_direction()

Controls the direction on the vertical axis in which the control should grow if its vertical minimum size is changed to be greater than its current size, as the control always has to be at least the minimum size.

LayoutDirection layout_direction = 0 🔗

void set_layout_direction(value: LayoutDirection)

LayoutDirection get_layout_direction()

Controls layout direction and text writing direction. Right-to-left layouts are necessary for certain languages (e.g. Arabic and Hebrew). See also is_layout_rtl().

bool localize_numeral_system = true 🔗

void set_localize_numeral_system(value: bool)

bool is_localizing_numeral_system()

If true, automatically converts code line numbers, list indices, SpinBox and ProgressBar values from the Western Arabic (0..9) to the numeral systems used in current locale.

Note: Numbers within the text are not automatically converted, it can be done manually, using TextServer.format_number().

MouseBehaviorRecursive mouse_behavior_recursive = 0 🔗

void set_mouse_behavior_recursive(value: MouseBehaviorRecursive)

MouseBehaviorRecursive get_mouse_behavior_recursive()

Determines which controls can receive mouse input together with mouse_filter. See get_mouse_filter_with_override(). Since the default behavior is MOUSE_BEHAVIOR_INHERITED, this can be used to prevent all children controls from receiving mouse input.

CursorShape mouse_default_cursor_shape = 0 🔗

void set_default_cursor_shape(value: CursorShape)

CursorShape get_default_cursor_shape()

The default cursor shape for this control. Useful for Godot plugins and applications or games that use the system's mouse cursors.

Note: On Linux, shapes may vary depending on the cursor theme of the system.

MouseFilter mouse_filter = 0 🔗

void set_mouse_filter(value: MouseFilter)

MouseFilter get_mouse_filter()

Determines which controls will be able to receive mouse button input events through _gui_input() and the mouse_entered, and mouse_exited signals. Also determines how these events should be propagated. See the constants to learn what each does. Use get_mouse_filter_with_override() to determine if a control can receive mouse input, since mouse_behavior_recursive also affects it.

bool mouse_force_pass_scroll_events = true 🔗

void set_force_pass_scroll_events(value: bool)

bool is_force_pass_scroll_events()

When enabled, scroll wheel events processed by _gui_input() will be passed to the parent control even if mouse_filter is set to MOUSE_FILTER_STOP.

You should disable it on the root of your UI if you do not want scroll events to go to the Node._unhandled_input() processing.

Note: Because this property defaults to true, this allows nested scrollable containers to work out of the box.

float offset_bottom = 0.0 🔗

void set_offset(side: Side, offset: float)

float get_offset(offset: Side) const

Distance between the node's bottom edge and its parent control, based on anchor_bottom.

Offsets are often controlled by one or multiple parent Container nodes, so you should not modify them manually if your node is a direct child of a Container. Offsets update automatically when you move or resize the node.

float offset_left = 0.0 🔗

void set_offset(side: Side, offset: float)

float get_offset(offset: Side) const

Distance between the node's left edge and its parent control, based on anchor_left.

Offsets are often controlled by one or multiple parent Container nodes, so you should not modify them manually if your node is a direct child of a Container. Offsets update automatically when you move or resize the node.

float offset_right = 0.0 🔗

void set_offset(side: Side, offset: float)

float get_offset(offset: Side) const

Distance between the node's right edge and its parent control, based on anchor_right.

Offsets are often controlled by one or multiple parent Container nodes, so you should not modify them manually if your node is a direct child of a Container. Offsets update automatically when you move or resize the node.

float offset_top = 0.0 🔗

void set_offset(side: Side, offset: float)

float get_offset(offset: Side) const

Distance between the node's top edge and its parent control, based on anchor_top.

Offsets are often controlled by one or multiple parent Container nodes, so you should not modify them manually if your node is a direct child of a Container. Offsets update automatically when you move or resize the node.

Vector2 pivot_offset = Vector2(0, 0) 🔗

void set_pivot_offset(value: Vector2)

Vector2 get_pivot_offset()

By default, the node's pivot is its top-left corner. When you change its rotation or scale, it will rotate or scale around this pivot. Set this property to size / 2 to pivot around the Control's center.

Vector2 position = Vector2(0, 0) 🔗

Vector2 get_position()

The node's position, relative to its containing node. It corresponds to the rectangle's top-left corner. The property is not affected by pivot_offset.

float rotation = 0.0 🔗

void set_rotation(value: float)

The node's rotation around its pivot, in radians. See pivot_offset to change the pivot's position.

Note: This property is edited in the inspector in degrees. If you want to use degrees in a script, use rotation_degrees.

float rotation_degrees 🔗

void set_rotation_degrees(value: float)

float get_rotation_degrees()

Helper property to access rotation in degrees instead of radians.

Vector2 scale = Vector2(1, 1) 🔗

void set_scale(value: Vector2)

The node's scale, relative to its size. Change this property to scale the node around its pivot_offset. The Control's tooltip will also scale according to this value.

Note: This property is mainly intended to be used for animation purposes. To support multiple resolutions in your project, use an appropriate viewport stretch mode as described in the documentation instead of scaling Controls individually.

Note: FontFile.oversampling does not take Control scale into account. This means that scaling up/down will cause bitmap fonts and rasterized (non-MSDF) dynamic fonts to appear blurry or pixelated. To ensure text remains crisp regardless of scale, you can enable MSDF font rendering by enabling ProjectSettings.gui/theme/default_font_multichannel_signed_distance_field (applies to the default project font only), or enabling Multichannel Signed Distance Field in the import options of a DynamicFont for custom fonts. On system fonts, SystemFont.multichannel_signed_distance_field can be enabled in the inspector.

Note: If the Control node is a child of a Container node, the scale will be reset to Vector2(1, 1) when the scene is instantiated. To set the Control's scale when it's instantiated, wait for one frame using await get_tree().process_frame then set its scale property.

Node shortcut_context 🔗

void set_shortcut_context(value: Node)

Node get_shortcut_context()

The Node which must be a parent of the focused Control for the shortcut to be activated. If null, the shortcut can be activated when any control is focused (a global shortcut). This allows shortcuts to be accepted only when the user has a certain area of the GUI focused.

Vector2 size = Vector2(0, 0) 🔗

The size of the node's bounding rectangle, in the node's coordinate system. Container nodes update this property automatically.

BitField[SizeFlags] size_flags_horizontal = 1 🔗

void set_h_size_flags(value: BitField[SizeFlags])

BitField[SizeFlags] get_h_size_flags()

Tells the parent Container nodes how they should resize and place the node on the X axis. Use a combination of the SizeFlags constants to change the flags. See the constants to learn what each does.

float size_flags_stretch_ratio = 1.0 🔗

void set_stretch_ratio(value: float)

float get_stretch_ratio()

If the node and at least one of its neighbors uses the SIZE_EXPAND size flag, the parent Container will let it take more or less space depending on this property. If this node has a stretch ratio of 2 and its neighbor a ratio of 1, this node will take two thirds of the available space.

BitField[SizeFlags] size_flags_vertical = 1 🔗

void set_v_size_flags(value: BitField[SizeFlags])

BitField[SizeFlags] get_v_size_flags()

Tells the parent Container nodes how they should resize and place the node on the Y axis. Use a combination of the SizeFlags constants to change the flags. See the constants to learn what each does.

void set_theme(value: Theme)

The Theme resource this node and all its Control and Window children use. If a child node has its own Theme resource set, theme items are merged with child's definitions having higher priority.

Note: Window styles will have no effect unless the window is embedded.

StringName theme_type_variation = &"" 🔗

void set_theme_type_variation(value: StringName)

StringName get_theme_type_variation()

The name of a theme type variation used by this Control to look up its own theme items. When empty, the class name of the node is used (e.g. Button for the Button control), as well as the class names of all parent classes (in order of inheritance).

When set, this property gives the highest priority to the type of the specified name. This type can in turn extend another type, forming a dependency chain. See Theme.set_type_variation(). If the theme item cannot be found using this type or its base types, lookup falls back on the class names.

Note: To look up Control's own items use various get_theme_* methods without specifying theme_type.

Note: Theme items are looked for in the tree order, from branch to root, where each Control node is checked for its theme property. The earliest match against any type/class name is returned. The project-level Theme and the default Theme are checked last.

AutoTranslateMode tooltip_auto_translate_mode = 0 🔗

void set_tooltip_auto_translate_mode(value: AutoTranslateMode)

AutoTranslateMode get_tooltip_auto_translate_mode()

Defines if tooltip text should automatically change to its translated version depending on the current locale. Uses the same auto translate mode as this control when set to Node.AUTO_TRANSLATE_MODE_INHERIT.

Note: Tooltips customized using _make_custom_tooltip() do not use this auto translate mode automatically.

String tooltip_text = "" 🔗

void set_tooltip_text(value: String)

String get_tooltip_text()

The default tooltip text. The tooltip appears when the user's mouse cursor stays idle over this control for a few moments, provided that the mouse_filter property is not MOUSE_FILTER_IGNORE. The time required for the tooltip to appear can be changed with the ProjectSettings.gui/timers/tooltip_delay_sec setting.

This string is the default return value of get_tooltip(). Override _get_tooltip() to generate tooltip text dynamically. Override _make_custom_tooltip() to customize the tooltip interface and behavior.

The tooltip popup will use either a default implementation, or a custom one that you can provide by overriding _make_custom_tooltip(). The default tooltip includes a PopupPanel and Label whose theme properties can be customized using Theme methods with the "TooltipPanel" and "TooltipLabel" respectively. For example:

String _accessibility_get_contextual_info() virtual const 🔗

Return the description of the keyboard shortcuts and other contextual help for this control.

bool _can_drop_data(at_position: Vector2, data: Variant) virtual const 🔗

Godot calls this method to test if data from a control's _get_drag_data() can be dropped at at_position. at_position is local to this control.

This method should only be used to test the data. Process the data in _drop_data().

Note: If the drag was initiated by a keyboard shortcut or accessibility_drag(), at_position is set to Vector2.INF, and the currently selected item/text position should be used as the drop position.

void _drop_data(at_position: Vector2, data: Variant) virtual 🔗

Godot calls this method to pass you the data from a control's _get_drag_data() result. Godot first calls _can_drop_data() to test if data is allowed to drop at at_position where at_position is local to this control.

Note: If the drag was initiated by a keyboard shortcut or accessibility_drag(), at_position is set to Vector2.INF, and the currently selected item/text position should be used as the drop position.

String _get_accessibility_container_name(node: Node) virtual const 🔗

Override this method to return a human-readable description of the position of the child node in the custom container, added to the accessibility_name.

Variant _get_drag_data(at_position: Vector2) virtual 🔗

Godot calls this method to get data that can be dragged and dropped onto controls that expect drop data. Returns null if there is no data to drag. Controls that want to receive drop data should implement _can_drop_data() and _drop_data(). at_position is local to this control. Drag may be forced with force_drag().

A preview that will follow the mouse that should represent the data can be set with set_drag_preview(). A good time to set the preview is in this method.

Note: If the drag was initiated by a keyboard shortcut or accessibility_drag(), at_position is set to Vector2.INF, and the currently selected item/text position should be used as the drag position.

Vector2 _get_minimum_size() virtual const 🔗

Virtual method to be implemented by the user. Returns the minimum size for this control. Alternative to custom_minimum_size for controlling minimum size via code. The actual minimum size will be the max value of these two (in each axis separately).

If not overridden, defaults to Vector2.ZERO.

Note: This method will not be called when the script is attached to a Control node that already overrides its minimum size (e.g. Label, Button, PanelContainer etc.). It can only be used with most basic GUI nodes, like Control, Container, Panel etc.

String _get_tooltip(at_position: Vector2) virtual const 🔗

Virtual method to be implemented by the user. Returns the tooltip text for the position at_position in control's local coordinates, which will typically appear when the cursor is resting over this control. See get_tooltip().

Note: If this method returns an empty String and _make_custom_tooltip() is not overridden, no tooltip is displayed.

void _gui_input(event: InputEvent) virtual 🔗

Virtual method to be implemented by the user. Override this method to handle and accept inputs on UI elements. See also accept_event().

Example: Click on the control to print a message:

If the event inherits InputEventMouse, this method will not be called when:

the control's mouse_filter is set to MOUSE_FILTER_IGNORE;

the control is obstructed by another control on top, that doesn't have mouse_filter set to MOUSE_FILTER_IGNORE;

the control's parent has mouse_filter set to MOUSE_FILTER_STOP or has accepted the event;

the control's parent has clip_contents enabled and the event's position is outside the parent's rectangle;

the event's position is outside the control (see _has_point()).

Note: The event's position is relative to this control's origin.

bool _has_point(point: Vector2) virtual const 🔗

Virtual method to be implemented by the user. Returns whether the given point is inside this control.

If not overridden, default behavior is checking if the point is within control's Rect.

Note: If you want to check if a point is inside the control, you can use Rect2(Vector2.ZERO, size).has_point(point).

Object _make_custom_tooltip(for_text: String) virtual const 🔗

Virtual method to be implemented by the user. Returns a Control node that should be used as a tooltip instead of the default one. for_text is the return value of get_tooltip().

The returned node must be of type Control or Control-derived. It can have child nodes of any type. It is freed when the tooltip disappears, so make sure you always provide a new instance (if you want to use a pre-existing node from your scene tree, you can duplicate it and pass the duplicated instance). When null or a non-Control node is returned, the default tooltip will be used instead.

The returned node will be added as child to a PopupPanel, so you should only provide the contents of that panel. That PopupPanel can be themed using Theme.set_stylebox() for the type "TooltipPanel" (see tooltip_text for an example).

Note: The tooltip is shrunk to minimal size. If you want to ensure it's fully visible, you might want to set its custom_minimum_size to some non-zero value.

Note: The node (and any relevant children) should have their CanvasItem.visible set to true when returned, otherwise, the viewport that instantiates it will not be able to calculate its minimum size reliably.

Note: If overridden, this method is called even if get_tooltip() returns an empty string. When this happens with the default tooltip, it is not displayed. To copy this behavior, return null in this method when for_text is empty.

Example: Use a constructed node as a tooltip:

Example: Usa a scene instance as a tooltip:

Array[Vector3i] _structured_text_parser(args: Array, text: String) virtual const 🔗

User defined BiDi algorithm override function.

Returns an Array of Vector3i text ranges and text base directions, in the left-to-right order. Ranges should cover full source text without overlaps. BiDi algorithm will be used on each range separately.

void accept_event() 🔗

Marks an input event as handled. Once you accept an input event, it stops propagating, even to nodes listening to Node._unhandled_input() or Node._unhandled_key_input().

Note: This does not affect the methods in Input, only the way events are propagated.

void accessibility_drag() 🔗

Starts drag-and-drop operation without using a mouse.

void accessibility_drop() 🔗

Ends drag-and-drop operation without using a mouse.

void add_theme_color_override(name: StringName, color: Color) 🔗

Creates a local override for a theme Color with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_color_override().

See also get_theme_color().

Example: Override a Label's color and reset it later:

void add_theme_constant_override(name: StringName, constant: int) 🔗

Creates a local override for a theme constant with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_constant_override().

See also get_theme_constant().

void add_theme_font_override(name: StringName, font: Font) 🔗

Creates a local override for a theme Font with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_font_override().

See also get_theme_font().

void add_theme_font_size_override(name: StringName, font_size: int) 🔗

Creates a local override for a theme font size with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_font_size_override().

See also get_theme_font_size().

void add_theme_icon_override(name: StringName, texture: Texture2D) 🔗

Creates a local override for a theme icon with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_icon_override().

See also get_theme_icon().

void add_theme_stylebox_override(name: StringName, stylebox: StyleBox) 🔗

Creates a local override for a theme StyleBox with the specified name. Local overrides always take precedence when fetching theme items for the control. An override can be removed with remove_theme_stylebox_override().

See also get_theme_stylebox().

Example: Modify a property in a StyleBox by duplicating it:

void begin_bulk_theme_override() 🔗

Prevents *_theme_*_override methods from emitting NOTIFICATION_THEME_CHANGED until end_bulk_theme_override() is called.

void end_bulk_theme_override() 🔗

Ends a bulk theme override update. See begin_bulk_theme_override().

Control find_next_valid_focus() const 🔗

Finds the next (below in the tree) Control that can receive the focus.

Control find_prev_valid_focus() const 🔗

Finds the previous (above in the tree) Control that can receive the focus.

Control find_valid_focus_neighbor(side: Side) const 🔗

Finds the next Control that can receive the focus on the specified Side.

Note: This is different from get_focus_neighbor(), which returns the path of a specified focus neighbor.

void force_drag(data: Variant, preview: Control) 🔗

Forces drag and bypasses _get_drag_data() and set_drag_preview() by passing data and preview. Drag will start even if the mouse is neither over nor pressed on this control.

The methods _can_drop_data() and _drop_data() must be implemented on controls that want to receive drop data.

float get_anchor(side: Side) const 🔗

Returns the anchor for the specified Side. A getter method for anchor_bottom, anchor_left, anchor_right and anchor_top.

Vector2 get_begin() const 🔗

Returns offset_left and offset_top. See also position.

Vector2 get_combined_minimum_size() const 🔗

Returns combined minimum size from custom_minimum_size and get_minimum_size().

CursorShape get_cursor_shape(position: Vector2 = Vector2(0, 0)) const 🔗

Returns the mouse cursor shape for this control when hovered over position in local coordinates. For most controls, this is the same as mouse_default_cursor_shape, but some built-in controls implement more complex logic.

Vector2 get_end() const 🔗

Returns offset_right and offset_bottom.

FocusMode get_focus_mode_with_override() const 🔗

Returns the focus_mode, but takes the focus_behavior_recursive into account. If focus_behavior_recursive is set to FOCUS_BEHAVIOR_DISABLED, or it is set to FOCUS_BEHAVIOR_INHERITED and its ancestor is set to FOCUS_BEHAVIOR_DISABLED, then this returns FOCUS_NONE.

NodePath get_focus_neighbor(side: Side) const 🔗

Returns the focus neighbor for the specified Side. A getter method for focus_neighbor_bottom, focus_neighbor_left, focus_neighbor_right and focus_neighbor_top.

Note: To find the next Control on the specific Side, even if a neighbor is not assigned, use find_valid_focus_neighbor().

Rect2 get_global_rect() const 🔗

Returns the position and size of the control relative to the containing canvas. See global_position and size.

Note: If the node itself or any parent CanvasItem between the node and the canvas have a non default rotation or skew, the resulting size is likely not meaningful.

Note: Setting Viewport.gui_snap_controls_to_pixels to true can lead to rounding inaccuracies between the displayed control and the returned Rect2.

Vector2 get_minimum_size() const 🔗

Returns the minimum size for this control. See custom_minimum_size.

MouseFilter get_mouse_filter_with_override() const 🔗

Returns the mouse_filter, but takes the mouse_behavior_recursive into account. If mouse_behavior_recursive is set to MOUSE_BEHAVIOR_DISABLED, or it is set to MOUSE_BEHAVIOR_INHERITED and its ancestor is set to MOUSE_BEHAVIOR_DISABLED, then this returns MOUSE_FILTER_IGNORE.

float get_offset(offset: Side) const 🔗

Returns the offset for the specified Side. A getter method for offset_bottom, offset_left, offset_right and offset_top.

Vector2 get_parent_area_size() const 🔗

Returns the width/height occupied in the parent control.

Control get_parent_control() const 🔗

Returns the parent control node.

Rect2 get_rect() const 🔗

Returns the position and size of the control in the coordinate system of the containing node. See position, scale and size.

Note: If rotation is not the default rotation, the resulting size is not meaningful.

Note: Setting Viewport.gui_snap_controls_to_pixels to true can lead to rounding inaccuracies between the displayed control and the returned Rect2.

Vector2 get_screen_position() const 🔗

Returns the position of this Control in global screen coordinates (i.e. taking window position into account). Mostly useful for editor plugins.

Equals to global_position if the window is embedded (see Viewport.gui_embed_subwindows).

Example: Show a popup at the mouse position:

Color get_theme_color(name: StringName, theme_type: StringName = &"") const 🔗

Returns a Color from the first matching Theme in the tree if that Theme has a color item with the specified name and theme_type. If theme_type is omitted the class name of the current control is used as the type, or theme_type_variation if it is defined. If the type is a class name its parent classes are also checked, in order of inheritance. If the type is a variation its base types are checked, in order of dependency, then the control's class name and its parent classes are checked.

For the current control its local overrides are considered first (see add_theme_color_override()), then its assigned theme. After the current control, each parent control and its assigned theme are considered; controls without a theme assigned are skipped. If no matching Theme is found in the tree, the custom project Theme (see ProjectSettings.gui/theme/custom) and the default Theme are used (see ThemeDB).

int get_theme_constant(name: StringName, theme_type: StringName = &"") const 🔗

Returns a constant from the first matching Theme in the tree if that Theme has a constant item with the specified name and theme_type.

See get_theme_color() for details.

float get_theme_default_base_scale() const 🔗

Returns the default base scale value from the first matching Theme in the tree if that Theme has a valid Theme.default_base_scale value.

See get_theme_color() for details.

Font get_theme_default_font() const 🔗

Returns the default font from the first matching Theme in the tree if that Theme has a valid Theme.default_font value.

See get_theme_color() for details.

int get_theme_default_font_size() const 🔗

Returns the default font size value from the first matching Theme in the tree if that Theme has a valid Theme.default_font_size value.

See get_theme_color() for details.

Font get_theme_font(name: StringName, theme_type: StringName = &"") const 🔗

Returns a Font from the first matching Theme in the tree if that Theme has a font item with the specified name and theme_type.

See get_theme_color() for details.

int get_theme_font_size(name: StringName, theme_type: StringName = &"") const 🔗

Returns a font size from the first matching Theme in the tree if that Theme has a font size item with the specified name and theme_type.

See get_theme_color() for details.

Texture2D get_theme_icon(name: StringName, theme_type: StringName = &"") const 🔗

Returns an icon from the first matching Theme in the tree if that Theme has an icon item with the specified name and theme_type.

See get_theme_color() for details.

StyleBox get_theme_stylebox(name: StringName, theme_type: StringName = &"") const 🔗

Returns a StyleBox from the first matching Theme in the tree if that Theme has a stylebox item with the specified name and theme_type.

See get_theme_color() for details.

String get_tooltip(at_position: Vector2 = Vector2(0, 0)) const 🔗

Returns the tooltip text for the position at_position in control's local coordinates, which will typically appear when the cursor is resting over this control. By default, it returns tooltip_text.

This method can be overridden to customize its behavior. See _get_tooltip().

Note: If this method returns an empty String and _make_custom_tooltip() is not overridden, no tooltip is displayed.

void grab_click_focus() 🔗

Creates an InputEventMouseButton that attempts to click the control. If the event is received, the control gains focus.

Steal the focus from another control and become the focused control (see focus_mode).

Note: Using this method together with Callable.call_deferred() makes it more reliable, especially when called inside Node._ready().

bool has_focus() const 🔗

Returns true if this is the current focused control. See focus_mode.

bool has_theme_color(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has a color item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_color_override(name: StringName) const 🔗

Returns true if there is a local override for a theme Color with the specified name in this Control node.

See add_theme_color_override().

bool has_theme_constant(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has a constant item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_constant_override(name: StringName) const 🔗

Returns true if there is a local override for a theme constant with the specified name in this Control node.

See add_theme_constant_override().

bool has_theme_font(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has a font item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_font_override(name: StringName) const 🔗

Returns true if there is a local override for a theme Font with the specified name in this Control node.

See add_theme_font_override().

bool has_theme_font_size(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has a font size item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_font_size_override(name: StringName) const 🔗

Returns true if there is a local override for a theme font size with the specified name in this Control node.

See add_theme_font_size_override().

bool has_theme_icon(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has an icon item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_icon_override(name: StringName) const 🔗

Returns true if there is a local override for a theme icon with the specified name in this Control node.

See add_theme_icon_override().

bool has_theme_stylebox(name: StringName, theme_type: StringName = &"") const 🔗

Returns true if there is a matching Theme in the tree that has a stylebox item with the specified name and theme_type.

See get_theme_color() for details.

bool has_theme_stylebox_override(name: StringName) const 🔗

Returns true if there is a local override for a theme StyleBox with the specified name in this Control node.

See add_theme_stylebox_override().

bool is_drag_successful() const 🔗

Returns true if a drag operation is successful. Alternative to Viewport.gui_is_drag_successful().

Best used with Node.NOTIFICATION_DRAG_END.

bool is_layout_rtl() const 🔗

Returns true if the layout is right-to-left. See also layout_direction.

void release_focus() 🔗

Give up the focus. No other control will be able to receive input.

void remove_theme_color_override(name: StringName) 🔗

Removes a local override for a theme Color with the specified name previously added by add_theme_color_override() or via the Inspector dock.

void remove_theme_constant_override(name: StringName) 🔗

Removes a local override for a theme constant with the specified name previously added by add_theme_constant_override() or via the Inspector dock.

void remove_theme_font_override(name: StringName) 🔗

Removes a local override for a theme Font with the specified name previously added by add_theme_font_override() or via the Inspector dock.

void remove_theme_font_size_override(name: StringName) 🔗

Removes a local override for a theme font size with the specified name previously added by add_theme_font_size_override() or via the Inspector dock.

void remove_theme_icon_override(name: StringName) 🔗

Removes a local override for a theme icon with the specified name previously added by add_theme_icon_override() or via the Inspector dock.

void remove_theme_stylebox_override(name: StringName) 🔗

Removes a local override for a theme StyleBox with the specified name previously added by add_theme_stylebox_override() or via the Inspector dock.

Resets the size to get_combined_minimum_size(). This is equivalent to calling set_size(Vector2()) (or any size below the minimum).

void set_anchor(side: Side, anchor: float, keep_offset: bool = false, push_opposite_anchor: bool = true) 🔗

Sets the anchor for the specified Side to anchor. A setter method for anchor_bottom, anchor_left, anchor_right and anchor_top.

If keep_offset is true, offsets aren't updated after this operation.

If push_opposite_anchor is true and the opposite anchor overlaps this anchor, the opposite one will have its value overridden. For example, when setting left anchor to 1 and the right anchor has value of 0.5, the right anchor will also get value of 1. If push_opposite_anchor was false, the left anchor would get value 0.5.

void set_anchor_and_offset(side: Side, anchor: float, offset: float, push_opposite_anchor: bool = false) 🔗

Works the same as set_anchor(), but instead of keep_offset argument and automatic update of offset, it allows to set the offset yourself (see set_offset()).

void set_anchors_and_offsets_preset(preset: LayoutPreset, resize_mode: LayoutPresetMode = 0, margin: int = 0) 🔗

Sets both anchor preset and offset preset. See set_anchors_preset() and set_offsets_preset().

void set_anchors_preset(preset: LayoutPreset, keep_offsets: bool = false) 🔗

Sets the anchors to a preset from LayoutPreset enum. This is the code equivalent to using the Layout menu in the 2D editor.

If keep_offsets is true, control's position will also be updated.

void set_begin(position: Vector2) 🔗

Sets offset_left and offset_top at the same time. Equivalent of changing position.

void set_drag_forwarding(drag_func: Callable, can_drop_func: Callable, drop_func: Callable) 🔗

Sets the given callables to be used instead of the control's own drag-and-drop virtual methods. If a callable is empty, its respective virtual method is used as normal.

The arguments for each callable should be exactly the same as their respective virtual methods, which would be:

drag_func corresponds to _get_drag_data() and requires a Vector2;

can_drop_func corresponds to _can_drop_data() and requires both a Vector2 and a Variant;

drop_func corresponds to _drop_data() and requires both a Vector2 and a Variant.

void set_drag_preview(control: Control) 🔗

Shows the given control at the mouse pointer. A good time to call this method is in _get_drag_data(). The control must not be in the scene tree. You should not free the control, and you should not keep a reference to the control beyond the duration of the drag. It will be deleted automatically after the drag has ended.

void set_end(position: Vector2) 🔗

Sets offset_right and offset_bottom at the same time.

void set_focus_neighbor(side: Side, neighbor: NodePath) 🔗

Sets the focus neighbor for the specified Side to the Control at neighbor node path. A setter method for focus_neighbor_bottom, focus_neighbor_left, focus_neighbor_right and focus_neighbor_top.

void set_global_position(position: Vector2, keep_offsets: bool = false) 🔗

Sets the global_position to given position.

If keep_offsets is true, control's anchors will be updated instead of offsets.

void set_offset(side: Side, offset: float) 🔗

Sets the offset for the specified Side to offset. A setter method for offset_bottom, offset_left, offset_right and offset_top.

void set_offsets_preset(preset: LayoutPreset, resize_mode: LayoutPresetMode = 0, margin: int = 0) 🔗

Sets the offsets to a preset from LayoutPreset enum. This is the code equivalent to using the Layout menu in the 2D editor.

Use parameter resize_mode with constants from LayoutPresetMode to better determine the resulting size of the Control. Constant size will be ignored if used with presets that change size, e.g. PRESET_LEFT_WIDE.

Use parameter margin to determine the gap between the Control and the edges.

void set_position(position: Vector2, keep_offsets: bool = false) 🔗

Sets the position to given position.

If keep_offsets is true, control's anchors will be updated instead of offsets.

void set_size(size: Vector2, keep_offsets: bool = false) 🔗

Sets the size (see size).

If keep_offsets is true, control's anchors will be updated instead of offsets.

void update_minimum_size() 🔗

Invalidates the size cache in this node and in parent nodes up to top level. Intended to be used with get_minimum_size() when the return value is changed. Setting custom_minimum_size directly calls this method automatically.

void warp_mouse(position: Vector2) 🔗

Moves the mouse cursor to position, relative to position of this Control.

Note: warp_mouse() is only supported on Windows, macOS and Linux. It has no effect on Android, iOS and Web.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _on_mouse_exited():
    if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
        # Not hovering over area.
```

Example 2 (unknown):
```unknown
func _notification(what):
    if what == NOTIFICATION_THEME_CHANGED:
        if not is_node_ready():
            await ready # Wait until ready signal.
        $Label.add_theme_color_override("font_color", Color.YELLOW)
```

Example 3 (unknown):
```unknown
var style_box = StyleBoxFlat.new()
style_box.set_bg_color(Color(1, 1, 0))
style_box.set_border_width_all(2)
# We assume here that the `theme` property has been assigned a custom Theme beforehand.
theme.set_stylebox("panel", "TooltipPanel", style_box)
theme.set_color("font_color", "TooltipLabel", Color(0, 1, 1))
```

Example 4 (unknown):
```unknown
var styleBox = new StyleBoxFlat();
styleBox.SetBgColor(new Color(1, 1, 0));
styleBox.SetBorderWidthAll(2);
// We assume here that the `Theme` property has been assigned a custom Theme beforehand.
Theme.SetStyleBox("panel", "TooltipPanel", styleBox);
Theme.SetColor("font_color", "TooltipLabel", new Color(0, 1, 1));
```

---

## Control node gallery — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html

**Contents:**
- Control node gallery
- User-contributed notes

Here is a list of common Control nodes with their name next to them:

The Control Gallery demo pictured above can be found on GitHub.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Custom GUI controls — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html

**Contents:**
- Custom GUI controls
- So many controls...
- Drawing
  - Checking control size
  - Checking focus
- Sizing
- Input
  - Input events
  - Notifications
- User-contributed notes

The content of this page was not yet updated for Godot 4.5 and may be outdated. If you know how to improve this page or you can confirm that it's up to date, feel free to open a pull request.

Yet there are never enough. Creating your own custom controls that act just the way you want them to is an obsession of almost every GUI programmer. Godot provides plenty of them, but they may not work exactly the way you want. Before contacting the developers with a pull-request to support diagonal scrollbars, at least it will be good to know how to create these controls easily from script.

For drawing, it is recommended to check the Custom drawing in 2D tutorial. The same applies. Some functions are worth mentioning due to their usefulness when drawing, so they will be detailed next:

Unlike 2D nodes, "size" is important with controls, as it helps to organize them in proper layouts. For this, the Control.size property is provided. Checking it during _draw() is vital to ensure everything is kept in-bounds.

Some controls (such as buttons or text editors) might provide input focus for keyboard or joypad input. Examples of this are entering text or pressing a button. This is controlled with the Control.focus_mode property. When drawing, and if the control supports input focus, it is always desired to show some sort of indicator (highlight, box, etc.) to indicate that this is the currently focused control. To check for this status, the Control.has_focus() method exists. Example

As mentioned before, size is important to controls. This allows them to lay out properly, when set into grids, containers, or anchored. Controls, most of the time, provide a minimum size to help properly lay them out. For example, if controls are placed vertically on top of each other using a VBoxContainer, the minimum size will make sure your custom control is not squished by the other controls in the container.

To provide this callback, just override Control._get_minimum_size(), for example:

Alternatively, set it using a function:

Controls provide a few helpers to make managing input events much easier than regular nodes.

There are a few tutorials about input before this one, but it's worth mentioning that controls have a special input method that only works when:

The mouse pointer is over the control.

The button was pressed over this control (control always captures input until button is released)

Control provides keyboard/joypad focus via Control.focus_mode.

This function is Control._gui_input(). To use it, override it in your control. No processing needs to be set.

For more information about events themselves, check the Using InputEvent tutorial.

Controls also have many useful notifications for which no dedicated callback exists, but which can be checked with the _notification callback:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _draw():
    if has_focus():
         draw_selected()
    else:
         draw_normal()
```

Example 2 (unknown):
```unknown
public override void _Draw()
{
    if (HasFocus())
    {
        DrawSelected()
    }
    else
    {
        DrawNormal();
    }
}
```

Example 3 (unknown):
```unknown
func _get_minimum_size():
    return Vector2(30, 30)
```

Example 4 (unknown):
```unknown
public override Vector2 _GetMinimumSize()
{
    return new Vector2(20, 20);
}
```

---

## EditorCommandPalette — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_editorcommandpalette.html

**Contents:**
- EditorCommandPalette
- Description
- Properties
- Methods
- Method Descriptions
- User-contributed notes

Inherits: ConfirmationDialog < AcceptDialog < Window < Viewport < Node < Object

Godot editor's command palette.

Object that holds all the available Commands and their shortcuts text. These Commands can be accessed through Editor > Command Palette menu.

Command key names use slash delimiters to distinguish sections, for example: "example/command1" then example will be the section name.

Note: This class shouldn't be instantiated directly. Instead, access the singleton using EditorInterface.get_command_palette().

false (overrides AcceptDialog)

add_command(command_name: String, key_name: String, binded_callable: Callable, shortcut_text: String = "None")

remove_command(key_name: String)

void add_command(command_name: String, key_name: String, binded_callable: Callable, shortcut_text: String = "None") 🔗

Adds a custom command to EditorCommandPalette.

command_name: String (Name of the Command. This is displayed to the user.)

key_name: String (Name of the key for a particular Command. This is used to uniquely identify the Command.)

binded_callable: Callable (Callable of the Command. This will be executed when the Command is selected.)

shortcut_text: String (Shortcut text of the Command if available.)

void remove_command(key_name: String) 🔗

Removes the custom command from EditorCommandPalette.

key_name: String (Name of the key for a particular Command.)

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
var command_palette = EditorInterface.get_command_palette()
# external_command is a function that will be called with the command is executed.
var command_callable = Callable(self, "external_command").bind(arguments)
command_palette.add_command("command", "test/command",command_callable)
```

Example 2 (unknown):
```unknown
EditorCommandPalette commandPalette = EditorInterface.Singleton.GetCommandPalette();
// ExternalCommand is a function that will be called with the command is executed.
Callable commandCallable = new Callable(this, MethodName.ExternalCommand);
commandPalette.AddCommand("command", "test/command", commandCallable)
```

---

## FoldableContainer — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/classes/class_foldablecontainer.html

**Contents:**
- FoldableContainer
- Description
- Properties
- Methods
- Theme Properties
- Signals
- Enumerations
- Property Descriptions
- Method Descriptions
- Theme Property Descriptions

Inherits: Container < Control < CanvasItem < Node < Object

A container that can be expanded/collapsed.

A container that can be expanded/collapsed, with a title that can be filled with controls, such as buttons.

The title can be positioned at the top or bottom of the container.

The container can be expanded or collapsed by clicking the title or by pressing ui_accept when focused.

Child control nodes are hidden when the container is collapsed. Ignores non-control children.

Can allow grouping with other FoldableContainers, check foldable_group and FoldableGroup.

2 (overrides Control)

0 (overrides Control)

title_text_overrun_behavior

add_title_bar_control(control: Control)

remove_title_bar_control(control: Control)

Color(0.875, 0.875, 0.875, 1)

Color(0.95, 0.95, 0.95, 1)

expanded_arrow_mirrored

folded_arrow_mirrored

title_collapsed_hover_panel

title_collapsed_panel

folding_changed(is_folded: bool) 🔗

Emitted when the container is folded/expanded.

enum TitlePosition: 🔗

TitlePosition POSITION_TOP = 0

Makes the title appear at the top of the container.

TitlePosition POSITION_BOTTOM = 1

Makes the title appear at the bottom of the container. Also makes all StyleBoxes flipped vertically.

FoldableGroup foldable_group 🔗

void set_foldable_group(value: FoldableGroup)

FoldableGroup get_foldable_group()

The FoldableGroup associated with the container. When multiple FoldableContainer nodes share the same group, only one of them is allowed to be unfolded.

bool folded = false 🔗

void set_folded(value: bool)

If true, the container will becomes folded and will hide all its children.

String language = "" 🔗

void set_language(value: String)

String get_language()

Language code used for text shaping algorithms. If left empty, current locale is used instead.

void set_title(value: String)

The container's title text.

HorizontalAlignment title_alignment = 0 🔗

void set_title_alignment(value: HorizontalAlignment)

HorizontalAlignment get_title_alignment()

Title's horizontal text alignment.

TitlePosition title_position = 0 🔗

void set_title_position(value: TitlePosition)

TitlePosition get_title_position()

TextDirection title_text_direction = 0 🔗

void set_title_text_direction(value: TextDirection)

TextDirection get_title_text_direction()

Title text writing direction.

OverrunBehavior title_text_overrun_behavior = 0 🔗

void set_title_text_overrun_behavior(value: OverrunBehavior)

OverrunBehavior get_title_text_overrun_behavior()

Defines the behavior of the title when the text is longer than the available space.

void add_title_bar_control(control: Control) 🔗

Adds a Control that will be placed next to the container's title, obscuring the clickable area. Prime usage is adding Button nodes, but it can be any Control.

The control will be added as a child of this container and removed from previous parent if necessary. The controls will be placed aligned to the right, with the first added control being the leftmost one.

Expands the container and emits folding_changed.

Folds the container and emits folding_changed.

void remove_title_bar_control(control: Control) 🔗

Removes a Control added with add_title_bar_control(). The node is not freed automatically, you need to use Node.queue_free().

Color collapsed_font_color = Color(1, 1, 1, 1) 🔗

The title's font color when collapsed.

Color font_color = Color(0.875, 0.875, 0.875, 1) 🔗

The title's font color when expanded.

Color font_outline_color = Color(1, 1, 1, 1) 🔗

The title's font outline color.

Color hover_font_color = Color(0.95, 0.95, 0.95, 1) 🔗

The title's font hover color.

int h_separation = 2 🔗

The horizontal separation between the title's icon and text, and between title bar controls.

int outline_size = 0 🔗

The title's font outline size.

The title's font size.

Texture2D expanded_arrow 🔗

The title's icon used when expanded.

Texture2D expanded_arrow_mirrored 🔗

The title's icon used when expanded (for bottom title).

Texture2D folded_arrow 🔗

The title's icon used when folded (for left-to-right layouts).

Texture2D folded_arrow_mirrored 🔗

The title's icon used when collapsed (for right-to-left layouts).

Background used when FoldableContainer has GUI focus. The focus StyleBox is displayed over the base StyleBox, so a partially transparent StyleBox should be used to ensure the base StyleBox remains visible. A StyleBox that represents an outline or an underline works well for this purpose. To disable the focus visual effect, assign a StyleBoxEmpty resource. Note that disabling the focus visual effect will harm keyboard/controller navigation usability, so this is not recommended for accessibility reasons.

Default background for the FoldableContainer.

StyleBox title_collapsed_hover_panel 🔗

Background used when the mouse cursor enters the title's area when collapsed.

StyleBox title_collapsed_panel 🔗

Default background for the FoldableContainer's title when collapsed.

StyleBox title_hover_panel 🔗

Background used when the mouse cursor enters the title's area when expanded.

StyleBox title_panel 🔗

Default background for the FoldableContainer's title when expanded.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Gradle builds for Android — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/export/android_gradle_build.html

**Contents:**
- Gradle builds for Android
- Set up the gradle build environment
- Enabling the gradle build and exporting
- User-contributed notes

Godot provides the option to build using the gradle buildsystem. Instead of using the already pre-built template that ships with Godot, an Android Java project gets installed into your project folder. Godot will then build it and use it as an export template every time you export the project.

There are some reasons why you may want to do this:

Modify the project before it's built.

Add external SDKs that build with your project.

Configuring the gradle build is a fairly straightforward process. But first you need to follow the steps in exporting for android up to Setting it up in Godot. After doing that, follow the steps below.

Go to the Project menu, and install the Gradle Build template:

Make sure export templates are downloaded. If not, this menu will help you download them.

A Gradle-based Android project will be created under res://android/build. Editing these files is not needed unless you really need to modify the project.

When setting up the Android project in the Project > Export dialog, Gradle Build needs to be enabled:

From now on, attempting to export the project or one-click deploy will call the Gradle build system to generate fresh templates (this window will appear every time):

The templates built will be used automatically afterwards, so no further configuration is needed.

When using the gradle Android build system, assets that are placed within a folder whose name begins with an underscore will not be included in the generated APK. This does not apply to assets whose file name begins with an underscore.

For example, _example/image.png will not be included as an asset, but _image.png will.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Handling quit requests — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/inputs/handling_quit_requests.html

**Contents:**
- Handling quit requests
- Quitting
- Handling the notification
- On mobile devices
- Sending your own quit notification
- User-contributed notes

Most platforms have the option to request the application to quit. On desktops, this is usually done with the "x" icon on the window title bar. On mobile devices, the app can quit at any time while it is suspended to the background.

On desktop and web platforms, Node receives a special NOTIFICATION_WM_CLOSE_REQUEST notification when quitting is requested from the window manager.

Handling the notification is done as follows (on any node):

It is important to note that by default, Godot apps have the built-in behavior to quit when quit is requested from the window manager. This can be changed, so that the user can take care of the complete quitting procedure:

There is no direct equivalent to NOTIFICATION_WM_CLOSE_REQUEST on mobile platforms. Due to the nature of mobile operating systems, the only place that you can run code prior to quitting is when the app is being suspended to the background. On both Android and iOS, the app can be killed while suspended at any time by either the user or the OS. A way to plan ahead for this possibility is to utilize NOTIFICATION_APPLICATION_PAUSED in order to perform any needed actions as the app is being suspended.

On iOS, you only have approximately 5 seconds to finish a task started by this signal. If you go over this allotment, iOS will kill the app instead of pausing it.

On Android, pressing the Back button will exit the application if Application > Config > Quit On Go Back is checked in the Project Settings (which is the default). This will fire NOTIFICATION_WM_GO_BACK_REQUEST.

While forcing the application to close can be done by calling SceneTree.quit, doing so will not send the NOTIFICATION_WM_CLOSE_REQUEST to the nodes in the scene tree. Quitting by calling SceneTree.quit will not allow custom actions to complete (such as saving, confirming the quit, or debugging), even if you try to delay the line that forces the quit.

Instead, if you want to notify the nodes in the scene tree about the upcoming program termination, you should send the notification yourself:

Sending this notification will inform all nodes about the program termination, but will not terminate the program itself unlike in 3.X. In order to achieve the previous behavior, SceneTree.quit should be called after the notification.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _notification(what):
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        get_tree().quit() # default behavior
```

Example 2 (unknown):
```unknown
public override void _Notification(int what)
{
    if (what == NotificationWMCloseRequest)
    {
        GetTree().Quit(); // default behavior
    }
}
```

Example 3 (unknown):
```unknown
get_tree().set_auto_accept_quit(false)
```

Example 4 (unknown):
```unknown
GetTree().AutoAcceptQuit = false;
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

## Inspector plugins — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/plugins/editor/inspector_plugins.html

**Contents:**
- Inspector plugins
- Setting up your plugin
- Interacting with the inspector
- Adding an interface to edit properties
- User-contributed notes

The inspector dock allows you to create custom widgets to edit properties through plugins. This can be beneficial when working with custom datatypes and resources, although you can use the feature to change the inspector widgets for built-in types. You can design custom controls for specific properties, entire objects, and even separate controls associated with particular datatypes.

This guide explains how to use the EditorInspectorPlugin and EditorProperty classes to create a custom interface for integers, replacing the default behavior with a button that generates random values between 0 and 99.

The default behavior on the left and the end result on the right.

Create a new empty plugin to get started.

See Making plugins guide to set up your new plugin.

Let's assume you've called your plugin folder my_inspector_plugin. If so, you should end up with a new addons/my_inspector_plugin folder that contains two files: plugin.cfg and plugin.gd.

As before, plugin.gd is a script extending EditorPlugin and you need to introduce new code for its _enter_tree and _exit_tree methods. To set up your inspector plugin, you must load its script, then create and add the instance by calling add_inspector_plugin(). If the plugin is disabled, you should remove the instance you have added by calling remove_inspector_plugin().

Here, you are loading a script and not a packed scene. Therefore you should use new() instead of instantiate().

To interact with the inspector dock, your my_inspector_plugin.gd script must extend the EditorInspectorPlugin class. This class provides several virtual methods that affect how the inspector handles properties.

To have any effect at all, the script must implement the _can_handle() method. This function is called for each edited Object and must return true if this plugin should handle the object or its properties.

This includes any Resource attached to the object.

You can implement four other methods to add controls to the inspector at specific positions. The _parse_begin() and _parse_end() methods are called only once at the beginning and the end of parsing for each object, respectively. They can add controls at the top or bottom of the inspector layout by calling add_custom_control().

As the editor parses the object, it calls the _parse_category() and _parse_property() methods. There, in addition to add_custom_control(), you can call both add_property_editor() and add_property_editor_for_multiple_properties(). Use these last two methods to specifically add EditorProperty-based controls.

The EditorProperty class is a special type of Control that can interact with the inspector dock's edited objects. It doesn't display anything but can house any other control nodes, including complex scenes.

There are three essential parts to the script extending EditorProperty:

You must define the _init() method to set up the control nodes' structure.

You should implement the _update_property() to handle changes to the data from the outside.

A signal must be emitted at some point to inform the inspector that the control has changed the property using emit_changed.

You can display your custom widget in two ways. Use just the default add_child() method to display it to the right of the property name, and use add_child() followed by set_bottom_editor() to position it below the name.

Using the example code above you should be able to make a custom widget that replaces the default SpinBox control for integers with a Button that generates random values.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
# plugin.gd
@tool
extends EditorPlugin

var plugin


func _enter_tree():
    plugin = preload("res://addons/my_inspector_plugin/my_inspector_plugin.gd").new()
    add_inspector_plugin(plugin)


func _exit_tree():
    remove_inspector_plugin(plugin)
```

Example 2 (unknown):
```unknown
// Plugin.cs
#if TOOLS
using Godot;

[Tool]
public partial class Plugin : EditorPlugin
{
    private MyInspectorPlugin _plugin;

    public override void _EnterTree()
    {
        _plugin = new MyInspectorPlugin();
        AddInspectorPlugin(_plugin);
    }

    public override void _ExitTree()
    {
        RemoveInspectorPlugin(_plugin);
    }
}
#endif
```

Example 3 (gdscript):
```gdscript
# my_inspector_plugin.gd
extends EditorInspectorPlugin

var RandomIntEditor = preload("res://addons/my_inspector_plugin/random_int_editor.gd")


func _can_handle(object):
    # We support all objects in this example.
    return true


func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
    # We handle properties of type integer.
    if type == TYPE_INT:
        # Create an instance of the custom property editor and register
        # it to a specific property path.
        add_property_editor(name, RandomIntEditor.new())
        # Inform the editor to remove the default property editor for
        # this property type.
        return true
    else:
        return false
```

Example 4 (unknown):
```unknown
// MyInspectorPlugin.cs
#if TOOLS
using Godot;

public partial class MyInspectorPlugin : EditorInspectorPlugin
{
    public override bool _CanHandle(GodotObject @object)
    {
        // We support all objects in this example.
        return true;
    }

    public override bool _ParseProperty(GodotObject @object, Variant.Type type,
        string name, PropertyHint hintType, string hintString,
        PropertyUsageFlags usageFlags, bool wide)
    {
        // We handle properties of type integer.
        if (type == Variant.Type.Int)
        {
            // Create an instance of the custom property editor and register
            // it to a specific property path.
            AddPropertyEditor(name, new RandomIntEditor());
            // Inform the editor to remove the default property editor for
            // this property type.
            return true;
        }

        return false;
    }
}
#endif
```

---

## Keyboard/Controller Navigation and Focus — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html

**Contents:**
- Keyboard/Controller Navigation and Focus
- Node settings
- Necessary code
- User-contributed notes

It is a common requirement for a user interface to have full keyboard and controller support for navigation and interaction. There are two main reasons why this is beneficial for projects: improved accessibility (not everyone can use mouse or touch controls for interactions), and getting your project ready for consoles (or just for people who prefer to game with a controller on PC).

Navigating between UI elements with keyboard or controller is done by changing which node is actively selected. This is also called changing UI focus. Every Control node in Godot is capable of having focus. By default, some control nodes have the ability to automatically grab focus reacting to built-in UI actions such as ui_up, ui_down, ui_focus_next, etc. These actions can be seen in the project settings in the input map and can be modified.

Because these actions are used for focus they should not be used for any gameplay code.

In addition to the built-in logic, you can define what is known as focus neighbors for each individual control node. This allows to finely tune the path the UI focus takes across the user interface of your project. The settings for individual nodes can be found in the Inspector dock, under the "Focus" category of the "Control" section.

Neighbor options are used to define nodes for 4-directional navigation, such as using arrow keys or a D-pad on a controller. For example, the bottom neighbor will be used when navigating down with the down arrow or by pushing down on the D-pad. The "Next" and "Previous" options are used with the focus shift button, such as Tab on desktop operating systems.

A node can lose focus if it becomes hidden.

The mode setting defines how a node can be focused. All means a node can be focused by clicking on it with the mouse, or selecting it with a keyboard or controller. Click means it can only be focused on by clicking on it. Finally, None means it can't be focused at all. Different control nodes have different default settings for this based on how they are typically used, for example, Label nodes are set to "None" by default, while buttons are set to "All".

Make sure to properly configure your scenes for focus and navigation. If a node has no focus neighbor configured, the engine will try to guess the next control automatically. This may result in unintended behavior, especially in a complex user interface that doesn't have well-defined vertical or horizontal navigation flow.

For keyboard and controller navigation to work correctly, any node must be focused by using code when the scene starts. Without doing this, pressing buttons or keys won't do anything.

You can use the Control.grab_focus() method to focus a control. Here is a basic example of setting initial focus with code:

Now when the scene starts, the "Start Button" node will be focused, and the keyboard or a controller can be used to navigate between it and other UI elements.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _ready():
    $StartButton.grab_focus.call_deferred()
```

Example 2 (unknown):
```unknown
public override void _Ready()
{
    GetNode<Button>("StartButton").GrabFocus.CallDeferred();
}
```

---

## Localization using gettext (PO files) — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_gettext.html

**Contents:**
- Localization using gettext (PO files)
- Advantages
- Disadvantages
- Installing gettext tools
- Creating the PO template
  - Automatic generation using the editor
  - Manual creation
- Creating a messages file from a PO template
- Loading a messages file in Godot
- Updating message files to follow the PO template

In addition to importing translations in CSV format, Godot also supports loading translation files written in the GNU gettext format (text-based .po and compiled .mo since Godot 4.0).

For an introduction to gettext, check out A Quick Gettext Tutorial. It's written with C projects in mind, but much of the advice also applies to Godot (with the exception of xgettext).

For the complete documentation, see GNU Gettext.

gettext is a standard format, which can be edited using any text editor or GUI editors such as Poedit. This can be significant as it provides a lot of tools for translators, such as marking outdated strings, finding strings that haven't been translated etc.

gettext supports plurals and context.

gettext is supported by translation platforms such as Transifex and Weblate, which makes it easier for people to collaborate to localization.

Compared to CSV, gettext files work better with version control systems like Git, as each locale has its own messages file.

Multiline strings are more convenient to edit in gettext PO files compared to CSV files.

gettext PO files have a more complex format than CSV and can be harder to grasp for people new to software localization.

People who maintain localization files will have to install gettext tools on their system. However, as Godot supports using text-based message files (.po), translators can test their work without having to install gettext tools.

gettext PO files usually use English as the base language. Translators will use this base language to translate to other languages. You could still user other languages as the base language, but this is not common.

The command line gettext tools are required to perform maintenance operations, such as updating message files. Therefore, it's strongly recommended to install them.

Windows: Download an installer from this page. Any architecture and binary type (shared or static) works; if in doubt, choose the 64-bit static installer.

macOS: Install gettext either using Homebrew with the brew install gettext command, or using MacPorts with the sudo port install gettext command.

Linux: On most distributions, install the gettext package from your distribution's package manager.

For a GUI tool you can get Poedit from its Official website. The basic version is open source and available under the MIT license.

Since Godot 4.0, the editor can generate a PO template automatically from specified scene and GDScript files. This POT generation also supports translation contexts and pluralization if used in a script, with the optional second argument of tr() and the tr_n() method.

Open the Project Settings' Localization > POT Generation tab, then use the Add… button to specify the path to your project's scenes and scripts that contain localizable strings:

Creating a PO template in the Localization > POT Generation tab of the Project Settings

After adding at least one scene or script, click Generate POT in the top-right corner, then specify the path to the output file. This file can be placed anywhere in the project directory, but it's recommended to keep it in a subdirectory such as locale, as each locale will be defined in its own file.

See below for how to add comments for translators or exclude some strings from being added to the PO template for GDScript files.

You can then move over to creating a messages file from a PO template.

Remember to regenerate the PO template after making any changes to localizable strings, or after adding new scenes or scripts. Otherwise, newly added strings will not be localizable and translators won't be able to update translations for outdated strings.

If the automatic generation approach doesn't work out for your needs, you can create a PO template by hand in a text editor. This file can be placed anywhere in the project directory, but it's recommended to keep it in a subdirectory, as each locale will be defined in its own file.

Create a directory named locale in the project directory. In this directory, save a file named messages.pot with the following contents:

Messages in gettext are made of msgid and msgstr pairs. msgid is the source string (usually in English), msgstr will be the translated string.

The msgstr value in PO template files (.pot) should always be empty. Localization will be done in the generated .po files instead.

The msginit command is used to turn a PO template into a messages file. For instance, to create a French localization file, use the following command while in the locale directory:

The command above will create a file named fr.po in the same directory as the PO template.

Alternatively, you can do that graphically using Poedit, or by uploading the POT file to your web platform of choice.

To register a messages file as a translation in a project, open the Project Settings, then go to the Localization tab. In Translations, click Add… then choose the .po or .mo file in the file dialog. The locale will be inferred from the "Language: <code>\n" property in the messages file.

See Internationalizing games for more information on importing and testing translations in Godot.

After updating the PO template, you will have to update message files so that they contain new strings, while removing strings that are no longer present in the PO template. This can be done automatically using the msgmerge tool:

If you want to keep a backup of the original message file (which would be saved as fr.po~ in this example), remove the --backup=none argument.

After running msgmerge, strings which were modified in the source language will have a "fuzzy" comment added before them in the .po file. This comment denotes that the translation should be updated to match the new source string, as the translation will most likely be inaccurate until it's updated.

Strings with "fuzzy" comments will not be read by Godot until the translation is updated and the "fuzzy" comment is removed.

It is possible to check whether a gettext file's syntax is valid.

If you open with Poeditor, it will display the appropriate warnings if there's some syntax errors. You can also verify by running the gettext command below:

If there are syntax errors or warnings, they will be displayed in the console. Otherwise, msgfmt won't output anything.

For large projects with several thousands of strings to translate or more, it can be worth it to use binary (compiled) MO message files instead of text-based PO files. Binary MO files are smaller and faster to read than the equivalent PO files.

You can generate an MO file with the command below:

If the PO file is valid, this command will create an fr.mo file besides the PO file. This MO file can then be loaded in Godot as described above.

The original PO file should be kept in version control so you can update your translation in the future. In case you lose the original PO file and wish to decompile an MO file into a text-based PO file, you can do so with:

The decompiled file will not include comments or fuzzy strings, as these are never compiled in the MO file in the first place.

The built-in editor plugin recognizes a variety of patterns in source code to extract localizable strings from GDScript files, including but not limited to the following:

tr(), tr_n(), atr(), and atr_n() calls;

assigning properties text, placeholder_text, and tooltip_text;

add_tab(), add_item(), set_tab_title(), and other calls;

FileDialog filters like "*.png ; PNG Images".

The argument or right operand must be a constant string, otherwise the plugin will not be able to evaluate the expression and will ignore it.

If the plugin extracts unnecessary strings, you can ignore them with the NO_TRANSLATE comment. You can also provide additional information for translators using the TRANSLATORS: comment. These comments must be placed either on the same line as the recognized pattern or precede it.

The context parameter can be used to differentiate the situation where a translation is used, or to differentiate polysemic words (words with multiple meanings).

Some time or later, you'll add new content to our game, and there will be new strings that need to be translated. When this happens, you'll need to update the existing PO files to include the new strings.

First, generate a new POT file containing all the existing strings plus the newly added strings. After that, merge the existing PO files with the new POT file. There are two ways to do this:

Use a gettext editor, and it should have an option to update a PO file from a POT file.

Use the gettext msgmerge tool:

If you want to keep a backup of the original message file (which would be saved as fr.po~ in this example), remove the --backup=none argument.

If you have any extra file format to deal with, you could write a custom plugin to parse and and extract the strings from the custom file. This custom plugin will extract the strings and write into the POT file when you hit Generate POT. To learn more about how to create the translation parser plugin, see EditorTranslationParserPlugin.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
# Don't remove the two lines below, they're required for gettext to work correctly.
msgid ""
msgstr ""

# Example of a regular string.
msgid "Hello world!"
msgstr ""

# Example of a string with pluralization.
msgid "There is %d apple."
msgid_plural "There are %d apples."
msgstr[0] ""
msgstr[1] ""

# Example of a string with a translation context.
msgctxt "Actions"
msgid "Close"
msgstr ""
```

Example 2 (unknown):
```unknown
msginit --no-translator --input=messages.pot --locale=fr
```

Example 3 (unknown):
```unknown
# The order matters: specify the message file *then* the PO template!
msgmerge --update --backup=none fr.po messages.pot
```

Example 4 (unknown):
```unknown
msgfmt fr.po --check
```

---

## Localization using spreadsheets — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/i18n/localization_using_spreadsheets.html

**Contents:**
- Localization using spreadsheets
- Formatting
- CSV importer
- User-contributed notes

Spreadsheets are one of the most common formats for localizing games. In Godot, spreadsheets are supported through the CSV format. This guide explains how to work with CSVs.

The CSV files must be saved with UTF-8 encoding without a byte order mark.

By default, Microsoft Excel will always save CSV files with ANSI encoding rather than UTF-8. There is no built-in way to do this, but there are workarounds as described here.

We recommend using LibreOffice or Google Sheets instead.

CSV files must be formatted as follows:

The "lang" tags must represent a language, which must be one of the valid locales supported by the engine, or they must start with an underscore (_), which means the related column is served as comment and won't be imported. The "KEY" tags must be unique and represent a string universally (they are usually in uppercase, to differentiate from other strings). These keys will be replaced at runtime by the matching translated string. Note that the case is important, "KEY1" and "Key1" will be different keys. The top-left cell is ignored and can be left empty or having any content. Here's an example:

"Hello" said the man.

"Hola" dijo el hombre.

The same example is shown below as a comma-separated plain text file, which should be the result of editing the above in a spreadsheet. When editing the plain text version, be sure to enclose with double quotes any message that contains commas, line breaks or double quotes, so that commas are not parsed as delimiters, line breaks don't create new entries and double quotes are not parsed as enclosing characters. Be sure to escape any double quotes a message may contain by preceding them with another double quote. Alternatively, you can select another delimiter than comma in the import options.

Godot will treat CSV files as translations by default. It will import them and generate one or more compressed translation resource files next to it.

Importing will also add the translation to the list of translations to load when the game runs, specified in project.godot (or the project settings). Godot allows loading and removing translations at runtime as well.

Select the .csv file and access the Import dock to define import options. You can toggle the compression of the imported translations, and select the delimiter to use when parsing the CSV file.

Be sure to click Reimport after any change to these options.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
keys,en,es,ja
GREET,"Hello, friend!","Hola, amigo!",こんにちは
ASK,How are you?,Cómo está?,元気ですか
BYE,Goodbye,Adiós,さようなら
QUOTE,"""Hello"" said the man.","""Hola"" dijo el hombre.",「こんにちは」男は言いました
```

---

## Making plugins — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html

**Contents:**
- Making plugins
- About plugins
- Creating a plugin
  - The script file
- A custom node
- A custom dock
  - Checking the results
- Registering autoloads/singletons in plugins
- Using sub-plugins
- Going beyond

A plugin is a great way to extend the editor with useful tools. It can be made entirely with GDScript and standard scenes, without even reloading the editor. Unlike modules, you don't need to create C++ code nor recompile the engine. While this makes plugins less powerful, there are still many things you can do with them. Note that a plugin is similar to any scene you can already make, except it is created using a script to add editor functionality.

This tutorial will guide you through the creation of two plugins so you can understand how they work and be able to develop your own. The first is a custom node that you can add to any scene in the project, and the other is a custom dock added to the editor.

Before starting, create a new empty project wherever you want. This will serve as a base to develop and test the plugins.

The first thing you need for the editor to identify a new plugin is to create two files: a plugin.cfg for configuration and a tool script with the functionality. Plugins have a standard path like addons/plugin_name inside the project folder. Godot provides a dialog for generating those files and placing them where they need to be.

In the main toolbar, click the Project dropdown. Then click Project Settings.... Go to the Plugins tab and then click on the Create New Plugin button in the top-right.

You will see the dialog appear, like so:

The placeholder text in each field describes how it affects the plugin's creation of the files and the config file's values.

To continue with the example, use the following values:

Unchecking the Activate now? option in C# is always required because, like every other C# script, the EditorPlugin script needs to be compiled which requires building the project. After building the project the plugin can be enabled in the Plugins tab of Project Settings.

You should end up with a directory structure like this:

plugin.cfg is an INI file with metadata about your plugin. The name and description help people understand what it does. Your name helps you get properly credited for your work. The version number helps others know if they have an outdated version; if you are unsure on how to come up with the version number, check out Semantic Versioning. The main script file will instruct Godot what your plugin does in the editor once it is active.

Upon creation of the plugin, the dialog will automatically open the EditorPlugin script for you. The script has two requirements that you cannot change: it must be a @tool script, or else it will not load properly in the editor, and it must inherit from EditorPlugin.

In addition to the EditorPlugin script, any other GDScript that your plugin uses must also be a tool. Any GDScript without @tool used by the editor will act like an empty file!

It's important to deal with initialization and clean-up of resources. A good practice is to use the virtual function _enter_tree() to initialize your plugin and _exit_tree() to clean it up. Thankfully, the dialog generates these callbacks for you. Your script should look something like this:

This is a good template to use when creating new plugins.

Sometimes you want a certain behavior in many nodes, such as a custom scene or control that can be reused. Instancing is helpful in a lot of cases, but sometimes it can be cumbersome, especially if you're using it in many projects. A good solution to this is to make a plugin that adds a node with a custom behavior.

Nodes added via an EditorPlugin are "CustomType" nodes. While they work with any scripting language, they have fewer features than the Script Class system. If you are writing GDScript or NativeScript, we recommend using Script Classes instead.

To create a new node type, you can use the function add_custom_type() from the EditorPlugin class. This function can add new types to the editor (nodes or resources). However, before you can create the type, you need a script that will act as the logic for the type. While that script doesn't have to use the @tool annotation, it can be added so the script runs in the editor.

For this tutorial, we'll create a button that prints a message when clicked. For that, we'll need a script that extends from Button. It could also extend BaseButton if you prefer:

That's it for our basic button. You can save this as my_button.gd inside the plugin folder. You'll also need a 16×16 icon to show in the scene tree. If you don't have one, you can grab the default one from the engine and save it in your addons/my_custom_node folder as icon.png, or use the default Godot logo (preload("res://icon.svg")).

SVG images that are used as custom node icons should have the Editor > Scale With Editor Scale and Editor > Convert Colors With Editor Theme import options enabled. This allows icons to follow the editor's scale and theming settings if the icons are designed with the same color palette as Godot's own icons.

Now, we need to add it as a custom type so it shows on the Create New Node dialog. For that, change the custom_node.gd script to the following:

With that done, the plugin should already be available in the plugin list in the Project Settings, so activate it as explained in Checking the results.

Then try it out by adding your new node:

When you add the node, you can see that it already has the script you created attached to it. Set a text to the button, save and run the scene. When you click the button, you can see some text in the console:

Sometimes, you need to extend the editor and add tools that are always available. An easy way to do it is to add a new dock with a plugin. Docks are just scenes based on Control, so they are created in a way similar to usual GUI scenes.

Creating a custom dock is done just like a custom node. Create a new plugin.cfg file in the addons/my_custom_dock folder, then add the following content to it:

Then create the script custom_dock.gd in the same folder. Fill it with the template we've seen before to get a good start.

Since we're trying to add a new custom dock, we need to create the contents of the dock. This is nothing more than a standard Godot scene: just create a new scene in the editor then edit it.

For an editor dock, the root node must be a Control or one of its child classes. For this tutorial, you can create a single button. The name of the root node will also be the name that appears on the dock tab, so be sure to give it a short and descriptive name. Also, don't forget to add some text to your button.

Save this scene as my_dock.tscn. Now, we need to grab the scene we created then add it as a dock in the editor. For this, you can rely on the function add_control_to_dock() from the EditorPlugin class.

You need to select a dock position and define the control to add (which is the scene you just created). Don't forget to remove the dock when the plugin is deactivated. The script could look like this:

Note that, while the dock will initially appear at its specified position, the user can freely change its position and save the resulting layout.

It's now time to check the results of your work. Open the Project Settings and click on the Plugins tab. Your plugin should be the only one on the list.

You can see the plugin is not enabled. Click the Enable checkbox to activate the plugin. The dock should become visible before you even close the settings window. You should now have a custom dock:

It is possible for editor plugins to automatically register autoloads when the plugin is enabled. This also includes unregistering the autoload when the plugin is disabled.

This makes setting up plugins faster for users, as they no longer have to manually add autoloads to their project settings if your editor plugin requires the use of an autoload.

Use the following code to register a singleton from an editor plugin:

Often a plugin adds multiple things, for example a custom node and a panel. In those cases it might be easier to have a separate plugin script for each of those features. Sub-plugins can be used for this.

First create all plugins and sub plugins as normal plugins:

Then move the sub plugins into the main plugin folder:

Godot will hide sub-plugins from the plugin list, so that a user can't enable or disable them. Instead the main plugin script should enable and disable sub-plugins like this:

Now that you've learned how to make basic plugins, you can extend the editor in several ways. Lots of functionality can be added to the editor with GDScript; it is a powerful way to create specialized editors without having to delve into C++ modules.

You can make your own plugins to help yourself and share them in the Asset Library so that people can benefit from your work.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
Plugin Name: My Custom Node
Subfolder: my_custom_node
Description: A custom node made to extend the Godot Engine.
Author: Your Name Here
Version: 1.0.0
Language: GDScript
Script Name: custom_node.gd
Activate now: No
```

Example 2 (unknown):
```unknown
Plugin Name: My Custom Node
Subfolder: MyCustomNode
Description: A custom node made to extend the Godot Engine.
Author: Your Name Here
Version: 1.0.0
Language: C#
Script Name: CustomNode.cs
Activate now: No
```

Example 3 (unknown):
```unknown
@tool
extends EditorPlugin


func _enter_tree():
    # Initialization of the plugin goes here.
    pass


func _exit_tree():
    # Clean-up of the plugin goes here.
    pass
```

Example 4 (unknown):
```unknown
#if TOOLS
using Godot;

[Tool]
public partial class CustomNode : EditorPlugin
{
    public override void _EnterTree()
    {
        // Initialization of the plugin goes here.
    }

    public override void _ExitTree()
    {
        // Clean-up of the plugin goes here.
    }
}
#endif
```

---

## Matrices and transforms — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/math/matrices_and_transforms.html

**Contents:**
- Matrices and transforms
- Introduction
  - Matrix components and the Identity matrix
  - Scaling the transformation matrix
  - Rotating the transformation matrix
  - Basis of the transformation matrix
  - Translating the transformation matrix
  - Putting it all together
  - Shearing the transformation matrix (advanced)
- Practical applications of transforms

Before reading this tutorial, we recommend that you thoroughly read and understand the Vector math tutorial, as this tutorial requires a knowledge of vectors.

This tutorial is about transformations and how we represent them in Godot using matrices. It is not a full in-depth guide to matrices. Transformations are most of the time applied as translation, rotation, and scale, so we will focus on how to represent those with matrices.

Most of this guide focuses on 2D, using Transform2D and Vector2, but the way things work in 3D is very similar.

As mentioned in the previous tutorial, it is important to remember that in Godot, the Y axis points down in 2D. This is the opposite of how most schools teach linear algebra, with the Y axis pointing up.

The convention is that the X axis is red, the Y axis is green, and the Z axis is blue. This tutorial is color-coded to match these conventions, but we will also represent the origin vector with a blue color.

The identity matrix represents a transform with no translation, no rotation, and no scale. Let's start by looking at the identity matrix and how its components relate to how it visually appears.

Matrices have rows and columns, and a transformation matrix has specific conventions on what each does.

In the image above, we can see that the red X vector is represented by the first column of the matrix, and the green Y vector is likewise represented by the second column. A change to the columns will change these vectors. We will see how they can be manipulated in the next few examples.

You should not worry about manipulating rows directly, as we usually work with columns. However, you can think of the rows of the matrix as showing which vectors contribute to moving in a given direction.

When we refer to a value such as t.x.y, that's the Y component of the X column vector. In other words, the bottom-left of the matrix. Similarly, t.x.x is top-left, t.y.x is top-right, and t.y.y is bottom-right, where t is the Transform2D.

Applying a scale is one of the easiest operations to understand. Let's start by placing the Godot logo underneath our vectors so that we can visually see the effects on an object:

Now, to scale the matrix, all we need to do is multiply each component by the scale we want. Let's scale it up by 2. 1 times 2 becomes 2, and 0 times 2 becomes 0, so we end up with this:

To do this in code, we multiply each of the vectors:

If we wanted to return it to its original scale, we can multiply each component by 0.5. That's pretty much all there is to scaling a transformation matrix.

To calculate the object's scale from an existing transformation matrix, you can use length() on each of the column vectors.

In actual projects, you can use the scaled() method to perform scaling.

We'll start the same way as earlier, with the Godot logo underneath the identity matrix:

As an example, let's say we want to rotate our Godot logo clockwise by 90 degrees. Right now the X axis points right and the Y axis points down. If we rotate these in our head, we would logically see that the new X axis should point down and the new Y axis should point left.

You can imagine that you grab both the Godot logo and its vectors, and then spin it around the center. Wherever you finish spinning, the orientation of the vectors determines what the matrix is.

We need to represent "down" and "left" in normal coordinates, so means we'll set X to (0, 1) and Y to (-1, 0). These are also the values of Vector2.DOWN and Vector2.LEFT. When we do this, we get the desired result of rotating the object:

If you have trouble understanding the above, try this exercise: Cut a square of paper, draw X and Y vectors on top of it, place it on graph paper, then rotate it and note the endpoints.

To perform rotation in code, we need to be able to calculate the values programmatically. This image shows the formulas needed to calculate the transformation matrix from a rotation angle. Don't worry if this part seems complicated, I promise it's the hardest thing you need to know.

Godot represents all rotations with radians, not degrees. A full turn is TAU or PI*2 radians, and a quarter turn of 90 degrees is TAU/4 or PI/2 radians. Working with TAU usually results in more readable code.

Fun fact: In addition to Y being down in Godot, rotation is represented clockwise. This means that all the math and trig functions behave the same as a Y-is-up CCW system, since these differences "cancel out". You can think of rotations in both systems being "from X to Y".

In order to perform a rotation of 0.5 radians (about 28.65 degrees), we plug in a value of 0.5 to the formula above and evaluate to find what the actual values should be:

Here's how that would be done in code (place the script on a Node2D):

To calculate the object's rotation from an existing transformation matrix, you can use atan2(t.x.y, t.x.x), where t is the Transform2D.

In actual projects, you can use the rotated() method to perform rotations.

So far we have only been working with the x and y, vectors, which are in charge of representing rotation, scale, and/or shearing (advanced, covered at the end). The X and Y vectors are together called the basis of the transformation matrix. The terms "basis" and "basis vectors" are important to know.

You might have noticed that Transform2D actually has three Vector2 values: x, y, and origin. The origin value is not part of the basis, but it is part of the transform, and we need it to represent position. From now on we'll keep track of the origin vector in all examples. You can think of origin as another column, but it's often better to think of it as completely separate.

Note that in 3D, Godot has a separate Basis structure for holding the three Vector3 values of the basis, since the code can get complex and it makes sense to separate it from Transform3D (which is composed of one Basis and one extra Vector3 for the origin).

Changing the origin vector is called translating the transformation matrix. Translating is basically a technical term for "moving" the object, but it explicitly does not involve any rotation.

Let's work through an example to help understand this. We will start with the identity transform like last time, except we will keep track of the origin vector this time.

If we want to move the object to a position of (1, 2), we need to set its origin vector to (1, 2):

There is also a translated_local() method, which performs a different operation to adding or changing origin directly. The translated_local() method will translate the object relative to its own rotation. For example, an object rotated 90 degrees clockwise will move to the right when translated_local() with Vector2.UP. To translate relative to the global/parent frame use translated() instead.

Godot's 2D uses coordinates based on pixels, so in actual projects you will want to translate by hundreds of units.

We're going to apply everything we mentioned so far onto one transform. To follow along, create a project with a Sprite2D node and use the Godot logo for the texture resource.

Let's set the translation to (350, 150), rotate by -0.5 rad, and scale by 3. I've posted a screenshot, and the code to reproduce it, but I encourage you to try and reproduce the screenshot without looking at the code!

If you are only looking for how to use transformation matrices, feel free to skip this section of the tutorial. This section explores an uncommonly used aspect of transformation matrices for the purpose of building an understanding of them.

Node2D provides a shearing property out of the box.

You may have noticed that a transform has more degrees of freedom than the combination of the above actions. The basis of a 2D transformation matrix has four total numbers in two Vector2 values, while a rotation value and a Vector2 for scale only has 3 numbers. The high-level concept for the missing degree of freedom is called shearing.

Normally, you will always have the basis vectors perpendicular to each other. However, shearing can be useful in some situations, and understanding shearing helps you understand how transforms work.

To show you visually how it will look, let's overlay a grid onto the Godot logo:

Each point on this grid is obtained by adding the basis vectors together. The bottom-right corner is X + Y, while the top-right corner is X - Y. If we change the basis vectors, the entire grid moves with it, as the grid is composed of the basis vectors. All lines on the grid that are currently parallel will remain parallel no matter what changes we make to the basis vectors.

As an example, let's set Y to (1, 1):

You can't set the raw values of a Transform2D in the editor, so you must use code if you want to shear the object.

Due to the vectors no longer being perpendicular, the object has been sheared. The bottom-center of the grid, which is (0, 1) relative to itself, is now located at a world position of (1, 1).

The intra-object coordinates are called UV coordinates in textures, so let's borrow that terminology for here. To find the world position from a relative position, the formula is U * X + V * Y, where U and V are numbers and X and Y are the basis vectors.

The bottom-right corner of the grid, which is always at the UV position of (1, 1), is at the world position of (2, 1), which is calculated from X*1 + Y*1, which is (1, 0) + (1, 1), or (1 + 1, 0 + 1), or (2, 1). This matches up with our observation of where the bottom-right corner of the image is.

Similarly, the top-right corner of the grid, which is always at the UV position of (1, -1), is at the world position of (0, -1), which is calculated from X*1 + Y*-1, which is (1, 0) - (1, 1), or (1 - 1, 0 - 1), or (0, -1). This matches up with our observation of where the top-right corner of the image is.

Hopefully you now fully understand how a transformation matrix affects the object, and the relationship between the basis vectors and how the object's "UV" or "intra-coordinates" have their world position changed.

In Godot, all transform math is done relative to the parent node. When we refer to "world position", that would be relative to the node's parent instead, if the node had a parent.

If you would like additional explanation, you should check out 3Blue1Brown's excellent video about linear transformations: https://www.youtube.com/watch?v=kYB8IZa5AuE

In actual projects, you will usually be working with transforms inside transforms by having multiple Node2D or Node3D nodes parented to each other.

However, it's useful to understand how to manually calculate the values we need. We will go over how you could use Transform2D or Transform3D to manually calculate transforms of nodes.

There are many cases where you'd want to convert a position in and out of a transform. For example, if you have a position relative to the player and would like to find the world (parent-relative) position, or if you have a world position and want to know where it is relative to the player.

We can find what a vector relative to the player would be defined in world space as using the * operator:

And we can use the * operator in the opposite order to find a what world space position would be if it was defined relative to the player:

If you know in advance that the transform is positioned at (0, 0), you can use the "basis_xform" or "basis_xform_inv" methods instead, which skip dealing with translation.

A common operation, especially in 3D games, is to move an object relative to itself. For example, in first-person shooter games, you would want the character to move forward (-Z axis) when you press W.

Since the basis vectors are the orientation relative to the parent, and the origin vector is the position relative to the parent, we can add multiples of the basis vectors to move an object relative to itself.

This code moves an object 100 units to its own right:

For moving in 3D, you would need to replace "x" with "basis.x".

In actual projects, you can use translate_object_local in 3D or move_local_x and move_local_y in 2D to do this.

One of the most important things to know about transforms is how you can use several of them together. A parent node's transform affects all of its children. Let's dissect an example.

In this image, the child node has a "2" after the component names to distinguish them from the parent node. It might look a bit overwhelming with so many numbers, but remember that each number is displayed twice (next to the arrows and also in the matrices), and that almost half of the numbers are zero.

The only transformations going on here are that the parent node has been given a scale of (2, 1), the child has been given a scale of (0.5, 0.5), and both nodes have been given positions.

All child transformations are affected by the parent transformations. The child has a scale of (0.5, 0.5), so you would expect it to be a 1:1 ratio square, and it is, but only relative to the parent. The child's X vector ends up being (1, 0) in world space, because it is scaled by the parent's basis vectors. Similarly, the child node's origin vector is set to (1, 1), but this actually moves it (2, 1) in world space, due to the parent node's basis vectors.

To calculate a child transform's world space transform manually, this is the code we would use:

In actual projects, we can find the world transform of the child by applying one transform onto another using the * operator:

When multiplying matrices, order matters! Don't mix them up.

Lastly, applying the identity transform will always do nothing.

If you would like additional explanation, you should check out 3Blue1Brown's excellent video about matrix composition: https://www.youtube.com/watch?v=XkY2DOUCWMU

The "affine_inverse" function returns a transform that "undoes" the previous transform. This can be useful in some situations. Let's take a look at a few examples.

Multiplying an inverse transform by the normal transform undoes all transformations:

Transforming a position by a transform and its inverse results in the same position:

One of the great things about transformation matrices is that they work very similarly between 2D and 3D transformations. All the code and formulas used above for 2D work the same in 3D, with 3 exceptions: the addition of a third axis, that each axis is of type Vector3, and also that Godot stores the Basis separately from the Transform3D, since the math can get complex and it makes sense to separate it.

All of the concepts for how translation, rotation, scale, and shearing work in 3D are all the same compared to 2D. To scale, we take each component and multiply it; to rotate, we change where each basis vector is pointing; to translate, we manipulate the origin; and to shear, we change the basis vectors to be non-perpendicular.

If you would like, it's a good idea to play around with transforms to get an understanding of how they work. Godot allows you to edit 3D transform matrices directly from the inspector. You can download this project which has colored lines and cubes to help visualize the Basis vectors and the origin in both 2D and 3D: https://github.com/godotengine/godot-demo-projects/tree/master/misc/matrix_transform

You cannot edit Node2D's transform matrix directly in Godot 4.0's inspector. This may be changed in a future release of Godot.

If you would like additional explanation, you should check out 3Blue1Brown's excellent video about 3D linear transformations: https://www.youtube.com/watch?v=rHLEWRxRGiM

The biggest difference between 2D and 3D transformation matrices is how you represent rotation by itself without the basis vectors.

With 2D, we have an easy way (atan2) to switch between a transformation matrix and an angle. In 3D, rotation is too complex to represent as one number. There is something called Euler angles, which can represent rotations as a set of 3 numbers, however, they are limited and not very useful, except for trivial cases.

In 3D we do not typically use angles, we either use a transformation basis (used pretty much everywhere in Godot), or we use quaternions. Godot can represent quaternions using the Quaternion struct. My suggestion to you is to completely ignore how they work under-the-hood, because they are very complicated and unintuitive.

However, if you really must know how it works, here are some great resources, which you can follow in order:

https://www.youtube.com/watch?v=mvmuCPvRoWQ

https://www.youtube.com/watch?v=d4EgbgTm0Bg

https://eater.net/quaternions

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
var t = Transform2D()
# Scale
t.x *= 2
t.y *= 2
transform = t # Change the node's transform to what we calculated.
```

Example 2 (unknown):
```unknown
Transform2D t = Transform2D.Identity;
// Scale
t.X *= 2;
t.Y *= 2;
Transform = t; // Change the node's transform to what we calculated.
```

Example 3 (unknown):
```unknown
var rot = 0.5 # The rotation to apply.
var t = Transform2D()
t.x.x = cos(rot)
t.y.y = cos(rot)
t.x.y = sin(rot)
t.y.x = -sin(rot)
transform = t # Change the node's transform to what we calculated.
```

Example 4 (unknown):
```unknown
float rot = 0.5f; // The rotation to apply.
Transform2D t = Transform2D.Identity;
t.X.X = t.Y.Y = Mathf.Cos(rot);
t.X.Y = t.Y.X = Mathf.Sin(rot);
t.Y.X *= -1;
Transform = t; // Change the node's transform to what we calculated.
```

---

## Random number generation — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html

**Contents:**
- Random number generation
- Global scope versus RandomNumberGenerator class
- The randomize() method
- Getting a random number
- Get a random array element
- Get a random dictionary value
- Weighted random probability
- "Better" randomness using shuffle bags
- Random noise
- Cryptographically secure pseudorandom number generation

Many games rely on randomness to implement core game mechanics. This page guides you through common types of randomness and how to implement them in Godot.

After giving you a brief overview of useful functions that generate random numbers, you will learn how to get random elements from arrays, dictionaries, and how to use a noise generator in GDScript. Lastly, we'll take a look at cryptographically secure random number generation and how it differs from typical random number generation.

Computers cannot generate "true" random numbers. Instead, they rely on pseudorandom number generators (PRNGs).

Godot internally uses the PCG Family of pseudorandom number generators.

Godot exposes two ways to generate random numbers: via global scope methods or using the RandomNumberGenerator class.

Global scope methods are easier to set up, but they don't offer as much control.

RandomNumberGenerator requires more code to use, but allows creating multiple instances, each with their own seed and state.

This tutorial uses global scope methods, except when the method only exists in the RandomNumberGenerator class.

Since Godot 4.0, the random seed is automatically set to a random value when the project starts. This means you don't need to call randomize() in _ready() anymore to ensure that results are random across project runs. However, you can still use randomize() if you want to use a specific seed number, or generate it using a different method.

In global scope, you can find a randomize() method. This method should be called only once when your project starts to initialize the random seed. Calling it multiple times is unnecessary and may impact performance negatively.

Putting it in your main scene script's _ready() method is a good choice:

You can also set a fixed random seed instead using seed(). Doing so will give you deterministic results across runs:

When using the RandomNumberGenerator class, you should call randomize() on the instance since it has its own seed:

Let's look at some of the most commonly used functions and methods to generate random numbers in Godot.

The function randi() returns a random number between 0 and 2^32 - 1. Since the maximum value is huge, you most likely want to use the modulo operator (%) to bound the result between 0 and the denominator:

randf() returns a random floating-point number between 0 and 1. This is useful to implement a Weighted random probability system, among other things.

randfn() returns a random floating-point number following a normal distribution. This means the returned value is more likely to be around the mean (0.0 by default), varying by the deviation (1.0 by default):

randf_range() takes two arguments from and to, and returns a random floating-point number between from and to:

randi_range() takes two arguments from and to, and returns a random integer between from and to:

We can use random integer generation to get a random element from an array, or use the Array.pick_random method to do it for us:

To prevent the same fruit from being picked more than once in a row, we can add more logic to the above method. In this case, we can't use Array.pick_random since it lacks a way to prevent repetition:

This approach can be useful to make random number generation feel less repetitive. Still, it doesn't prevent results from "ping-ponging" between a limited set of values. To prevent this, use the shuffle bag pattern instead.

We can apply similar logic from arrays to dictionaries as well:

The randf() method returns a floating-point number between 0.0 and 1.0. We can use this to create a "weighted" probability where different outcomes have different likelihoods:

You can also get a weighted random index using the rand_weighted() method on a RandomNumberGenerator instance. This returns a random integer between 0 and the size of the array that is passed as a parameter. Each value in the array is a floating-point number that represents the relative likelihood that it will be returned as an index. A higher value means the value is more likely to be returned as an index, while a value of 0 means it will never be returned as an index.

For example, if [0.5, 1, 1, 2] is passed as a parameter, then the method is twice as likely to return 3 (the index of the value 2) and twice as unlikely to return 0 (the index of the value 0.5) compared to the indices 1 and 2.

Since the returned value matches the array's size, it can be used as an index to get a value from another array as follows:

Taking the same example as above, we would like to pick fruits at random. However, relying on random number generation every time a fruit is selected can lead to a less uniform distribution. If the player is lucky (or unlucky), they could get the same fruit three or more times in a row.

You can accomplish this using the shuffle bag pattern. It works by removing an element from the array after choosing it. After multiple selections, the array ends up empty. When that happens, you reinitialize it to its default value:

When running the above code, there is a chance to get the same fruit twice in a row. Once we picked a fruit, it will no longer be a possible return value unless the array is now empty. When the array is empty, we reset it back to its default value, making it possible to have the same fruit again, but only once.

The random number generation shown above can show its limits when you need a value that slowly changes depending on the input. The input can be a position, time, or anything else.

To achieve this, you can use random noise functions. Noise functions are especially popular in procedural generation to generate realistic-looking terrain. Godot provides FastNoiseLite for this, which supports 1D, 2D and 3D noise. Here's an example with 1D noise:

So far, the approaches mentioned above are not suitable for cryptographically secure pseudorandom number generation (CSPRNG). This is fine for games, but this is not sufficient for scenarios where encryption, authentication or signing is involved.

Godot offers a Crypto class for this. This class can perform asymmetric key encryption/decryption, signing/verification, while also generating cryptographically secure random bytes, RSA keys, HMAC digests, and self-signed X509Certificates.

The downside of CSPRNG is that it's much slower than standard pseudorandom number generation. Its API is also less convenient to use. As a result, CSPRNG should be avoided for gameplay elements.

Example of using the Crypto class to generate 2 random integers between 0 and 2^32 - 1 (inclusive):

See PackedByteArray's documentation for other methods you can use to decode the generated bytes into various types of data, such as integers or floats.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _ready():
    randomize()
```

Example 2 (unknown):
```unknown
public override void _Ready()
{
    GD.Randomize();
}
```

Example 3 (unknown):
```unknown
func _ready():
    seed(12345)
    # To use a string as a seed, you can hash it to a number.
    seed("Hello world".hash())
```

Example 4 (unknown):
```unknown
public override void _Ready()
{
    GD.Seed(12345);
    // To use a string as a seed, you can hash it to a number.
    GD.Seed("Hello world".Hash());
}
```

---

## Shaders style guide — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/shaders/shaders_style_guide.html

**Contents:**
- Shaders style guide
- Formatting
  - Encoding and special characters
  - Indentation
  - Line breaks and blank lines
  - Blank lines
  - Line length
  - One statement per line
  - Comment spacing
  - Documentation comments

This style guide lists conventions to write elegant shaders. The goal is to encourage writing clean, readable code and promote consistency across projects, discussions, and tutorials. Hopefully, this will also support the development of auto-formatting tools.

Since the Godot shader language is close to C-style languages and GLSL, this guide is inspired by Godot's own GLSL formatting. You can view examples of GLSL files in Godot's source code here.

Style guides aren't meant as hard rulebooks. At times, you may not be able to apply some of the guidelines below. When that happens, use your best judgment, and ask fellow developers for insights.

In general, keeping your code consistent in your projects and within your team is more important than following this guide to a tee.

Godot's built-in shader editor uses a lot of these conventions by default. Let it help you.

Here is a complete shader example based on these guidelines:

Use line feed (LF) characters to break lines, not CRLF or CR. (editor default)

Use one line feed character at the end of each file. (editor default)

Use UTF-8 encoding without a byte order mark. (editor default)

Use Tabs instead of spaces for indentation. (editor default)

Each indent level should be one tab greater than the block containing it.

Use 2 indent levels to distinguish continuation lines from regular code blocks.

For a general indentation rule, follow the "1TBS Style" which recommends placing the brace associated with a control statement on the same line. Always use braces for statements, even if they only span one line. This makes them easier to refactor and avoids mistakes when adding more lines to an if statement or similar.

Surround function definitions with one (and only one) blank line:

Use one (and only one) blank line inside functions to separate logical sections.

Keep individual lines of code under 100 characters.

If you can, try to keep lines under 80 characters. This helps to read the code on small displays and with two shaders opened side-by-side in an external text editor. For example, when looking at a differential revision.

Never combine multiple statements on a single line.

The only exception to that rule is the ternary operator:

Regular comments should start with a space, but not code that you comment out. This helps differentiate text comments from disabled code.

Don't use multiline comment syntax if your comment can fit on a single line:

In the shader editor, to make the selected code a comment (or uncomment it), press Ctrl + K. This feature adds or removes // at the start of the selected lines.

Use the following format for documentation comments above uniforms, with two leading asterisks (/**) and follow-up asterisks on every line:

These comments will appear when hovering a property in the inspector. If you don't wish the comment to be visible in the inspector, use the standard comment syntax instead (// ... or /* ... */ with only one leading asterisk).

Always use one space around operators and after commas. Also, avoid extraneous spaces in function calls.

Don't use spaces to align expressions vertically:

Always specify at least one digit for both the integer and fractional part. This makes it easier to distinguish floating-point numbers from integers, as well as distinguishing numbers greater than 1 from those lower than 1.

Use r, g, b, and a when accessing a vector's members if it contains a color. If the vector contains anything else than a color, use x, y, z, and w. This allows those reading your code to better understand what the underlying data represents.

These naming conventions follow the Godot Engine style. Breaking these will make your code clash with the built-in naming conventions, leading to inconsistent code.

Use snake_case to name functions and variables:

Write constants with CONSTANT_CASE, that is to say in all caps with an underscore (_) to separate words:

Shader preprocessor directives should be written in CONSTANT__CASE. Directives should be written without any indentation before them, even if nested within a function.

To preserve the natural flow of indentation when shader errors are printed to the console, extra indentation should not be added within #if, #ifdef or #ifndef blocks:

To automatically format shader files, you can use clang-format on one or several .gdshader files, as the syntax is close enough to a C-style language.

However, the default style in clang-format doesn't follow this style guide, so you need to save this file as .clang-format in your project's root folder:

While in the project root, you can then call clang-format -i path/to/shader.gdshader in a terminal to format a single shader file, or clang-format -i path/to/folder/*.gdshader to format all shaders in a folder.

We suggest to organize shader code this way:

We optimized the order to make it easy to read the code from top to bottom, to help developers reading the code for the first time understand how it works, and to avoid errors linked to the order of variable declarations.

This code order follows two rules of thumb:

Metadata and properties first, followed by methods.

"Public" comes before "private". In a shader language's context, "public" refers to what's easily adjustable by the user (uniforms).

Declare local variables as close as possible to their first use. This makes it easier to follow the code, without having to scroll too much to find where the variable was declared.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
shader_type canvas_item;
// Screen-space shader to adjust a 2D scene's brightness, contrast
// and saturation. Taken from
// https://github.com/godotengine/godot-demo-projects/blob/master/2d/screen_space_shaders/shaders/BCS.gdshader

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float brightness = 0.8;
uniform float contrast = 1.5;
uniform float saturation = 1.8;

void fragment() {
    vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

    c.rgb = mix(vec3(0.0), c.rgb, brightness);
    c.rgb = mix(vec3(0.5), c.rgb, contrast);
    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);

    COLOR.rgb = c;
}
```

Example 2 (unknown):
```unknown
void fragment() {
    COLOR = vec3(1.0, 1.0, 1.0);
}
```

Example 3 (unknown):
```unknown
void fragment() {
        COLOR = vec3(1.0, 1.0, 1.0);
}
```

Example 4 (unknown):
```unknown
vec2 st = vec2(
        atan(NORMAL.x, NORMAL.z),
        acos(NORMAL.y));
```

---

## Shading language — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html

**Contents:**
- Shading language
- Introduction
- Data types
  - Comments
  - Casting
  - Members
  - Constructing
  - Swizzling
  - Precision
- Arrays

Godot uses a shading language similar to GLSL ES 3.0. Most datatypes and functions are supported, and the few remaining ones will likely be added over time.

If you are already familiar with GLSL, the Godot Shader Migration Guide is a resource that will help you transition from regular GLSL to Godot's shading language.

Most GLSL ES 3.0 datatypes are supported:

Void datatype, useful only for functions that return nothing.

Boolean datatype, can only contain true or false.

Two-component vector of booleans.

Three-component vector of booleans.

Four-component vector of booleans.

32 bit signed scalar integer.

Two-component vector of signed integers.

Three-component vector of signed integers.

Four-component vector of signed integers.

Unsigned scalar integer; can't contain negative numbers.

Two-component vector of unsigned integers.

Three-component vector of unsigned integers.

Four-component vector of unsigned integers.

32 bit floating-point scalar.

Two-component vector of floating-point values.

Three-component vector of floating-point values.

Four-component vector of floating-point values.

2x2 matrix, in column major order.

3x3 matrix, in column major order.

4x4 matrix, in column major order.

Sampler type for binding 2D textures, which are read as float.

Sampler type for binding 2D textures, which are read as signed integer.

Sampler type for binding 2D textures, which are read as unsigned integer.

Sampler type for binding 2D texture arrays, which are read as float.

Sampler type for binding 2D texture arrays, which are read as signed integer.

Sampler type for binding 2D texture arrays, which are read as unsigned integer.

Sampler type for binding 3D textures, which are read as float.

Sampler type for binding 3D textures, which are read as signed integer.

Sampler type for binding 3D textures, which are read as unsigned integer.

Sampler type for binding Cubemaps, which are read as float.

Sampler type for binding Cubemap arrays, which are read as float. Only supported in Forward+ and Mobile, not Compatibility.

External sampler type. Only supported in Compatibility/Android platform.

Local variables are not initialized to a default value such as 0.0. If you use a variable without assigning it first, it will contain whatever value was already present at that memory location, and unpredictable visual glitches will appear. However, uniforms and varyings are initialized to a default value.

The shading language supports the same comment syntax as used in C# and C++, using // for single-line comments and /* */ for multi-line comments:

Additionally, you can use documentation comments that are displayed in the inspector when hovering a shader parameter. Documentation comments are currently only supported when placed immediately above a uniform declaration. These documentation comments only support the multiline comment syntax and must use two leading asterisks (/**) instead of just one (/*):

The asterisks on the follow-up lines are not required, but are recommended as per the Shaders style guide. These asterisks are automatically stripped by the inspector, so they won't appear in the tooltip.

Just like GLSL ES 3.0, implicit casting between scalars and vectors of the same size but different type is not allowed. Casting of types of different size is also not allowed. Conversion must be done explicitly via constructors.

Default integer constants are signed, so casting is always needed to convert to unsigned:

Individual scalar members of vector types are accessed via the "x", "y", "z" and "w" members. Alternatively, using "r", "g", "b" and "a" also works and is equivalent. Use whatever fits best for your needs.

For matrices, use the m[column][row] indexing syntax to access each scalar, or m[column] to access a vector by column index. For example, for accessing the y-component of the translation from a mat4 transform matrix (4th column, 2nd line) you use m[3][1] or m[3].y.

Construction of vector types must always pass:

Construction of matrix types requires vectors of the same dimension as the matrix, interpreted as columns. You can also build a diagonal matrix using matx(float) syntax. Accordingly, mat4(1.0) is an identity matrix.

Matrices can also be built from a matrix of another dimension. There are two rules:

1. If a larger matrix is constructed from a smaller matrix, the additional rows and columns are set to the values they would have in an identity matrix. 2. If a smaller matrix is constructed from a larger matrix, the top, left submatrix of the larger matrix is used.

It is possible to obtain any combination of components in any order, as long as the result is another vector type (or scalar). This is easier shown than explained:

It is possible to add precision modifiers to datatypes; use them for uniforms, variables, arguments and varyings:

Using lower precision for some operations can speed up the math involved (at the cost of less precision). This is rarely needed in the vertex processor function (where full precision is needed most of the time), but is often useful in the fragment processor.

Some architectures (mainly mobile) can benefit significantly from this, but there are downsides such as the additional overhead of conversion between precisions. Refer to the documentation of the target architecture for further information. In many cases, mobile drivers cause inconsistent or unexpected behavior and it is best to avoid specifying precision unless necessary.

Arrays are containers for multiple variables of a similar type.

Local arrays are declared in functions. They can use all of the allowed datatypes, except samplers. The array declaration follows a C-style syntax: [const] + [precision] + typename + identifier + [array size].

They can be initialized at the beginning like:

You can declare multiple arrays (even with different sizes) in one expression:

To access an array element, use the indexing syntax:

Arrays also have a built-in function .length() (not to be confused with the built-in length() function). It doesn't accept any parameters and will return the array's size.

If you use an index either below 0 or greater than array size - the shader will crash and break rendering. To prevent this, use length(), if, or clamp() functions to ensure the index is between 0 and the array's length. Always carefully test and check your code. If you pass a constant expression or a number, the editor will check its bounds to prevent this crash.

You can declare arrays in global space as either const or uniform:

Global arrays use the same syntax as local arrays, except with a const or uniform added to their declaration. Note that uniform arrays can't have a default value.

Use the const keyword before the variable declaration to make that variable immutable, which means that it cannot be modified. All basic types, except samplers can be declared as constants. Accessing and using a constant value is slightly faster than using a uniform. Constants must be initialized at their declaration.

Constants cannot be modified and additionally cannot have hints, but multiple of them (if they have the same type) can be declared in a single expression e.g

Similar to variables, arrays can also be declared with const.

Constants can be declared both globally (outside of any function) or locally (inside a function). Global constants are useful when you want to have access to a value throughout your shader that does not need to be modified. Like uniforms, global constants are shared between all shader stages, but they are not accessible outside of the shader.

Constants of the float type must be initialized using . notation after the decimal part or by using the scientific notation. The optional f post-suffix is also supported.

Constants of the uint (unsigned int) type must have a u suffix to differentiate them from signed integers. Alternatively, this can be done by using the uint(x) built-in conversion function.

Structs are compound types which can be used for better abstraction of shader code. You can declare them at the global scope like:

After declaration, you can instantiate and initialize them like:

Or use struct constructor for same purpose:

Structs may contain other struct or array, you can also instance them as global constant:

You can also pass them to functions:

Godot shading language supports the same set of operators as GLSL ES 3.0. Below is the list of them in precedence order:

parenthetical grouping

bit-wise exclusive OR

bit-wise inclusive OR

Most operators that accept vectors or matrices (multiplication, division, etc) operate component-wise, meaning the function is applied to the first value of each vector and then on the second value of each vector, etc. Some examples:

Equivalent Scalar Operation

vec3(4 + 2, 5 + 2, 6 + 2)

vec2(3, 4) * vec2(10, 20)

mat2(vec2(1, 2), vec2(3, 4)) + 10

mat2(vec2(1 + 10, 2 + 10), vec2(3 + 10, 4 + 10))

The GLSL Language Specification says under section 5.10 Vector and Matrix Operations:

With a few exceptions, operations are component-wise. Usually, when an operator operates on a vector or matrix, it is operating independently on each component of the vector or matrix, in a component-wise fashion. [...] The exceptions are matrix multiplied by vector, vector multiplied by matrix, and matrix multiplied by matrix. These do not operate component-wise, but rather perform the correct linear algebraic multiply.

Godot Shading language supports the most common types of flow control:

Keep in mind that in modern GPUs, an infinite loop can exist and can freeze your application (including editor). Godot can't protect you from this, so be careful not to make this mistake!

Also, when comparing floating-point values against a number, make sure to compare them against a range instead of an exact number.

A comparison like if (value == 0.3) may not evaluate to true. Floating-point math is often approximate and can defy expectations. It can also behave differently depending on the hardware.

Instead, always perform a range comparison with an epsilon value. The larger the floating-point number (and the less precise the floating-point number), the larger the epsilon value should be.

See floating-point-gui.de for more information.

Fragment, light, and custom functions (called from fragment or light) can use the discard keyword. If used, the fragment is discarded and nothing is written.

Beware that discard has a performance cost when used, as it will prevent the depth prepass from being effective on any surfaces using the shader. Also, a discarded pixel still needs to be rendered in the vertex shader, which means a shader that uses discard on all of its pixels is still more expensive to render compared to not rendering any object in the first place.

It is possible to define functions in a Godot shader. They use the following syntax:

You can only use functions that have been defined above (higher in the editor) the function from which you are calling them. Redefining a function that has already been defined above (or is a built-in function name) will cause an error.

Function arguments can have special qualifiers:

in: Means the argument is only for reading (default).

out: Means the argument is only for writing.

inout: Means the argument is fully passed via reference.

const: Means the argument is a constant and cannot be changed, may be combined with in qualifier.

Function overloading is supported. You can define multiple functions with the same name, but different arguments. Note that implicit casting in overloaded function calls is not allowed, such as from int to float (1 to 1.0).

To send data from the vertex to the fragment (or light) processor function, varyings are used. They are set for every primitive vertex in the vertex processor, and the value is interpolated for every pixel in the fragment processor.

Varying can also be an array:

It's also possible to send data from fragment to light processors using varying keyword. To do so you can assign it in the fragment and later use it in the light function.

Note that varying may not be assigned in custom functions or a light processor function like:

This limitation was introduced to prevent incorrect usage before initialization.

Certain values are interpolated during the shading pipeline. You can modify how these interpolations are done by using interpolation qualifiers.

There are two possible interpolation qualifiers:

The value is not interpolated.

The value is interpolated in a perspective-correct fashion. This is the default.

Passing values to shaders is possible with uniforms, which are defined in the global scope of the shader, outside of functions. When a shader is later assigned to a material, the uniforms will appear as editable parameters in the material's inspector. Uniforms can't be written from within the shader. Any data type except for void can be a uniform.

You can set uniforms in the editor in the material's inspector. Alternately, you can set them from code.

Godot provides optional uniform hints to make the compiler understand what the uniform is used for, and how the editor should allow users to modify it.

Uniforms can also be assigned default values:

Note that when adding a default value and a hint, the default value goes after the hint.

Full list of uniform hints below:

hint_enum("String1", "String2")

Displays int input as a dropdown widget in the editor.

hint_range(min, max[, step])

Restricted to values in a range (with min/max/step).

Used as albedo color.

As value or albedo color, default to opaque white.

As value or albedo color, default to opaque black.

hint_default_transparent

As value or albedo color, default to transparent black.

As flowmap, default to right.

hint_roughness[_r, _g, _b, _a, _normal, _gray]

Used for roughness limiter on import (attempts reducing specular aliasing). _normal is a normal map that guides the roughness limiter, with roughness increasing in areas that have high-frequency detail.

filter[_nearest, _linear][_mipmap][_anisotropic]

Enabled specified texture filtering.

repeat[_enable, _disable]

Enabled texture repeating.

Texture is the screen texture.

Texture is the depth texture.

hint_normal_roughness_texture

Texture is the normal roughness texture (only supported in Forward+).

You can access int values as a readable dropdown widget using the hint_enum uniform:

You can assign explicit values to the hint_enum uniform using colon syntax similar to GDScript:

The value will be stored as an integer, corresponding to the index of the selected option (i.e. 0, 1, or 2) or the value assigned by colon syntax (i.e. 30, 60, or 200). When setting the value with set_shader_parameter(), you must use the integer value, not the String name.

Any texture which contains sRGB color data requires a source_color hint in order to be correctly sampled. This is because Godot renders in linear color space, but some textures contain sRGB color data. If this hint is not used, the texture will appear washed out.

Albedo and color textures should typically have a source_color hint. Normal, roughness, metallic, and height textures typically do not need a source_color hint.

Using source_color hint is required in the Forward+ and Mobile renderers, and in canvas_item shaders when HDR 2D is enabled. The source_color hint is optional for the Compatibility renderer, and for canvas_item shaders if HDR 2D is disabled. However, it is recommended to always use the source_color hint, because it works even if you change renderers or disable HDR 2D.

To group multiple uniforms in a section in the inspector, you can use a group_uniform keyword like this:

You can close the group by using:

The syntax also supports subgroups (it's not mandatory to declare the base group before this):

Sometimes, you want to modify a parameter in many different shaders at once. With a regular uniform, this takes a lot of work as all these shaders need to be tracked and the uniform needs to be set for each of them. Global uniforms allow you to create and update uniforms that will be available in all shaders, in every shader type (canvas_item, spatial, particles, sky and fog).

Global uniforms are especially useful for environmental effects that affect many objects in a scene, like having foliage bend when the player is nearby, or having objects move with the wind.

Global uniforms are not the same as global scope for an individual shader. While regular uniforms are defined outside of shader functions and are therefore the global scope of the shader, global uniforms are global to all shaders in the entire project (but within each shader, are also in the global scope).

To create a global uniform, open the Project Settings then go to the Shader Globals tab. Specify a name for the uniform (case-sensitive) and a type, then click Add in the top-right corner of the dialog. You can then edit the value assigned to the uniform by clicking the value in the list of uniforms:

Adding a global uniform in the Shader Globals tab of the Project Settings

After creating a global uniform, you can use it in a shader as follows:

Note that the global uniform must exist in the Project Settings at the time the shader is saved, or compilation will fail. While you can assign a default value using global uniform vec4 my_color = ... in the shader code, it will be ignored as the global uniform must always be defined in the Project Settings anyway.

To change the value of a global uniform at runtime, use the RenderingServer.global_shader_parameter_set method in a script:

Assigning global uniform values can be done as many times as desired without impacting performance, as setting data doesn't require synchronization between the CPU and GPU.

You can also add or remove global uniforms at runtime:

Adding or removing global uniforms at runtime has a performance cost, although it's not as pronounced compared to getting global uniform values from a script (see the warning below).

While you can query the value of a global uniform at runtime in a script using RenderingServer.global_shader_parameter_get("uniform_name"), this has a large performance penalty as the rendering thread needs to synchronize with the calling thread.

Therefore, it's not recommended to read global shader uniform values continuously in a script. If you need to read values in a script after setting them, consider creating an autoload where you store the values you need to query at the same time you're setting them as global uniforms.

Per-instance uniforms are available in both canvas_item (2D) and spatial (3D) shaders.

Sometimes, you want to modify a parameter on each node using the material. As an example, in a forest full of trees, when you want each tree to have a slightly different color that is editable by hand. Without per-instance uniforms, this requires creating a unique material for each tree (each with a slightly different hue). This makes material management more complex, and also has a performance overhead due to the scene requiring more unique material instances. Vertex colors could also be used here, but they'd require creating unique copies of the mesh for each different color, which also has a performance overhead.

Per-instance uniforms are set on each GeometryInstance3D, rather than on each Material instance. Take this into account when working with meshes that have multiple materials assigned to them, or MultiMesh setups.

After saving the shader, you can change the per-instance uniform's value using the inspector:

Setting a per-instance uniform's value in the GeometryInstance3D section of the inspector

Per-instance uniform values can also be set at runtime using set_instance_shader_parameter method on a node that inherits from GeometryInstance3D:

When using per-instance uniforms, there are some restrictions you should be aware of:

Per-instance uniforms do not support textures or arrays, only regular scalar and vector types. As a workaround, you can pass a texture array as a regular uniform, then pass the index of the texture to be drawn using a per-instance uniform.

There is a practical maximum limit of 16 instance uniforms per shader.

If your mesh uses multiple materials, the parameters for the first mesh material found will "win" over the subsequent ones, unless they have the same name, index and type. In this case, all parameters are affected correctly.

If you run into the above situation, you can avoid clashes by manually specifying the index (0-15) of the instance uniform by using the instance_index hint:

You can set uniforms from GDScript using the set_shader_parameter() method:

The first argument to set_shader_parameter() is the name of the uniform in the shader. It must match exactly to the name of the uniform in the shader or else it will not be recognized.

GDScript uses different variable types than GLSL does, so when passing variables from GDScript to shaders, Godot converts the type automatically. Below is a table of the corresponding types:

Bitwise packed int where bit 0 (LSB) corresponds to x.

For example, a bvec2 of (bx, by) could be created in the following way:

Bitwise packed int where bit 0 (LSB) corresponds to x.

Bitwise packed int where bit 0 (LSB) corresponds to x.

When Color is used, it will be interpreted as (r, g, b).

Vector4, Color, Rect2, Plane, Quaternion

When Color is used, it will be interpreted as (r, g, b, a).

When Rect2 is used, it will be interpreted as (position.x, position.y, size.x, size.y).

When Plane is used it will be interpreted as (normal.x, normal.y, normal.z, d).

Projection, Transform3D

When a Transform3D is used, the w Vector is set to the identity.

See Changing import type for instructions on importing cubemaps for use in Godot.

Only supported in Forward+ and Mobile, not Compatibility.

Only supported in Compatibility/Android platform.

Be careful when setting shader uniforms from GDScript, since no error will be thrown if the type does not match. Your shader will just exhibit undefined behavior. Specifically, this includes setting a GDScript int/float (64 bit) into a Godot shader language int/float (32 bit). This may lead to unintended consequences in cases where high precision is required.

There is a limit to the total size of shader uniforms that you can use in a single shader. On most desktop platforms, this limit is 65536 bytes, or 4096 vec4 uniforms. On mobile platforms, the limit is typically 16384 bytes, or 1024 vec4 uniforms. Vector uniforms smaller than a vec4, such as vec2 or vec3, are padded to the size of a vec4. Scalar uniforms such as int or float are not padded, and bool is padded to the size of an int.

Arrays count as the total size of their contents. If you need a uniform array that is larger than this limit, consider packing the data into a texture instead, since the contents of a texture do not count towards this limit, only the size of the sampler uniform.

A large number of built-in variables are available, like UV, COLOR and VERTEX. What variables are available depends on the type of shader (spatial, canvas_item, particle, etc) and the function used (vertex, fragment, light, start, process, sky, or fog). For a list of the built-in variables that are available, please see the corresponding pages:

A large number of built-in functions are supported, conforming to GLSL ES 3.0. See the Built-in functions page for details.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
// Single-line comment.
int a = 2;  // Another single-line comment.

/*
Multi-line comment.
The comment ends when the ending delimiter is found
(here, it's on the line below).
*/
int b = 3;
```

Example 2 (unknown):
```unknown
/**
 * This is a documentation comment.
 * These lines will appear in the inspector when hovering the shader parameter
 * named "Something".
 * You can use [b]BBCode[/b] [i]formatting[/i] in the comment.
 */
uniform int something = 1;
```

Example 3 (unknown):
```unknown
float a = 2; // invalid
float a = 2.0; // valid
float a = float(2); // valid
```

Example 4 (unknown):
```unknown
int a = 2; // valid
uint a = 2; // invalid
uint a = uint(2); // valid
```

---

## Size and anchors — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html

**Contents:**
- Size and anchors
- Centering a control
- Anchor Presets
- User-contributed notes

If a game was always going to be run on the same device and at the same resolution, positioning controls would be a simple matter of setting the position and size of each one of them. Unfortunately, that is rarely the case.

While some configurations may be more common than others, devices like phones, tablets and portable gaming consoles can vary greatly. Therefore, we often have to account for different aspect ratios, resolutions and user scaling.

There are several ways to account for this, but for now, let's just imagine that the screen resolution has changed and the controls need to be re-positioned. Some will need to follow the bottom of the screen, others the top of the screen, or maybe the right or left margins.

This is done by editing the anchor offsets of controls, which behave similar to a margin. To access these settings, you will first need to select the Custom anchor preset.

Each control has four anchor offsets: left, right, bottom, and top, which correspond to the respective edges of the control. By default, all of them represent a distance in pixels relative to the top-left corner of the parent control or (in case there is no parent control) the viewport.

So to make the control wider you can make the right offset larger and/or make the left offset smaller. This lets you set the exact placement and shape of the control.

The anchor properties adjust where the offsets are relative to. Each offset has an individual anchor that can be adjusted from the beginning to the end of the parent. So the vertical (top, bottom) anchors adjust from 0.0 (top of parent) to 1.0 (bottom of parent) with 0.5 being the center, and the control offsets will be placed relative to that point. The horizontal (left, right) anchors similarly adjust from left to right of the parent.

Note that when you wish the edge of a control to be above or left of the anchor point, you must change the offset value to be negative.

For example: when horizontal anchors are changed to 1.0, the offset values become relative to the top-right corner of the parent control or viewport.

Adjusting the two horizontal or the two vertical anchors to different values will make the control change size when the parent control does. Here, the control is set to anchor its bottom-right corner to the parent's bottom-right, while the top-left control offsets are still anchored to the top-left of the parent, so when re-sizing the parent, the control will always cover it, leaving a 20 pixel offset:

To center a control in its parent, set its anchors to 0.5 and each offset to half of its relevant dimension. For example, the code below shows how a TextureRect can be centered in its parent:

Setting each anchor to 0.5 moves the reference point for the offsets to the center of its parent. From there, we set negative offsets so that the control gets its natural size.

Instead of manually adjusting the offset and anchor values, you can use the toolbar's Anchor menu, above the viewport. Besides centering, it gives you many options to align and resize control nodes.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
var rect = TextureRect.new()
rect.texture = load("res://icon.png")
rect.anchor_left = 0.5
rect.anchor_right = 0.5
rect.anchor_top = 0.5
rect.anchor_bottom = 0.5
var texture_size = rect.texture.get_size()
rect.offset_left = -texture_size.x / 2
rect.offset_right = texture_size.x / 2
rect.offset_top = -texture_size.y / 2
rect.offset_bottom = texture_size.y / 2
add_child(rect)
```

Example 2 (unknown):
```unknown
var rect = new TextureRect();

rect.Texture = ResourceLoader.Load<Texture>("res://icon.png");
rect.AnchorLeft = 0.5f;
rect.AnchorRight = 0.5f;
rect.AnchorTop = 0.5f;
rect.AnchorBottom = 0.5f;

var textureSize = rect.Texture.GetSize();

rect.OffsetLeft = -textureSize.X / 2;
rect.OffsetRight = textureSize.X / 2;
rect.OffsetTop = -textureSize.Y / 2;
rect.OffsetBottom = textureSize.Y / 2;
AddChild(rect);
```

---

## Support different actor types — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_different_actor_types.html

**Contents:**
- Support different actor types
- User-contributed notes

To support different actor types due to e.g. their sizes each type requires its own navigation map and navigation mesh baked with an appropriated agent radius and height. The same approach can be used to distinguish between e.g. landwalking, swimming or flying agents.

Agents are exclusively defined by a radius and height value for baking navigation meshes, pathfinding and avoidance. More complex shapes are not supported.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
# Create a navigation mesh resource for each actor size.
var navigation_mesh_standard_size: NavigationMesh = NavigationMesh.new()
var navigation_mesh_small_size: NavigationMesh = NavigationMesh.new()
var navigation_mesh_huge_size: NavigationMesh = NavigationMesh.new()

# Set appropriated agent parameters.
navigation_mesh_standard_size.agent_radius = 0.5
navigation_mesh_standard_size.agent_height = 1.8
navigation_mesh_small_size.agent_radius = 0.25
navigation_mesh_small_size.agent_height = 0.7
navigation_mesh_huge_size.agent_radius = 1.5
navigation_mesh_huge_size.agent_height = 2.5

# Get the root node to parse geometry for the baking.
var root_node: Node3D = get_node("NavigationMeshBakingRootNode")

# Create the source geometry resource that will hold the parsed geometry data.
var source_geometry_data: NavigationMeshSourceGeometryData3D = NavigationMeshSourceGeometryData3D.new()

# Parse the source geometry from the scene tree on the main thread.
# The navigation mesh is only required for the parse settings so any of the three will do.
NavigationServer3D.parse_source_geometry_data(navigation_mesh_standard_size, source_geometry_data, root_node)

# Bake the navigation geometry for each agent size from the same source geometry.
# If required for performance this baking step could also be done on background threads.
NavigationServer3D.bake_from_source_geometry_data(navigation_mesh_standard_size, source_geometry_data)
NavigationServer3D.bake_from_source_geometry_data(navigation_mesh_small_size, source_geometry_data)
NavigationServer3D.bake_from_source_geometry_data(navigation_mesh_huge_size, source_geometry_data)

# Create different navigation maps on the NavigationServer.
var navigation_map_standard: RID = NavigationServer3D.map_create()
var navigation_map_small: RID = NavigationServer3D.map_create()
var navigation_map_huge: RID = NavigationServer3D.map_create()

# Set the new navigation maps as active.
NavigationServer3D.map_set_active(navigation_map_standard, true)
NavigationServer3D.map_set_active(navigation_map_small, true)
NavigationServer3D.map_set_active(navigation_map_huge, true)

# Create a region for each map.
var navigation_region_standard: RID = NavigationServer3D.region_create()
var navigation_region_small: RID = NavigationServer3D.region_create()
var navigation_region_huge: RID = NavigationServer3D.region_create()

# Add the regions to the maps.
NavigationServer3D.region_set_map(navigation_region_standard, navigation_map_standard)
NavigationServer3D.region_set_map(navigation_region_small, navigation_map_small)
NavigationServer3D.region_set_map(navigation_region_huge, navigation_map_huge)

# Set navigation mesh for each region.
NavigationServer3D.region_set_navigation_mesh(navigation_region_standard, navigation_mesh_standard_size)
NavigationServer3D.region_set_navigation_mesh(navigation_region_small, navigation_mesh_small_size)
NavigationServer3D.region_set_navigation_mesh(navigation_region_huge, navigation_mesh_huge_size)

# Create start and end position for the navigation path query.
var start_pos: Vector3 = Vector3(0.0, 0.0, 0.0)
var end_pos: Vector3 = Vector3(2.0, 0.0, 0.0)
var use_corridorfunnel: bool = true

# Query paths for each agent size.
var path_standard_agent = NavigationServer3D.map_get_path(navigation_map_standard, start_pos, end_pos, use_corridorfunnel)
var path_small_agent = NavigationServer3D.map_get_path(navigation_map_small, start_pos, end_pos, use_corridorfunnel)
var path_huge_agent = NavigationServer3D.map_get_path(navigation_map_huge, start_pos, end_pos, use_corridorfunnel)
```

Example 2 (unknown):
```unknown
// Create a navigation mesh resource for each actor size.
NavigationMesh navigationMeshStandardSize = new NavigationMesh();
NavigationMesh navigationMeshSmallSize = new NavigationMesh();
NavigationMesh navigationMeshHugeSize = new NavigationMesh();

// Set appropriated agent parameters.
navigationMeshStandardSize.AgentRadius = 0.5f;
navigationMeshStandardSize.AgentHeight = 1.8f;
navigationMeshSmallSize.AgentRadius = 0.25f;
navigationMeshSmallSize.AgentHeight = 0.7f;
navigationMeshHugeSize.AgentRadius = 1.5f;
navigationMeshHugeSize.AgentHeight = 2.5f;

// Get the root node to parse geometry for the baking.
Node3D rootNode = GetNode<Node3D>("NavigationMeshBakingRootNode");

// Create the source geometry resource that will hold the parsed geometry data.
NavigationMeshSourceGeometryData3D sourceGeometryData = new NavigationMeshSourceGeometryData3D();

// Parse the source geometry from the scene tree on the main thread.
// The navigation mesh is only required for the parse settings so any of the three will do.
NavigationServer3D.ParseSourceGeometryData(navigationMeshStandardSize, sourceGeometryData, rootNode);

// Bake the navigation geometry for each agent size from the same source geometry.
// If required for performance this baking step could also be done on background threads.
NavigationServer3D.BakeFromSourceGeometryData(navigationMeshStandardSize, sourceGeometryData);
NavigationServer3D.BakeFromSourceGeometryData(navigationMeshSmallSize, sourceGeometryData);
NavigationServer3D.BakeFromSourceGeometryData(navigationMeshHugeSize, sourceGeometryData);

// Create different navigation maps on the NavigationServer.
Rid navigationMapStandard = NavigationServer3D.MapCreate();
Rid navigationMapSmall = NavigationServer3D.MapCreate();
Rid navigationMapHuge = NavigationServer3D.MapCreate();

// Set the new navigation maps as active.
NavigationServer3D.MapSetActive(navigationMapStandard, true);
NavigationServer3D.MapSetActive(navigationMapSmall, true);
NavigationServer3D.MapSetActive(navigationMapHuge, true);

// Create a region for each map.
Rid navigationRegionStandard = NavigationServer3D.RegionCreate();
Rid navigationRegionSmall = NavigationServer3D.RegionCreate();
Rid navigationRegionHuge = NavigationServer3D.RegionCreate();

// Add the regions to the maps.
NavigationServer3D.RegionSetMap(navigationRegionStandard, navigationMapStandard);
NavigationServer3D.RegionSetMap(navigationRegionSmall, navigationMapSmall);
NavigationServer3D.RegionSetMap(navigationRegionHuge, navigationMapHuge);

// Set navigation mesh for each region.
NavigationServer3D.RegionSetNavigationMesh(navigationRegionStandard, navigationMeshStandardSize);
NavigationServer3D.RegionSetNavigationMesh(navigationRegionSmall, navigationMeshSmallSize);
NavigationServer3D.RegionSetNavigationMesh(navigationRegionHuge, navigationMeshHugeSize);

// Create start and end position for the navigation path query.
Vector3 startPos = new Vector3(0.0f, 0.0f, 0.0f);
Vector3 endPos = new Vector3(2.0f, 0.0f, 0.0f);
bool useCorridorFunnel = true;

// Query paths for each agent size.
var pathStandardAgent = NavigationServer3D.MapGetPath(navigationMapStandard, startPos, endPos, useCorridorFunnel);
var pathSmallAgent = NavigationServer3D.MapGetPath(navigationMapSmall, startPos, endPos, useCorridorFunnel);
var pathHugeAgent = NavigationServer3D.MapGetPath(navigationMapHuge, startPos, endPos, useCorridorFunnel);
```

---

## Theme type variations — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/gui_theme_type_variations.html

**Contents:**
- Theme type variations
- Creating a type variation
- Using a type variation
- User-contributed notes

When designing a user interface there may be times when a Control node needs to have a different look than what is normally defined by a Theme. Every control node has theme property overrides, which allow you to redefine the styling for each individual UI element.

This approach quickly becomes hard to manage, if you need to share the same custom look between several controls. Imagine that you use gray, blue, and red variants of Button throughout your project. Setting it up every time you add a new button element to your interface is a tedious task.

To help with the organization and to better utilize the power of themes you can use theme type variations. These work like normal theme types, but instead of being self-sufficient and standalone they extend another, base type.

Following the previous example, your theme can have some styles, colors, and fonts defined for the Button type, customizing the looks of every button element in your UI. To then have a gray, red, or blue button you would create a new type, e.g. GrayButton, and mark it as a variation of the base Button type.

Type variations can replace some aspects of the base type, but keep others. They can also define properties that the base style hasn't defined. For example, your GrayButton can override the normal style from the base Button and add font_color that Button has never defined. The control will use a combination of both types giving priority to the type variation.

The way controls resolve what theme items they use from each type and each theme is better described in the Customizing a project section of the "Introduction to GUI skinning" article.

To create a type variation open the theme editor, then click the plus icon next to the Type dropdown on the right side of the editor. Type in what you want to name your theme type variation in the text box, then click Add Type.

Below the Type dropdown are the property tabs. Switch to the tab with a wrench and screwdriver icon.

Click on the plus icon next to the Base Type field. You can select the base type there, which would typically be the name of a control node class (e.g., Button, Label, etc). Type variations can also chain and extend other type variations. This works in the same way control nodes inherit styling of their base class. For example, CheckButton inherits styles from Button because corresponding node types extend each other.

After you select the base type, you should now be able to see its properties on the other tabs in the theme editor. You can edit them as usual.

Now that a type variation has been created you can apply it to your nodes. In the inspector dock, under the Theme property of a control node, you can find the Theme Type Variation property. It is empty by default, which means that only the base type has an effect on this node.

You can either select a type variation from a dropdown list, or input its name manually. Variations appear on the list only if the type variation belongs to the project-wide theme, which you can configure in the project settings. For any other case you have to input the name of the variation manually. Click on the pencil icon to the right. Then type in the name of the type variation and click the check mark icon or press enter. If a type variation with that name exists it will now be used by the node.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## The XR action map — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/xr/xr_action_map.html

**Contents:**
- The XR action map
- The default action map
- Action sets
- Actions
- Profiles
- Our first controller binding
- The simple controller
- Binding Modifiers
  - Binding modifiers on an interaction profile
    - Dpad Binding modifier

Godot has an action map feature as part of the XR system. At this point in time this system is part of the OpenXR module. There are plans to encompass WebXR into this in the near future hence we call it the XR action map system in this document. It implements the built-in action map system of OpenXR mostly exactly as it is offered.

The XR action map system exposes input, positional data and output for XR controllers to your game/application. It does this by exposing named actions that can be tailored to your game/application and binding these to the actual inputs and outputs on your XR devices.

As the XR action map is currently part of the OpenXR module, OpenXR needs to be enabled in your project settings to expose it:

You will then find the XR Action Map interface in the bottom of the screen:

Godot's built-in input system has many things in common with the XR action map system. In fact our original idea was to add functionality to the existing input system and expose the data to the OpenXR action map system. We may revisit that idea at some point but as it turns out there were just too many problems to overcome. To name a few:

Godot's input system mainly centers around button inputs, XR adds triggers, axis, poses and haptics (output) into the mix. This would greatly complicate the input system with features that won't work for normal controllers or contrast with the current approach. It was felt this would lead to confusion for the majority of Godot users.

Godot's input system works with raw input data that is parsed and triggers emitting actions. This input data is made available to the end user. OpenXR completely hides raw data and does all the parsing for us, we only get access to already parsed action data. This inconsistency is likely to lead to bugs when an unsuspecting user tries to use an XR device as a normal input device.

Godot's input system allows changes to what inputs are bound to actions in runtime, OpenXR does not.

Godot's input system is based on device ids which are meaningless in OpenXR.

This does mean that a game/application that mixes traditional inputs with XR controllers will have a separation. For most applications either one or the other is used and this is not seen as a problem. In the end, it's a limitation of the system.

Godot will automatically create a default action map if no action map file is found.

This default map was designed to help developers port their XR games/applications from Godot 3 to Godot 4. As a result this map essentially binds all known inputs on all controllers supported by default, to actions one on one. This is not a good example of setting up an action map. It does allow a new developer to have a starting point when they want to become familiar with Godot XR. It prevents having to design a proper action map for their game/application first.

For this walkthrough we're going to start with a blank action map. You can delete the "Godot action set" entry at the top by pressing the trash can icon. This will clear out all actions. You might also want to remove the controllers that you do not wish to setup, more on this later.

Before we dive in, you will see the term XR runtime used throughout this document. With XR runtime we mean the software that is controlling and interacting with the AR or VR headset. The XR runtime then exposes this to us through an API such as OpenXR. So:

for Steam this is SteamVR,

for Meta on desktop this is the Oculus Client (including when using Quest link),

for Meta on Quest this is the Quest's native OpenXR client,

on Linux this could be Monado, etc.

The action map allows us to organize our actions in sets. Each set can be enabled or disabled on its own.

The concept here is that you could have different sets that provide bindings in different scenarios. You could have:

a Character control set for when you're walking around,

a Vehicle control set for when you're operating a vehicle,

a Menu set for when a menu is open.

Only the action set applicable to the current state of your game/application can then be enabled.

This is especially important if you wish to bind the same input on a controller to a different action. For instance:

in your Character control set you may have an action Jump,

in your Vehicle control set you may have an action Accelerate,

in your Menu set you may have an action Select.

All are bound to the trigger on your controller.

OpenXR will only bind an input or output to a single action. If the same input or output is bound to multiple actions the one in the active action set with the highest priority will be the one updated/used. So in our above example it will thus be important that only one action set is active.

For your first XR game/application we highly recommend starting with just a single action set and to not over-engineer things.

For our walkthrough in this document we will thus create a single action set called my_first_action_set. We do this by pressing the Add action set button:

The columns in our table are as follows:

This is the internal name of the action set. OpenXR doesn't specify specific restrictions on this name other then size, however some XR runtimes will not like spaces or special characters.

This is a human-readable name for the action set. Some XR runtimes will display this name to the end user, for example in configuration dialogs.

This is the priority of the action set. If multiple active action sets have actions bound to the same controller's inputs or outputs, the action set with the highest priority value will determine the action that is updated.

In the XR action map, actions are the entities that your game/application will interact with. For instance, we can define an action Shoot and the input bound to that action will trigger the button_pressed signal on the relevant XRController3D node in your scene with Shoot as the name parameter of the signal.

You can also poll the current state of an action. XRController3D for instance has an is_button_pressed method.

Actions can be used for both input and output and each action has a type that defines its behavior.

The Bool type is used for discrete input like buttons.

The Float type is used for analogue input like triggers.

These two are special as they are the only ones that are interchangeable. OpenXR will handle conversions between Bool and Float inputs and actions. You can get the value of a Float type action by calling the method get_float on your XRController3D node. It emits the input_float_changed signal when changed.

Where analogue inputs are queried as buttons a threshold is applied. This threshold is currently managed exclusively by the XR runtime. There are plans to extend Godot to provide some level of control over these thresholds in the future.

The Vector2 type defines the input as an axis input. Touchpads, thumbsticks and similar inputs are exposed as vectors. You can get the value of a Vector2 type action by calling the method get_vector2 on your XRController3D node. It emits the input_vector2_changed signal when changed.

The Pose type defines a spatially tracked input. Multiple "pose" inputs are available in OpenXR: aim, grip and palm. Your XRController3D node is automatically positioned based on the pose action assigned to pose property of this node. More about poses later.

The OpenXR implementation in Godot also exposes a special pose called Skeleton. This is part of the hand tracking implementation. This pose is exposed through the skeleton action that is supported outside of the action map system. It is thus always present if hand tracking is supported. You don't need to bind actions to this pose to use it.

Finally, the only output type is Haptic and it allows us to set the intensity of haptic feedback, such as controller vibration. Controllers can have multiple haptic outputs and support for haptic vests is coming to OpenXR.

So lets add an action for our aim pose, we do this by clicking on the + button for our action set:

The columns in our table are as follows:

This is the internal name of the action. OpenXR doesn't specify specific restrictions on this name other then size, however some XR runtimes will not like spaces or special characters.

This is a human-readable name for the action. Some XR runtimes will display this name to the end user, for example in configuration dialogs.

The type of this action.

OpenXR defines a number of bindable input poses that are commonly available for controllers. There are no rules for which poses are supported for different controllers. The poses OpenXR currently defines are:

The aim pose on most controllers is positioned slightly in front of the controller and aims forward. This is a great pose to use for laser pointers or to align the muzzle of a weapon with.

The grip pose on most controllers is positioned where the grip button is placed on the controller. The orientation of this pose differs between controllers and can differ for the same controller on different XR runtimes.

The palm pose on most controllers is positioned in the center of the palm of the hand holding the controller. This is a new pose that is not available on all XR runtimes.

If hand tracking is used, there are currently big differences in implementations between the different XR runtimes. As a result the action map is currently not suitable for hand tracking. Work is being done on this so stay tuned.

Let's complete our list of actions for a very simple shooting game/application:

The actions we have added are:

movement, which allows the user to move around outside of normal room scale tracking.

grab, which detects that the user wants to hold something.

shoot, which detects that the user wants to fire the weapon they are holding.

haptic, which allows us to output haptic feedback.

Now note that we don't distinguish between the left and right hand. This is something that is determined at the next stage. We've implemented the action system in such a way that you can bind the same action to both hands. The appropriate XRController3D node will emit the signal.

For both grab and shoot we've used the Bool type. As mentioned before, OpenXR does automatic conversions from an analogue controls however not all XR Runtimes currently apply sensible thresholds.

We recommend as a workaround to use the Float type when interacting with triggers and grip buttons and apply your own threshold.

For buttons like A/B/X/Y and similar where there is no analogue option, the Bool type works fine.

You can bind the same action to multiple inputs for the same controller on the same profile. In this case the XR runtime will attempt to combine the inputs.

For Bool inputs, this will perform an OR operation between the buttons.

For Float inputs, this will take the highest value of the bound inputs.

The behavior for Pose inputs is undefined, but the first bound input is likely to be used.

You shouldn't bind multiple actions of the same action set to the same controller input. If you do this, or if actions are bound from multiple action sets but they have overlapping priorities, the behavior is undefined. The XR runtime may simply not accept your action map, or it may take this on a first come first serve basis.

We are still investigating the restrictions around binding multiple actions to the same output as this scenario makes sense. The OpenXR specification seems to not allow this.

Now that we have our basic actions defined, it's time to hook them up.

In OpenXR controller bindings are captured in so-called "Interaction Profiles". We've shortened it to "Profiles" because it takes up less space.

This generic name is chosen because controllers don't cover the entire system. Currently there are also profiles for trackers, remotes and tracked pens. There are also provisions for devices such as treadmills, haptic vests and such even though those are not part of the specification yet.

It is important to know that OpenXR has strict checking on supported devices. The core specification identifies a number of controllers and similar devices with their supported inputs and outputs. Every XR runtime must accept these interaction profiles even if they aren't applicable.

New devices are added through extensions and XR runtimes must specify which ones they support. XR runtimes that do not support a device added through extensions will not accept these profiles. XR runtimes that do not support added input or output types will often crash if supplied.

As such Godot keeps meta data of all available devices, their inputs and outputs and which extension adds support for them. You can create interaction profiles for all devices you wish to support. Godot will filter out those not supported by the XR runtime the user is using.

This does mean that in order to support new devices, you might need to update to a more recent version of Godot.

It is however also important to note that the action map has been designed with this in mind. When new devices enter the market, or when your users use devices that you do not have access to, the action map system relies on the XR runtime. It is the XR runtime's job to choose the best fitting interaction profile that has been specified and adapt it for the controller the user is using.

How the XR runtime does this is left to the implementation of the runtime and there are thus vast differences between the runtimes. Some runtimes might even permit users to edit the bindings themselves.

A common approach for a runtime is to look for a matching interaction profile first. If this is not found it will check the most common profiles such as that of the "Touch controller" and do a conversion. If all else fails, it will check the generic "Simple controller".

There is an important conclusion to be made here: When a controller is found, and the action map is applied to it, the XR runtime is not limited to the exact configurations you set up in Godot's action map editor. While the runtime will generally choose a suitable mapping based on one of the bindings you set up in the action map, it can deviate from it.

For example, when the Touch controller profile is used any of the following scenarios could be true:

we could be using a Quest 1 controller,

we could be using a Quest 2 controller,

we could be using a Quest Pro controller but no Quest Pro profile was given or the XR runtime being used does not support the Quest Pro controller,

it could be a completely different controller for which no profile was given but the XR runtime is using the touch bindings as a base.

Ergo, there currently is no way to know with certainty, which controller the user is actually using.

Finally, and this trips up a lot of people, the bindings aren't set in stone. It is fully allowed, and even expected, that an XR runtime allows a user to customise the bindings.

At the moment none of the XR runtimes offer this functionality though SteamVR has an existing UI from OpenVRs action map system that is still accessible. This is actively being worked on however.

Let's set up our first controller binding, using the Touch controller as an example.

Press "Add profile", find the Touch controller, and add it. If it is not in the list, then it may already have been added.

Our UI now shows panels for both the left and right controllers. The panels contain all of the possible inputs and outputs for each controller. We can use the + next to each entry to bind it to an action:

Let's finish our configuration:

Each action is bound the given input or output for both controllers to indicate that we support the action on either controller. The exception is the movement action which is bound only to the right hand controller. It is likely that we would want to use the left hand thumbstick for a different purpose, say a teleport function.

In developing your game/application you have to account for the possibility that the user changes the binding and binds the movement to the left hand thumbstick.

Also note that our shoot and grab boolean actions are linked to inputs of type Float. As mentioned before OpenXR will do conversions between the two, but do read the warning given on that subject earlier in this document.

Some of the inputs seem to appear in our list multiple times.

For instance we can find the X button twice, once as X click and then as X touch. This is due to the Touch controller having a capacitive sensor.

X touch will be true if the user is merely touching the X button.

X click will be true when the user is actually pressing down on the button.

Similarly for the thumbstick we have:

Thumbstick touch which will be true if the user is touching the thumbstick.

Thumbstick which gives a value for the direction the thumbstick is pushed to.

Thumbstick click which is true when the user is pressing down on the thumbstick.

It is important to note that only a select number of XR controllers support touch sensors or have click features on thumbsticks. Keep that in mind when designing your game/application. Make sure these are used for optional features of your game/application.

The "Simple controller" is a generic controller that OpenXR offers as a fallback. We'll apply our mapping:

As becomes painfully clear, the simple controller is often far too simple and falls short for anything but the simplest of VR games/applications.

This is why many XR runtimes only use it as a last resort and will attempt to use bindings from one of the more popular systems as a fallback first.

Due to the simple controller likely not covering the needs of your game, it is tempting to provide bindings for every controller supported by OpenXR. The default action map seems to suggest this as a valid course of action. As mentioned before, the default action map was designed for ease of migration from Godot 3.

It is the recommendation from the OpenXR Working Group that only bindings for controllers actually tested by the developer are setup. The XR runtimes are designed with this in mind. They can perform a better job of rebinding a provided binding than a developer can make educated guesses. Especially as the developer can't test if this leads to a comfortable experience for the end user.

This is our advice as well: limit your action map to the interaction profiles for devices you have actually tested your game with. The Oculus Touch controller is widely used as a fallback controller by many runtimes. If you are able to test your game using a Meta Rift or Quest and add this profile there is a high probability your game will work with other headsets.

One of the main goals of the action map is to remove the need for the application to know the hardware used. However, sometimes the hardware has physical differences that require inputs to be altered in ways other than how they are bound to actions. This need ranges from setting thresholds, to altering the inputs available on a controller.

Binding modifiers are not enabled by default and require enabling in the OpenXR project settings. Also there is no guarantee that these modifiers are supported by every runtime. You will need to consult the support for the runtimes you are targeting and decide whether to rely on the modifiers or implement some form of fallback mechanism.

If you are targeting multiple runtimes that have support for the same controllers, you may need to create separate action maps for each runtime. You can control which action map Godot uses by using different export templates for each runtime and using a custom feature tag to set the action map.

In Godot, binding modifiers are divided into two groups: modifiers that work on the interaction profile level, and modifiers that work on individual bindings.

Binding modifiers that are applied to the whole interaction profile can be accessed through the modifier button on the right side of the interaction profile editor.

You can add a new modifier by pressing the Add binding modifier button.

As Godot doesn't know which controllers and runtimes support a modifier, there is no restriction to adding modifiers. Unsupported modifiers will be ignored.

The dpad binding modifier adds new inputs to an interaction profile for each joystick and thumbpad input on this controller. It turns the input into a dpad with separate up, down, left and right inputs that are exposed as buttons:

Inputs related to extensions are denoted with an asterix.

In order to use the dpad binding modifier you need to enable the dpad binding modifier extension in project settings:

Enabling the extension is enough to make this functionality work using default settings.

Adding the modifier is optional and allows you to fine tune the way the dpad functionality behaves. You can add the modifier multiple times to set different settings for different inputs.

These settings are used as follows:

Action Set defines the action set to which these settings are applied.

Input Path defines the original input that is mapped to the new dpad inputs.

Threshold specifies the threshold value that will enable a dpad action, e.g. a value of 0.6 means that if the distance from center goes above 0.6 the dpad action is pressed.

Threshold Released specifies the threshold value that will disable a dpad action, e.g. a value of 0.4 means that if the distance from center goes below 0.4 the dpad action is released.

Center Region specifies the distance from center that enabled the center action, this is only supported for trackpads.

Wedge Angle specifies the angle of each wedge. A value of 90 degrees or lower means that up, down, left and right each have a separate slice in which they are in the pressed state. A value above 90 degrees means that the slices overlap and that multiple actions can be in the pressed state.

Is Sticky, when enabled means that an action stays in the pressed state until the thumbstick or trackpad moves into another wedge even if it has left the wedge for that action.

On Haptic lets us define a haptic output that is automatically activated when an action becomes pressed.

Off Haptic lets us define a haptic output that is automatically activated when an action is released.

Binding modifiers that are applied to individual bindings can be accessed through the binding modifier button next to action attached to an input:

You can add a new modifier by pressing the Add binding modifier button.

As Godot doesn't know which inputs on each runtime support a modifier, there is no restriction to adding modifiers. If the modifier extension is unsupported, modifiers will be filtered out at runtime. Modifiers added to the wrong input may result in a runtime error.

You should test your action map on the actual hardware and runtime to verify the proper setup.

The analog threshold modifier allows you to specify the thresholds used for any analog input, like the trigger, that has a boolean input. This controls when the input is in the pressed state.

In order to use this modifier you must enable the analog threshold extension in the project settings:

The analog threshold modifier has the following settings:

These are defined as follows:

On Threshold specifies the threshold value that will enable the action, e.g. a value of 0.6 means that when the analog value gets above 0.6 the action is set to the pressed state.

Off Threshold specifies the threshold value that will disable the action, e.g. a value of 0.4 means that when the analog value goes below 0.4 the action is set in to the released state.

On Haptic lets us define a haptic output that is automatically activated when the input is pressed.

Off Haptic lets us define a haptic output that is automatically activated when the input is released.

Modifiers can support automatic haptic output that is triggered when thresholds are reached.

Currently both available modifiers support this feature however there is no rule future modifiers also have this capability. Only one type of haptic feedback is supported but in the future other options may become available.

The haptic vibration allows us to specify a simple haptic pulse:

It has the following options:

Duration is the duration of the pulse in nanoseconds. -1 lets the runtime choose an optimal value for a short pulse suitable for the current hardware.

Frequency is the frequency of the pulse in Hz. 0 lets the runtime choose an optimal frequency for a short pulse suitable for the current hardware.

Amplitude is the amplitude of the pulse.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## User interface (UI) — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/index.html

**Contents:**
- User interface (UI)
- UI building blocks
- GUI skinning and themes
- Control node tutorials

In this section of the tutorial we explain the basics of creating a graphical user interface (GUI) in Godot.

Like everything else in Godot the user interface is built using nodes, specifically Control nodes. There are many different types of controls which are useful for creating specific types of GUIs. For simplicity we can separate them into two groups: content and layout.

Typical content controls include:

LineEdits and TextEdits

Typical layout controls include:

The following pages explain the basics of using such controls.

Godot features an in-depth skinning/theming system for control nodes. The pages in this section explain the benefits of that system and how to set it up in your projects.

The following articles cover specific details of using particular control nodes.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Using an external text editor — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html

**Contents:**
- Using an external text editor
- Automatically reloading your changes
- Using External Editor in Debugger
- Official editor plugins
- LSP/DAP support
  - Visual Studio Code
  - Emacs
- User-contributed notes

This page explains how to code using an external text editor.

To code C# in an external editor, see the C# guide to configure an external editor.

Godot can be used with an external text editor, such as Sublime Text or Visual Studio Code. Browse to the relevant editor settings: Editor > Editor Settings > Text Editor > External

Text Editor > External section of the Editor Settings

There are two text fields: the executable path and command-line flags. The flags allow you to integrate the editor with Godot, passing it the file path to open and other relevant arguments. Godot will replace the following placeholders in the flags string:

The absolute path to the project directory

The absolute path to the file

The column number of the error

The line number of the error

Some example Exec Flags for various editors include:

{file} --line {line} --column {col}

{project} --line {line} {file}

{project} --goto {file}:{line}:{col}

"+call cursor({line}, {col})" {file}

emacs +{line}:{col} {file}

{project} {file}:{line}:{col}

*: Arguments are not automatically detected, so you must fill them in manually.

Since Godot 4.5, Exec Flags are automatically detected for all editors listed above (unless denoted with an asterisk). You don't need to paste them from this page for it to work, unless your editor has an executable name not recognized automatically (e.g. a fork of an editor listed here).

For Visual Studio Code on Windows, you will have to point to the code.cmd file.

For Emacs, you can call emacsclient instead of emacs if you use the server mode.

For Visual Studio, you will have to open the solution file .sln manually to get access to the IDE features. Additionally, it will not go to a specific line.

To have the Godot Editor automatically reload any script that has been changed by an external text editor, enable Editor > Editor Settings > Text Editor > Behavior > Auto Reload Scripts on External Change.

Using external editor in debugger is determined by a separate option in settings. For details, see Script editor debug tools and options.

We have official plugins for the following code editors:

Godot supports the Language Server Protocol (LSP) for code completion and the Debug Adapter Protocol (DAP) for debugging. You can check the LSP client list and DAP client list to find if your editor supports them. If this is the case, you should be able to take advantage of these features without the need of a custom plugin.

To use these protocols, a Godot instance must be running on your current project. You should then configure your editor to communicate to the running adapter ports in Godot, which by default are 6005 for LSP, and 6006 for DAP. You can change these ports and other settings in the Editor Settings, under the Network > Language Server and Network > Debug Adapter sections respectively.

Below are some configuration steps for specific editors:

You need to install the official Visual Studio Code plugin.

For LSP, follow these instructions to change the default LSP port. The connection status can be checked on the status bar:

For DAP, specify the debugServer property in your launch.json file:

Check the official instructions to configure LSP, and DAP.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "GDScript Godot",
            "type": "godot",
            "request": "launch",
            "project": "${workspaceFolder}",
            "port": 6007,
            "debugServer": 6006,
        }
    ]
}
```

---

## Using Containers — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html

**Contents:**
- Using Containers
- Container layout
- Sizing options
- Container types
  - Box Containers
  - Grid Container
  - Margin Container
  - Tab Container
  - Split Container
  - PanelContainer

Anchors are an efficient way to handle different aspect ratios for basic multiple resolution handling in GUIs.

For more complex user interfaces, they can become difficult to use.

This is often the case of games, such as RPGs, online chats, tycoons or simulations. Another common case where more advanced layout features may be required is in-game tools (or simply just tools).

All these situations require a more capable OS-like user interface, with advanced layout and formatting. For that, Containers are more useful.

Containers provide a huge amount of layout power (as an example, the Godot editor user interface is entirely done using them):

When a Container-derived node is used, all children Control nodes give up their own positioning ability. This means the Container will control their positioning and any attempt to manually alter these nodes will be either ignored or invalidated the next time their parent is resized.

Likewise, when a Container derived node is resized, all its children will be re-positioned according to it, with a behavior based on the type of container used:

Example of HBoxContainer resizing children buttons.

The real strength of containers is that they can be nested (as nodes), allowing the creation of very complex layouts that resize effortlessly.

When adding a node to a container, the way the container treats each child depends mainly on their container sizing options. These options can be found by inspecting the layout of any Control that is a child of a Container.

Sizing options are independent for vertical and horizontal sizing and not all containers make use of them (but most do):

Fill: Ensures the control fills the designated area within the container. No matter if a control expands or not (see below), it will only fill the designated area when this is toggled on (it is by default).

Expand: Attempts to use as much space as possible in the parent container (in each axis). Controls that don't expand will be pushed away by those that do. Between expanding controls, the amount of space they take from each other is determined by the Stretch Ratio (see below). This option is only available when the parent Container is of the right type, for example the HBoxContainer has this option for horizontal sizing.

Shrink Begin When expanding, try to remain at the left or top of the expanded area.

Shrink Center When expanding, try to remain at the center of the expanded area.

Shrink End When expanding, try to remain at the right or bottom of the expanded area.

Stretch Ratio: The ratio of how much expanded controls take up the available space in relation to each other. A control with "2", will take up twice as much available space as one with "1".

Experimenting with these flags and different containers is recommended to get a better grasp on how they work.

Godot provides several container types out of the box as they serve different purposes:

Arranges child controls vertically or horizontally (via HBoxContainer and VBoxContainer). In the opposite of the designated direction (as in, vertical for a horizontal container), it just expands the children.

These containers make use of the Stretch Ratio property for children with the Expand flag set.

Arranges child controls in a grid layout (via GridContainer, amount of columns must be specified). Uses both the vertical and horizontal expand flags.

Child controls are expanded towards the bounds of this control (via MarginContainer). Padding will be added on the margins depending on the theme configuration.

Again, keep in mind that the margins are a Theme value, so they need to be edited from the constants overrides section of each control:

Allows you to place several child controls stacked on top of each other (via TabContainer), with only the current one visible.

Changing the current one is done via tabs located at the top of the container, via clicking:

The titles are generated from the node names by default (although they can be overridden via TabContainer API).

Settings such as tab placement and StyleBox can be modified in the TabContainer theme overrides.

Accepts only one or two children controls, then places them side to side with a divisor (via HSplitContainer and VSplitContainer). Respects both horizontal and vertical flags, as well as Ratio.

The divisor can be dragged around to change the size relation between both children:

A container that draws a StyleBox, then expands children to cover its whole area (via PanelContainer, respecting the StyleBox margins). It respects both the horizontal and vertical sizing options.

This container is useful as a top-level control, or just to add custom backgrounds to sections of a layout.

A container that can be expanded/collapsed (via FoldableContainer). Child controls are hidden when it is collapsed.

Accepts a single child node. If the child node is bigger than the container, scrollbars will be added to allow panning the node around (via ScrollContainer). Both vertical and horizontal size options are respected, and the behavior can be turned on or off per axis in the properties.

Mouse wheel and touch drag (when touch is available) are also valid ways to pan the child control around.

As in the example above, one of the most common ways to use this container is together with a VBoxContainer as child.

A container type that arranges its child controls in a way that preserves their proportions automatically when the container is resized. (via AspectRatioContainer). It has multiple stretch modes, providing options for adjusting the child controls' sizes concerning the container: "fill," "width control height," "height control width," and "cover."

It is useful when you have a container that needs to be dynamic and responsive to different screen sizes, and you want the child elements to scale proportionally without losing their intended shapes.

FlowContainer is a container that arranges its child controls either horizontally or vertically (via HFlowContainer and via VFlowContainer). When the available space runs out, it wraps the children to the next line or column, similar to how text wraps in a book.

It is useful for creating flexible layouts where the child controls adjust automatically to the available space without overlapping.

CenterContainer is a container that automatically keeps all of its child controls centered within it at their minimum size. It ensures that the child controls are always aligned to the center, making it easier to create centered layouts without manual positioning (via CenterContainer).

This is a special control that will only accept a single Viewport node as child, and it will display it as if it was an image (via SubViewportContainer).

It is possible to create a custom container using a script. Here is an example of a container that fits children to its size:

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
extends Container

func _notification(what):
    if what == NOTIFICATION_SORT_CHILDREN:
        # Must re-sort the children
        for c in get_children():
            # Fit to own size
            fit_child_in_rect(c, Rect2(Vector2(), size))

func set_some_setting():
    # Some setting changed, ask for children re-sort.
    queue_sort()
```

Example 2 (unknown):
```unknown
using Godot;

public partial class CustomContainer : Container
{
    public override void _Notification(int what)
    {
        if (what == NotificationSortChildren)
        {
            // Must re-sort the children
            foreach (Control c in GetChildren())
            {
                // Fit to own size
                FitChildInRect(c, new Rect2(new Vector2(), Size));
            }
        }
    }

    public void SetSomeSetting()
    {
        // Some setting changed, ask for children re-sort.
        QueueSort();
    }
}
```

---

## Using Fonts — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html

**Contents:**
- Using Fonts
- Dynamic fonts
- Bitmap fonts
- Loading a font file
- Font outlines and shadows
- Advanced font features
  - Antialiasing
  - Hinting
  - Subpixel positioning
  - Mipmaps

Godot allows you to set specific fonts for different UI nodes.

There are three different places where you can setup font usage. The first is the theme editor. Choose the node you want to set the font for and select the font tab. The second is in the inspector for control nodes under Theme Overrides > Fonts. Lastly, in the inspector settings for themes under Default Font.

If no font override is specified anywhere, Open Sans SemiBold is used as the default project font.

Since Godot 4.0, font sizes are no longer defined in the font itself but are instead defined in the node that uses the font. This is done in the Theme Overrides > Font Sizes section of the inspector.

This allows changing the font size without having to duplicate the font resource for every different font size.

There are 2 kinds of font files: dynamic (TTF/OTF/WOFF/WOFF2 formats) and bitmap (BMFont .fnt format or monospaced image). Dynamic fonts are the most commonly used option, as they can be resized and still look crisp at higher sizes. Thanks to their vector-based nature, they can also contain a lot more glyphs while keeping a reasonable file size compared to bitmap fonts. Dynamic fonts also support some advanced features that bitmap fonts cannot support, such as ligatures (several characters transforming into a single different design).

You can find freely licensed font files on websites such as Google Fonts and Font Library.

Fonts are covered by copyright. Double-check the license of a font before using it, as not all fonts allow commercial use without purchasing a license.

You can see how fonts work in action using the BiDI and Font Features demo project.

Godot supports the following dynamic font formats:

TrueType Font or Collection (.ttf, .ttc)

OpenType Font or Collection (.otf, .otc)

Web Open Font Format 1 (.woff)

Web Open Font Format 2 (.woff2, since Godot 3.5)

While .woff and especially .woff2 tend to result in smaller file sizes, there is no universally "better" font format. In most situations, it's recommended to use the font format that was shipped on the font developer's website.

Godot supports the BMFont (.fnt) bitmap font format. This is a format created by the BMFont program. Many BMFont-compatible programs also exist, like BMGlyph or web-based fontcutter.

Alternatively, you can import any image to be used as a bitmap font. To do so, select the image in the FileSystem dock, go to the Import dock, change its import type to Font Data (Image Font) then click Reimport:

Changing import type to Font Data (Image Font)

The font's character set layout can be in any order, but orders that match standard Unicode are recommended as they'll require far less configuration to import. For example, the bitmap font below contains ASCII characters and follows standard ASCII ordering:

Credit: LibreQuake (scaled and cropped to exclude extended range)

The following import options can be used to import the above font image successfully:

Import options to use for the above example font

The Character Ranges option is an array that maps each position on the image (in tile coordinates, not pixels). The font atlas is traversed from left to right and top to bottom. Characters can be specified with decimal numbers (127), hexadecimal numbers (0x007f) or between single quotes ('~'). Ranges can be specified with a hyphen between characters.

For instance, 0-127 (or 0x0000-0x007f) denotes the full ASCII range. As another example, ' '-'~' is equivalent to 32-127 and denotes the range of printable (visible) ASCII characters.

Make sure the Character Ranges option doesn't exceed the number of Columns × Rows defined. Otherwise, the font will fail to import.

If your font image contains margins not used for font glyphs (such as attribution information), try adjusting Image Margin. This is a margin applied only once around the whole image.

If your font image contains guides (in the form of lines between glyphs) or if spacing between characters appears incorrect, try adjusting Character Margin. This margin is applied for every imported glyph.

If you need finer control over character spacing than what the Character Margin options provide, you have more options.

For one, Character Ranges supports 3 additional arguments after the specified range of characters. These additional arguments control their positioning and spacing. They represent space advance, X axis offset, and Y axis offset in that order. They will change the space advance and offset of each character by the amount of pixels written. Space advance is most useful if, for example, your lowercase letters are thinner than your uppercase letters.

Do note that the offsets can cause your text to be cropped off the edge of your label boundaries.

Secondly, you can also set up Kerning Pairs for individual characters. Specify your kerning pair by typing two sets of characters separated by a space, then followed by another space, a number to specify how many extra/less pixels to space those two sets of characters when placed next to each other.

If needed, your kerning pair characters can be specified by Unicode character code by entering \uXXXX where XXXX is the hexadecimal value of the Unicode character.

To load a font file (dynamic or bitmap), use the resource dropdown's Quick Load or Load option next to a font property, then navigate to the font file in question:

You can also drag-and-drop a font file from the FileSystem dock to the inspector property that accepts a Font resource.

In Godot 4.0 and later, texture filter and repeat properties are defined in the location where the texture is used, rather than on the texture itself. This also applies to fonts (both dynamic fonts and bitmap fonts).

Fonts that have a pixel art appearance should have bilinear filtering disabled by changing the Rendering > Textures > Canvas Textures > Default Texture Filter project setting to Nearest.

The font size must also be an integer multiple of the design size (which varies on a per-font basis), and the Control node using the font must be scaled by an integer multiple as well. Otherwise, the font may look blurry. Font sizes in Godot are specified in pixels (px), not points (pt). Keep this in mind when comparing font sizes across different software.

The texture filter mode can also be set on individual nodes that inherit from CanvasItem by setting CanvasItem.texture_filter.

Font outlines and shadows can be used to improve readability when the background color isn't known in advance. For instance, this is the case for HUD elements that are drawn over a 2D/3D scene.

Font outlines are available in most nodes that derive from Control, in addition to Label3D.

To enable outline for a font on a given node, configure the theme overrides Font Outline Color and Outline Size in the inspector. The result should look like this:

Font outline example

If using a font with MSDF rendering, its MSDF Pixel Range import option be set to at least twice the value of the outline size for outline rendering to look correct. Otherwise, the outline may appear to be cut off earlier than intended.

Support for font shadows is more limited: they are only available in Label and RichTextLabel. Additionally, font shadows always have a hard edge (but you can reduce their opacity to make them look more subtle). To enable font shadows on a given node, configure the Font Shadow Color, Shadow Offset X, and Shadow Offset Y theme overrides in a Label or RichTextLabel node accordingly:

Configuring font shadow in a Label node

The result should look like this:

You can create local overrides to font display in Label nodes by creating a LabelSettings resource that you reuse across Label nodes. This resource takes priority over theme properties.

You can adjust how the font should be smoothed out when rendering by adjusting antialiasing and hinting. These are different properties, with different use cases.

Antialiasing controls how glyph edges should be smoothed out when rasterizing the font. The default antialiasing method (Grayscale) works well on every display technology. However, at small sizes, grayscale antialiasing may result in fonts looking blurry.

The antialiasing sharpness can be improved by using LCD subpixel optimization, which exploits the subpixel patterns of most LCD displays by offsetting the font antialiasing on a per-channel basis (red/green/blue). The downside is that this can introduce "fringing" on edges, especially on display technologies that don't use standard RGB subpixels (such as OLED displays).

In most games, it's recommended to stick to the default Grayscale antialiasing. For non-game applications, LCD subpixel optimization is worth exploring.

From top to bottom: Disabled, Grayscale, LCD Subpixel (RGB)

Antialiasing cannot be changed on MSDF-rendered fonts – these are always rendered with grayscale antialiasing.

Hinting controls how aggressively glyph edges should be snapped to pixels when rasterizing the font. None results in the smoothest appearance, which can make the font look blurry at small sizes. Light (default) is sharper by snapping glyph edges to pixels on the Y axis only, while Full is even sharper by snapping glyph edges to pixels on both X and Y axes. Depending on personal preference, you may prefer using one hinting mode over the other.

From top to bottom: None, Light, Full hinting

If changing the hinting mode has no visible effect after clicking Reimport, it's usually because the font doesn't include hinting instructions. This can be resolved by looking for a version of the font file that includes hinting instructions, or enabling Force Autohinter in the Import dock. This will use FreeType's autohinter to automatically add hinting instructions to the imported font.

Subpixel positioning can be adjusted. This is a FreeType feature that allows glyphs to be rendered more closely to their intended form. The default setting of Auto automatically enables subpixel positioning at small sizes, but disables it at large font sizes to improve rasterization performance.

You can force the subpixel positioning mode to Disabled, One half of a pixel or One quarter of a pixel. One quarter of a pixel provides the best quality, at the cost of longer rasterization times.

Changing antialiasing, hinting and subpixel positioning has the most visible effect at smaller font sizes.

Fonts that have a pixel art appearance should have their subpixel positioning mode set to Disabled. Otherwise, the font may appear to have uneven pixel sizes.

This step is not required for bitmap fonts, as subpixel positioning is only relevant for dynamic fonts (which are usually made of vector elements).

By default, fonts do not have mipmaps generated to reduce memory usage and speed up rasterization. However, this can cause downscaled fonts to become grainy. This can be especially noticeable with 3D text that doesn't have Fixed Size enabled. This can also occur when displaying text with a traditional rasterized (non-MSDF) font in a Control node that has its scale lower than (1, 1).

After selecting a font in the FileSystem dock, you can enable the Mipmaps in the Import dock to improve downscaled font rendering appearance.

Mipmaps can be enabled on MSDF fonts as well. This can improve font rendering quality a little at smaller-than-default sizes, but MSDF fonts are already resistant to graininess out of the box.

Multi-channel signed distance field (MSDF) font rendering allows rendering fonts at any size, without having to re-rasterize them when their size changes.

MSDF font rendering has 2 upsides over traditional font rasterization, which Godot uses by default:

The font will always look crisp, even at huge sizes.

There is less stuttering when rendering characters at large font sizes for the first time, as there is no rasterization performed.

The downsides of MSDF font rendering are:

Higher baseline cost for font rendering. This is usually not noticeable on desktop platforms, but it can have an impact on low-end mobile devices.

Fonts at small sizes will not look as clear as rasterized fonts, due to the lack of hinting.

Rendering new glyphs for the first time at small font sizes may be more expensive compared to traditional rasterized fonts. Font prerendering can be used to alleviate this.

LCD subpixel optimization cannot be enabled for MSDF fonts.

Fonts with self-intersecting outlines will not render correctly in MSDF mode. If you notice rendering issues on fonts downloaded from websites such as Google Fonts, try downloading the font from the font author's official website instead.

Comparison of font rasterization methods. From top to bottom: rasterized without oversampling, rasterized with oversampling, MSDF

To enable MSDF rendering for a given font, select it in the FileSystem dock, go to the Import dock, enable Multichannel Signed Distance Field, then click Reimport:

Enabling MSDF in the font's import options

Godot has limited support for emoji fonts:

CBDT/CBLC (embedded PNGs) and SVG emoji fonts are supported.

COLR/CPAL emoji fonts (custom vector format) are not supported.

EMJC bitmap image compression (used by iOS' system emoji font) is not supported. This means that to support emoji on iOS, you must use a custom font that uses SVG or PNG bitmap compression instead.

For Godot to be able to display emoji, the font used (or one of its fallbacks) needs to include them. Otherwise, emoji won't be displayed and placeholder "tofu" characters will appear instead:

Default appearance when trying to use emoji in a label

After adding a font to display emoji such as Noto Color Emoji, you get the expected result:

Correct appearance after adding an emoji font to the label

To use a regular font alongside emoji, it's recommended to specify a fallback font that points to the emoji font in the regular font's advanced import options. If you wish to use the default project font while displaying emoji, leave the Base Font property in FontVariation empty while adding a font fallback pointing to the emoji font:

Emoji fonts are quite large in size, so you may want to load a system font to provide emoji glyphs rather than bundling it with your project. This allows providing full emoji support in your project without increasing the size of its exported PCK. The downside is that emoji will look different depending on the platform, and loading system fonts is not supported on all platforms.

It's possible to use a system font as a fallback font too.

Tools like Fontello can be used to generate font files containing vectors imported from SVG files. This can be used to render custom vector elements as part of your text, or to create extruded 3D icons with 3D text and TextMesh.

Fontello currently does not support creating multicolored fonts (which Godot can render). As of November 2022, support for multicolored fonts in icon font generation tools remains scarce.

Depending on your use cases, this may lead to better results compared to using the img tag in RichTextLabel. Unlike bitmap images (including SVGs which are rasterized on import by Godot), true vector data can be resized to any size without losing quality.

After downloading the generated font file, load it in your Godot project then specify it as a custom font for a Label, RichTextLabel or Label3D node. Switch over to the Fontello web interface, then copy the character by selecting it then pressing Ctrl + C (Cmd + C on macOS). Paste the character in the Text property of your Label node. The character will appear as a placeholder glyph in the inspector, but it should appear correctly in the 2D/3D viewport.

To use an icon font alongside a traditional font in the same Control, you can specify the icon font as a fallback. This works because icon fonts use the Unicode private use area, which is reserved for use by custom fonts and doesn't contain standard glyphs by design.

Several modern icon fonts such as Font Awesome 6 have a desktop variant that uses ligatures to specify icons. This allows you to specify icons by entering their name directly in the Text property of any node that can display fonts. Once the icon's name is fully entered as text (such as house), it will be replaced by the icon.

While easier to use, this approach cannot be used with font fallbacks as the main font's characters will take priority over the fallback font's ligatures.

Godot supports defining one or more fallbacks when the main font lacks a glyph to be displayed. There are 2 main use cases for defining font fallbacks:

Use a font that only supports Latin character sets, but use another font to be able to display text another character set such as Cyrillic.

Use a font to render text, and another font to render emoji or icons.

Open the Advanced Import Settings dialog by double-clicking the font file in the FileSystem dock. You can also select the font in the FileSystem dock, go to the Import dock then choose Advanced… at the bottom:

In the dialog that appears, look for Fallbacks section on the sidebar on the right, click the Array[Font] (size 0) text to expand the property, then click Add Element:

Adding font fallback

Click the dropdown arrow on the new element, then choose a font file using the Quick Load or Load options:

Loading font fallback

It is possible to add fallback fonts while using the default project font. To do so, leave the Base Font property empty while adding one or more font fallbacks.

Font fallbacks can also be defined on a local basis similar to OpenType font features, but this is not covered here for brevity reasons.

Godot has full support for variable fonts, which allow you to use a single font file to represent various font weights and styles (regular, bold, italic, …). This must be supported by the font file you're using.

To use a variable font, create a FontVariation resource in the location where you intend to use the font, then load a font file within the FontVariation resource:

Creating a FontVariation resource

Loading a font file into the FontVariation resource

Scroll down to the FontVariation's Variation section, then click the Variation Coordinates text to expand the list of axes that can be adjusted:

List of variation axes

The set of axes you can adjust depends on the font loaded. Some variable fonts only support one axis of adjustment (typically weight or slant), while others may support multiple axes of adjustment.

For example, here's the Inter V font with a weight of 900 and a slant of -10:

Variable font example (Inter V)

While variable font axis names and scales aren't standardized, some common conventions are usually followed by font designers. The weight axis is standardized in OpenType to work as follows:

Effective font weight

Extra Light (Ultra Light)

Semi-Bold (Demi-Bold)

Extra Bold (Ultra Bold)

Extra Black (Ultra Black)

You can save the FontVariation to a .tres resource file to reuse it in other places:

Saving FontVariation to an external resource file

When writing text in bold or italic, using font variants specifically designed for this looks better. Spacing between glyphs will be more consistent when using a bold font, and certain glyphs' shapes may change entirely in italic variants (compare "a" and "a").

However, real bold and italic fonts require shipping more font files, which increases distribution size. A single variable font file can also be used, but this file will be larger than a single non-variable font. While file size is usually not an issue for desktop projects, it can be a concern for mobile/web projects that strive to keep distribution size as low as possible.

To allow bold and italic fonts to be displayed without having to ship additional fonts (or use a variable font that is larger in size), Godot supports faux bold and italic.

Faux bold/italic (top), real bold/italic (bottom). Normal font used: Open Sans SemiBold

Faux bold and italic is automatically used in RichTextLabel's bold and italic tags if no custom fonts are provided for bold and/or italic.

To use faux bold, create a FontVariation resource in a property where a Font resource is expected. Set Variation > Embolden to a positive value to make a font bolder, or to a negative value to make it less bold. Recommended values are between 0.5 and 1.2 depending on the font.

Faux italic is created by skewing the text, which is done by modifying the per-character transform. This is also provided in FontVariation using the Variation > Transform property. Setting the yx component of the character transform to a positive value will italicize the text. Recommended values are between 0.2 and 0.4 depending on the font.

For stylistic purposes or for better readability, you may want to adjust how a font is presented in Godot.

Create a FontVariation resource in a property where a Font resource is expected. There are 4 properties available in the Variation > Extra Spacing section, which accept positive and negative values:

Glyph: Additional spacing between every glyph.

Space: Additional spacing between words.

Top: Additional spacing above glyphs. This is used for multiline text, but also to calculate the minimum size of controls such as Label and Button.

Bottom: Additional spacing below glyphs. This is used for multiline text, but also to calculate the minimum size of controls such as Label and Button.

The Variation > Transform property can also be adjusted to stretch characters horizontally or vertically. This is specifically done by adjusting the xx (horizontal scale) and yy (vertical scale) components. Remember to adjust glyph spacing to account for any changes, as glyph transform doesn't affect how much space each glyph takes in the text. Non-uniform scaling of this kind should be used sparingly, as fonts are generally not designed to be displayed with stretching.

Godot supports enabling OpenType font features, which are a standardized way to define alternate characters that can be toggled without having to swap font files entirely. Despite being named OpenType font features, these are also supported in TrueType (.ttf) and WOFF/WOFF2 font files.

Support for OpenType features highly depends on the font used. Some fonts don't support any OpenType features, while other fonts can support dozens of toggleable features.

There are 2 ways to use OpenType font features:

Globally on a font file

Open the Advanced Import Settings dialog by double-clicking the font file in the FileSystem dock. You can also select the font in the FileSystem dock, go to the Import dock then choose Advanced… at the bottom:

In the dialog that appears, look for the Metadata Overrides > OpenType Features section on the sidebar on the right, click the Features (0 of N set) text to expand the property, then click Add Feature:

OpenType feature overrides in Advanced Import Settings

In a specific font usage (FontVariation)

To use a font feature, create a FontVariation resource like you would do for a variable font, then load a font file within the FontVariation resource:

Creating a FontVariation resource

Loading a font file into a FontVariation resource

Scroll down to the FontVariation's OpenType Features section, click the Features (0 of N set) text to expand the property, then click Add Feature and select the desired feature in the dropdown:

Specifying OpenType features in a FontVariation resource

For example, here's the Inter font without the Slashed Zero feature (top), then with the Slashed Zero OpenType feature enabled (bottom):

OpenType feature comparison (Inter)

You can disable ligatures and/or kerning for a specific font by adding OpenType features, then unchecking them in the inspector:

Disabling ligatures and kerning for a font

Loading system fonts is only supported on Windows, macOS, Linux, Android and iOS.

However, loading system fonts on Android is unreliable as there is no official API for doing so. Godot has to rely on parsing system configuration files, which can be modified by third-party Android vendors. This may result in non-functional system font loading.

System fonts are a different type of resource compared to imported fonts. They are never actually imported into the project, but are loaded at runtime. This has 2 benefits:

The fonts are not included within the exported PCK file, leading to a smaller file size for the exported project.

Since fonts are not included with the exported project, this avoids licensing issues that would occur if proprietary system fonts were distributed alongside the project.

The engine automatically uses system fonts as fallback fonts, which makes it possible to display CJK characters and emoji without having to load a custom font. There are some restrictions that apply though, as mentioned in the Using emoji section.

Create a SystemFont resource in the location where you desire to use the system font:

Creating a SystemFont resource

Specifying a font name to use in a SystemFont resource

You can either specify one or more font names explicitly (such as Arial), or specify the name of a font alias that maps to a "standard" default font for the system:

Handled by fontconfig

Handled by fontconfig

Handled by fontconfig

Handled by fontconfig

Handled by fontconfig

On Android, Roboto is used for Latin/Cyrillic text and Noto Sans is used for other languages' glyphs such as CJK. On third-party Android distributions, the exact font selection may differ.

If specifying more than one font, the first font that is found on the system will be used (from top to bottom). Font names and aliases are case-insensitive on all platforms.

Like for font variations, you can save the SystemFont arrangement to a resource file to reuse it in other places.

Remember that different system fonts have different metrics, which means that text that can fit within a rectangle on one platform may not be doing so on another platform. Always reserve some additional space during development so that labels can extend further if needed.

Unlike Windows and macOS/iOS, the set of default fonts shipped on Linux depends on the distribution. This means that on different Linux distributions, different fonts may be displayed for a given system font name or alias.

It is also possible to load fonts at runtime even if they aren't installed on the system. See Runtime loading and saving for details.

When using traditional rasterized fonts, Godot caches glyphs on a per-font and per-size basis. This reduces stuttering, but it can still occur the first time a glyph is displayed when running the project. This can be especially noticeable at higher font sizes or on mobile devices.

When using MSDF fonts, they only need to be rasterized once to a special signed distance field texture. This means caching can be done purely on a per-font basis, without taking the font size into consideration. However, the initial rendering of MSDF fonts is slower compared to a traditional rasterized font at a medium size.

To avoid stuttering issues related to font rendering, it is possible to prerender certain glyphs. This can be done for all glyphs you intend to use (for optimal results), or only for common glyphs that are most likely to appear during gameplay (to reduce file size). Glyphs that aren't pre-rendered will be rasterized on-the-fly as usual.

In both cases (traditional and MSDF), font rasterization is done on the CPU. This means that the GPU performance doesn't affect how long it takes for fonts to be rasterized.

Open the Advanced Import Settings dialog by double-clicking the font file in the FileSystem dock. You can also select the font in the FileSystem dock, go to the Import dock then choose Advanced… at the bottom:

Move to the Pre-render Configurations tab of the Advanced Import Settings dialog, then add a configuration by clicking the "plus" symbol:

Adding a new prerendering configuration in the Advanced Import Settings dialog

After adding a configuration, make sure it is selected by clicking its name once. You can also rename the configuration by double-clicking it.

There are 2 ways to add glyphs to be prerendered to a given configuration. It is possible to use both approaches in a cumulative manner:

Using text from translations

For most projects, this approach is the most convenient to use, as it automatically sources text from your language translations. The downside is that it can only be used if your project supports internationalization. Otherwise, stick to the "Using custom text" approach described below.

After adding translations to the Project Settings, use the Glyphs from the Translations tab to check translations by double-clicking them, then click Shape All Strings in the Translations and Add Glyphs at the bottom:

Enabling prerendering in the Advanced Import Settings dialog with the Glyphs from the Translations tab

The list of prerendered glyphs is not automatically updated when translations are updated, so you need to repeat this process if your translations have changed significantly.

While it requires manually specifying text that will appear in the game, this is the most efficient approach for games which don't feature user text input. This approach is worth exploring for mobile games to reduce the file size of the distributed app.

To use existing text as a baseline for prerendering, go to the Glyphs from the Text sub-tab of the Advanced Import Settings dialog, enter text in the window on the right, then click Shape Text and Add Glyphs at the bottom of the dialog:

Enabling prerendering in the Advanced Import Settings dialog with the Glyphs from the Text tab

If your project supports internationalization, you can paste the contents of your CSV or PO files in the above box to quickly prerender all possible characters that may be rendered during gameplay (excluding user-provided or non-translatable strings).

By enabling character sets

The second method requires less configuration and fewer updates if your game's text changes, and is more suited to text-heavy games or multiplayer games with chat. On the other hand, it may cause glyphs that never show up in the game to be prerendered, which is less efficient in terms of file size.

To use existing text as a baseline for prerendering, go to the Glyphs from the Character Map sub-tab of the Advanced Import Settings dialog, then double-click character sets to be enabled on the right:

Enabling prerendering in the Advanced Import Settings dialog with the Glyphs from the Character Map tab

To ensure full prerendering, the character sets you need to enable depend on which languages are supported in your game. For English, only Basic Latin needs to be enabled. Enabling Latin-1 Supplement as well allows fully covering many more languages, such as French, German and Spanish. For Russian, Cyrillic needs to be enabled, and so on.

In the GUI > Theme section of the advanced Project Settings, you can choose how the default font should be rendered:

Default Font Antialiasing: Controls the antialiasing method used for the default project font.

Default Font Hinting: Controls the hinting method used for the default project font.

Default Font Subpixel Positioning: Controls the subpixel positioning method for the default project font.

Default Font Multichannel Signed Distance Field: If true, makes the default project font use MSDF font rendering instead of traditional rasterization.

Default Font Generate Mipmaps: If true, enables mipmap generation and usage for the default project font.

These project settings only affect the default project font (the one that is hardcoded in the engine binary).

Custom fonts' properties are governed by their respective import options instead. You can use the Import Defaults section of the Project Settings dialog to override default import options for custom fonts.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Using the theme editor — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_theme_editor.html

**Contents:**
- Using the theme editor
- Creating a theme
- Theme editor overview
  - Theme previews
  - Theme types and items
- Manage and import items
- User-contributed notes

This article explains how to create and manage UI themes using the Godot editor and its theme editor tool. We recommend getting familiar with the basics behind GUI skinning/theming by reading Introduction to GUI skinning before starting.

The theme editor is a bottom panel tool that activates automatically, when a Theme resource is selected for editing. It contains the necessary UI for adding, removing, and adjusting theme types and theme items. It features a preview section for testing your changes live, as well as a window dialog for doing bulk operations of the theme items.

Like any other resources, themes can be created directly in the file system dock by right-clicking and selecting New Resource..., then selecting Theme and clicking Create. This is especially useful for creating project-wide themes.

Themes also can be created from any control node. Select a control node in the scene hierarchy, then in the inspector go to the theme property. From there you can select New Theme.

This will create an empty theme and open up the theme editor. Keep in mind that resources created this way are bundled with the scene by default. Use the context menu to save the new theme to a file instead.

While the theme editor provides the tools to manage theme types and items, themes also include the default, fallback font that you can edit only using the Inspector dock. Same applies to the contents of complex resource types, such as StyleBoxes and icons — they open for editing in the Inspector.

The theme editor has two main parts. The main theme editor, located at the bottom of the Godot editor, aims to provide users with tools to quickly create, edit, and delete theme items and types. It gives visual tools for picking and changing controls, abstracting the underlying theme concepts. The Manage Theme Items dialog, on the other hand, tries to address the needs of those who want to change themes manually. It's also useful for creating a new editor theme.

The left-hand side of the main editor has a set of preview tabs. The Default Preview tab is visible out of the box and contains most of the frequently used controls in various states. Previews are interactive, so intermediate states (e.g. hover) can be previewed as well.

Additional tabs can be created from arbitrary scenes in your project. The scene must have a control node as its root to function as a preview. To add a new tab click the Add Preview button and select the saved scene from your file system.

If you make changes to the scene, they will not be reflected in the preview automatically. To update the preview click the reload button on the toolbar.

Previews can also be used to quickly select the theme type to edit. Select the picker tool from the toolbar and hover over the preview area to highlight control nodes. Highlighted control nodes display their class name, or type variation if available. Clicking on the highlighted control opens it for editing on the right-hand side.

The right-hand side of the theme editor provides a list of theme types available in the edited theme resource, and the contents of the selected type. The list of type's items is divided into several tabs, corresponding to each data type available in the theme (colors, constants, styles, etc.). If the Show Default option is enabled, then for each built-in type its default theme values are displayed, greyed out. If the option is disabled, only the items available in the edited theme itself are displayed.

Individual items from the default theme can be added to the current theme by clicking on the Override button next to the item. You can also override all the default items of the selected theme type by clicking on the Override All button. Overridden properties can then be removed with the Remove Item button. Properties can also be renamed using the Rename Item button, and completely custom properties can be added to the list using the text field below it.

Overridden theme items can be edited directly in the right-hand panel, unless they are resources. Resources have rudimentary controls available for them, but must be edited in the Inspector dock instead.

Styleboxes have a unique feature available, where you can pin an individual stylebox from the list. Pinned stylebox acts like the leader of the pack, and all styleboxes of the same type are updated alongside it when you change its properties. This allows you to edit properties of several styleboxes at the same time.

While theme types can be picked from a preview, they can also be added manually. Clicking the plus button next to the type list opens the Add item Type menu. In that menu you can either select a type from the list, or you can enter an arbitrary name to create a custom type. Text field also filters the list of control nodes.

Clicking the Manage Items button brings up the Manage Theme Items dialog.

In the Edit Items tab you can view and add theme types, as well as view and edit the theme items of the selected type.

You can create, rename and remove individual theme items here by clicking the corresponding Add X Item and specifying their name. You can also mass delete theme items either by their data type (using the brush icon in the list) or by their quality. Remove Class Items will remove all built-in theme items you have customized for a control node type. Remove Custom Items will remove all the custom theme items for the selected type. Finally, Remove All Items will remove everything from the type.

From the Import Items tab you can import theme items from other themes. You can import items from the default Godot theme, the Godot editor theme, or another custom theme. You can import individual or multiple items, and you can decide whether to copy or omit their data as well. There are several ways you can select and deselect the items, including by hand, by hierarchy, by data type, and everything. Opting to include the data will copy all theme items as they are to your theme. Omitting the data will create the items of the corresponding data type and name, but will leave them empty, creating a template of a theme in a way.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Version control systems — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/best_practices/version_control_systems.html

**Contents:**
- Version control systems
- Introduction
- Version control plugins
  - Official Git plugin
- Files to exclude from VCS
- Working with Git on Windows
- Git LFS
- User-contributed notes

Godot aims to be VCS-friendly and generate mostly readable and mergeable files.

Godot also supports the use of version control systems in the editor itself. However, version control in the editor requires a plugin for the specific VCS you're using.

As of July 2023, there is only a Git plugin available, but the community may create additional VCS plugins.

Using Git from inside the editor is supported with an official plugin. You can find the latest releases on GitHub.

Documentation on how to use the Git plugin can be found on its wiki.

This lists files and folders that should be ignored from version control in Godot 4.1 and later.

The list of files of folders that should be ignored from version control in Godot 3.x and Godot 4.0 is entirely different. This is important, as Godot 3.x and 4.0 may store sensitive credentials in export_presets.cfg (unlike Godot 4.1 and later).

If you are using Godot 3, check the 3.5 version of this documentation page instead.

There are some files and folders Godot automatically creates when opening a project in the editor for the first time. To avoid bloating your version control repository with generated data, you should add them to your VCS ignore:

.godot/: This folder stores various project cache data.

*.translation: These files are binary imported translations generated from CSV files.

You can make the Godot project manager generate version control metadata for you automatically when creating a project. When choosing the Git option, this creates .gitignore and .gitattributes files in the project root:

Creating version control metadata in the project manager's New Project dialog

In existing projects, select the Project menu at the top of the editor, then choose Version Control > Generate Version Control Metadata. This creates the same files as if the operation was performed in the project manager.

Most Git for Windows clients are configured with the core.autocrlf set to true. This can lead to files unnecessarily being marked as modified by Git due to their line endings being converted from LF to CRLF automatically.

It is better to set this option as:

Creating version control metadata using the project manager or editor will automatically enforce LF line endings using the .gitattributes file. In this case, you don't need to change your Git configuration.

Git LFS (Large File Storage) is a Git extension that allows you to manage large files in your repository. It replaces large files with text pointers inside Git, while storing the file contents on a remote server. This is useful for managing large assets, such as textures, audio files, and 3D models, without bloating your Git repository.

When using Git LFS you will want to ensure it is setup before you commit any files to your repository. If you have already committed files to your repository, you will need to remove them from the repository and re-add them after setting up Git LFS.

It is possible to use git lfs migrate to convert existing files in your repository, but this is more in-depth and requires a good understanding of Git.

A common approach is setting up a new repository with Git LFS (and a proper .gitattributes), then copying the files from the old repository to the new one. This way, you can ensure that all files are tracked by LFS from the start.

To use Git LFS with Godot, you need to install the Git LFS extension and configure it to track the file types you want to manage. You can do this by running the following command in your terminal:

This will create a .gitattributes file in your repository that tells Git to use LFS for the specified file types. You can add more file types by modifying the .gitattributes file. For example, to track all GLB files, you can do this by running the following command in your terminal:

When you add or modify files that are tracked by LFS, Git will automatically store them in LFS instead of the regular Git history. You can push and pull LFS files just like regular Git files, but keep in mind that LFS files are stored separately from the rest of your Git history. This means that you may need to install Git LFS on any machine that you clone the repository to in order to access the LFS files.

Below is an example .gitattributes file that you can use as a starting point for Git LFS. These file types were chosen because they are commonly used, but you can modify the list to include any binary types you may have in your project.

For more information on Git LFS, check the official documentation: https://git-lfs.github.com/ and https://docs.github.com/en/repositories/working-with-files/managing-large-files.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
git config --global core.autocrlf input
```

Example 2 (unknown):
```unknown
git lfs install
```

Example 3 (unknown):
```unknown
git lfs track "*.glb"
```

Example 4 (unknown):
```unknown
# Normalize EOL for all files that Git considers text files.
* text=auto eol=lf

# Git LFS Tracking (Assets)

# 3D Models
*.fbx filter=lfs diff=lfs merge=lfs -text
*.gltf filter=lfs diff=lfs merge=lfs -text
*.glb filter=lfs diff=lfs merge=lfs -text
*.blend filter=lfs diff=lfs merge=lfs -text
*.obj filter=lfs diff=lfs merge=lfs -text

# Images
*.png filter=lfs diff=lfs merge=lfs -text
*.svg filter=lfs diff=lfs merge=lfs -text
*.jpg filter=lfs diff=lfs merge=lfs -text
*.jpeg filter=lfs diff=lfs merge=lfs -text
*.gif filter=lfs diff=lfs merge=lfs -text
*.tga filter=lfs diff=lfs merge=lfs -text
*.webp filter=lfs diff=lfs merge=lfs -text
*.exr filter=lfs diff=lfs merge=lfs -text
*.hdr filter=lfs diff=lfs merge=lfs -text
*.dds filter=lfs diff=lfs merge=lfs -text

# Audio
*.mp3 filter=lfs diff=lfs merge=lfs -text
*.wav filter=lfs diff=lfs merge=lfs -text
*.ogg filter=lfs diff=lfs merge=lfs -text

# Font & Icon
*.ttf filter=lfs diff=lfs merge=lfs -text
*.otf filter=lfs diff=lfs merge=lfs -text
*.ico filter=lfs diff=lfs merge=lfs -text

# Godot LFS Specific
*.scn filter=lfs diff=lfs merge=lfs -text
*.res filter=lfs diff=lfs merge=lfs -text
*.material filter=lfs diff=lfs merge=lfs -text
*.anim filter=lfs diff=lfs merge=lfs -text
*.mesh filter=lfs diff=lfs merge=lfs -text
*.lmbake filter=lfs diff=lfs merge=lfs -text
```

---
