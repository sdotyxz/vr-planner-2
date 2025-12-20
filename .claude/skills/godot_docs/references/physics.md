# Godot_Docs - Physics

**Pages:** 12

---

## Advanced physics interpolation — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/advanced_physics_interpolation.html

**Contents:**
- Advanced physics interpolation
- Exceptions to automatic physics interpolation
  - Cameras
  - Manual camera interpolation
    - Ensure the camera is using global coordinate space
    - Typical example
    - get_global_transform_interpolated()
    - Example manual camera script
    - Mouse look
  - Disabling interpolation on other nodes

Although the previous instructions will give satisfactory results in a lot of games, in some cases you will want to go a stage further to get the best possible results and the smoothest possible experience.

Even with physics interpolation active, there may be some local situations where you would benefit from disabling automatic interpolation for a Node (or branch of the SceneTree), and have the finer control of performing interpolation manually.

This is possible using the Node.physics_interpolation_mode property which is present in all Nodes. If you for example, turn off interpolation for a Node, the children will recursively also be affected (as they default to inheriting the parent setting). This means you can easily disable interpolation for an entire subscene.

The most common situation where you may want to perform your own interpolation is Cameras.

In many cases, a Camera3D can use automatic interpolation just like any other node. However, for best results, especially at low physics tick rates, it is recommended that you take a manual approach to camera interpolation.

This is because viewers are very sensitive to camera movement. For instance, a Camera3D that realigns slightly every 1/10th of a second (at 10tps tick rate) will often be noticeable. You can get a much smoother result by moving the camera each frame in _process, and following an interpolated target manually.

The very first step when performing manual camera interpolation is to make sure the Camera3D transform is specified in global space rather than inheriting the transform of a moving parent. This is because feedback can occur between the movement of a parent node of a Camera3D and the movement of the camera Node itself, which can mess up the interpolation.

There are two ways of doing this:

Move the Camera3D so it is independent on its own branch, rather than being a child of a moving object.

Call Node3D.top_level and set this to true, which will make the Camera ignore the transform of its parent.

A typical example of a custom approach is to use the look_at function in the Camera3D every frame in _process() to look at a target node (such as the player).

But there is a problem. If we use the traditional get_global_transform() on a Camera3D "target" node, this transform will only focus the Camera3D on the target at the current physics tick. This is not what we want, as the camera will jump about on each physics tick as the target moves. Even though the camera may be updated each frame, this does not help give smooth motion if the target is only changing each physics tick.

What we really want to focus the camera on, is not the position of the target on the physics tick, but the interpolated position, i.e. the position at which the target will be rendered.

We can do this using the Node3D.get_global_transform_interpolated function. This acts exactly like getting Node3D.global_transform but it gives you the interpolated transform (during a _process() call).

get_global_transform_interpolated() should only be used once or twice for special cases such as cameras. It should not be used all over the place in your code (both for performance reasons, and to give correct gameplay).

Aside from exceptions like the camera, in most cases, your game logic should be in _physics_process(). In game logic you should be calling get_global_transform() or get_transform(), which will give the current physics transform (in global or local space respectively), which is usually what you will want for gameplay code.

Here is an example of a simple fixed camera which follows an interpolated target:

Mouse look is a very common way of controlling cameras. But there is a problem. Unlike keyboard input which can be sampled periodically on the physics tick, mouse move events can come in continuously. The camera will be expected to react and follow these mouse movements on the next frame, rather than waiting until the next physics tick.

In this situation, it can be better to disable physics interpolation for the camera node (using Node.physics_interpolation_mode) and directly apply the mouse input to the camera rotation, rather than apply it in _physics_process.

Sometimes, especially with cameras, you will want to use a combination of interpolation and non-interpolation:

A first person camera may position the camera at a player location (perhaps using Node3D.get_global_transform_interpolated), but control the Camera rotation from mouse look without interpolation.

A third person camera may similarly determine the look at (target location) of the camera using Node3D.get_global_transform_interpolated, but position the camera using mouse look without interpolation.

There are many permutations and variations of camera types, but it should be clear that in many cases, disabling automatic physics interpolation and handling this yourself can give a better result.

Although cameras are the most common example, there are a number of cases when you may wish other nodes to control their own interpolation, or be non-interpolated. Consider for example, a player in a top view game whose rotation is controlled by mouse look. Disabling physics rotation allows the player rotation to match the mouse in real-time.

Although most visual Nodes follow the single Node single visual instance paradigm, MultiMeshes can control several instances from the same Node. Therefore, they have some extra functions for controlling interpolation functionality on a per-instance basis. You should explore these functions if you are using interpolated MultiMeshes.

MultiMesh.reset_instance_physics_interpolation

MultiMesh.set_buffer_interpolated

Full details are in the MultiMesh documentation.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
extends Camera3D

# Node that the camera will follow
var _target

# We will smoothly lerp to follow the target
# rather than follow exactly
var _target_pos : Vector3 = Vector3()

func _ready() -> void:
    # Find the target node
    _target = get_node("../Player")

    # Turn off automatic physics interpolation for the Camera3D,
    # we will be doing this manually
    set_physics_interpolation_mode(Node.PHYSICS_INTERPOLATION_MODE_OFF)

func _process(delta: float) -> void:
    # Find the current interpolated transform of the target
    var tr : Transform = _target.get_global_transform_interpolated()

    # Provide some delayed smoothed lerping towards the target position
    _target_pos = lerp(_target_pos, tr.origin, min(delta, 1.0))

    # Fixed camera position, but it will follow the target
    look_at(_target_pos, Vector3(0, 1, 0))
