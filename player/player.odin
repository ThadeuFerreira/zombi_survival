package player

import rl "vendor:raylib"

PROJECTILE_SPEED : f32 = 100
Projectile :: struct{
    transform : Transform,
    size : f32,
    color : rl.Color,
    active : bool,
    direction : rl.Vector2,
    speed : f32,
}

AMMO_TYPE :: enum {
    BULLET,
    LASER,
    ROCKET,
    SHOTGUN,
    GRENADE,
}

Weapon :: struct {
    transform_offset : Transform,
    transform : Transform,
    sprite : ^Sprite,
    projectiles : [dynamic]^Projectile,

    range : f32,
    fire_rate : f32,
    damage : f32,

    ammo_type : AMMO_TYPE,
    ammo : i32,
    max_ammo : i32,
}

Transform :: struct {
    position: rl.Vector2,
    rotation: rl.Quaternion,
}

Sprite :: struct {
    height : f32,
    width : f32,
    transform_offset : Transform,
    transform : Transform,
    texture : rl.Texture2D,
    rectangle : rl.Rectangle,
    color : rl.Color,
}

Player :: struct {
    transform : Transform,
    sprite : ^Sprite,
    weapon : ^Weapon,
    camera : ^rl.Camera2D,
}

make_sprite :: proc(height : f32 = 40, width :f32 = 40, transform_offset : rl.Vector2 = rl.Vector2{ 0, 0 }, color : rl.Color = rl.RED) -> ^Sprite {
    s := new(Sprite)
    s.height = height
    s.width = width
    s.transform_offset.position = transform_offset
    s.color = color
    s.rectangle = rl.Rectangle{ 0, 0, s.width, s.height }
    return s
}

make_weapon :: proc() -> ^Weapon {
    w := new(Weapon)
    w.transform_offset.position = rl.Vector2{ 40, 20 }
    w.sprite = make_sprite(5, 10, rl.Vector2{ 0, 0 }, rl.BLUE)
    w.projectiles = make([dynamic]^Projectile, 0,20)
    return w
}

Make_Player :: proc() -> ^Player {
    p := new(Player)
    p.transform.position = rl.Vector2{ 400, 280 }
    p.sprite = make_sprite()
    p.weapon = make_weapon()
    return p
}


update_sprite :: proc(entity: $T) {
    entity.sprite.transform.position = entity.sprite.transform_offset.position + entity.transform.position
    entity.sprite.rectangle.height = entity.sprite.height
    entity.sprite.rectangle.width = entity.sprite.width
}

update_weapon :: proc(p: ^Player) {
    p.weapon.transform.position = p.weapon.transform_offset.position + p.transform.position
    update_sprite(p.weapon)
}

Update :: proc(p: ^Player) {
    // Update
    //----------------------------------------------------------------------------------
    // Player movement
    move(p)
    update_sprite(p)
    update_weapon(p)
    
}

draw_sprite :: proc(s: $T) {
    // Draw
    //----------------------------------------------------------------------------------
    s.rectangle = rl.Rectangle{ s.transform.position.x, s.transform.position.y, s.width, s.height }
    rl.DrawRectangleRec(s.rectangle, s.color)
}

Draw :: proc(p: ^Player) {
    // Draw
    //----------------------------------------------------------------------------------
    draw_sprite(p.sprite)
    draw_sprite(p.weapon.sprite)
    mouse_position := rl.GetScreenToWorld2D(rl.GetMousePosition(), p.camera^)

    rl.DrawLineV(mouse_position, p.weapon.transform.position, rl.RED);
    for i in p.weapon.projectiles {
        if i.active {
            rl.DrawCircle(i32(i.transform.position.x), i32(i.transform.position.y), i.size, i.color)
        }
    }

}

projectile_timer : f32 = 0
move :: proc(p: ^Player) {
    if (rl.IsKeyDown(rl.KeyboardKey.RIGHT) || rl.IsKeyDown(rl.KeyboardKey.D)) {
        p.transform.position.x += 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.LEFT) || rl.IsKeyDown(rl.KeyboardKey.A)) {
        p.transform.position.x -= 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.UP) || rl.IsKeyDown(rl.KeyboardKey.W)) {
        p.transform.position.y -= 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.DOWN) || rl.IsKeyDown(rl.KeyboardKey.S)) {
        p.transform.position.y += 20
    }
    else if (rl.IsKeyDown(rl.KeyboardKey.SPACE) || rl.IsMouseButtonDown(rl.MouseButton.LEFT)) {
        shoot(p)
    }
    projectile_timer += rl.GetFrameTime()
    if projectile_timer > 1/PROJECTILE_SPEED{  
        for i in p.weapon.projectiles {      
            if i.active{
                i.transform.position.x += i.direction.x * i.speed
                i.transform.position.y += i.direction.y * i.speed
                projectile_timer = 0
            }
        }
    }
}

shoot :: proc(p: ^Player) {
    projectile := new(Projectile)
    projectile.transform.position = p.weapon.transform.position
    projectile.size = 5
    projectile.color = rl.BLUE
    projectile.speed = 10
    projectile.active = true
    mouse_position := rl.GetScreenToWorld2D(rl.GetMousePosition(), p.camera^)
    projectile.direction = rl.Vector2Normalize(mouse_position - p.weapon.transform.position)
    append(&p.weapon.projectiles, projectile)
}