pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

--constants

playerheight = 7
mapheight = 120

jumpvel = -2.71
gravity = .25

leveldialog={
    --{male dialog, female dialog}
    {{},{"sometimes i feel like","there's someone out", "there for me"}},
    {{"i wonder what it feels like", "to have a connection", "with someone..."},{}},
    {{},{"i wonder whats behind","these doors..."}},
    {{"now that i think about it,", "sometimes i do feel","like i'm connected"},{}},
    {{},{"perhaps if i just go", "through the doors", "i'll find the one"}},
    {{"theres no doubt now,","i have a connection with someone","across time and space!"},{}},
    {{},{"i almost can't believe it:","with every door i go through,","i'm getting closer to love!"}},
    {{"i have to know:","who is this person?","who shares this cosmic","bond with me?"},{}},
    {{},{"i can feel our energies","intertwining, our bond", "must be getting stronger"}},
    {{"is this floating feeling","what love feels like?"},{}},
    {{},{"sometimes i feel like","i run into a wall.", "is this what falling in love","feels like?"}},
    {{"we're getting close,", "i can sense it..."},{}},
    {{},{"the anticipation is so intense","i can hardly bear it!"}},
    {{},{}},
}

topplayer={
    x=0,
    y=48,
    v=0,
    spritestand = 14,
    spritejump = 15,
    spriterun = 16,
    spritecurrent = 14,
    spritedir = 1,
    framenum = 0,
    running=false
}

botplayer={
    x=0,
    y=48,
    v=0,
    spritestand = 26,
    spritejump = 27,
    spriterun = 28,
    spritecurrent = 26,
    spritedir = 1,
    framenum = 0,
    running=false
}

level={
    x=0,
    y=0,
    levelnum=1,
    linked=false,
    state="m"
}

