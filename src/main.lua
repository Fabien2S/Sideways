physics = require("physics")
vector = require("vector")

-- SCENE DEFINITION
local scene_time = 0;
local scene_gameTime = 0;

--- Represents the index of the current level of the scene AND the state of the game
--- <0 stand for "Dead", math.abs(scene_level) gives the level that was played
--- 0 stand for "Main Menu"
--- >0 stand for "Playing", where this match the current level
---
local scene_level = 0;
local scene_updated = true;

local scene_width = 800;
local scene_height = 600;

-- LEVEL DEFINITION
local level_mainMenu_transitionDuration = 1;

-- MISC
local easterEggSprite;
local easterEggSound;

-- WORLD DEFINITION
local layer_sky_sprite;
local layer_background_sprite;
local layer_ground_sprite;
local layer_hud_sprite;
local layer_hud_logo;
local layer_hud_button;
local layer_hud_small_font;
local layer_hud_large_font;
local layer_hud_splashIndex = 0;
local layer_hud_indicator_time = 0;
local layer_hud_indicator_score = 0;

-- ENTITIES DEFINITION
local entity_player_sprite;
local entity_player_frame_walk1;
local entity_player_frame_walk2;
local entity_player_frame_walk3;
local entity_player_frame_walk4;
local entity_player_frame_idle1;
local entity_player_frame_idle2;
local entity_player_frame_shoot1;
local entity_player_frame_shoot2;

local entity_bat_sprite;
local entity_bat_frame1;
local entity_bat_frame2;
local entity_bat_frame3;
local entity_bat_frame4;
local entity_bat_frame5;

local entity_wolf_sprite;
local entity_wolf_width;
local entity_wolf_height;
local entity_wolf_frame1;
local entity_wolf_frame2;
local entity_wolf_frame3;
local entity_wolf_frame4;
local entity_wolf_frame5;

-- ENTITIES
local ent_player_x = -150;
local ent_player_y = 480;
local ent_player_r = 0;
local ent_player_shootTime = 0;
local ent_player_shootDuration = .2;
local ent_player_health = 3;
local ent_player_score = 0;
local ent_player_highScore = 0;

local ent_bat1_seed = 0;
local ent_bat1_x = -1000;
local ent_bat1_y = 0;
local ent_bat1_width = 128;
local ent_bat1_height = 128;
local ent_bat1_health = 0;
local ent_bat1_speed = 200;

local ent_bat2_seed = 0;
local ent_bat2_x = -1000
local ent_bat2_y = 0;
local ent_bat2_width = 128;
local ent_bat2_height = 128;
local ent_bat2_health = 0;
local ent_bat2_speed = 200;

local ent_wolf1_x = -1000;
local ent_wolf1_y = 475;
local ent_wolf1_damage = 100;
local ent_wolf1_health = 0;
local ent_wolf1_speed = 400;