```

---

## Large world coordinates — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/large_world_coordinates.html

**Contents:**
- Large world coordinates
- Why use large world coordinates?
- How large world coordinates work
- Who are large world coordinates for?
- Enabling large world coordinates
- Compatibility between single-precision and double-precision builds
  - Known incompatibilities
- Limitations
- User-contributed notes

Large world coordinates are mainly useful in 3D projects; they are rarely required in 2D projects. Also, unlike 3D rendering, 2D rendering currently doesn't benefit from increased precision when large world coordinates are enabled.

In Godot, physics simulation and rendering both rely on floating-point numbers. However, in computing, floating-point numbers have limited precision and range. This can be a problem for games with huge worlds, such as space or planetary-scale simulation games.

Precision is the greatest when the value is close to 0.0. Precision becomes gradually lower as the value increases or decreases away from 0.0. This occurs every time the floating-point number's exponent increases, which happens when the floating-point number surpasses a power of 2 value (2, 4, 8, 16, …). Every time this occurs, the number's minimum step will increase, resulting in a loss of precision.

In practice, this means that as the player moves away from the world origin (Vector2(0, 0) in 2D games or Vector3(0, 0, 0) in 3D games), precision will decrease.

This loss of precision can result in objects appearing to "vibrate" when far away from the world origin, as the model's position will snap to the nearest value that can be represented in a floating-point number. This can also result in physics glitches that only occur when the player is far from the world origin.

The range determines the minimum and maximum values that can be stored in the number. If the player tries to move past this range, they will simply not be able to. However, in practice, floating-point precision almost always becomes a problem before the range does.

The range and precision (minimum step between two exponent intervals) are determined by the floating-point number type. The theoretical range allows extremely high values to be stored in single-precision floats, but with very low precision. In practice, a floating-point type that cannot represent all integer values is not very useful. At extreme values, precision becomes so low that the number cannot even distinguish two separate integer values from each other.

This is the range where individual integer values can be represented in a floating-point number:

Single-precision float range (represent all integers): Between -16,777,216 and 16,777,216

Double-precision float range (represent all integers): Between -9 quadrillion and 9 quadrillion

Precision becomes greater near 0.0 (this table is abbreviated).

Maximum recommended single-precision range for a first-person 3D game without rendering artifacts or physics glitches.

Maximum recommended single-precision range for a third-person 3D game without rendering artifacts or physics glitches.

Maximum recommended single-precision range for a top-down 3D game without rendering artifacts or physics glitches.

Maximum recommended single-precision range for any 3D game. Double precision (large world coordinates) is usually required past this point.

~1e-10 (0.0000000001)

Double-precision remains far more precise than single-precision past this value.

When using single-precision floats, it is possible to go past the suggested ranges, but more visible artifacting will occur and physics glitches will be more common (such as the player not walking straight in certain directions).

See the Demystifying Floating Point Precision article for more information.

Large world coordinates (also known as double-precision physics) increase the precision level of all floating-point computations within the engine.

By default, float is 64-bit in GDScript, but Vector2, Vector3 and Vector4 are 32-bit. This means that the precision of vector types is much more limited. To resolve this, we can increase the number of bits used to represent a floating-point number in a Vector type. This results in an exponential increase in precision, which means the final value is not just twice as precise, but potentially thousands of times more precise at high values. The maximum value that can be represented is also greatly increased by going from a single-precision float to a double-precision float.

To avoid model snapping issues when far away from the world origin, Godot's 3D rendering engine will increase its precision for rendering operations when large world coordinates are enabled. The shaders do not use double-precision floats for performance reasons, but an alternative solution is used to emulate double precision for rendering using single-precision floats.

Enabling large world coordinates comes with a performance and memory usage penalty, especially on 32-bit CPUs. Only enable large world coordinates if you actually need them.

This feature is tailored towards mid-range/high-end desktop platforms. Large world coordinates may not perform well on low-end mobile devices, unless you take steps to reduce CPU usage with other means (such as decreasing the number of physics ticks per second).

On low-end platforms, an origin shifting approach can be used instead to allow for large worlds without using double-precision physics and rendering. Origin shifting works with single-precision floats, but it introduces more complexity to game logic, especially in multiplayer games. Therefore, origin shifting is not detailed on this page.

Large world coordinates are typically required for 3D space or planetary-scale simulation games. This extends to games that require supporting very fast movement speeds, but also very slow and precise movements at times.

On the other hand, it's important to only use large world coordinates when actually required (for performance reasons). Large world coordinates are usually not required for:

2D games, as precision issues are usually less noticeable.

Games with small-scale or medium-scale worlds.

Games with large worlds, but split into different levels with loading sequences in between. You can center each level portion around the world origin to avoid precision issues without a performance penalty.

Open world games with a playable on-foot area not exceeding 8192×8192 meters (centered around the world origin). As shown in the above table, the level of precision remains acceptable within that range, even for a first-person game.

If in doubt, you probably don't need to use large world coordinates in your project. For reference, most modern AAA open world titles don't use a large world coordinates system and still rely on single-precision floats for both rendering and physics.

This process requires recompiling the editor and all export template binaries you intend to use. If you only intend to export your project in release mode, you can skip the compilation of debug export templates. In any case, you'll need to compile an editor build so you can test your large precision world without having to export the project every time.

See the Compiling section for compiling instructions for each target platform. You will need to add the precision=double SCons option when compiling the editor and export templates.

The resulting binaries will be named with a .double suffix to distinguish them from single-precision binaries (which lack any precision suffix). You can then specify the binaries as custom export templates in your project's export presets in the Export dialog.

When saving a binary resource using the ResourceSaver singleton, a special flag is stored in the file if the resource was saved using a build that uses double-precision numbers. As a result, all binary resources will change on disk when you switch to a double-precision build and save over them.

Both single-precision and double-precision builds support using the ResourceLoader singleton on resources that use this special flag. This means single-precision builds can load resources saved using double-precision builds and vice versa. Text-based resources don't store a double-precision flag, as they don't require such a flag for correct reading.

In a networked multiplayer game, the server and all clients should be using the same build type to ensure precision remains consistent across clients. Using different build types may work, but various issues can occur.

The GDExtension API changes in an incompatible way in double-precision builds. This means extensions must be rebuilt to work with double-precision builds. On the extension developer's end, the REAL_T_IS_DOUBLE define is enabled when building a GDExtension with precision=double. real_t can be used as an alias for float in single-precision builds, and double in double-precision builds.

Since 3D rendering shaders don't actually use double-precision floats, there are some limitations when it comes to 3D rendering precision:

Shaders using the skip_vertex_transform or world_vertex_coords don't benefit from increased precision.

Triplanar mapping doesn't benefit from increased precision. Materials using triplanar mapping will exhibit visible jittering when far away from the world origin.

In double-precision builds, world space coordinates in a shader fragment() function can't be reconstructed from view space, for example:

Instead, calculate the world space coordinates in the vertex() function and pass them using a varying, for example:

2D rendering currently doesn't benefit from increased precision when large world coordinates are enabled. This can cause visible model snapping to occur when far away from the world origin (starting from a few million pixels at typical zoom levels). 2D physics calculations will still benefit from increased precision though.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
```

Example 2 (unknown):
```unknown
varying vec3 world;
void vertex() {
    world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
```

---

## Physics — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/index.html

**Contents:**
- Physics

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Physics Interpolation — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/index.html

**Contents:**
- Physics Interpolation

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Quick start guide — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/physics_interpolation_quick_start_guide.html

**Contents:**
- Quick start guide
- User-contributed notes

Turn on physics interpolation: Project Settings > Physics > Common > Physics Interpolation

Make sure you move objects and run your game logic in _physics_process() rather than _process(). This includes moving objects directly and indirectly (by e.g. moving a parent, or using another mechanism to automatically move nodes).

Be sure to call Node.reset_physics_interpolation on nodes after you first position or teleport them, to prevent "streaking".

