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
    {{"press the arrow keys to move"},{"i wonder whats behind","these doors..."}},
    {{"fire... curious"},{"press up to jump"}},
    {{"press z to reset"}, {"sometimes it's best","to start over"}},
    {{"i might need a little help this time"},{"press x to link"}},
    {{"x to unlink"},{"maybe linking isn't", "always helpful..."}},
    {{},{"sometimes i feel like","there's someone out", "there for me"}},
    {{"i wonder what it feels like", "to have a connection", "with someone..."},{}},
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


spritetop = 1
spritebot = 1
menuitem = 1

spriteids = {
    {25, 31, 37, 43}, --females
    {1, 7, 13, 19} --males
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
i = 1
carrott = {45, 55, 65}
carroti = {1,2,3}

function zspr(n,dx,dy,dz) --zoom sprite https://pico-8.fandom.com/wiki/Draw_zoomed_sprite_(zspr)
    sx = 8 * (n % 16)
    sy = 8 * flr(n / 16)
    dw = 8 * dz
    dh = 8 * dz
    sspr(sx,sy,8,8, dx,dy,dw,dh)
end

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
    for i=1,#text[2] do
        centertext(text[2][i], y, 8)
        y+=6
    end
    y = 110
    for i=#text[1],1,-1 do
        centertext(text[1][i], y, 8)
        y-=6
    end

end


function movecarrotdown()
   i += 1
   i %= 3
   if (i == 0) then
        i = 3
   end 
end

function movecarrotup()
    i -= 1
    i %= 3
    if (i == 0) then
        i = 3
    end 
end


function _update()
    if (level.state == "m") then
<<<<<<< HEAD
=======
        if (btnp(5)) then
            level.state = "c"
        end
    elseif (level.state == "c") then
>>>>>>> 3ba15aa64abd6871a38fcc9dacabf5cfb28b0680
        if(btnp(5)) then
            level.state = "g"
            level.x=0
            level.y=0
            level.levelnum=1
            level.linked=false
            topplayer.spritestand = spriteids[1][spritetop]
            topplayer.spritejump = topplayer.spritestand + 1
            topplayer.spriterun = topplayer.spritestand + 2
            topplayer.spritecurrent = topplayer.spritestand
            botplayer.spritestand = spriteids[2][spritebot]
            botplayer.spritejump = botplayer.spritestand + 1
            botplayer.spriterun = botplayer.spritestand + 2
            botplayer.spritecurrent = botplayer.spritestand

        end
        if (btnp(2)) then
            if(menuitem == 1) then
                spritetop +=1
                spritetop %= #spriteids[1]
                if (spritetop == 0) then
                    spritetop = #spriteids[1]
                end
                
            elseif(menuitem == 2) then
                spritebot +=1
                spritebot %= #spriteids[2]
                if (spritebot == 0) then
                    spritebot = #spriteids[2]
                end
            end
        end
        if (btnp(3)) then
            if(menuitem == 1) then
                spritetop -=1
                spritetop %= #spriteids[1]
                if (spritetop == 0) then
                    spritetop = #spriteids[1]
                end
            elseif(menuitem == 2) then
                spritebot -=1
                spritebot %= #spriteids[2]
                if (spritebot == 0) then
                    spritebot = #spriteids[2]
                end
            end
        end

        if (btnp(0)) then --left
            if (menuitem == 1) then
                menuitem = 2
            else
                menuitem -= 1
            end
        end

        if (btnp(1)) then --right
            if (menuitem == 2) then
                menuitem = 1
            else
                menuitem += 1
            end
        end

    elseif (level.state == "p") then
        

        --resume game
        if (btnp(4)) then
            level.state = "g"
        end

        --move carrot down 
        if (btnp(3)) then
            movecarrotdown()
        end

        --move carrot up 
        if (btnp(2)) then
            movecarrotup()
        end

        if (btn(5))then 
            if (i == 1) then 
                resetlevel()
                level.state = "g"
            elseif (i == 2) then 
                level.state = "m"
            elseif (i == 3) then
                level.state = "g"
            end
        end

    

    elseif (level.state == "g") then
        checkspikes()
        checkexit()
        
        --pause menu
        if (btnp(4)) then
            level.state = "p"
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
    if (level.state == "m") then --main menu
        rectfill(0,0,127,127,0)
        print("tHE", 58, 20, 3)
        print("oNE", 58, 30, 3)

        print("press x to start", 32, 100, 3)

    elseif (level.state == "p") then --pause menu
        rectfill(15,15,112,112,0)
        rect(15,15,112,112,7)

        print("pause",58,30,7)
        
        print(">", 30, carrott[carroti[i]], 7 )

        print("i = ",16, 16, 14 )
        print(i,30, 16)

        print("reset", 40, 45, 7)
        print("menu", 40, 55, 7)
        print("continue", 40, 65, 7)

               
        
    elseif (level.state == "c") then --character selection
        rectfill(0,0,127,127,0)
        centertext("select characters:", 20, 8)
        
        rectfill(17,45,54,82,6)
        rectfill(19,47,52,80,0)
        zspr(spriteids[1][spritetop], 20, 48, 4)

        rectfill(73,45,110,82,6)
        rectfill(75,47,108,80,0)
        zspr(spriteids[2][spritebot], 76, 48, 4)

        if (menuitem == 1) then

        else

        end

        centertext("press x to start", 100, 8)
    elseif (level.state == "g") then --game loop
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
00000000000000000000000001111100000000000111110000000000000000000000000000ddddd00000000000ddddd000000000000555500005555000555555
0000000001111100011111000117770001111100011777000111110000ddddd000ddddd000d7770000ddddd000d7770000ddddd0005555500055555000577755
0070070001177700011777000175750001177700017575000117770000d7770000d777000075750000d777000075750000d77700005777000057770000757500
00077000017575000175750001777700017575000177770001757500007575000075750000777700007575000077770000757500007575000075750000777700
00077000017777000177770006ccc0000177770000c6c00001777700007777000077770006999000007777000096900000777700007777000077770006222000
00700700006cc00006ccc00000ccc600006cc00000ccc000006cc000006996000699900000999600006990000099900000699000006220000622200000222600
0000000000ccc00000ccc6000060000000ccc0000600600000ccc000009990000099960000600000009990000600600000999000002220000022260000600000
00000000006060000600000000000000006060000000000000606000006060000600000000000000006060000000000000606000006060000600000000000000
000555500055555500055550000bbb00000bbb0000bbbbb0000bbb0000bbbbb0000bbb0000999900009999000999999000999900099999900099990000000000
00555550005777550055555000bbbb0000bbbb000067770000bbbb000067770000bbbb0009999990099999909997779009999990999777900999999002222200
00577700007575000057770000677700006777000075750000677700007575000067770099977790999777909975759099977790997575099997779002277700
00757500007777000075750000757500007575000077770000757500007777000075750099757509997575099977770999757509997777009975750902757500
00777700002620000077770000777700007777000655500000777700005650000077770099777700997777000622200099777700092620000977770002777700
006220000022200000622000006550000655500000555600006550000055500000655000096220000622200090222600096220009022200090622000226ee000
00222000060060000022200000555000005556000060000000555000060060000055500090222000902226000060000090222000060060000022200022eee000
00606000000000000060600000606000060000000000000000606000000000000060600000606000060000000000000000606000000000000060600000606000
00000000022222000000000002222200000000000000000000000000088888000000000008888800000000000333300003333000039333000333300003933300
02222200022777000222220002277700022222000888880008888800888777800888880088877780088888003393330033933300393777003393330039377700
02277700027575000227770002757500022777008887778088877780887575808887778088757580888777803937770039377700337575003937770033757500
02757500027777000275750002777700027575008875758088757580887777008875758088777700887575803375750033757500037777003375750033777700
0277770026eee0000277770022e6e00002777700887777008877770006ddd0008877770000d6d000887777000377770003777700069990000377770003969000
26eee00022eee600226ee00022eee000226ee000006dd00006ddd00000ddd600006dd00000ddd000006dd0000069900006999000009996000069900000999000
22eee6002260000022eee0002600600022eee00000ddd00000ddd6000060000000ddd0000600600000ddd0000099900000999600006000000099900006006000
06000000000000000060600000000000006060000060600006000000000000000060600000000000006060000060600006000000000000000060600000000000
03333000000000000000000001010101010101010101111111111111111111111111111111111111444444444444444444444444454544444444444444444444
33933300005555000555550010101010101010101011111111111111111111111101111111111111444444444444444444444444545444444444444444444454
39377700005777000557770011110101010101010111111101111111111111111010111111111111444444444444444444444444454444444454444444445445
33757500007575000575750011111110101110101011111110111111111011111111111111111111444444444444444454444444544444444444444444444444
03777700007777000577770011111111111111110111111101111111111111111111111111111111444444454544454545444444454444444445444444444444
00699000006550000565500011111111111111111111111110111111110111111111011011111111444454545454545454444444544444444444444445454444
00999000005550000055500011111111111111111111111101011111111111111111110111111111454545454545454545444444444444444444444444544444
00606000006060000060600011111111111111111111111110101111111111111111111111111111545454545454545454544444444444444444444444444444
444444441cccccccccccccc11ccccccc1cccccccccccccc1ccccccc11cccccc11cccccc1ccc777cccc777ccc1cccccc11cccccc1cccccccccccccccccc7777cc
44444444ccccc7ccccccccccccccc77cccc77cccccc77cccccc77ccccc77cccccccc77cccc7777cccc7777ccccc77ccccccc7cccccccccc77ccc77cccc77777c
44444444ccc7777c7c777cccc777c777c7777777777777ccc77777cccc77777ccc7777cccc77777ccc7777cccc7777cccc7777cc77777c7777c77777ccc7777c
44444444cc777777777777cccc777777c7777777777777cc777777ccc777777cc777777cc777777cc777777cc77777ccc777777c7777777777777777cc77777c
44444444cc7777777777777ccc777777cc7777777777777c7777777ccc7777ccc777777ccc7777ccc777777cc777777ccc77777c7777777777777777cc7777cc
44444444c7777777777777cccc777777cc77777cc777777c7c77777ccc777ccccc7777cccc7777cccc7777cccc7777cccc7777cc77777777cc777c77c777777c
44444444cc77777c777777ccccc7ccccccc77ccccc77ccccccc77ccccc7777cccc777ccccc7ccccccc77ccccccc7ccccccc77ccc77ccc77ccccccccccc77777c
44444444cc7777cccc7777cc1ccccccc1cccccccccccccc1ccccccc1ccc777ccccc777cc1cccccc11cccccc11cccccc11cccccc1ccccccccccccccccccc777cc
cc777ccccc77777cc7777ccccc7777cccccccccccccccccc49999999999999944999999949999999999999949999999449999994499999949997779999777999
cc7777ccccc7777c777777ccc777777cc7ccccccccc77ccc99999799999999999977999999999779997799999997799999779999999977999977779999777799
cc7777cccc7777777777777c777777777777cc77cc7777c799977779797779999977797797779777777777997777779999777779997777999977777999777799
c77777ccc77777777777777c77777777777777777777777799777777777777999977777799777777777777997777779997777779977777799777777997777779
c777777cc7777777777777cc77777777777777777777777799777777777777799777777799777777777777997777777999777799977777799977779997777779
cc7777cccc7777cc7c777ccc77777777977777777777777997777777777777999777777999777777977777799777777999777999997777999977779999777799
c77777ccccc7ccccccccccccc777777c999779999977999999777779777777999997999999979999999799999977999999777799997779999979999999779999
c7777ccc1cccccccccccccc1ccc777cc999999999999999999777799997777994999999949999999999999949999999499977799999777994999999449999994
49999994499999949999999999999999997777999977799999777779977779999977779911111a11a111a1119999999999999999666666666666666666666666
99977999999979999999999779997799997777799977779999977779777777999777777919111a919911a911cccccccccccccccc633333366033333660033336
9977779999777799777779777797777799977779997777999977777777777779777777771911999199119919ccc6ccccccc6c4cc633333366033333660033336
9777779997777779777777777777777799777779977777999777777777777779777777771991999189199919c6c646ccc4c6646c633333366033333660033336
9777777999777779777777777777777799777799977777799777777777777799777777778891989889199818466646646466646c636333366036333660036336
99777799997777997777777799777977977777799977779999777799797779997777777788889888881898884666446464664466633333366033333660033336
99979999999779997799977999999999997777799777779999979999999999999777777988888888888888884674447444674466633333366033333660033336
499999944999999499999999999999999997779997777999499999999999999499977799cccccccccccccccc4474444444474447633333366033333660033336
66666666666666666333333660333336600333366000033660000036000000000000000000000000000000000000000000000000000000000000000000000000
60000336600000366333333660333336600333366000033660000036000000000000000000000000000000000000000000000000000000000000000000000000
60000336600000366333333660333336600333366000033660000036000700000000000000000000000000000000000000000000000000000000000000000000
60000336600000366363333660363336600363366000036660000036007070000000000000000000000000000000000000000000000000000000000000000000
60000366600000366333333660333336600333366000033660000036070007000000000000000000000000000000000000000000000000000000000000000000
60000336600000366333333660333336600333366000033660000036000000000000000000000000000000000000000000000000000000000000000000000000
60000336600000366333333660333336600333366000033660000036000000000000000000000000000000000000000000000000000000000000000000000000
60000336600000366666666666666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000000000000
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