function love.load()
    -- WINDOW
    love.window.setTitle("Sideways");
    love.window.setMode(scene_width, scene_height, {
        resizable = false,
        vsync = 1
    });

    -- GRAPHICS
    love.graphics.setDefaultFilter("nearest", "nearest", 1);

    -- CURSOR
    love.mouse.setGrabbed(true);

    -- Layers
    layer_sky_sprite = love.graphics.newImage("sprites/levels/forest/sky.png");
    layer_background_sprite = love.graphics.newImage("sprites/levels/forest/background.png");
    layer_ground_sprite = love.graphics.newImage("sprites/levels/forest/ground.png");

    -- Layer UI
    layer_hud_sprite = love.graphics.newImage("sprites/hud.png");
    layer_hud_logo = love.graphics.newQuad(0, 0, 512, 256, 512, 512);
    layer_hud_button = love.graphics.newQuad(0, 256, 256, 64, 512, 512);
    layer_hud_small_font = love.graphics.newFont("fonts/mono.ttf", 24);
    layer_hud_large_font = love.graphics.newFont("fonts/mono.ttf", 40);

    -- ENTITIES DEFINITION
    entity_player_sprite = love.graphics.newImage("sprites/player.png");
    entity_player_frame_walk1 = love.graphics.newQuad(0, 0, 128, 96, 512, 192)
    entity_player_frame_walk2 = love.graphics.newQuad(128, 0, 128, 96, 512, 192)
    entity_player_frame_walk3 = love.graphics.newQuad(256, 0, 128, 96, 512, 192)
    entity_player_frame_walk4 = love.graphics.newQuad(384, 0, 128, 96, 512, 192)
    entity_player_frame_idle1 = love.graphics.newQuad(0, 96, 128, 96, 512, 192)
    entity_player_frame_idle2 = love.graphics.newQuad(128, 96, 128, 96, 512, 192)
    entity_player_frame_shoot1 = love.graphics.newQuad(256, 96, 128, 96, 512, 192)
    entity_player_frame_shoot2 = love.graphics.newQuad(384, 96, 128, 96, 512, 192)

    -- Layer ENTITIES
    local seed = os.time();
    scene_seed = math.floor(seed / 1);
    ent_bat1_seed = math.floor(seed / 2);
    ent_bat2_seed = math.floor(seed / 3);
end