Temporarily try setting Project Settings > Physics > Common > Physics Tick per Second to 10 to see the difference with and without interpolation.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Ragdoll system — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html

**Contents:**
- Ragdoll system
- Introduction
- Setting up the ragdoll
  - Creating physical bones
  - Cleaning up the skeleton
  - Collision shape adjustment
  - Joints adjustment
- Simulating the ragdoll
  - Collision layer and mask
- User-contributed notes

Since version 3.1, Godot supports ragdoll physics. Ragdolls rely on physics simulation to create realistic procedural animation. They are used for death animations in many games.

In this tutorial, we will be using the Platformer3D demo to set up a ragdoll.

You can download the Platformer3D demo on GitHub or using the Asset Library.

Like many other features in the engine, there is a node to set up a ragdoll: the PhysicalBone3D node. To simplify the setup, you can generate PhysicalBone nodes with the "Create physical skeleton" feature in the skeleton node.

Open the platformer demo in Godot, and then the Robi scene. Select the Skeleton node. A skeleton button appears on the top bar menu:

Click it and select the Create physical skeleton option. Godot will generate PhysicalBone nodes and collision shapes for each bone in the skeleton and pin joints to connect them together:

Some of the generated bones aren't necessary: the MASTER bone for example. So we're going to clean up the skeleton by removing them.

Each PhysicalBone the engine needs to simulate has a performance cost, so you want to remove every bone that is too small to make a difference in the simulation, as well as all utility bones.

For example, if we take a humanoid, you do not want to have physical bones for each finger. You can use a single bone for the entire hand instead, or one for the palm, one for the thumb, and a last one for the other four fingers.

Remove these physical bones: MASTER, waist, neck, headtracker. This gives us an optimized skeleton and makes it easier to control the ragdoll.

The next task is adjusting the collision shape and the size of physical bones to match the part of the body that each bone should simulate.

Once you adjusted the collision shapes, your ragdoll is almost ready. You just want to adjust the pin joints to get a better simulation. PhysicalBone nodes have an unconstrained pin joint assigned to them by default. To change the pin joint, select the PhysicalBone and change the constraint type in the Joint section. There, you can change the constraint's orientation and its limits.

This is the final result:

The ragdoll is now ready to use. To start the simulation and play the ragdoll animation, you need to call the physical_bones_start_simulation method. Attach a script to the skeleton node and call the method in the _ready method:

To stop the simulation, call the physical_bones_stop_simulation() method.

You can also limit the simulation to only a few bones. To do so, pass the bone names as a parameter. Here's an example of partial ragdoll simulation:

Make sure to set up your collision layers and masks properly so the CharacterBody3D's capsule doesn't get in the way of the physics simulation:

For more information, read Collision layers and masks.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (unknown):
```unknown
func _ready():
    physical_bones_start_simulation()
```

Example 2 (unknown):
```unknown
public override void _Ready()
{
    PhysicalBonesStartSimulation();
}
```

---

## Ray-casting — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html

**Contents:**
- Ray-casting
- Introduction
- Space
- Accessing space
- Raycast query
- Collision exceptions
- Collision Mask
- 3D ray casting from screen
- User-contributed notes

One of the most common tasks in game development is casting a ray (or custom shaped object) and checking what it hits. This enables complex behaviors, AI, etc. to take place. This tutorial will explain how to do this in 2D and 3D.

Godot stores all the low-level game information in servers, while the scene is only a frontend. As such, ray casting is generally a lower-level task. For simple raycasts, nodes like RayCast3D and RayCast2D will work, as they return every frame what the result of a raycast is.

Many times, though, ray-casting needs to be a more interactive process so a way to do this by code must exist.

In the physics world, Godot stores all the low-level collision and physics information in a space. The current 2d space (for 2D Physics) can be obtained by accessing CanvasItem.get_world_2d().space. For 3D, it's Node3D.get_world_3d().space.

The resulting space RID can be used in PhysicsServer3D and PhysicsServer2D respectively for 3D and 2D.

Godot physics runs by default in the same thread as game logic, but may be set to run on a separate thread to work more efficiently. Due to this, the only time accessing space is safe is during the Node._physics_process() callback. Accessing it from outside this function may result in an error due to space being locked.

To perform queries into physics space, the PhysicsDirectSpaceState2D and PhysicsDirectSpaceState3D must be used.

Use the following code in 2D:

For performing a 2D raycast query, the method PhysicsDirectSpaceState2D.intersect_ray() may be used. For example:

The result is a dictionary. If the ray didn't hit anything, the dictionary will be empty. If it did hit something, it will contain collision information:

The result dictionary when a collision occurs contains the following data:

The data is similar in 3D space, using Vector3 coordinates. Note that to enable collisions with Area3D, the boolean parameter collide_with_areas must be set to true.

A common use case for ray casting is to enable a character to gather data about the world around it. One problem with this is that the same character has a collider, so the ray will only detect its parent's collider, as shown in the following image:

To avoid self-intersection, the intersect_ray() parameters object can take an array of exceptions via its exclude property. This is an example of how to use it from a CharacterBody2D or any other collision object node:

The exceptions array can contain objects or RIDs.

While the exceptions method works fine for excluding the parent body, it becomes very inconvenient if you need a large and/or dynamic list of exceptions. In this case, it is much more efficient to use the collision layer/mask system.

The intersect_ray() parameters object can also be supplied a collision mask. For example, to use the same mask as the parent body, use the collision_mask member variable. The array of exceptions can be supplied as the last argument as well:

See Code example for details on how to set the collision mask.

Casting a ray from screen to 3D physics space is useful for object picking. There is not much need to do this because CollisionObject3D has an "input_event" signal that will let you know when it was clicked, but in case there is any desire to do it manually, here's how.

To cast a ray from the screen, you need a Camera3D node. A Camera3D can be in two projection modes: perspective and orthogonal. Because of this, both the ray origin and direction must be obtained. This is because origin changes in orthogonal mode, while normal changes in perspective mode:

To obtain it using a camera, the following code can be used:

Remember that during _input(), the space may be locked, so in practice this query should be run in _physics_process().

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
func _physics_process(delta):
    var space_rid = get_world_2d().space
    var space_state = PhysicsServer2D.space_get_direct_state(space_rid)
```

Example 2 (unknown):
```unknown
public override void _PhysicsProcess(double delta)
{
    var spaceRid = GetWorld2D().Space;
    var spaceState = PhysicsServer2D.SpaceGetDirectState(spaceRid);
}
```

Example 3 (gdscript):
```gdscript
func _physics_process(delta):
    var space_state = get_world_2d().direct_space_state
