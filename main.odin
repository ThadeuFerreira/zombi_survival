package main

import rl "vendor:raylib"

import pl "./player"

// Global variables
screenWidth  :: 1800
screenHeight :: 900
MAX_BUILDINGS :: 100


//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: proc()
{
    // Initialization
    //--------------------------------------------------------------------------------------


    rl.InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera")

    player := pl.Make_Player()
    // player.transform.position = rl.Vector2{ 400, 280 }
    // player.rectangle = rl.Rectangle{ 400, 280, 40, 40 }

    //player := rl.Rectangle{ 400, 280, 40, 40 }
    // player.x = 400
    // player.y = 280
    // player.width = 40
    // player.height = 40
    buildings := [MAX_BUILDINGS]rl.Rectangle{}
    buildColors := [MAX_BUILDINGS]rl.Color{}

    spacing : int = 0

    for i in 0..<MAX_BUILDINGS {
        buildings[i].width = f32(rl.GetRandomValue(50, 200))
        buildings[i].height = f32(rl.GetRandomValue(100, 800))
        buildings[i].y = screenHeight - 130.0 - buildings[i].height
        buildings[i].x = -6000.0 + f32(spacing)

        spacing += int(buildings[i].width)

        buildColors[i] = rl.Color{ u8(rl.GetRandomValue(200, 240)), u8(rl.GetRandomValue(200, 240)), u8(rl.GetRandomValue(200, 240)), 255 }
    }

    camera := rl.Camera2D{}
    camera.target = { player.transform.position.x + 20.0, player.transform.position.y + 20.0 }
    camera.offset = { screenWidth/2.0, screenHeight/2.0 }
    camera.rotation = 0.0
    camera.zoom = 1.0

    rl.SetTargetFPS(60)                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    for !rl.WindowShouldClose()        // Detect window close button or ESC key
    {
        pl.Update(player)
        rl.TraceLog(rl.TraceLogLevel.INFO, "Player position: %f, %f\n", player.transform.position.x, player.transform.position.y)
        // Camera target follows player
        camera.target = { player.transform.position.x + 20, player.transform.position.y + 20 }

        // Camera rotation controls
        if rl.IsKeyDown(rl.KeyboardKey.A) {
            camera.rotation -= 1
        }
        else if (rl.IsKeyDown(rl.KeyboardKey.S)) {
            camera.rotation += 1
        }

        // Limit camera rotation to 80 degrees (-40 to 40)
        if (camera.rotation > 40) {
            camera.rotation = 40
        }
        else if (camera.rotation < -40) {
            camera.rotation = -40
        }
        // Camera zoom controls
        camera.zoom += f32(rl.GetMouseWheelMove()*0.05)

        if (camera.zoom > 3.0) {
            camera.zoom = 3.0
        }
        else if (camera.zoom < 0.1) {
            camera.zoom = 0.1
        }
        // Camera reset (zoom and rotation)
        if rl.IsKeyPressed(rl.KeyboardKey.R)
        {
            camera.zoom = 1.0
            camera.rotation = 0.0
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing()

        rl.ClearBackground(rl.RAYWHITE)

        rl.BeginMode2D(camera)

        rl.DrawRectangle(-6000, 320, 13000, 8000, rl.DARKGRAY)

                for i in 0..<MAX_BUILDINGS{
                    rl.DrawRectangleRec(buildings[i], buildColors[i])
                }
                
                pl.Draw(player)  

                rl.DrawLine(i32(camera.target.x), -screenHeight*10, i32(camera.target.x), screenHeight*10, rl.GREEN)
                rl.DrawLine(-screenWidth*10, i32(camera.target.y), screenWidth*10, i32(camera.target.y), rl.GREEN)

                rl.EndMode2D()

                rl.DrawText("SCREEN AREA", 640, 10, 20, rl.RED)

                rl.DrawRectangle(0, 0, screenWidth, 5, rl.RED)
                rl.DrawRectangle(0, 5, 5, screenHeight - 10, rl.RED)
                rl.DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, rl.RED)
                rl.DrawRectangle(0, screenHeight - 5, screenWidth, 5, rl.RED)

                rl.DrawRectangle( 10, 10, 250, 113, rl.Fade(rl.SKYBLUE, 0.5))
                rl.DrawRectangleLines( 10, 10, 250, 113, rl.BLUE)

                rl.DrawText("Free 2d camera controls:", 20, 20, 10, rl.BLACK)
                rl.DrawText("- Right/Left to move Offset", 40, 40, 10, rl.DARKGRAY)
                rl.DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, rl.DARKGRAY)
                rl.DrawText("- A / S to Rotate", 40, 80, 10, rl.DARKGRAY)
                rl.DrawText("- R to reset Zoom and Rotation", 40, 100, 10, rl.DARKGRAY)

                rl.EndDrawing()
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.CloseWindow()        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}