function love.update(deltaTime)
    scene_time = scene_time + deltaTime;

    if (scene_updated) then
        scene_updated = false;

        if (scene_level > 0) then
            scene_gameTime = 0;

            local cursor = love.mouse.newCursor("sprites/crosshair.png", 8, 8);
            love.mouse.setCursor(cursor);

            local levelName;

            if (scene_level == 1) then
                levelName = "forest";
            elseif (scene_level == 2) then
                levelName = "sea";
            end

            -- Layer SKY
            layer_sky_sprite = love.graphics.newImage("sprites/levels/" .. levelName .. "/sky.png");
            layer_background_sprite = love.graphics.newImage("sprites/levels/" .. levelName .. "/background.png");
            layer_ground_sprite = love.graphics.newImage("sprites/levels/" .. levelName .. "/ground.png");

            -- Enemies
            entity_bat_sprite = love.graphics.newImage("sprites/levels/" .. levelName .. "/enemy.png");
            local enemySpriteWidth, enemySpriteHeight = entity_bat_sprite:getDimensions();
            local enemyWidth = math.floor(enemySpriteWidth / 2);
            local enemyHeight = math.floor(enemySpriteHeight / 3);
            entity_bat_frame1 = love.graphics.newQuad(0, 0, enemyWidth, enemyHeight, enemySpriteWidth, enemySpriteHeight)
            entity_bat_frame2 = love.graphics.newQuad(enemyWidth, 0, enemyWidth, enemyHeight, enemySpriteWidth, enemySpriteHeight)
            entity_bat_frame3 = love.graphics.newQuad(0, enemyHeight, enemyWidth, enemyHeight, enemySpriteWidth, enemySpriteHeight)
            entity_bat_frame4 = love.graphics.newQuad(enemyWidth, enemyHeight, enemyWidth, enemyHeight, enemySpriteWidth, enemySpriteHeight)
            entity_bat_frame5 = love.graphics.newQuad(0, 2 * enemyHeight, enemyWidth, enemyHeight, enemySpriteWidth, enemySpriteHeight)

            entity_wolf_sprite = love.graphics.newImage("sprites/levels/" .. levelName .. "/boss.png");
            local bossSpriteWidth, bossSpriteHeight = entity_wolf_sprite:getDimensions();
            entity_wolf_width = math.floor(bossSpriteWidth / 2);
            entity_wolf_height = math.floor(bossSpriteHeight / 3);
            entity_wolf_frame1 = love.graphics.newQuad(0, 0, entity_wolf_width, entity_wolf_height, bossSpriteWidth, bossSpriteHeight)
            entity_wolf_frame2 = love.graphics.newQuad(entity_wolf_width, 0, entity_wolf_width, entity_wolf_height, bossSpriteWidth, bossSpriteHeight)
            entity_wolf_frame3 = love.graphics.newQuad(0, entity_wolf_height, entity_wolf_width, entity_wolf_height, bossSpriteWidth, bossSpriteHeight)
            entity_wolf_frame4 = love.graphics.newQuad(entity_wolf_width, entity_wolf_height, entity_wolf_width, entity_wolf_height, bossSpriteWidth, bossSpriteHeight)
            entity_wolf_frame5 = love.graphics.newQuad(0, 2 * entity_wolf_height, entity_wolf_width, entity_wolf_height, bossSpriteWidth, bossSpriteHeight)
        else
            scene_gameTime = -1000;

            local cursor = love.mouse.newCursor("sprites/cursor.png", 0, 0);
            love.mouse.setCursor(cursor);
        end
    end

    if (scene_level > 0) then
        scene_gameTime = scene_gameTime + deltaTime;

        ent_player_score = ent_player_score + 100 * deltaTime;
        ent_player_shootTime = ent_player_shootTime - deltaTime;

        layer_hud_indicator_time = layer_hud_indicator_time - deltaTime;

        -- ON DEATH
        if (ent_player_health <= 0) then
            scene_level = -math.abs(scene_level);
            scene_updated = true;

            ent_player_health = 3;
            ent_player_highScore = math.max(math.floor(ent_player_score), ent_player_highScore);
            ent_player_score = 0;

            ent_bat1_x = -1000;
            ent_bat1_health = 0;
            ent_bat2_x = -1000;
            ent_bat2_health = 0;
            ent_wolf1_x = -1000;
            ent_wolf1_health = 0;
        end

        -- bat1
        if (ent_bat1_health <= 0) then
            ent_bat1_x = math.random(850, 1500);
            ent_bat1_y = math.random(0, scene_height - 64);
            ent_bat1_health = math.floor(math.random(4, 6));
            ent_bat1_speed = math.random(180, 220);
        else
            local x, y, reached = vector.moveTowards(ent_bat1_x, ent_bat1_y, ent_player_x, ent_player_y, ent_bat1_speed * deltaTime);
            if (reached) then
                ent_player_health = ent_player_health - ent_bat1_health * deltaTime;
            end
            ent_bat1_x = x;
            ent_bat1_y = y;
        end

        -- bat2
        if (ent_bat2_health <= 0) then
            ent_bat2_x = math.random(850, 1500);
            ent_bat2_y = math.random(-scene_height, scene_height - 64);
            ent_bat2_health = math.floor(math.random(4, 6));
            ent_bat2_speed = math.random(180, 220);
        else
            local x, y, reached = vector.moveTowards(ent_bat2_x, ent_bat2_y, ent_player_x, ent_player_y, ent_bat2_speed * deltaTime);
            if (reached) then
                ent_player_health = ent_player_health - ent_bat2_health * deltaTime;
            end
            ent_bat2_x = x;
            ent_bat2_y = y;
        end

        -- wolf1
        if (ent_wolf1_health <= 0) then
            ent_wolf1_x = math.random(4000, 5000);
            ent_wolf1_health = 1;
            ent_wolf1_speed = math.random(350, 500);
        else
            local x, _, reached = vector.moveTowards(ent_wolf1_x, 0, ent_player_x, 0, ent_wolf1_speed * deltaTime);
            if (reached) then
                ent_player_health = ent_player_health - ent_wolf1_damage * deltaTime;
            end
            ent_wolf1_x = x;
        end
    else
        ent_player_x = ent_player_x - 200 * deltaTime;
        ent_player_r = ent_player_r - 8 * deltaTime;

        if(layer_hud_splashIndex == 9) then
            layer_hud_splashIndex = 10;

            love.mouse.setGrabbed(false);
            easterEggSprite = love.graphics.newImage("sprites/nggyu.png");
            easterEggSound = love.audio.newSource("sounds/nggyu.ogg", "stream");
            easterEggSound:setLooping(true);
            easterEggSound:setVolume(.2);
            easterEggSound:play();
        end

        if (scene_gameTime >= -level_mainMenu_transitionDuration) then
            scene_gameTime = scene_gameTime + deltaTime;

            local startX = -150;
            local endX = 80;
            ent_player_x = math.lerp(startX, endX, 1 - (scene_gameTime / -level_mainMenu_transitionDuration));
            ent_player_r = 0;

            if (scene_gameTime >= 0) then
                -- GAME START

                scene_updated = true;
                scene_level = math.abs(scene_level);
                if (scene_level == 0) then
                    scene_level = 2;
                end

                ent_player_x = endX;
                ent_player_r = 0;
            end
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1, 1);

    if(layer_hud_splashIndex == 10) then
        local neverGonnaGiveYouUpFrame = (scene_time * 12) % 81;
        local easterEggWidth, easterEggHeight = easterEggSprite:getDimensions();
        local easterEggX = math.floor(neverGonnaGiveYouUpFrame % 9) * scene_width;
        local easterEggY = math.floor(neverGonnaGiveYouUpFrame / 9) * scene_height;
        local easterEggQuad = love.graphics.newQuad(easterEggX, easterEggY, scene_width, scene_height, easterEggWidth, easterEggHeight);
        love.graphics.draw(easterEggSprite, easterEggQuad, 0, 0);

        local splashText = "GET RICKROLLED";
        local splashWidth = layer_hud_large_font:getWidth(splashText);
        local splashHeight = layer_hud_large_font:getHeight();
        local splashScale = .6 + ((math.sin(scene_time * 4) + 1) / 2) * .4;
        local splashAngle = math.cos(scene_time * 4) * .2;
        love.graphics.setColor(1, 1, 0);
        love.graphics.print(splashText, layer_hud_large_font, scene_width / 2, scene_height * .75, splashAngle, splashScale, splashScale, splashWidth / 2, splashHeight / 2);
        love.graphics.setColor(1, 1, 1);
        return;
    end

    -- Layer SKY
    local skyWidth, skyHeight = layer_sky_sprite:getDimensions();
    love.graphics.draw(layer_sky_sprite, 0, 0, 0, scene_width / skyWidth, scene_height / skyHeight);

    local scrollingSpeed = 100;

    -- Layer BACKGROUND
    local backgroundWidth, backgroundHeight = layer_background_sprite:getDimensions();
    local backgroundScale = scene_height / backgroundHeight;
    local backgroundScrolling = -((scene_time * scrollingSpeed * .5) % (backgroundWidth * backgroundScale));
    love.graphics.draw(layer_background_sprite, backgroundScrolling, 0, 0, backgroundScale, backgroundScale);
    love.graphics.draw(layer_background_sprite, backgroundScrolling + (backgroundWidth * backgroundScale), 0, 0, backgroundScale, backgroundScale);

    -- Layer FOREGROUND
    local foregroundWidth, foregroundHeight = layer_ground_sprite:getDimensions();
    local foregroundScale = scene_height / foregroundHeight;
    local foregroundScrolling = -((scene_time * scrollingSpeed) % (foregroundWidth * foregroundScale));
    love.graphics.draw(layer_ground_sprite, foregroundScrolling, 0, 0, foregroundScale, foregroundScale);
    love.graphics.draw(layer_ground_sprite, foregroundScrolling + (foregroundWidth * foregroundScale), 0, 0, foregroundScale, foregroundScale);

    -- PLAYER
    local playerFrameQuad = entity_player_frame_walk1;
    if (ent_player_shootTime > 0) then
        if (ent_player_shootTime > ent_player_shootDuration / 2) then
            playerFrameQuad = entity_player_frame_shoot1;
        else
            playerFrameQuad = entity_player_frame_shoot2;
        end
    else
        local frameIndex = math.floor((scene_time * 5) % 4);
        if (frameIndex == 1) then
            playerFrameQuad = entity_player_frame_walk2;
        elseif (frameIndex == 2) then
            playerFrameQuad = entity_player_frame_walk3;
        elseif (frameIndex == 3) then
            playerFrameQuad = entity_player_frame_walk4;
        else
            playerFrameQuad = entity_player_frame_walk1;
        end
    end
    love.graphics.draw(entity_player_sprite, playerFrameQuad, ent_player_x, ent_player_y, ent_player_r, 1, 1, 64, 48);

    if (scene_level > 0 and scene_updated == false) then
        -- BAT1
        math.randomseed(ent_bat1_seed)
        for _ = 1, ent_bat1_health do
            local xOff = math.random(0, ent_bat1_width - 64);
            local yOff = math.random(0, ent_bat1_height - 64);
            local frameIndex = math.floor((scene_time * 5 + math.random()) % 6);
            local frameQuad = entity_bat_frame1;
            if (frameIndex == 1) then
                frameQuad = entity_bat_frame2;
            elseif (frameIndex == 2) then
                frameQuad = entity_bat_frame3;
            elseif (frameIndex == 3) then
                frameQuad = entity_bat_frame4;
            elseif (frameIndex == 4) then
                frameQuad = entity_bat_frame5;
            end

            local angle = math.atan(ent_player_x - ent_bat1_x, ent_player_y - ent_bat1_y) / 2;
            love.graphics.draw(entity_bat_sprite, frameQuad, ent_bat1_x + xOff, ent_bat1_y + yOff, angle, 1, 1, 64 / 2, 64 / 2)
        end

        -- BAT2
        math.randomseed(ent_bat2_seed)
        for _ = 1, ent_bat2_health do
            local xOff = math.random(0, ent_bat2_width - 64);
            local yOff = math.random(0, ent_bat2_height - 64);
            local frameIndex = math.floor((scene_time * 5 + math.random()) % 6);
            local frameQuad = entity_bat_frame1;
            if (frameIndex == 1) then
                frameQuad = entity_bat_frame2;
            elseif (frameIndex == 2) then
                frameQuad = entity_bat_frame3;
            elseif (frameIndex == 3) then
                frameQuad = entity_bat_frame4;
            elseif (frameIndex == 4) then
                frameQuad = entity_bat_frame5;
            end

            local angle = math.atan(ent_player_x - ent_bat2_x, ent_player_y - ent_bat2_y) / 2;
            love.graphics.draw(entity_bat_sprite, frameQuad, ent_bat2_x + xOff, ent_bat2_y + yOff, angle, 1, 1, 64 / 2, 64 / 2)
        end

        -- WOLF
        local wolfFrameQuad = entity_wolf_frame1;
        local wolfFrameIndex = math.floor((scene_time * 5) % 4);
        if (wolfFrameIndex == 1) then
            wolfFrameQuad = entity_wolf_frame2;
        elseif (wolfFrameIndex == 2) then
            wolfFrameQuad = entity_wolf_frame3;
        elseif (wolfFrameIndex == 3) then
            wolfFrameQuad = entity_wolf_frame4;
        else
            wolfFrameQuad = entity_wolf_frame5;
        end
        love.graphics.draw(entity_wolf_sprite, wolfFrameQuad, ent_wolf1_x, ent_wolf1_y)

        -- HUD
        love.graphics.setColor(1, 1, 1, 1);
        love.graphics.rectangle("fill", 10, 10, 128, 24);
        love.graphics.setColor(0, 0, 0, 1);
        love.graphics.rectangle("fill", 12, 12, 124, 20);
        love.graphics.setColor(0, 0, 0, 1);
        love.graphics.rectangle("fill", 12, 12, 124, 20);
        love.graphics.setColor(1, 0, 0, 1);
        love.graphics.rectangle("fill", 12, 12, 124 * (ent_player_health / 3), 20);

        local scoreMessage = "SCORE " .. math.floor(ent_player_score);
        local scoreMessageWidth = layer_hud_small_font:getWidth(scoreMessage);
        love.graphics.setColor(1, 0, 0, 1);
        love.graphics.print(scoreMessage, layer_hud_small_font, scene_width - scoreMessageWidth - 10, 10);

        if (layer_hud_indicator_time > 0) then
            love.graphics.setColor(0, .6, 0, 1);
            local fontHeight = layer_hud_small_font:getHeight();
            local xOffset = layer_hud_small_font:getWidth("Score ");
            local yOffset = math.lerp(0, 10, layer_hud_indicator_time);
            love.graphics.print(layer_hud_indicator_score, layer_hud_small_font, scene_width - scoreMessageWidth - 10 + xOffset, fontHeight + yOffset);
        end
    else
        local halfWidth = scene_width / 2;
        local halfHeight = scene_height / 2;

        local _, _, logoWidth, logoHeight = layer_hud_logo:getViewport();
        local layer_hud_offset = 0;

        if (scene_gameTime >= -level_mainMenu_transitionDuration) then
            local normalizedTime = 1 - (scene_gameTime / -level_mainMenu_transitionDuration);
            layer_hud_offset = layer_hud_offset - math.lerp(0, scene_height * 2 / 3, normalizedTime);
        else
            layer_hud_offset = 0
        end
        love.graphics.draw(layer_hud_sprite, layer_hud_logo, halfWidth - logoWidth / 2, halfHeight - logoHeight + layer_hud_offset);

        local splashText = "UNDEFINED";
        if (layer_hud_splashIndex == 0) then
            splashText = "I'm more interactive than you think";
        elseif (layer_hud_splashIndex == 1) then
            splashText = "MADE WITH LOVE AND LÖVE";
        elseif (layer_hud_splashIndex == 2) then
            splashText = "BUT, WITHOUT FUNCTION™!";
        elseif (layer_hud_splashIndex == 3) then
            splashText = "NOR TABLE™!";
        elseif (layer_hud_splashIndex == 4) then
            splashText = "AT THE COST OF MORE BUGS!";
        elseif (layer_hud_splashIndex == 5) then
            splashText = "[...]";
        elseif (layer_hud_splashIndex == 6) then
            splashText = "*music intensifies*";
        elseif(layer_hud_splashIndex == 7) then
            splashText = "WE'RE NOT STRANGERS TO <U>LÖVE</u>,";
        elseif(layer_hud_splashIndex == 8) then
            splashText = "YOU KNOW THE RULES, AND SO DO I";
        end
        local splashWidth = layer_hud_small_font:getWidth(splashText);
        local splashHeight = layer_hud_small_font:getHeight();
        local splashScale = .8 + ((math.sin(scene_time * 4) + 1) / 2) * .2;
        love.graphics.setColor(1, 1, 0);
        love.graphics.print(splashText, layer_hud_small_font, halfWidth + 80, halfHeight - 60 + layer_hud_offset, -0.06981317, splashScale, splashScale, splashWidth / 2, splashHeight / 2);
        love.graphics.setColor(1, 1, 1);

        local _, _, buttonWidth, buttonHeight = layer_hud_button:getViewport();
        local fontHeight = layer_hud_large_font:getHeight();

        local layoutOffset = halfHeight + 40 - layer_hud_offset;

        if (ent_player_highScore > 0) then
            local highScoreMessage = "HIGH SCORE " .. ent_player_highScore;
            local deathMessageWidth = layer_hud_large_font:getWidth(highScoreMessage);
            love.graphics.print(highScoreMessage, layer_hud_large_font, halfWidth - deathMessageWidth / 2, halfHeight - fontHeight + layer_hud_offset);
        end

        local forestMessage = "FOREST";
        local forestMessageWidth = layer_hud_large_font:getWidth(forestMessage);
        love.graphics.draw(layer_hud_sprite, layer_hud_button, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2);
        love.graphics.print(forestMessage, layer_hud_large_font, halfWidth - forestMessageWidth / 2, layoutOffset - fontHeight / 2);

        layoutOffset = layoutOffset + buttonHeight + 20;
        local seaMessage = "SEA";
        local seaMessageWidth = layer_hud_large_font:getWidth(seaMessage);
        love.graphics.draw(layer_hud_sprite, layer_hud_button, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2);
        love.graphics.print(seaMessage, layer_hud_large_font, halfWidth - seaMessageWidth / 2, layoutOffset - fontHeight / 2);

        layoutOffset = layoutOffset + buttonHeight + 20;
        local quitMessage = "QUIT";
        local quitMessageWidth = layer_hud_large_font:getWidth(quitMessage);
        love.graphics.draw(layer_hud_sprite, layer_hud_button, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2);
        love.graphics.print(quitMessage, layer_hud_large_font, halfWidth - quitMessageWidth / 2, layoutOffset - fontHeight / 2);
    end