```

Example 4 (unknown):
```unknown
public override void _PhysicsProcess(double delta)
{
    var spaceState = GetWorld2D().DirectSpaceState;
}
```

---

## Troubleshooting physics issues — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/troubleshooting_physics_issues.html

**Contents:**
- Troubleshooting physics issues
- Objects are passing through each other at high speeds
- Stacked objects are unstable and wobbly
- Scaled physics bodies or collision shapes do not collide correctly
- Thin objects are wobbly when resting on the floor
- Cylinder collision shapes are unstable
- VehicleBody simulation is unstable, especially at high speeds
- Collision results in bumps when an object moves across tiles
- Framerate drops when an object touches another object
- Framerate suddenly drops to a very low value beyond a certain amount of physics simulation

When working with a physics engine, you may encounter unexpected results.

While many of these issues can be resolved through configuration, some of them are the result of engine bugs. For known issues related to the physics engine, see open physics-related issues on GitHub. Looking through closed issues can also help answer questions related to physics engine behavior.

This is known as tunneling. Enabling Continuous CD in the RigidBody properties can sometimes resolve this issue. If this does not help, there are other solutions you can try:

Make your static collision shapes thicker. For example, if you have a thin floor that the player can't get below in some way, you can make the collider thicker than the floor's visual representation.

Modify your fast-moving object's collision shape depending on its movement speed. The faster the object moves, the larger the collision shape should extend outside of the object to ensure it can collide with thin walls more reliably.

Increase Physics Ticks per Second in the advanced Project Settings. While this has other benefits (such as more stable simulation and reduced input lag), this increases CPU utilization and may not be viable for mobile/web platforms. Multipliers of the default value of 60 (such as 120, 180 or 240) should be preferred for a smooth appearance on most displays.

Despite seeming like a simple problem, stable RigidBody simulation with stacked objects is difficult to implement in a physics engine. This is caused by integrating forces going against each other. The more stacked objects are present, the stronger the forces will be against each other. This eventually causes the simulation to become wobbly, making the objects unable to rest on top of each other without moving.

Increasing the physics simulation rate can help alleviate this issue. To do so, increase Physics Ticks per Second in the advanced Project Settings. Note that increases CPU utilization and may not be viable for mobile/web platforms. Multipliers of the default value of 60 (such as 120, 180 or 240) should be preferred for a smooth appearance on most displays.

In 3D, switching the physics engine from the default GodotPhysics to Jolt can also improve stability. See Using Jolt Physics for more information.

Godot does not currently support scaling of physics bodies or collision shapes. As a workaround, change the collision shape's extents instead of changing its scale. If you want the visual representation's scale to change as well, change the scale of the underlying visual representation (Sprite2D, MeshInstance3D, …) and change the collision shape's extents separately. Make sure the collision shape is not a child of the visual representation in this case.

Since resources are shared by default, you'll have to make the collision shape resource unique if you don't want the change to be applied to all nodes using the same collision shape resource in the scene. This can be done by calling duplicate() in a script on the collision shape resource before changing its size.

This can be due to one of two causes:

The floor's collision shape is too thin.

The RigidBody's collision shape is too thin.

In the first case, this can be alleviated by making the floor's collision shape thicker. For example, if you have a thin floor that the player can't get below in some way, you can make the collider thicker than the floor's visual representation.

In the second case, this can usually only be resolved by increasing the physics simulation rate (as making the shape thicker would cause a disconnect between the RigidBody's visual representation and its collision).

In both cases, increasing the physics simulation rate can also help alleviate this issue. To do so, increase Physics Ticks per Second in the advanced Project Settings. Note that this increases CPU utilization and may not be viable for mobile/web platforms. Multipliers of the default value of 60 (such as 120, 180 or 240) should be preferred for a smooth appearance on most displays.

Switching the physics engine from the default GodotPhysics to Jolt should make cylinder collision shapes more reliable. See Using Jolt Physics for more information.

During the transition from Bullet to GodotPhysics in Godot 4, cylinder collision shapes had to be reimplemented from scratch. However, cylinder collision shapes are one of the most difficult shapes to support, which is why many other physics engines don't provide any support for them. There are several known bugs with cylinder collision shapes currently.

If you are sticking to GodotPhysics, we recommend using box or capsule collision shapes for characters for now. Boxes generally provide the best reliability, but have the downside of making the character take more space diagonally. Capsule collision shapes do not have this downside, but their shape can make precision platforming more difficult.

When a physics body moves at a high speed, it travels a large distance between each physics step. For instance, when using the 1 unit = 1 meter convention in 3D, a vehicle moving at 360 km/h will travel 100 units per second. With the default physics simulation rate of 60 Hz, the vehicle moves by ~1.67 units each physics tick. This means that small objects may be ignored entirely by the vehicle (due to tunneling), but also that the simulation has little data to work with in general at such a high speed.

Fast-moving vehicles can benefit a lot from an increased physics simulation rate. To do so, increase Physics Ticks per Second in the advanced Project Settings. Note that this increases CPU utilization and may not be viable for mobile/web platforms. Multipliers of the default value of 60 (such as 120, 180 or 240) should be preferred for a smooth appearance on most displays.

This is a known issue in the physics engine caused by the object bumping on a shape's edges, even though that edge is covered by another shape. This can occur in both 2D and 3D.

The best way to work around this issue is to create a "composite" collider. This means that instead of individual tiles having their collision, you create a single collision shape representing the collision for a group of tiles. Typically, you should split composite colliders on a per-island basis (which means each group of touching tiles gets its own collider).

Using a composite collider can also improve physics simulation performance in certain cases. However, since the composite collision shape is much more complex, this may not be a net performance win in all cases.

In Godot 4.5 and later, creating a composite collider is automatically done when using a TileMapLayer node. The chunk size (16 tiles on each axis by default) can be set using the Physics Quadrant Size property in the TileMapLayer inspector. Larger values provide more reliable collision, at the cost of slower updates when the TileMap is changed.

This is likely due to one of the objects using a collision shape that is too complex. Convex collision shapes should use a number of shapes as low as possible for performance reasons. When relying on Godot's automatic generation, it's possible that you ended up with dozens if not hundreds of shapes created for a single convex shape collision resource.

In some cases, replacing a convex collider with a couple of primitive collision shapes (box, sphere, or capsule) can deliver better performance.

This issue can also occur with StaticBodies that use very detailed trimesh (concave) collisions. In this case, use a simplified representation of the level geometry as a collider. Not only this will improve physics simulation performance significantly, but this can also improve stability by letting you remove small fixtures and crevices from being considered by collision.

In 3D, switching the physics engine from the default GodotPhysics to Jolt can also improve performance. See Using Jolt Physics for more information.

This occurs because the physics engine can't keep up with the expected simulation rate. In this case, the framerate will start dropping, but the engine is only allowed to simulate a certain number of physics steps per rendered frame. This snowballs into a situation where framerate keeps dropping until it reaches a very low framerate (typically 1-2 FPS) and is called the physics spiral of death.

To avoid this, you should check for situations in your project that can cause excessive number of physics simulations to occur at the same time (or with excessively complex collision shapes). If these situations cannot be avoided, you can increase the Max Physics Steps per Frame project setting and/or reduce Physics Ticks per Second to alleviate this.

This is caused by floating-point precision errors, which become more pronounced as the physics simulation occurs further away from the world origin. This issue also affects rendering, which results in wobbly camera movement when far away from the world origin. See Large world coordinates for more information.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Using Jolt Physics — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/using_jolt_physics.html

**Contents:**
- Using Jolt Physics
- Introduction
- Notable differences to Godot Physics
  - Joint properties
  - Single-body joints
  - Collision margins
  - Baumgarte stabilization
  - Ghost collisions
  - Memory usage
  - Ray-cast face index

The Jolt physics engine was added as an alternative to the existing Godot Physics physics engine in 4.4. Jolt is developed by Jorrit Rouwe with a focus on games and VR applications. Previously it was available as an extension but is now built into Godot.

It is important to note that the built-in Jolt Physics module is considered not finished, experimental, and lacks feature parity with both Godot Physics and the Godot Jolt extension. Behavior may change as it is developed further. Please keep that in mind when choosing what to use for your project.

The existing extension is now considered in maintenance mode. That means bug fixes will be merged, and it will be kept compatible with new versions of Godot until the built-in module has feature parity with the extension. The extension can be found here on GitHub and in Godot's asset library.

To change the 3D physics engine to be Jolt Physics, set Project Settings > Physics > 3D > Physics Engine to Jolt Physics. Once you've done that, click the Save & Restart button. When the editor opens again, 3D scenes should now be using Jolt for physics.

There are many differences between the existing Godot Physics engine and Jolt.

The current interfaces for the 3D joint nodes don't quite line up with the interface of Jolt's own joints. As such, there are a number of joint properties that are not supported, mainly ones related to configuring the joint's soft limits.

The unsupported properties are:

PinJoint3D: bias, damping, impulse_clamp

HingeJoint3D: bias, softness, relaxation

SliderJoint3D: angular_\*, \*_limit/softness, \*_limit/restitution, \*_limit/damping

ConeTwistJoint3D: bias, relaxation, softness

Generic6DOFJoint3D: *_limit_*/softness, *_limit_*/restitution, *_limit_*/damping, *_limit_*/erp

Currently a warning is emitted if you set these properties to anything but their default values.

You can, in Godot, omit one of the joint bodies for a two-body joint and effectively have "the world" be the other body. However, the node path that you assign your body to (node_a vs node_b) is ignored. Godot Physics will always behave as if you assigned it to node_a, and since node_a is also what defines the frame of reference for the joint limits, you end up with inverted limits and a potentially strange limit shape, especially if your limits allow both linear and angular degrees of freedom.

Jolt will behave as if you assigned the body to node_b instead, with node_a representing "the world". There is a project setting called Physics > Jolt Physics 3D > Joints > World Node that lets you toggle this behavior, if you need compatibility for an existing project.

Jolt (and other similar physics engines) uses something that Jolt refers to as "convex radius" to help improve the performance and behavior of the types of collision detection that Jolt relies on for convex shapes. Other physics engines (Godot included) might refer to these as "collision margins" instead. Godot exposes these as the margin property on every Shape3D-derived class, but Godot Physics itself does not use them for anything.

What these collision margins sometimes do in other engines (as described in Godot's documentation) is effectively add a "shell" around the shape, slightly increasing its size while also rounding off any edges/corners. In Jolt however, these margins are first used to shrink the shape, and then the "shell" is applied, resulting in edges/corners being similarly rounded off, but without increasing the size of the shape.

To prevent having to tweak this margin property manually, since its default value can be problematic for smaller shapes, the Jolt module exposes a project setting called Physics > Jolt Physics 3D > Collisions > Collision Margin Fraction which is multiplied with the smallest axis of the shape's AABB to calculate the actual margin. The margin property of the shape is then instead used as an upper bound.

These margins should, for most use-cases, be more or less transparent, but can sometimes result in odd collision normals when performing shape queries. You can lower the above mentioned project setting to mitigate some of this, including setting it to 0.0, but too small of a margin can also cause odd collision results, so is generally not recommended.

Baumgarte stabilization is a method to resolve penetrating bodies and push them to a state where they are just touching. In Godot Physics this works like a spring. This means that bodies can accelerate and may cause the bodies to overshoot and separate completely. With Jolt, the stabilization is only applied to the position and not to the velocity of the body. This means it cannot overshoot but it may take longer to resolve the penetration.

The strength of this stabilization can be tweaked using the project setting Physics > Jolt Physics 3D > Simulation > Baumgarte Stabilization Factor. Setting this project setting to 0.0 will turn Baumgarte stabilization off. Setting it to 1.0 will resolve penetration in 1 simulation step. This is fast but often also unstable.

Jolt employs two techniques to mitigate ghost collisions, meaning collisions with internal edges of shapes/bodies that result in collision normals that oppose the direction of movement.

The first technique, called "active edge detection", marks edges of triangles in ConcavePolygonShape3D or HeightMapShape3D as either "active" or "inactive", based on the angle to the neighboring triangle. When a collision happens with an inactive edge the collision normal will be replaced with the triangle's normal instead, to lessen the effect of ghost collisions.

The angle threshold for this active edge detection is configurable through the project setting Physics >Jolt Physics 3D > Collisions > Active Edge Threshold.

The second technique, called "enhanced internal edge removal", instead adds runtime checks to detect whether an edge is active or inactive, based on the contact points of the two bodies. This has the benefit of applying not only to collisions with ConcavePolygonShape3D and HeightMapShape3D, but also edges between any shapes within the same body.

Enhanced internal edge removal can be toggled on and off for the various contexts to which it's applied, using the Physics >Jolt Physics 3D > Simulation > Use Enhanced Internal Edge Removal, project setting, and the similar settings for queries and motion queries.

Note that neither the active edge detection nor enhanced internal edge removal apply when dealing with ghost collisions between two different bodies.

Jolt uses a stack allocator for temporary allocations within its simulation step. This stack allocator requires allocating a set amount of memory up front, which can be configured using the Physics > Jolt Physics 3D > Limits > Temporary Memory Buffer Size project setting.

The face_index property returned in the results of intersect_ray() and RayCast3D will by default always be -1 with Jolt. The project setting Physics > Jolt Physics 3D > Queries > Enable Ray Cast Face Index will enable them.

Note that enabling this setting will increase the memory requirement of ConcavePolygonShape3D with about 25%.

When using Jolt, a RigidBody3D frozen with FREEZE_MODE_KINEMATIC will by default not report contacts from collisions with other static/kinematic bodies, for performance reasons, even when setting a non-zero max_contacts_reported. If you have many/large kinematic bodies overlapping with complex static geometry, such as ConcavePolygonShape3D or HeightMapShape3D, you can end up wasting a significant amount of CPU performance and memory without realizing it.

For this reason this behavior is opt-in through the project setting Physics > Jolt Physics 3D > Simulation > Generate All Kinematic Contacts.

Due to limitations internal to Jolt, the contact impulses provided by PhysicsDirectBodyState3D.get_contact_impulse() are estimated ahead of time based on things like the contact manifold and velocities of the colliding bodies. This means that the reported impulses will only be accurate in cases where the two bodies in question are not colliding with any other bodies.

Jolt does not currently support any interactions between SoftBody3D and Area3D, such as overlap events, or the wind properties found on Area3D.

WorldBoundaryShape3D, which is meant to represent an infinite plane, is implemented a bit differently in Jolt compared to Godot Physics. Both engines have an upper limit for how big the effective size of this plane can be, but this size is much smaller when using Jolt, in order to avoid precision issues.

You can configure this size using the Physics > Jolt Physics 3D > Limits > World Boundary Shape Size project setting.

While the built-in Jolt module is largely a straight port of the Godot Jolt extension, there are a few things that are different.

All project settings have been moved from the physics/jolt_3d category to physics/jolt_physics_3d.

On top of that, there's been some renaming and refactoring of the individual project settings as well. These include:

sleep/enabled is now simulation/allow_sleep.

sleep/velocity_threshold is now simulation/sleep_velocity_threshold.

sleep/time_threshold is now simulation/sleep_time_threshold.

collisions/use_shape_margins is now collisions/collision_margin_fraction, where a value of 0 is equivalent to disabling it.

collisions/use_enhanced_internal_edge_removal is now simulation/use_enhanced_internal_edge_removal.

collisions/areas_detect_static_bodies is now simulation/areas_detect_static_bodies.

collisions/report_all_kinematic_contacts is now simulation/generate_all_kinematic_contacts.

collisions/soft_body_point_margin is now simulation/soft_body_point_radius.

collisions/body_pair_cache_enabled is now simulation/body_pair_contact_cache_enabled.

collisions/body_pair_cache_distance_threshold is now simulation/body_pair_contact_cache_distance_threshold.

collisions/body_pair_cache_angle_threshold is now simulation/body_pair_contact_cache_angle_threshold.

continuous_cd/movement_threshold is now simulation/continuous_cd_movement_threshold, but expressed as a fraction instead of a percentage.

continuous_cd/max_penetration is now simulation/continuous_cd_max_penetration, but expressed as a fraction instead of a percentage.

kinematics/use_enhanced_internal_edge_removal is now motion_queries/use_enhanced_internal_edge_removal.

kinematics/recovery_iterations is now motion_queries/recovery_iterations, but expressed as a fraction instead of a percentage.

kinematics/recovery_amount is now motion_queries/recovery_amount.

queries/use_legacy_ray_casting has been removed.

solver/position_iterations is now simulation/position_steps.

solver/velocity_iterations is now simulation/velocity_steps.

solver/position_correction is now simulation/baumgarte_stabilization_factor, but expressed as a fraction instead of a percentage.

solver/active_edge_threshold is now collisions/active_edge_threshold.

solver/bounce_velocity_threshold is now simulation/bounce_velocity_threshold.

solver/contact_speculative_distance is now simulation/speculative_contact_distance.

solver/contact_allowed_penetration is now simulation/penetration_slop.

limits/max_angular_velocity is now stored as radians instead.

limits/max_temporary_memory is now limits/temporary_memory_buffer_size.

The joint nodes that are exposed in the Godot Jolt extension (JoltPinJoint3D, JoltHingeJoint3D, JoltSliderJoint3D, JoltConeTwistJoint3D, and JoltGeneric6DOFJoint) have not been included in the Jolt module.

Unlike the Godot Jolt extension, the Jolt module does have thread-safety, including support for the Physics > 3D > Run On Separate Thread project setting. However this has not been tested very thoroughly, so it should be considered experimental.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Using NavigationLayers — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationlayers.html

**Contents:**
- Using NavigationLayers
- User-contributed notes

NavigationLayers are an optional feature to further control which navigation meshes are considered in a path query. They work similar to how physics layers control collision between collision objects or how visual layers control what is rendered to the Viewport.

NavigationLayers can be named in the ProjectSettings the same as physics layers or visual layers.

If a region has not a single compatible navigation layer with the navigation_layers parameter of a path query this regions navigation mesh will be skipped in pathfinding. See Using NavigationPaths for more information on querying the NavigationServer for paths.

NavigationLayers are a single int value that is used as a bitmask. Many navigation related nodes have set_navigation_layer_value() and get_navigation_layer_value() functions to set and get a layer number directly without the need for more complex bitwise operations.

In scripts the following helper functions can be used to work with the navigation_layers bitmask.

Changing navigation layers for path queries is a performance friendly alternative to enabling / disabling entire navigation regions. Compared to region changes a navigation path query with different navigation layers does not trigger large scale updates on the NavigationServer.

Changing the navigation layers of NavigationAgent nodes will have an immediate effect on the next path query. Changing the navigation layers of regions will have an effect after the next NavigationServer sync.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
func change_layers():
    var region: NavigationRegion2D = get_node("NavigationRegion2D")
    # enables 4-th layer for this region
    region.navigation_layers = enable_bitmask_inx(region.navigation_layers, 4)
    # disables 1-rst layer for this region
    region.navigation_layers = disable_bitmask_inx(region.navigation_layers, 1)

    var agent: NavigationAgent2D = get_node("NavigationAgent2D")
    # make future path queries of this agent ignore regions with 4-th layer
    agent.navigation_layers = disable_bitmask_inx(agent.navigation_layers, 4)

    var path_query_navigation_layers: int = 0
    path_query_navigation_layers = enable_bitmask_inx(path_query_navigation_layers, 2)
    # get a path that only considers 2-nd layer regions
    var path: PackedVector2Array = NavigationServer2D.map_get_path(
        map,
        start_position,
        target_position,
        true,
        path_query_navigation_layers
        )

static func is_bitmask_inx_enabled(_bitmask: int, _index: int) -> bool:
    return _bitmask & (1 << _index) != 0

static func enable_bitmask_inx(_bitmask: int, _index: int) -> int:
    return _bitmask | (1 << _index)

static func disable_bitmask_inx(_bitmask: int, _index: int) -> int:
    return _bitmask & ~(1 << _index)
```

