local QBCore = exports['qb-core']:GetCoreObject()
local allowedrole = admin
local stringlength = 6
DISCORD_CUXHOOK = Config.CuxHook
QBCore.Commands.Add("code", "Collect reward from code", {{name="Code", help="Enter Code"}}, true, function(src, args)
    exports['ghmattimysql']:execute('SELECT * FROM codes WHERE cuxcode = @playerCode', {['@playerCode'] = args[1]}, function(result)
        local xPlayer = QBCore.Functions.GetPlayer(src)
        local code = result[1].cuxcode
        local type = result[1].cuxtype
        local amount = result[1].cuxamount
        local status = result[1].cuxstatus

        local steamid = GetPlayerIdentifiers(src)[1]
        if status == 0 then 
            if type == 'money' then
                xPlayer.Functions.AddMoney("cash", amount)
                TriggerClientEvent('QBCore:Notify', src, "Yay! You redeemed the code!")
		SendRedeemLog(code, type, amount, steamid)
                QBCore.Functions.ExecuteSql(false, "UPDATE `codes` SET cuxstatus = 1, cuxusedby = '"..steamid.."' WHERE `cuxcode` = '"..code.."'")
            else
                xPlayer.Functions.AddItem(type, amount)
                TriggerClientEvent('QBCore:Notify', src, "Yay! You redeemed the code!")
		SendRedeemLog(code, type, amount, steamid)
                QBCore.Functions.ExecuteSql(false, "UPDATE `codes` SET cuxstatus = 1, cuxusedby = '"..steamid.."' WHERE `cuxcode` = '"..code.."'")
            end
        else
            TriggerClientEvent('QBCore:Notify', src, "This code is already used!")
        end
        -- exports['ghmattimysql']:execute('DELETE FROM codes WHERE cuxcode = @playerCode', {['@playerCode'] = args[1]}, function(result)
        end)
    end)
QBCore.Commands.Add("createcode", "Create a code with a reward", {{name="type", help="money or item name"}, {name="amount", help="Amount"}}, true, function(src, args)
        local type = tostring(args[1]):lower()
        local amount = tonumber(args[2])

        if type ~= nil and amount ~= nil then 
            local upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            local lowerCase = "abcdefghijklmnopqrstuvwxyz"
            local numbers = "0123456789"
            local symbols = ".@$#()"
            local steamid = GetPlayerIdentifiers(src)[1]

            local characterSet = upperCase .. lowerCase .. numbers .. symbols

            local keyLength = stringlength
            local output = ""

            for	i = 1, keyLength do
                local rand = math.random(#characterSet)
                output = output .. string.sub(characterSet, rand, rand)
            end

            Citizen.Wait(100)
	    SendMadeLog(output, type, amount, steamid)
            local message = 'Code Created - '..output..''
			TriggerClientEvent('chatMessage', src, "CUXP24-CODEGEN V1.0 ", "warning", message)
		    QBCore.Functions.ExecuteSql(true, "INSERT INTO `codes` (`cuxcode`, `cuxtype`, `cuxamount`, `cuxstatus`, `cuxmadeby`) VALUES ('"..output.."', '"..type.."', '"..amount.."', 0, '"..steamid.."')")

        end

end, allowedrole)
function SendRedeemLog(c,t,a,s)
	local connect = {
		{
		    ["color"] = "200",
		    ["title"] = "Code Was Redeemed",
		    ["description"] = "**Code :**`"..c.."`\n\n**Type :**`"..t.."`\n**Amount :**`"..a.."`\n**Used by :**`"..s.."`",
			["footer"] = {
			["text"] = "CUXP24-CODES",
		    },
		}
	    }
	PerformHttpRequest(DISCORD_CUXHOOK, function(err, text, headers) end, 'POST', json.encode({username = "CUXP24-CODES",  avatar_url = "https://i.ibb.co/bW9XGnb/logo.png",embeds = connect}), { ['Content-Type'] = 'application/json' })
end
function SendMadeLog(c,t,a,s)
	local connect = {
		{
		    ["color"] = "200",
		    ["title"] = "Code Was Generated",
		    ["description"] = "**Code :**`"..c.."`\n\n**Type :**`"..t.."`\n**Amount :**`"..a.."`\n**Generated by :**`"..s.."`",
			["footer"] = {
			["text"] = "CUXP24-CODES",
		    },
		}
	    }
	PerformHttpRequest(DISCORD_CUXHOOK, function(err, text, headers) end, 'POST', json.encode({username = "CUXP24-CODES",  avatar_url = "https://i.ibb.co/bW9XGnb/logo.png",embeds = connect}), { ['Content-Type'] = 'application/json' })
end
