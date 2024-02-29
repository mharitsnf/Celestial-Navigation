extends GutTest

# var main_camera : PackedScene = preload("res://assets/prefabs/virtual camera/main_camera.tscn")
# var third_person_camera : PackedScene = preload("res://assets/prefabs/virtual camera/third_person_camera.tscn")

class TestVirtualCamera extends GutTest:
    var third_person_camera : PackedScene = preload("res://assets/prefabs/virtual camera/third_person_camera.tscn")
    
    func test_transition() -> void:
        var parent : Node = autoqfree(Node.new())
        var first_target : Node3D = autoqfree(Node3D.new())
        var second_target : Node3D = autoqfree(Node3D.new())
        var tpc : ThirdPersonCamera = autoqfree(third_person_camera.instantiate())

        add_child(parent)

        parent.add_child(first_target)
        first_target.global_position = Vector3(5, 0, 0)

        parent.add_child(second_target)
        second_target.global_position = Vector3(-5, 0, 0)

        parent.add_child(tpc)

        # Test transition between two objects
        tpc.set_follow_target(first_target)
        await wait_for_signal(tpc.transition_finished, 5., "Wait for finish transition")
        assert_eq(tpc.global_position, first_target.global_position)

        tpc.set_follow_target(second_target)
        await wait_for_signal(tpc.transition_finished, 5., "Wait for finish transition")
        assert_eq(tpc.global_position, second_target.global_position)

        # Test removing from tree and putting it back
        remove_child(parent)
        add_child(parent)

        tpc.set_follow_target(first_target)
        await wait_for_signal(tpc.transition_finished, 5., "Wait for finish transition")
        assert_eq(tpc.global_position, first_target.global_position)

        # Test setting object immediately
        tpc.set_follow_target(second_target)
        tpc.set_follow_target(first_target)
        assert_eq(tpc.get_follow_target(), second_target, "Follow target should not be changed (still second_target)")

        # Test setting object to null
        tpc.set_follow_target(null)
        assert_eq(tpc.get_follow_target(), second_target, "null value cannot be set as follow target")

class TestMainCamera extends GutTest:
    var main_camera : PackedScene = preload("res://assets/prefabs/virtual camera/main_camera.tscn")
    var third_person_camera : PackedScene = preload("res://assets/prefabs/virtual camera/third_person_camera.tscn")

    func test_transition() -> void:
        var mc : MainCamera = autoqfree(main_camera.instantiate())
        var target1 : Node3D = autoqfree(Node3D.new())
        var tpc1 : ThirdPersonCamera = autoqfree(third_person_camera.instantiate())
        var target2 : Node3D = autoqfree(Node3D.new())
        var tpc2 : ThirdPersonCamera = autoqfree(third_person_camera.instantiate())

        add_child(target1)
        target1.global_position.x = 5
        add_child(target2)
        target2.global_position.x = -5
        add_child(mc)
        add_child(tpc1)
        add_child(tpc2)

        tpc1.set_follow_target(target1)
        tpc2.set_follow_target(target2)
        await wait_for_signal(tpc2.transition_finished, 3, "Wait for finish transition")

        mc.set_follow_target(tpc1)
        await wait_for_signal(mc.transition_finished, 3, "Wait for finish transition")
        var rt : RemoteTransform3D = tpc1.remote_transform_parent_for_other.get_node("FollowedByMainCamera")
        assert_ne(rt, null, "Should have a remote transform for camera")
        assert_eq(rt.global_position, mc.global_position, "Main camera position should be the same as the remote transform")

        mc.set_follow_target(null)
        assert_eq(mc.get_follow_target(), tpc1, "Should not be able to switch follow target to null")

        mc.set_follow_target(tpc2)
        mc.set_follow_target(tpc1)
        assert_eq(mc.get_follow_target(), tpc2, "Should not be able to switch follow target while transitioning")

class TestThirdPersonCamera extends GutTest:
    var third_person_camera : PackedScene = preload("res://assets/prefabs/virtual camera/third_person_camera.tscn")

    func test_changing_spring_length() -> void:
        var first_target : Node3D = autoqfree(Node3D.new())
        var tpc : ThirdPersonCamera = autoqfree(third_person_camera.instantiate())

        tpc.set_follow_target(first_target)

        add_child(first_target)
        add_child(tpc)

        tpc._spring_length = 10
        await wait_seconds(1.)
        assert_almost_eq(tpc.spring_arm.spring_length, tpc._spring_length, .5, "Spring Arm length should equal to _spring_length")