Example 2 (unknown):
```unknown
using Godot;

public partial class MyNode2D : Node2D
{
    private Rid _map;
    private Vector2 _startPosition;
    private Vector2 _targetPosition;

    private void ChangeLayers()
    {
        NavigationRegion2D region = GetNode<NavigationRegion2D>("NavigationRegion2D");
        // Enables the 4th layer for this region.
        region.NavigationLayers = EnableBitmaskInx(region.NavigationLayers, 4);
        // Disables the 1st layer for this region.
        region.NavigationLayers = DisableBitmaskInx(region.NavigationLayers, 1);

        NavigationAgent2D agent = GetNode<NavigationAgent2D>("NavigationAgent2D");
        // Make future path queries of this agent ignore regions with the 4th layer.
        agent.NavigationLayers = DisableBitmaskInx(agent.NavigationLayers, 4);

        uint pathQueryNavigationLayers = 0;
        pathQueryNavigationLayers = EnableBitmaskInx(pathQueryNavigationLayers, 2);
        // Get a path that only considers 2nd layer regions.
        Vector2[] path = NavigationServer2D.MapGetPath(
            _map,
            _startPosition,
            _targetPosition,
            true,
            pathQueryNavigationLayers
        );
    }

    private static bool IsBitmaskInxEnabled(uint bitmask, int index)
    {
        return (bitmask & (1 << index)) != 0;
    }

    private static uint EnableBitmaskInx(uint bitmask, int index)
    {
        return bitmask | (1u << index);
    }

    private static uint DisableBitmaskInx(uint bitmask, int index)
    {
        return bitmask & ~(1u << index);
    }
}
```

