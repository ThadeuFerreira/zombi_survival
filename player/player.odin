package player

import rl "vendor:raylib"

Projectile :: struct{
    transform : Transform,
    size : f32,
    color : rl.Color,
    active : bool,
    direction : rl.Vector2,
    speed : f32,
}

PROJECTILE_SPEED : f32 = 100

Transform :: struct {
    position: rl.Vector2,
    rotation: rl.Quaternion,
}

Player :: struct {
    transform : Transform,
    rectangle : rl.Rectangle,
    projectiles : [dynamic]^Projectile,
    color : rl.Color,
}

BuildPlayer :: proc() -> ^Player {
    p := new(Player)
    p.transform.position = rl.Vector2{ 400, 280 }
    p.rectangle = rl.Rectangle{ 400, 280, 40, 40 }
    p.color = rl.RED
    projectiles := make([dynamic]^Projectile, 0,20)
    return p
}

Update :: proc(p: ^Player) {
    // Update
    //----------------------------------------------------------------------------------
    // Player movement
    move(p)
    
    p.rectangle.x = p.transform.position.x
    p.rectangle.y = p.transform.position.y
}

Draw :: proc(p: ^Player) {
    // Draw
    //----------------------------------------------------------------------------------
    rl.DrawRectangleRec(p.rectangle, p.color)
    for i in p.projectiles {
        if i.active {
            rl.DrawCircle(i32(i.transform.position.x), i32(i.transform.position.y), i.size, i.color)
        }
    }

}

peojectile_timer : f32 = 0
move :: proc(p: ^Player) {
    if (rl.IsKeyDown(rl.KeyboardKey.RIGHT)) {
        p.transform.position.x += 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.LEFT)) {
        p.transform.position.x -= 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.UP)) {
        p.transform.position.y -= 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.DOWN)) {
        p.transform.position.y += 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.SPACE)) {
        shoot(p)
    }
    peojectile_timer += rl.GetFrameTime()
    if peojectile_timer > 1/PROJECTILE_SPEED{  
        for i in 0..<len(p.projectiles) {
            
            if p.projectiles[i].active{
                p.projectiles[i].transform.position.x += p.projectiles[i].direction.x * p.projectiles[i].speed
                p.projectiles[i].transform.position.y += p.projectiles[i].direction.y * p.projectiles[i].speed
                peojectile_timer = 0
            }
        }
    }
}

shoot :: proc(p: ^Player) {
    projectile := new(Projectile)
    projectile.transform.position = rl.Vector2{ p.transform.position.x, p.transform.position.y }
    projectile.size = 5
    projectile.color = rl.BLUE
    projectile.speed = 10
    projectile.active = true
    projectile.direction = rl.Vector2{ 1, 0 }
    append(&p.projectiles, projectile)
}