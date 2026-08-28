const rl = @import("raylib");

const xboxAlias1 = "xbox";
const xboxAlias2 = "x-box";
const psAlias1 = "playstation";
const psAlias2 = "sony";
const psAlias3 = "dualsense";

const screenWidth = 800;
const screenHeight = 450;

pub fn main() anyerror!void {
    rl.initWindow(screenWidth, screenHeight, "raylib [core] example - input gamepad");
    defer rl.closeWindow();

    const psPad = try rl.loadTexture("resources/textures/ps3.png");
    defer rl.unloadTexture(psPad);

    const xboxPad = try rl.loadTexture("resources/textures/xbox.png");
    defer rl.unloadTexture(xboxPad);

    // Set axis deadzones
    const leftStickDeadzoneX = 0.1;
    const leftStickDeadzoneY = 0.1;
    const rightStickDeadzoneX = 0.1;
    const rightStickDeadzoneY = 0.1;
    const leftTriggerDeadzone = -0.9;
    const rightTriggerDeadzone = -0.9;

    var vibrateButton: rl.Rectangle = undefined;
    var gamepad: u16 = 0;

    rl.setConfigFlags(.{ .msaa_4x_hint = true }); // NOTE: Try to enable MSAA 4X

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(.left)) {
            gamepad -|= 1;
        }

        if (rl.isKeyPressed(.right)) {
            gamepad += 1;
        }

        vibrateButton = .{ .x = 10, .y = 70 + 20 * @as(f32, @floatFromInt(rl.getGamepadAxisCount(gamepad))) + 20, .width = 75, .height = 24 };

        const mousePosition = rl.getMousePosition();
        if (rl.isMouseButtonPressed(.left) and rl.checkCollisionPointRec(mousePosition, vibrateButton)) {
            rl.setGamepadVibration(gamepad, 1, 1, 1);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.ray_white);

        if (rl.isGamepadAvailable(gamepad)) {
            rl.drawText(rl.textFormat("GP%d: %s", .{ gamepad, rl.getGamepadName(gamepad).ptr }), 10, 10, 10, .black);

            // Get axis values
            var leftStickX = rl.getGamepadAxisMovement(gamepad, .left_x);
            var leftStickY = rl.getGamepadAxisMovement(gamepad, .left_y);
            var rightStickX = rl.getGamepadAxisMovement(gamepad, .right_x);
            var rightStickY = rl.getGamepadAxisMovement(gamepad, .right_y);
            var leftTrigger = rl.getGamepadAxisMovement(gamepad, .left_trigger);
            var rightTrigger = rl.getGamepadAxisMovement(gamepad, .right_trigger);

            // Calculate deadzones
            if (leftStickX > -leftStickDeadzoneX and leftStickX < leftStickDeadzoneX) {
                leftStickX = 0;
            }
            if (leftStickY > -leftStickDeadzoneY and leftStickY < leftStickDeadzoneY) {
                leftStickY = 0;
            }
            if (rightStickX > -rightStickDeadzoneX and rightStickX < rightStickDeadzoneX) {
                rightStickX = 0;
            }
            if (rightStickY > -rightStickDeadzoneY and rightStickY < rightStickDeadzoneY) {
                rightStickY = 0;
            }
            if (leftTrigger < leftTriggerDeadzone) {
                leftTrigger = -1;
            }
            if (rightTrigger < rightTriggerDeadzone) {
                rightTrigger = -1;
            }

            const gamepadName = rl.textToLower(rl.getGamepadName(gamepad));
            if (rl.textFindIndex(gamepadName, xboxAlias1) > -1 or
                rl.textFindIndex(gamepadName, xboxAlias2) > -1)
            {
                // Draw background: XBOX
                rl.drawTexture(xboxPad, 0, 0, .dark_gray);

                // Draw buttons: xbox home
                if (rl.isGamepadButtonDown(gamepad, .middle)) {
                    rl.drawCircle(394, 89, 19, .red);
                }

                // Draw buttons: basic
                if (rl.isGamepadButtonDown(gamepad, .middle_right)) {
                    rl.drawCircle(436, 150, 9, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .middle_left)) {
                    rl.drawCircle(352, 150, 9, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_left)) {
                    rl.drawCircle(501, 151, 15, .blue);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_down)) {
                    rl.drawCircle(536, 187, 15, .lime);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_right)) {
                    rl.drawCircle(572, 151, 15, .maroon);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_up)) {
                    rl.drawCircle(536, 115, 15, .gold);
                }

                // Draw buttons: d-pad
                rl.drawRectangle(317, 202, 19, 71, .black);
                rl.drawRectangle(293, 228, 69, 19, .black);
                if (rl.isGamepadButtonDown(gamepad, .left_face_up)) {
                    rl.drawRectangle(317, 202, 19, 26, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_down)) {
                    rl.drawRectangle(317, 202 + 45, 19, 26, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_left)) {
                    rl.drawRectangle(292, 228, 25, 19, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_right)) {
                    rl.drawRectangle(292 + 44, 228, 26, 19, .red);
                }

                // Draw buttons: left-right back
                if (rl.isGamepadButtonDown(gamepad, .left_trigger_1)) {
                    rl.drawCircle(259, 61, 20, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_trigger_1)) {
                    rl.drawCircle(536, 61, 20, .red);
                }

                // Draw axis: left joystick
                const leftGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .left_thumb)) .red else .black;
                rl.drawCircle(259, 152, 39, .black);
                rl.drawCircle(259, 152, 34, .light_gray);
                rl.drawCircle(259 + @as(i32, @round(leftStickX * 20)), 152 + @as(i32, @round(leftStickY * 20)), 25, leftGamepadColor);

                // Draw axis: right joystick
                const rightGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .right_thumb)) .red else .black;
                rl.drawCircle(461, 237, 38, .black);
                rl.drawCircle(461, 237, 33, .light_gray);
                rl.drawCircle(461 + @as(i32, @round(rightStickX * 20)), 237 + @as(i32, @round(rightStickY * 20)), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                rl.drawRectangle(170, 30, 15, 70, .gray);
                rl.drawRectangle(604, 30, 15, 70, .gray);
                rl.drawRectangle(170, 30, 15, @as(i32, @round(((1 + leftTrigger) / 2) * 70)), .red);
                rl.drawRectangle(604, 30, 15, @as(i32, @round(((1 + rightTrigger) / 2) * 70)), .red);
            } else if (rl.textFindIndex(gamepadName, psAlias1) > -1 or
                rl.textFindIndex(gamepadName, psAlias2) > -1 or
                rl.textFindIndex(gamepadName, psAlias3) > -1)
            {
                // Draw background: PS
                rl.drawTexture(psPad, 0, 0, .dark_gray);

                // Draw buttons: ps
                if (rl.isGamepadButtonDown(gamepad, .middle)) {
                    rl.drawCircle(396, 222, 13, .red);
                }

                // Draw buttons: basic
                if (rl.isGamepadButtonDown(gamepad, .middle_left)) {
                    rl.drawRectangle(328, 170, 32, 13, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .middle_right)) {
                    rl.drawTriangle(.{ .x = 436, .y = 168 }, .{ .x = 436, .y = 185 }, .{ .x = 464, .y = 177 }, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_up)) {
                    rl.drawCircle(557, 144, 13, .lime);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_right)) {
                    rl.drawCircle(586, 173, 13, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_down)) {
                    rl.drawCircle(557, 203, 13, .violet);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_left)) {
                    rl.drawCircle(527, 173, 13, .pink);
                }

                // Draw buttons: d-pad
                rl.drawRectangle(225, 132, 24, 84, .black);
                rl.drawRectangle(195, 161, 84, 25, .black);
                if (rl.isGamepadButtonDown(gamepad, .left_face_up)) {
                    rl.drawRectangle(225, 132, 24, 29, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_down)) {
                    rl.drawRectangle(225, 132 + 54, 24, 30, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_left)) {
                    rl.drawRectangle(195, 161, 30, 25, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_right)) {
                    rl.drawRectangle(195 + 54, 161, 30, 25, .red);
                }

                // Draw buttons: left-right back buttons
                if (rl.isGamepadButtonDown(gamepad, .left_trigger_1)) {
                    rl.drawCircle(239, 82, 20, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_trigger_1)) {
                    rl.drawCircle(557, 82, 20, .red);
                }

                // Draw axis: left joystick
                const leftGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .left_thumb)) .red else .black;
                rl.drawCircle(319, 255, 35, .black);
                rl.drawCircle(319, 255, 31, .light_gray);
                rl.drawCircle(319 + @as(i32, @round(leftStickX * 20)), 255 + @as(i32, @round(leftStickY * 20)), 25, leftGamepadColor);

                // Draw axis: right joystick
                const rightGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .right_thumb)) .red else .black;
                rl.drawCircle(475, 255, 35, .black);
                rl.drawCircle(475, 255, 31, .light_gray);
                rl.drawCircle(475 + @as(i32, @round(rightStickX * 20)), 255 + @as(i32, @round(rightStickY * 20)), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                rl.drawRectangle(169, 48, 15, 70, .gray);
                rl.drawRectangle(611, 48, 15, 70, .gray);
                rl.drawRectangle(169, 48, 15, @as(i32, @round(((1 + leftTrigger) / 2) * 70)), .red);
                rl.drawRectangle(611, 48, 15, @as(i32, @round(((1 + rightTrigger) / 2) * 70)), .red);
                // } else {
            } else {
                // Draw background: generic
                rl.drawRectangleRounded(.{ .x = 175, .y = 110, .width = 460, .height = 220 }, 0.3, 16, .dark_gray);

                // Draw buttons: basic
                rl.drawCircle(365, 170, 12, .ray_white);
                rl.drawCircle(405, 170, 12, .ray_white);
                rl.drawCircle(445, 170, 12, .ray_white);
                rl.drawCircle(516, 191, 17, .ray_white);
                rl.drawCircle(551, 227, 17, .ray_white);
                rl.drawCircle(587, 191, 17, .ray_white);
                rl.drawCircle(551, 155, 17, .ray_white);
                if (rl.isGamepadButtonDown(gamepad, .middle_left)) {
                    rl.drawCircle(365, 170, 10, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .middle)) {
                    rl.drawCircle(405, 170, 10, .green);
                }
                if (rl.isGamepadButtonDown(gamepad, .middle_right)) {
                    rl.drawCircle(445, 170, 10, .blue);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_left)) {
                    rl.drawCircle(516, 191, 15, .gold);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_down)) {
                    rl.drawCircle(551, 227, 15, .blue);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_right)) {
                    rl.drawCircle(587, 191, 15, .green);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_face_up)) {
                    rl.drawCircle(551, 155, 15, .red);
                }

                // Draw buttons: d-pad
                rl.drawRectangle(245, 145, 28, 88, .ray_white);
                rl.drawRectangle(215, 174, 88, 29, .ray_white);
                rl.drawRectangle(247, 147, 24, 84, .black);
                rl.drawRectangle(217, 176, 84, 25, .black);
                if (rl.isGamepadButtonDown(gamepad, .left_face_up)) {
                    rl.drawRectangle(247, 147, 24, 29, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_down)) {
                    rl.drawRectangle(247, 147 + 54, 24, 30, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_left)) {
                    rl.drawRectangle(217, 176, 30, 25, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .left_face_right)) {
                    rl.drawRectangle(217 + 54, 176, 30, 25, .red);
                }

                // Draw buttons: left-right back
                rl.drawRectangleRounded(.{ .x = 215, .y = 98, .width = 100, .height = 10 }, 0.5, 16, .dark_gray);
                rl.drawRectangleRounded(.{ .x = 495, .y = 98, .width = 100, .height = 10 }, 0.5, 16, .dark_gray);
                if (rl.isGamepadButtonDown(gamepad, .left_trigger_1)) {
                    rl.drawRectangleRounded(.{ .x = 215, .y = 98, .width = 100, .height = 10 }, 0.5, 16, .red);
                }
                if (rl.isGamepadButtonDown(gamepad, .right_trigger_1)) {
                    rl.drawRectangleRounded(.{ .x = 495, .y = 98, .width = 100, .height = 10 }, 0.5, 16, .red);
                }

                // Draw axis: left joystick
                const leftGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .left_thumb)) .red else .black;
                rl.drawCircle(345, 260, 40, .black);
                rl.drawCircle(345, 260, 35, .light_gray);
                rl.drawCircle(345 + @as(i32, @round(leftStickX * 20)), 260 + @as(i32, @round(leftStickY * 20)), 25, leftGamepadColor);

                // Draw axis: right joystick
                const rightGamepadColor: rl.Color = if (rl.isGamepadButtonDown(gamepad, .right_thumb)) .red else .black;
                rl.drawCircle(465, 260, 40, .black);
                rl.drawCircle(465, 260, 35, .light_gray);
                rl.drawCircle(465 + @as(i32, @round(rightStickX * 20)), 260 + @as(i32, @round(rightStickY * 20)), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                rl.drawRectangle(151, 110, 15, 70, .gray);
                rl.drawRectangle(644, 110, 15, 70, .gray);
                rl.drawRectangle(151, 110, 15, @as(i32, @round(((1 + leftTrigger) / 2) * 70)), .red);
                rl.drawRectangle(644, 110, 15, @as(i32, @round(((1 + rightTrigger) / 2) * 70)), .red);
            }

            // Draw axis movement text
            rl.drawText(rl.textFormat("DETECTED AXIS [%d]:", .{rl.getGamepadAxisCount(gamepad)}), 10, 50, 10, .maroon);

            const axisCount = rl.getGamepadAxisCount(gamepad);
            for (0..@intCast(axisCount)) |i| {
                const axis: rl.GamepadAxis = @enumFromInt(i);
                rl.drawText(rl.textFormat("AXIS %d: %.02f", .{ i, rl.getGamepadAxisMovement(gamepad, axis) }), 20, 70 + 20 * @as(i32, @intCast(i)), 10, .dark_gray);
            }

            // Draw vibrate button
            rl.drawRectangleRec(vibrateButton, .sky_blue);
            rl.drawText("VIBRATE", @as(i32, @round(vibrateButton.x)) + 14, @as(i32, @round(vibrateButton.y)) + 1, 10, .dark_gray);

            if (rl.getGamepadButtonPressed() != .unknown) {
                rl.drawText(rl.textFormat("DETECTED BUTTON: %d", .{@intFromEnum(rl.getGamepadButtonPressed())}), 10, 430, 10, .red);
            } else {
                rl.drawText("DETECTED BUTTON: NONE", 10, 430, 10, .gray);
            }
        } else {
            rl.drawText(rl.textFormat("GP%d: NOT DETECTED", .{gamepad}), 10, 10, 10, .gray);
            rl.drawTexture(xboxPad, 0, 0, .light_gray);
        }
    }
}
