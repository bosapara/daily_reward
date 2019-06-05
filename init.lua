modname = "daily_reward";

daily_reward = {}
daily_reward.time_left = 60*60*24 -- 24 hours before player can get new reward
daily_reward.new_player = 21*60*60 -- 3 hours time left tp first gift for new players

daily_reward.item_list = {
"default:diamondblock",
"default:goldblock",
"default:mese",
"default:bronzeblock",
"default:copperblock",
"default:tinblock",
"default:pick_diamond",
"default:pick_steel",
"default:pick_mese",
"default:sword_diamond",
"default:sword_mese",
"default:sword_steel",
"default:shovel_diamond",
"default:shovel_mese",
"default:shovel_steel",
"wool:red 10",
"farming:straw 10",
"default:obsidian 10"
}

--show time correct time 00:00:00
local function time_main(seconds)
  local seconds = tonumber(seconds)
  local hours, mins, secs
  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

minetest.register_chatcommand("gift", { 
	description = "Player can get reward once per day",
	privs = { interact = true },
	func = function(name, param)

		if not name then
		return ""
		end

		local player = minetest.get_player_by_name(name)
		local inv = player:get_inventory()
		local time_os = os.time()		
		local gift_time = player:get_attribute("gift_time") or 0
		local per = (time_os - gift_time)
		
		--local showtime = math.floor((86400 - (time_os - gift_time))/3600) .. " hours"
		local showtime = (daily_reward.time_left - (time_os - gift_time))
		
		if (per <= daily_reward.time_left) then
		
		minetest.chat_send_player(name, minetest.colorize("#ff5151", "<Mr.Bot> time until next reward: "..time_main(showtime)))
		elseif inv:room_for_item("main", {name=name, count=1}) then
		minetest.chat_send_player(name, minetest.colorize("#ff5151", "<Mr.Bot> "..name.. ", take your gift"))
		player:get_inventory():add_item('main', 'daily_reward:gift')
		local time_gift = minetest.get_gametime(player)
		player:set_attribute("gift_time", os.time())
		else
		minetest.chat_send_player(name, minetest.colorize("#ff5151", "<Mr.Bot> "..name.. ", your inventory is full"))
		end

		
	end
})

--prevent abuse with multi account
minetest.register_on_newplayer(function(player)
	local new_time = os.time() - daily_reward.new_player --3 hours to first gift for new players
	player:set_attribute("gift_time", new_time)
end)


--[[particles effect]]
local function particle_effect(pos)
	minetest.add_particlespawner({
		amount = 30,
		time = 2.5,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -1, y = 2, z = -1},
		maxvel = {x = 1, y = 4, z = 1},
		minacc = {x = -1, y = 0, z = -1},
		maxacc = {x = 1, y = 1, z = 1},
		minexptime = 1.5,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 3,
		texture = "gift_particle.png",
		glow = 8,
	})
end

minetest.register_craftitem("daily_reward:gift", {
	description = "Daily gift",
	wield_image = "gift.png",
	stack_max = 1,
	wield_scale = {x=0.7, y=0.7, z=5},
	wield_image = "gift.png",
	
	inventory_image = minetest.inventorycube("gift_top.png","gift.png","gift.png","gift.png"),
	sounds = default.node_sound_leaves_defaults(),
	
	on_place = function(itemstack, placer, pointed_thing)
	
	local pt = pointed_thing		
	if not pt or pt.type ~= "node" then	return end -- check if pointing at a node
	local under = minetest.get_node(pt.under);
	local p = {x = pt.under.x, y = pt.under.y+1, z = pt.under.z};	local above = minetest.get_node(p)
	--if minetest.is_protected(p, placer:get_player_name()) then	minetest.record_protection_violation(p, placer:get_player_name())return end
	
	local RndChoice = daily_reward.item_list[math.random( #daily_reward.item_list )]	 	
	minetest.after(2.5, function()
	minetest.spawn_item(p, RndChoice)
	end)	
		
	particle_effect(p)

-- play sound

	minetest.sound_play("gift_sound", {
		pos = p,
		gain = 0.7
	})
	itemstack:take_item()
	return itemstack
	
	end
})







--print ("[Mod] Daily gift")