Example 3 (gdscript):
```gdscript
func change_layers():
    var region: NavigationRegion3D = get_node("NavigationRegion3D")
    # enables 4-th layer for this region
    region.navigation_layers = enable_bitmask_inx(region.navigation_layers, 4)
    # disables 1-rst layer for this region
    region.navigation_layers = disable_bitmask_inx(region.navigation_layers, 1)

    var agent: NavigationAgent3D = get_node("NavigationAgent3D")
    # make future path queries of this agent ignore regions with 4-th layer
    agent.navigation_layers = disable_bitmask_inx(agent.navigation_layers, 4)

    var path_query_navigation_layers: int = 0
    path_query_navigation_layers = enable_bitmask_inx(path_query_navigation_layers, 2)
    # get a path that only considers 2-nd layer regions
    var path: PackedVector3Array = NavigationServer3D.map_get_path(
        map,
        start_position,
        target_position,
        true,
        path_query_navigation_layers
        )

static func is_bitmask_inx_enabled(_bitmask: int, _index: int) -> bool:
    return _bitmask & (1 << _index) != 0

static func enable_bitmask_inx(_bitmask: int, _index: int) -> int:
    return _bitmask | (1 << _index)

static func disable_bitmask_inx(_bitmask: int, _index: int) -> int:
    return _bitmask & ~(1 << _index)
```

