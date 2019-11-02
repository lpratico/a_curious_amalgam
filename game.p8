pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--constants
solidsprite = 5
exitsprite = 6
spikesprite = 7


jumpvel = -2.21
gravity = .15

spriteheight = 8
spritewidth  = 8

topplayer={
    x=0,
    y=48,
    v=0
}

botplayer={
    x=0,
    y=64,
    v=0
}

level={
    x=0,
    y=0,
    linked=false
}

function postospr(x,y)
    return mget(level.x + x/8, level.y + y/8)
end

function getcorners(player) 
    return {{player.x,                  player.y},
            {player.x + spritewidth,    player.y},
            {player.x,                  player.y + spriteheight - 1},
            {player.x + spritewidth,    player.y + spriteheight - 1}}
end

function validlocation(x, y)
    if(x < 0 or x >= 120) then
        return false
    end
    if (y < 0 or y >= 120) then
        return false
    end
    if (postospr(x,y) == solidsprite) then
        return false
    end
    return true
end

function moveplayersx(x)
    validtop = true
    validbot = true
    topplayer.x += x
    botplayer.x += x
    if(topplayer.x < 0 or topplayer.x > 120) then
        validtop = false
    end
    topcorners = getcorners(topplayer)
    botcorners = getcorners(botplayer)
    for i = 1,4 do
        if (not validlocation(topcorners[i][1], topcorners[i][2])) then
            validtop = false
        end
        if (not validlocation(botcorners[i][1], botcorners[i][2])) then
            validbot = false
        end
    end
    if (not validtop or (not validbot and level.linked)) then
        topplayer.x -= x
    end
    if (not validbot or (not validtop and level.linked)) then
        botplayer.x -= x
    end
end

function moveplayersy()
    validtop = true
    validbot = true
    topplayer.y += topplayer.v
    botplayer.y -= botplayer.v
    topcorners = getcorners(topplayer)
    botcorners = getcorners(botplayer)
    for i = 1,4 do
        if (not validlocation(topcorners[i][1], topcorners[i][2])) then
            validtop = false
        end
        if (not validlocation(botcorners[i][1], botcorners[i][2])) then
            validbot = false
        end
    end
    if (not validtop or (not validbot and level.linked)) then
        topplayer.y -= topplayer.v
        topplayer.v = 0
    end
    if (not validbot or (not validtop and level.linked)) then
        botplayer.y += botplayer.v
        botplayer.v = 0
    end
end

function resetlevel()
    topplayer.x = 0
    topplayer.y = 48
    topplayer.v = 0
    botplayer.x = 0
    botplayer.y = 64
    botplayer.v = 0

    level.linked = false
    
end

function checkspikes()
    topcorners = getcorners(topplayer)
    botcorners = getcorners(botplayer)
    for i = 1,4 do
        if (postospr(topcorners[i][1], topcorners[i][2]) == spikesprite) then
            resetlevel()
        end
        if (postospr(botcorners[i][1], botcorners[i][2]) == spikesprite) then
            resetlevel()
        end
    end
end


--todo: switch to next map
function checkexit()
    if (postospr(topplayer.x+4, topplayer.y + 4) == exitsprite) then
        if (postospr(botplayer.x+4, botplayer.y + 4) == exitsprite) then
            level.x += 15
            if (level.x >= 120) then
                level.x -= 120
                level.y += 15
            end
            resetlevel()
        end
    end
end

function _update()
    checkspikes()
    checkexit()
    
    --reset button
    if (btnp(5)) then
        resetlevel()
    end


    --jump
    if (btn(2)) then
        if (topplayer.v == 0) then
            topplayer.v = jumpvel
        end
        if (botplayer.v == 0) then
            botplayer.v = jumpvel
        end
    end


    --gravity
    topplayer.v += gravity
    botplayer.v += gravity

    moveplayersy()


    --controls
    if(btn(0)) then
        moveplayersx(-1)
    end
    if(btn(1)) then
        moveplayersx(1)
    end
    if (btnp(4)) then
        level.linked = not level.linked
    end
end

function _draw()
    --draw base color
    if (level.linked) then
        rectfill(0,0,127,127,11)
    else
        rectfill(0,0,127,127,7)
    end
    rectfill(4,4,123,123,0)


    --draw map
    map(level.x,level.y,4,4,15,15)

    --draw players
    spr(1, topplayer.x + 4, topplayer.y + 4) 
    spr(2, botplayer.x + 4, botplayer.y + 4, 1, 1, false, true)
end
__gfx__
0000000080077708b0cc000b000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
00000000007007700ccccc00000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
00700700007707700c000cc0000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
00077000000777000cc000c0000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
000770000770707700cccc00000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
00700700007777700000c000000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
0000000000077700000ccc00000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
0000000080770778b0cc0ccb000000000000000033333333aaaaaaaa888888880000000000000000000000000000000000000000000000000000000000000000
__map__
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000060000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000500000505000005050505050000000500000000000500000000000000000000000505050505050505050000000000000500000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000050500000000000005050505050000050500000000000505000000000000000000000505050505050505050000000005000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000060000000000070000000000000000060005050500000000000005050505050005050500000000000505050000060000000000000505050505050505050000050000000000000000000000000000000000050000000000000000060000000000000000000000000000060000000000000000
0505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050000000000000000
0000000000000000000000000000060000000000070000000000000000060005050500000000000005050505050000000005050505050000000000060000000000000505050505050505050000050000000000000000000000000000000000050000000000000000060000000000000000000000000000060000000000000000
0000000000000000000000000000000000000000000000000000000000000000050500000000000005050505050000000005050505050000000000000000000000000005050505050505050000000005000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000500000505000005050505050000000005050505050000000000000000000000000000050505050505050000000000000500000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000060000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000070000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000700000505050500000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000700000700000700000700060000050505000000000000000500060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050505050505050505050505050505050505050505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000700000700000700000700060000050505000000000505000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000005050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