end

function love.mousepressed(x, y, button)
    if (button ~= 1 or layer_hud_splashIndex == 10) then
        return ;
    end

    if (scene_level > 0) then
        if (ent_player_shootTime <= 0) then
            ent_player_shootTime = ent_player_shootDuration;

            -- handle shooting
            if (physics.testRectangle(x, y, ent_wolf1_x, ent_wolf1_y, entity_wolf_width, entity_wolf_height)) then
                ent_wolf1_health = ent_wolf1_health - 1;
                ent_player_score = ent_player_score + 2000;

                layer_hud_indicator_time = 1;
                layer_hud_indicator_score = 20;
            elseif (physics.testRectangle(x, y, ent_bat1_x, ent_bat1_y, ent_bat1_width, ent_bat1_height)) then
                ent_bat1_health = ent_bat1_health - 1;
                ent_player_score = ent_player_score + 20;

                layer_hud_indicator_time = 1;
                layer_hud_indicator_score = 20;
            elseif (physics.testRectangle(x, y, ent_bat2_x, ent_bat2_y, ent_bat2_width, ent_bat2_height)) then
                ent_bat2_health = ent_bat2_health - 1;
                ent_player_score = ent_player_score + 20;

                layer_hud_indicator_time = 1;
                layer_hud_indicator_score = 20;
            end
        end
    else
        local halfWidth = scene_width / 2;
        local halfHeight = scene_height / 2;

        local _, _, buttonWidth, buttonHeight = layer_hud_button:getViewport();
        local layoutOffset = halfHeight + 40;

        -- dont you dare look at this
        if (physics.testRectangle(x, y, 0, halfHeight - 80, scene_width, 50)) then
            layer_hud_splashIndex = layer_hud_splashIndex + 1;
        end

        if (physics.testRectangle(x, y, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2, buttonWidth, buttonHeight)) then
            scene_level = -1;
            scene_gameTime = -level_mainMenu_transitionDuration;
        end

        layoutOffset = layoutOffset + buttonHeight + 20;
        if (physics.testRectangle(x, y, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2, buttonWidth, buttonHeight)) then
            scene_level = -2;
            scene_gameTime = -level_mainMenu_transitionDuration;
        end

        layoutOffset = layoutOffset + buttonHeight + 20;
        if (physics.testRectangle(x, y, halfWidth - buttonWidth / 2, layoutOffset - buttonHeight / 2, buttonWidth, buttonHeight)) then
            love.event.quit(0);
        end
    end
end

function math.lerp(a, b, t)
    return (1 - t) * a + t * b
end