Example 4 (unknown):
```unknown
using Godot;

public partial class MyNode3D : Node3D
{
    private Rid _map;
    private Vector3 _startPosition;
    private Vector3 _targetPosition;

    private void ChangeLayers()
    {
        NavigationRegion3D region = GetNode<NavigationRegion3D>("NavigationRegion3D");
        // Enables the 4th layer for this region.
        region.NavigationLayers = EnableBitmaskInx(region.NavigationLayers, 4);
        // Disables the 1st layer for this region.
        region.NavigationLayers = DisableBitmaskInx(region.NavigationLayers, 1);

        NavigationAgent3D agent = GetNode<NavigationAgent3D>("NavigationAgent2D");
        // Make future path queries of this agent ignore regions with the 4th layer.
        agent.NavigationLayers = DisableBitmaskInx(agent.NavigationLayers, 4);

        uint pathQueryNavigationLayers = 0;
        pathQueryNavigationLayers = EnableBitmaskInx(pathQueryNavigationLayers, 2);
        // Get a path that only considers 2nd layer regions.
        Vector3[] path = NavigationServer3D.MapGetPath(
            _map,
            _startPosition,
            _targetPosition,
            true,
            pathQueryNavigationLayers
        );
    }

    private static bool IsBitmaskInxEnabled(uint bitmask, int index)
    {
        return (bitmask & (1 << index)) != 0;
    }

    private static uint EnableBitmaskInx(uint bitmask, int index)
    {
        return bitmask | (1u << index);
    }

    private static uint DisableBitmaskInx(uint bitmask, int index)
    {
        return bitmask & ~(1u << index);
    }
}
```

---

## Using physics interpolation — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html

**Contents:**
- Using physics interpolation
- Turn on the physics interpolation setting
- Move (almost) all game logic from _process to _physics_process
- Ensure that all indirect movement happens during physics ticks
- Choose a physics tick rate
- Call reset_physics_interpolation() when teleporting objects
- Testing and debugging tips
- User-contributed notes

How do we incorporate physics interpolation into a Godot game? Are there any caveats?

We have tried to make the system as easy to use as possible, and many existing games will work with few changes. That said there are some situations which require special treatment, and these will be described.

The first step is to turn on physics interpolation in Project Settings > Physics > Common > Physics Interpolation You can now run your game.

It is likely that nothing looks hugely different, particularly if you are running physics at 60 TPS or a multiple of it. However, quite a bit more is happening behind the scenes.

To convert an existing game to use interpolation, it is highly recommended that you temporarily set Project Settings > Physics > Common > Physics Tick per Second to a low value such as 10, which will make interpolation problems more obvious.

The most fundamental requirement for physics interpolation (which you may be doing already) is that you should be moving and performing game logic on your objects within _physics_process (which runs at a physics tick) rather than _process (which runs on a rendered frame). This means your scripts should typically be doing the bulk of their processing within _physics_process, including responding to input and AI.

Setting the transform of objects only within physics ticks allows the automatic interpolation to deal with transforms between physics ticks, and ensures the game will run the same whatever machine it is run on. As a bonus, this also reduces CPU usage if the game is rendering at high FPS, since AI logic (for example) will no longer run on every rendered frame.

If you attempt to set the transform of interpolated objects outside the physics tick, the calculations for the interpolated position will be incorrect, and you will get jitter. This jitter may not be visible on your machine, but it will occur for some players. For this reason, setting the transform of interpolated objects should be avoided outside of the physics tick. Godot will attempt to produce warnings in the editor if this case is detected.

This is only a soft rule. There are some occasions where you might want to teleport objects outside of the physics tick (for instance when starting a level, or respawning objects). Still, in general, you should be applying transforms from the physics tick.

Consider that in Godot, nodes can be moved not just directly in your own scripts, but also by automatic methods such as tweening, animation, and navigation. All these methods should also have their timing set to operate on the physics tick rather than each frame ("idle"), if you are using them to move objects (these methods can also be used to control properties that are not interpolated).

Also consider that nodes can be moved not just by moving themselves, but also by moving parent nodes in the SceneTree. The movement of parents should therefore also only occur during physics ticks.

