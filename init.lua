--[[

The MIT License (MIT)
Copyright (C) 2023 Acronymmk

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]

local function get_inventory_formspec(player_inv, player_name, own_inv, owner_name)
  local formspec = "size[8,11]" ..
  "label[0,0;" .. "# "..minetest.colorize("orange", player_name).."'s inventory" .. "]" ..
  "label[0,5;" .. "# "..minetest.colorize("orange", owner_name).."'s inventory" .. "]" ..
  "box[-0.1,-0.1;8,0.7;black]" ..
  "box[-0.1,4.9;8,0.7;black]" ..
  "button_exit[0,10;2,1;cancel;Cancel]"
  -- "listring[current_player;main]"

  for i = 1, player_inv:get_size("main") do
    local itemstack = player_inv:get_stack("main", i)
    local itemname = itemstack:get_name()
    local itemcount = itemstack:get_count()
    if itemcount > 1 then
      formspec = formspec .. "item_image_button[" .. (i-1)%8 .. "," .. math.floor((i-9)/8) + 1.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (i-1)%8+0.55 .. "," .. math.floor((i-9)/8) + 1.9 .. ";\n" .. itemcount .. "]"
    elseif itemcount == 1 then
      formspec = formspec .. "item_image_button[" .. (i-1)%8 .. "," .. math.floor((i-9)/8) + 1.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (i-1)%8+0.55 .. "," .. math.floor((i-9)/8) + 1.9 .. ";\n]"
    else
      formspec = formspec .. "item_image_button[" .. (i-1)%8 .. "," .. math.floor((i-9)/8) + 1.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (i-1)%8+0.55 .. "," .. math.floor((i-9)/8) + 1.9 .. ";\n]"
    end
  end

  for p = 1, own_inv:get_size("main") do
    local itemstack = own_inv:get_stack("main", p)
    local itemname = itemstack:get_name()
    local itemcount = itemstack:get_count()
    if itemcount > 1 then
      formspec = formspec .. "item_image_button[" .. (p-1)%8 .. "," .. math.floor((p+23)/8) + 2.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (p-1)%8+0.55 .. "," .. math.floor((p+23)/8) + 3.9 .. ";\n" .. itemcount .. "]"
    elseif itemcount == 1 then
      formspec = formspec .. "item_image_button[" .. (p-1)%8 .. "," .. math.floor((p+23)/8) + 2.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (p-1)%8+0.55 .. "," .. math.floor((p+23)/8) + 3.9 .. ";\n]"
    else
      formspec = formspec .. "item_image_button[" .. (p-1)%8 .. "," .. math.floor((p+23)/8) + 2.8 .. ";1,1;" .. itemname .. ";" .. itemcount .. ";]" ..
      "label[" .. (p-1)%8+0.55 .. "," .. math.floor((p+23)/8) + 3.9 .. ";\n]"
    end
  end
  return formspec
end

local function update_inventory_formspec(name, player_name)
  local player = minetest.get_player_by_name(player_name)
  local owner = minetest.get_player_by_name(name)
  if not player then
    return
  end
  local inv = player:get_inventory()
  local own_inv = owner:get_inventory()
  local owner_name = owner:get_player_name(name)
  local formspec = get_inventory_formspec(inv, player_name, own_inv, owner_name)
  minetest.show_formspec(name, "inv_inspector:main", formspec)
end

minetest.register_chatcommand("inv", {
  description = "View the main inventory of a player",
  params = "<playername>",
  func = function(name, param)
  local player = minetest.get_player_by_name(param)
  if player then
    update_inventory_formspec(name, param)
    local player_name = player:get_player_name()
    local timer = 0
    local stop_globalstep = false

    minetest.register_on_player_receive_fields(function(player, formname, fields)
      if formname == "inv_inspector:main" and fields.cancel then
        stop_globalstep = true
        minetest.close_formspec(player_name, "inv_inspector:main")
      end
    end)

    minetest.register_globalstep(function(dtime)
      if not stop_globalstep then
        timer = timer + dtime
        if timer >= 1 then
          update_inventory_formspec(name, player_name)
          timer = 0
        end
      end
    end)
  else
    minetest.chat_send_player(name, "Player " .. param .. " not found.")
  end
end
})
