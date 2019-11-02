pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--constants
solidsprite = 5
exitsprite = 6
spikesprite = 7

mapheight = 120 --119?

jumpvel = -2.21
gravity = .15

topplayer={
    x=0,
    y=48,
    v=0
}

botplayer={
    x=0,
    y=48,
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
    return {{player.x + 2,   player.y + 2},
            {player.x + 5,   player.y + 2},
            {player.x + 2,   player.y + 7},
            {player.x + 5,   player.y + 7}}
end

function validlocation(x, y)
    if(x < 0 or x >= mapheight) then
        return false
    end
    if (y < 0 or y >= mapheight) then
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
    topcorners = getcorners(topplayer)
    botcorners = getcorners(botplayer)
    for i = 1,4 do
        if (not validlocation(topcorners[i][1], topcorners[i][2])) then
            validtop = false
        end
        if (not validlocation(botcorners[i][1], mapheight - botcorners[i][2])) then
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
    topplayer.y += topplayer.v
    botplayer.y += botplayer.v
    topcorners = getcorners(topplayer)
    botcorners = getcorners(botplayer)
    topplayer.y -= topplayer.v
    botplayer.y -= botplayer.v
    fracttop = 1

    fractbot = 1
    for i = 1,4 do
        if (not validlocation(topcorners[i][1], topcorners[i][2])) then
            if (topplayer.v < 0) then --upward
                edge = flr(topcorners[i][2]/8)*8 + 7
                fracttop = min(fracttop, topplayer.v/(edge-topcorners[i][2]-topplayer.v))
            else --downward
                edge = flr(topcorners[i][2]/8)*8
                fracttop = min(fracttop, topplayer.v/(edge-topcorners[i][2]-topplayer.v))
            end
        end
        if (not validlocation(botcorners[i][1], mapheight - botcorners[i][2])) then
            if (botplayer.v < 0) then --upward
                edge = flr(botcorners[i][2]/8)*8 + 7
                fractbot = min(fracttop, botplayer.v/(edge-botcorners[i][2]-botplayer.v))
            else --downward
                edge = flr(botcorners[i][2]/8)*8
                fractbot = min(fractbot, botplayer.v/(edge-botcorners[i][2]-botplayer.v))
            end
        end
    end

    if(level.linked) then
        fracttop = min(fractbot, fracttop)
        fractbot = fracttop
    end

    topplayer.y += topplayer.v * fracttop
    botplayer.y += botplayer.v * fractbot


    if (fracttop < 1) then
        topplayer.v = 0
        topplayer.y = ceil(topplayer.y)
    end
    if (fractbot < 1) then
        botplayer.v = 0
        botplayer.y = ceil(botplayer.y)
    end
end

function resetlevel()
    topplayer.x = 0
    topplayer.y = 48
    topplayer.v = 0
    botplayer.x = 0
    botplayer.y = 48
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
        if (postospr(botcorners[i][1], mapheight - botcorners[i][2]) == spikesprite) then
            resetlevel()
        end
    end
end


function checkexit()
    if (postospr(topplayer.x + 4, topplayer.y + 4) == exitsprite) then
        if (postospr(botplayer.x + 4, mapheight - (botplayer.y + 4)) == exitsprite) then
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
    spr(2, botplayer.x + 4, mapheight - botplayer.y - 3, 1, 1, false, true)
end
__gfx__
0000000000000000000bbb007777777766666666999999993333333111111a117777777777777777777777777777777777777777777777775555555500000000
000000000888880000bbbb007777777766666666999999993333333119111a9166666666ffffffff77777777777777777777777777777777aa0dd0ee00000000
007007000887778000677700aaaaaaaacccccccc99999999333333311911999166666666ffffffff6666666666666666ffffffff66666666aa0dd0ee00000000
000770008875758000757500bbbbbbbbcccccccc77779997333333311991999166666666ffffffff6666666666666666ffffffff66666666aa0dd0ee00000000
00077000887777000077770033333333ddddddddccc777773333303188919898ddddddddeeeeeeee111111113333333399999999cccccccc0000000000000000
00700700006dd0000065500033333333ddddddddcccccccc3333333188889888ddddddddeeeeeeee111111113333333399999999cccccccc8803302200000000
0000000000ddd000005550005555555555555555cccccccc3333333188888888ddddddddeeeeeeee555555555555555544444444111111118803302200000000
0000000000606000006060005555555555555555cccccccc33333331cccccccc5555555555555555555555555555555544444444111111118803302200000000
111111110000000000000000033330000099990000000000000bbb00000555500000000000000000000000000000550000000000000000000000000000000000
55555555044444000111110033933300099999900044444000bbbb00005555500888880000229200005555000055550000000000000000000000000000000000
55555555044777000117770039377700999777900047770000677700005777000887778000222200005333000057770000000000000000000000000000000000
55555555047575000175750033757500997575090075750000757500007575008875758000212100003767000075750000000000000000000000000000000000
55555555047777000177770003777700997777000077770000777700007777008877770000222200003333000077770000000000000000000000000000000000
55555555006cc000116ee00000699000096220000069960000655000006cc000006dd0000052200005222500086cc00000000000000000000000000000000000
5555555500ccc00011eee0000099900090222000009990000055500000ccc00000ddd000002220000022200088caa00000000000000000000000000000000000
44444444006060000060600000606000006060000060600000606000006060000060600000505000005050000060600000000000000000000000000000000000
00000000000008008000800011111a11a111a1114444474474447444999999990000222210001111444444441111111133333331000000000000000000000000
00000000080008808800880019111a919911a911474447c4cc447c44999999990000022200000111444444441111111133333331000000000000000000000000
00000000080088808800880819119991991199194c44ccc4cc447c4c9999999902cccc2201999911444444441111111133333331000000000000000000000000
00000000088088808808880819919991991999194cc4ccc4cc4ccc4c7777999702c77c2001977910444444441111111133333331000000000000000000000000
000000008880888888088808889198988919981811c4c1c11c4ccc41ccc7777722cc7c2011997910444444441111111133333031000000000000000000000000
000000008888888888888808888898888818981811c1c1c1114cc141cccccccc722ccc2001199910444444441111111133333331000000000000000000000000
00000000888888888888888888888888888888881111c1111111c111cccccccc7772222070111110444444441111111133333331000000000000000000000000
000000008888888888888888cccccccccccccccc1111111111111111cccccccc2272222277711111444444441111111133333331000000000000000000000000
00000000111111719999999999999999999999999999999999999999999979999997999999999999999999999997999999997999999999990000000000000000
00000000177111119999999999999999999999999999999999999999999979999997999999999999999999999997999999997999999999990000000000000000
000000001559999d9977779999777799997777999999999999999999999979999997999999777799997777999977779999777799999999990000000000000000
000000005559999d9979979999799799997997999999999977777777999979999997999999799799997997999979979999799799999999990000000000000000
0000000055dddddd9979977777799799997997997777777799999999999979999997999977799799997997779979979999799799999999990000000000000000
000000005ccccddd9977799999977799997777999999999999999999999979999997999999777799997777999977779999777799999999990000000000000000
00000000dccccddd9999799999979999999999999999999999999999999979999997999999999999999999999999999999999999999999990000000000000000
00000000dddddddd9999799999979999999999999999999999999999999979999997999999999999999999999999999999999999999999990000000000000000
00000000000000009999799999979999cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999799999979999cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009977799999977799cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009979977777799799cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009979979999799799cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009977779999777799cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999cccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000cccccccccccccccccccccccccccccccccccccccccccc6cccccc6ccccccccccccccccccccccc6cccccccc6ccccccccccc0000000000000000
0000000000000000cccccccccccccccccccccccccccccccccccccccccccc6cccccc6ccccccccccccccccccccccc6cccccccc6ccccccccccc0000000000000000
0000000000000000cc7777cccc7777cccc7777cccccccccccccccccccccc6cccccc6cccccc6666cccc6666cccc6666cccc6666cccccccccc0000000000000000
0000000000000000cc7cc7cccc7cc7cccc7cc7cccccccccc66666666cccc6cccccc6cccccc6cc6cccc6cc6cccc6cc6cccc6cc6cccccccccc0000000000000000
0000000000000000cc7cc777777cc7cccc7cc7cc66666666cccccccccccc6cccccc6cccc666cc6cccc6cc666cc6cc6cccc6cc6cccccccccc0000000000000000
0000000000000000cc777cccccc777cccc7777cccccccccccccccccccccc6cccccc6cccccc6666cccc6666cccc6666cccc6666cccccccccc0000000000000000
0000000000000000cccc7cccccc7cccccccccccccccccccccccccccccccc6cccccc6cccccccccccccccccccccccccccccccccccccccccccc0000000000000000
0000000000000000cccc7cccccc7cccccccccccccccccccccccccccccccc6cccccc6cccccccccccccccccccccccccccccccccccccccccccc0000000000000000
0000000000000000cccc7cccccc7cccc00000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
0000000000000000cccc7cccccc7cccc00000000000000000000000000000000000000000000000000000000cccccccccccccccc000000000000000000000000
0000000000000000cc777cccccc777cc00000000000000000000000000000000000000000000000000000000cc6666cccc6666cc000000000000000000000000
0000000000000000cc7cc777777cc7cc00000000000000000000000000000000000000000000000000000000cc6cc6cccc6cc6cc000000000000000000000000
0000000000000000cc7cc7cccc7cc7cc00000000000000000000000000000000000000000000000000000000cc6cc6cccc6cc6cc000000000000000000000000
0000000000000000cc7777cccc7777cc00000000000000000000000000000000000000000000000000000000cc6666cccc6666cc000000000000000000000000
0000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000ccc6cccccccc6ccc000000000000000000000000
0000000000000000cccccccccccccccc00000000000000000000000000000000000000000000000000000000ccc6cccccccc6ccc000000000000000000000000
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