When using physics interpolation, the rendering is decoupled from physics, and you can choose any value that makes sense for your game. You are no longer limited to values that are multiples of the user's monitor refresh rate (for stutter-free gameplay if the target FPS is reached).

Low tick rates (10-30)

Medium tick rates (30-60)

High tick rates (60+)

Better CPU performance

Good physics behavior in complex scenes

Good with fast physics

Add some delay to input

Good for first person games

Good for racing games

Simple physics behaviour

You can always change the tick rate as you develop, it is as simple as changing the project setting.

Most of the time, interpolation is what you want between two physics ticks. However, there is one situation in which it may not be what you want. That is when you are initially placing objects, or moving them to a new location. Here, you don't want a smooth motion between where the object was (e.g. the origin) and the initial position - you want an instantaneous move.

The solution to this is to call the Node.reset_physics_interpolation function. What this function does under the hood is set the internally stored previous transform of the object to be equal to the current transform. This ensures that when interpolating between these two equal transforms, there will be no movement.

Even if you forget to call this, it will usually not be a problem in most situations (especially at high tick rates). This is something you can easily leave to the polishing phase of your game. The worst that will happen is seeing a streaking motion for a frame or so when you move them - you will know when you need it!

There are actually two ways to use reset_physics_interpolation():

Standing start (e.g. player)

Set the initial transform

Call reset_physics_interpolation()

The previous and current transforms will be identical, resulting in no initial movement.

Moving start (e.g. bullet)

Set the initial transform

Call reset_physics_interpolation()

Immediately set the transform expected after the first tick of motion

The previous transform will be the starting position, and the current transform will act as though a tick of simulation has already taken place. This will immediately start moving the object, instead of having a tick delay standing still.

Make sure you set the transform and call reset_physics_interpolation() in the correct order as shown above, otherwise you will see unwanted "streaking".

Even if you intend to run physics at 60 TPS, in order to thoroughly test your interpolation and get the smoothest gameplay, it is highly recommended to temporarily set the physics tick rate to a low value such as 10 TPS.

The gameplay may not work perfectly, but it should enable you to more easily see cases where you should be calling Node.reset_physics_interpolation, or where you should be using your own custom interpolation on e.g. a Camera3D. Once you have these cases fixed, you can set the physics tick rate back to the desired setting.

The other great advantage to testing at a low tick rate is you can often notice other game systems that are synchronized to the physics tick and creating glitches which you may want to work around. Typical examples include setting animation blend values, which you may decide to set in _process() and interpolate manually.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

---

## Using RigidBody — Godot Engine (stable) documentation in English

**URL:** https://docs.godotengine.org/en/stable/tutorials/physics/rigid_body.html

**Contents:**
- Using RigidBody
- What is a rigid body?
- How to control a rigid body
- The "look at" method
- User-contributed notes

A rigid body is one that is directly controlled by the physics engine in order to simulate the behavior of physical objects. In order to define the shape of the body, it must have one or more Shape3D objects assigned. Note that setting the position of these shapes will affect the body's center of mass.

A rigid body's behavior can be altered by setting its properties, such as mass and weight. A physics material needs to be added to the rigid body to adjust its friction and bounce, and set if it's absorbent and/or rough. These properties can be set in the Inspector or via code. See RigidBody3D and PhysicsMaterial for the full list of properties and their effects.

There are several ways to control a rigid body's movement, depending on your desired application.

If you only need to place a rigid body once, for example to set its initial location, you can use the methods provided by the Node3D node, such as set_global_transform() or look_at(). However, these methods cannot be called every frame or the physics engine will not be able to correctly simulate the body's state. As an example, consider a rigid body that you want to rotate so that it points towards another object. A common mistake when implementing this kind of behavior is to use look_at() every frame, which breaks the physics simulation. Below, we'll demonstrate how to implement this correctly.

The fact that you can't use set_global_transform() or look_at() methods doesn't mean that you can't have full control of a rigid body. Instead, you can control it by using the _integrate_forces() callback. In this method, you can add forces, apply impulses, or set the velocity in order to achieve any movement you desire.

As described above, using the Node3D's look_at() method can't be used each frame to follow a target. Here is a custom look_at() method called look_follow() that will work with rigid bodies:

This method uses the rigid body's angular_velocity property to rotate the body. The axis to rotate around is given by the cross product between the current forward direction and the direction one wants to look in. The clamp is a simple method used to prevent the amount of rotation from going past the direction which is wanted to be looked in, as the total amount of rotation needed is given by the arccosine of the dot product. This method can be used with axis_lock_angular_* as well. If more precise control is needed, solutions such as ones relying on Quaternion may be required, as discussed in Using 3D transforms.

Please read the User-contributed notes policy before submitting a comment.

© Copyright 2014-present Juan Linietsky, Ariel Manzur and the Godot community (CC BY 3.0).

**Examples:**

Example 1 (gdscript):
```gdscript
extends RigidBody3D

var speed: float = 0.1

func look_follow(state: PhysicsDirectBodyState3D, current_transform: Transform3D, target_position: Vector3) -> void:
    var forward_local_axis: Vector3 = Vector3(1, 0, 0)
    var forward_dir: Vector3 = (current_transform.basis * forward_local_axis).normalized()
    var target_dir: Vector3 = (target_position - current_transform.origin).normalized()
    var local_speed: float = clampf(speed, 0, acos(forward_dir.dot(target_dir)))
    if forward_dir.dot(target_dir) > 1e-4:
        state.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step

func _integrate_forces(state):
    var target_position = $my_target_node3d_node.global_transform.origin
    look_follow(state, global_transform, target_position)
```

Example 2 (unknown):
```unknown
using Godot;

public partial class MyRigidBody3D : RigidBody3D
{
    private float _speed = 0.1f;
    private void LookFollow(PhysicsDirectBodyState3D state, Transform3D currentTransform, Vector3 targetPosition)
    {
        Vector3 forwardLocalAxis = new Vector3(1, 0, 0);
        Vector3 forwardDir = (currentTransform.Basis * forwardLocalAxis).Normalized();
        Vector3 targetDir = (targetPosition - currentTransform.Origin).Normalized();
        float localSpeed = Mathf.Clamp(_speed, 0.0f, Mathf.Acos(forwardDir.Dot(targetDir)));
        if (forwardDir.Dot(targetDir) > 1e-4)
        {
            state.AngularVelocity = forwardDir.Cross(targetDir) * localSpeed / state.Step;
        }
    }

    public override void _IntegrateForces(PhysicsDirectBodyState3D state)
    {
        Vector3 targetPosition = GetNode<Node3D>("MyTargetNode3DNode").GlobalTransform.Origin;
        LookFollow(state, GlobalTransform, targetPosition);
    }
}
```

---