function centertext(text, y, color)
    print(text, 64-#text*2, y, color)
end

function postosprtop(x,y)
    return mget(level.x + flr(x/8), level.y + flr(y/8))
end

function postosprbot(x,y)
    return mget(level.x + flr(x/8), level.y + 14 - flr(y/8))
end

function getcorners(player) 
    return {{player.x + 2,   flr(player.y + 1)},
            {player.x + 5,   flr(player.y + 1)},
            {player.x + 2,   ceil(player.y + 7)},
            {player.x + 5,   ceil(player.y + 7)}}
end

function validlocation(x, y, isbot)
    if(x < 0 or x >= mapheight) then
        return false
    end
    if (y < 0 or y >= mapheight) then
        return false
    end
    if (isbot) then 
        solidsprite = fget(postosprbot(x,y),0)
        if (solidsprite) then
            return false
        end
    else
        solidsprite = fget(postosprtop(x,y),0)
        if (solidsprite) then
            return false
        end
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
        if (not validlocation(topcorners[i][1], topcorners[i][2], false)) then
            validtop = false
        end
        if (not validlocation(botcorners[i][1], botcorners[i][2], true)) then
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
    disttop = topplayer.v
    distbot = botplayer.v

    for i = 1,4 do
        if (not validlocation(topcorners[i][1], topcorners[i][2], false)) then
            if (topplayer.v < 0) then --upward
                edge = flr(topcorners[i][2] / 8) * 8
                disttop = edge + playerheight - topplayer.y 
                
            else --downward
                edge = flr(topcorners[i][2] / 8) * 8 - 8
                disttop = edge - topplayer.y
            end
        end
        if (not validlocation(botcorners[i][1], botcorners[i][2], true)) then
            if (botplayer.v < 0) then --upward
                edge = flr(botcorners[i][2] / 8) * 8
                distbot = edge + playerheight - botplayer.y 

            else --downward
                edge = flr(botcorners[i][2] / 8) * 8 - 8
                distbot = edge - botplayer.y
            end
        end
    end

    if(level.linked) then
        if (abs(disttop) < abs(distbot)) then

            distbot = disttop
        else
            disttop = distbot
        end
    end

    topplayer.y += disttop
    botplayer.y += distbot


    if (disttop < topplayer.v) then --hit ground
        topplayer.v = 0
    elseif (disttop > topplayer.v) then --bounce off of ceiling
        topplayer.v = .1
    end
    if (distbot < botplayer.v) then --hit ground
        botplayer.v = 0
    elseif (distbot > botplayer.v) then --bounce oof of ceiling
        botplayer.v = .1
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
        if (fget(postosprtop(topcorners[i][1], topcorners[i][2]), 1)) then
            resetlevel()
        end
        if (fget(postosprbot(botcorners[i][1], botcorners[i][2]), 1)) then
            resetlevel()
        end
    end
end


function checkexit()
    if fget(postosprtop(topplayer.x + 4, topplayer.y + 4),2) then
        if fget(postosprbot(botplayer.x + 4, botplayer.y + 4),2) then
            level.levelnum+=1
            level.x += 15
            if (level.x >= 120) then
                level.x -= 120
                level.y += 15
            end
            resetlevel()
        end
    end
end

function drawtext(text)
    y = 8
    for i=1,#text[1] do
        centertext(text[1][i], y, 8)
        y+=6
    end
    y = 110
    for i=#text[2],1,-1 do
        centertext(text[2][i], y, 8)
        y-=6
    end

end

function _update()
    if (level.state == "m") then
        if(btn(5)) then
            level.state = "g"
            level.x=0
            level.y=0
            level.levelnum=1
            level.linked=false
        end
    elseif (level.state == "g") then
        checkspikes()
        checkexit()
        
        --reset button
        if (btnp(4)) then
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


        --controls
        if(btn(0)) then
            moveplayersx(-1)
        end
        if(btn(1)) then
            moveplayersx(1)
        end

        if (btnp(5)) then
            level.linked = not level.linked
            if (level.linked) then
                topplayer.v = (topplayer.v + botplayer.v)/2
                botplayer.v = topplayer.v
            end
        end

        --gravity
        topplayer.v += gravity
        botplayer.v += gravity

        moveplayersy()
    end
end

function _draw()
    if (level.state == "m") then
        rectfill(0,0,127,127,0)
        print("tHE", 58, 20, 3)
        print("oNE", 58, 30, 3)

        print("press x to start", 32, 100, 3)
    elseif (level.state == "g") then
        --draw base color
        if (level.linked) then
            rectfill(0,0,127,127,11)
        else
            rectfill(0,0,127,127,7)
        end
        rectfill(4,4,123,123,0)


        --draw map
        map(level.x,level.y,4,4,15,15)

        --draw text
        drawtext(leveldialog[level.levelnum])


        --draw players
        if (btn(0) and not btn(1)) then
            topplayer.spritedir = -1
            botplayer.spritedir = -1
        elseif (btn(1) and not btn(0)) then
            topplayer.spritedir = 1
            botplayer.spritedir = -1
        end
        if (topplayer.v != 0) then
            topplayer.spritecurrent = topplayer.spritejump
        elseif (btn(0) and not btn(1)) then
            topplayer.framenum +=1
            topplayer.framenum %= 20
            topplayer.spritecurrent = topplayer.spriterun + flr(topplayer.framenum/5)
        elseif (btn(1) and not btn(0)) then
            topplayer.framenum +=1
            topplayer.framenum %= 20
            topplayer.spritecurrent = topplayer.spriterun  + flr(topplayer.framenum/5)
        else
            topplayer.spritecurrent = topplayer.spritestand
            topplayer.framenum = 0
        end

        if (botplayer.v != 0) then
            botplayer.spritecurrent = botplayer.spritejump
        elseif (btn(0) and not btn(1)) then
            botplayer.framenum +=1
            botplayer.framenum %= 20
            botplayer.spritecurrent = botplayer.spriterun + flr(botplayer.framenum/5)
        elseif (btn(1) and not btn(0)) then
            botplayer.framenum +=1
            botplayer.framenum %= 20
            botplayer.spritecurrent = botplayer.spriterun  + flr(botplayer.framenum/5)
        else
            botplayer.spritecurrent = botplayer.spritestand
            botplayer.framenum = 0
        end

        if (topplayer.spritedir == 1) then
            spr(topplayer.spritecurrent, topplayer.x + 4, topplayer.y + 4, 1, 1, false, false) 
        else
            spr(topplayer.spritecurrent, topplayer.x + 4, topplayer.y + 4, 1, 1, true, false) 
        end

        if (topplayer.spritedir == 1) then
            spr(botplayer.spritecurrent, botplayer.x + 4, mapheight - botplayer.y - 4, 1, 1, false, true)
        else
            spr(botplayer.spritecurrent, botplayer.x + 4, mapheight - botplayer.y - 4, 1, 1, true, true)
        end

        -- print("bot y :", 0, 0, 14)
        -- print(botplayer.y, 30, 0)
        -- print("top y :", 0, 8, 14)
        -- print(topplayer.y, 30, 8)
    end

end
__gfx__
00000000000000000000000000000000000000000444440000000000044444000000000000444440000000000044444000000000004444400005555000555555
00000000000000000444440004444400044444000447770004444400044777000044444000477700004444400047770000444440004777000055555000577755
00000000000000000447770004477700044777000475750004477700047575000047770000757500004777000075750000477700007575000057770000757500
00000000000000000475750004757500047575000477770004757500047777000075750000777700007575000077770000757500007777000075750000777700
000000000000000004777700047777000477770006ccc0000477770000c6c0000077770006999000007777000699900000777700009690000077770006ccc000
0000000000000000006cc00006ccc000006cc00000ccc600006cc00000ccc000006996000099960000699000009996000069900000999000006cc00000ccc600
000000000000000000ccc00000ccc60000ccc0000060000000ccc0000600600000999000060000000099900000600000009990000600600000ccc00006000000
00000000000000000060600006000000006060000000000000606000000000000060600000000000006060000000000000606000000000000060600000000000
00055550005555550005555000555555000bbb0000bbbbb0000bbb0000bbbbb0000bbb0000bbbbb0009999000999999000999900099999900099990009999990
0055555000577755005555500057775500bbbb000067770000bbbb000067770000bbbb0000677700099999909997779009999990999777900999999099977790
00577700007575000057770000757500006777000075750000677700007575000067770000757500999777909975759099977790997575909997779099757509
00757500007777000075750000777700007575000077770000757500007777000075750000777700997575099977770999757509997777099975750999777700
0077770006ccc0000077770000c6c000007777000655500000777700065550000077770000565000997777000622200099777700062220000977770009262000
006cc00000ccc600006cc00000ccc000006550000055560000655000005556000065500000555000096220009022260009622000902226009062200090222000
00ccc0000060000000ccc00006006000005550000600000000555000006000000055500006006000902220000600000090222000006000000022200006006000
00606000000000000060600000000000006060000000000000606000000000000060600000000000006060000000000000606000000000000060600000000000
00000000011111000000000001111100000000000111110000000000000000000000000008888800000000000888880003333000039333000333300003933300
01111100011777000111110001177700011111000117770008888800088888000888880088877780088888008887778033933300393777003393330039377700
01177700017575000117770001757500011777000175750088877780888777808887778088757580888777808875758039377700337575003937770033757500
01757500017777000175750001777700017575000177770088757580887575808875758088777700887575808877770033757500037777003375750003777700
0177770016eee0000177770016eee0000177770011e6e00088777700887777008877770006ddd0008877770000d6d00003777700069990000377770006999000
116ee00011eee600116ee00011eee600116ee00011eee000006dd00006ddd000006dd00000ddd600006dd00000ddd00000699000009996000069900000999600
11eee0000600000011eee0001160000011eee0001600600000ddd00000ddd60000ddd0000060000000ddd0000600600000999000060000000099900000600000
00606000000000000060600000000000006060000000000000606000060000000060600000000000006060000000000000606000000000000060600000000000
03333000039333000001010000111100000101000011110000010100001111000000550000555500000055000055550000005500005555000000000000000000
33933300393777000011110000111100001111000011110000111100001111000055550000577700005555000057770000555500005777000000000000000000
39377700337575000011110000171700001111000017170000111100001717000057770000757500005777000075750000577700007575000000000000000000
33757500337777000017170000555500001717000055550000171700005555000075750000777700007575000077770000757500007777000000000000000000
03777700039690000055550001155000005555000155500000555500015150000077770006ccc0000077770006ccc0000077770008c6c0000000000000000000
0069900000999000011550001155510001155000115551000115500011555000086cc00088caa600086cc00088caa600086cc00088caa0000000000000000000
009990000600600011555000010000001155500000100000115550000100100088caa0008600000088caa0008060000088caa000860060000000000000000000
00606000000000000010100000000000001010000000000000101000000000000060600000000000006060000000000000606000000000000000000000000000
00000000000000009999799999979999cccccccccccccccc00700770333333307777777700000000000000000000000000000000000000000000000000000000
00000000000000009999799999979999cccccccccccccccc00700770333333307777777700000000000000000000000000000000000000000000000000000000
00000000000000009977799999977799cccccccccccccccc07700770333333307777777700000000000000000000000000000000000000000000000000000000
00000000000000009979977777799799cccccccccccccccc0777077033333a307777777700000000000000000000000000000000000000000000000000000000
00000000000000009979979999799799cccccccccccccccc07770777333333307777777700000000000000000000000000000000000000000000000000000000
00000000000000009977779999777799cccccccccccccccc77777777333333307707707000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999cccccccccccccccc77777777333333307707007000000000000000000000000000000000000000000000000000000000
00000000000000009999999999999999cccccccccccccccc77777777333333300707007000000000000000000000000000000000000000000000000000000000
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
__gff__
0000000000010402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010102040201010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004700000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056565600000000000000000000000000000000000000565600000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000470000000000000000000000000000000000000000000000000000000000470000000000000000560000000000000000000000000000000000000000000000565600000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000005500005555000055555555550000005500000000005500000000000000000000005555555555555555550000000000005600000000000000000000000055000000000000000000000000565600000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000555500000000000055555555550000555500000000005555000000000000000000005555555555555555550000000056000000000000000000000000000000005500000000000000000000565600000000000000000000000000000000000000
0000000000000000000000000000470000000000460000000000000000470055555500000000000055555555550055555500000000005555550000470000000000005555555555555555550000560000000000000000000000000000000000550000000000000000470000000000000000000000000000470000000000000000
5555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555550000000000000000
0000000000000000000000000000470000000000480000000000000000470055555500000000000055555555550000000055555555550000000000470000000000005555555555555555550000560000000000000000000000000000000000550000000000000000470000000000004848484848000000470000000000000000
0000000000000000000000000000000000000000000000000000000000000000555500000000000055555555550000000055555555550000000000000000000000000055555555555555550000000056000000000000000000000000000000550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000005500005555000055555555550000000055555555550000000000000000000000000000555555555555550000000000005600000000000000000000000000550000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000470000000000000000000000000000000000000000000000000000000000470000000000000000560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000056565600000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004700000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000000000000000050000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000460000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000004600005656565600005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004600004600004600004600470000565656000000000000005600470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5656565656565656565656565656565656565656565656565656565656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004800004800004800004800470000565656000000005656000000470000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000056565600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0500000000000000000000000000050000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
