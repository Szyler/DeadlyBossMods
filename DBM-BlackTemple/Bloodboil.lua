local mod	= DBM:NewMod("Bloodboil", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 5019 $"):sub(12, -3))
mod:SetCreatureID(22948)
mod:RegisterCombat("yell", DBM_BLOODBOIL_YELL_PULL)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED"
)


local warnChaosBlast           		= mod:NewSpellAnnounce(2144804, 2)
local warnFlameCrash           		= mod:NewSpellAnnounce(2144720, 2)
local warnFlameCrashDot        		= mod:NewSpellAnnounce(2144720, 3)
local warnForceNova            		= mod:NewSpellAnnounce(2144724, 2)
local warnShear                		= mod:NewSpellAnnounce(2144718, 2)
local warnDrawSoul             		= mod:NewSpellAnnounce(2144737, 2)
local warnFelFireBlast         		= mod:NewSpellAnnounce(2144829, 2)
local warnUnharnessedBlade     		= mod:NewSpellAnnounce(2144742, 2)

local timerChaosBlast          		= mod:NewCastTimer(2, 2144804)
local timerChaosBlastDebuff    		= mod:NewBuffActiveTimer(6, 2144804)
local timerNextFlameCrash      		= mod:NewNextTimer(25, 2144720)
local timerFlameCrash          		= mod:NewCastTimer(2, 2144720)
local timerNextForceNova       		= mod:NewNextTimer(25, 2144724)
local timerNextShear           		= mod:NewNextTimer(25, 2144718)
local timerNextDrawSoul        		= mod:NewNextTimer(30, 2144737)
local timerFelFireBlast        		= mod:NewCastTimer(2, 2144804)
local timerNextFelFireBlast    		= mod:NewNextTimer(20, 2144829)
local timerFelFireBlast2       		= mod:NewCastTimer(2, 2144804)
local timerNextFelFireBlast2   		= mod:NewNextTimer(20, 2144829)
local timerParalyze	= mod:NewTargetTimer(30, 25725)

local warningBoilingBlood		= mod:NewSpellAnnounce(2143509, 3)
local warningSeismicSmash		= mod:NewSpellAnnounce(2143531, 3)
local warnMakgora				= mod:NewSpellAnnounce(2143520, 2)

local timerNextBoilingBlood		= mod:NewNextTimer(20, 2143509)
local timerNextSeismicSmash		= mod:NewNextTimer(20, 2143531)
local timerSeismicSmash			= mod:NewCastTimer(5, 2143531)
local timerNextMakgora			= mod:NewNextTimer(70, 2143520)


local warningFatalstrike		= mod:NewSpellAnnounce(21435227, 3)
local timerNextFatalstrike		= mod:NewNextTimer(20, 21435227)

local timerMakgora 				= mod:NewTargetTimer(20, 2143523)


local timerNextMalevolentCleave = mod:NewNextTimer(5, 2143525)

local warningBoilBlood 			= mod:NewSpellAnnounce(2143517, 3) --Burst damage from boiling the pools
local timerNextBoilBlood 		= mod:NewNextTimer(20, 2143517)



function mod:OnCombatStart(delay)
	timerNextBoilingBlood:Start(10-delay)
	timerNextSeismicSmash:Start(20-delay)
	timerNextMakgora:Start(70-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(2143508, 2143509, 2143510, 2143511) and timerMakgora:GetTime() >= 25 then
		warningBoilingBlood:Show()
		timerNextBoilingBlood:Start()
	elseif args:IsSpellID(2143530, 2143531, 2143532, 2143533) and timerMakgora:GetTime() >= 10 then
		warningSeismicSmash:Show()
		timerNextSeismicSmash:Start()
		timerSeismicSmash:Start()
	elseif args:IsSpellID(2143523) then
		warnMakgora:Show()
		timerNextMakgora:Start()
		timerMakgora:Start(args.destName)
		timerNextMalevolentCleave:Start()
	elseif args:IsSpellID(21435227) and timerMakgora:GetTime() >= 20 then
		warningFatalstrike:Show()
		timerNextFatalstrike:Start()
	elseif args:IsSpellID(2143517) and DBM:AntiSpam(15) and timerMakgora:GetTime() >= 25 then
		warningBoilBlood:Show()
		timerNextBoilBlood:Start()
	end
end

-- local boilCounter = 0

--Bloodboil:AddOption("WarnSmash", false, DBM_BLOODBOIL_OPTION_SMASH)

--Bloodboil:AddBarOption("Enrage")
--Bloodboil:AddBarOption("Bloodboil")
--Bloodboil:AddBarOption("Fel Rage")
--Bloodboil:AddBarOption("Normal Phase")
--Bloodboil:AddBarOption("Arcing Smash")



-- boilCounter = 0

-- self:StartStatusBarTimer(600 - delay, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
-- self:ScheduleSelf(300 - delay, "EnrageWarn", 300)
-- self:ScheduleSelf(480 - delay, "EnrageWarn", 120)
-- self:ScheduleSelf(540 - delay, "EnrageWarn", 60)
-- self:ScheduleSelf(570 - delay, "EnrageWarn", 30)
-- self:ScheduleSelf(590 - delay, "EnrageWarn", 10)

-- self:StartStatusBarTimer(57.5, "Fel Rage", "Interface\\Icons\\Spell_Fire_ElementalDevastation")
-- self:ScheduleSelf(52.5, "FelRageWarn")
-- self:StartStatusBarTimer(11.5, "Bloodboil", "Interface\\Icons\\Spell_Shadow_BloodBoil")



-- function Bloodboil:OnEvent(event, arg1)
-- 	if event == "SPELL_AURA_APPLIED" then
-- 		if arg1.spellId == 42005 then
-- 			self:SendSync("Bloodboil")
-- 		elseif arg1.spellId == 40604 then
-- 			self:SendSync("FelRage"..tostring(arg1.destName))
-- 		elseif arg1.spellId == 40599 then
-- 			self:SendSync("ArcingSmash"..tostring(arg1.destName))
-- 		end
-- 	elseif event == "SPELL_AURA_REMOVED" then
-- 		if arg1.spellId == 40594 then
-- 			boilCounter = 0
-- 			self:Announce(DBM_BLOODBOIL_WARN_NORMALPHASE, 3)
-- 			self:ScheduleSelf(52, "FelRageWarn")
-- 			self:StartStatusBarTimer(57, "Fel Rage", "Interface\\Icons\\Spell_Fire_ElementalDevastation")
-- 			self:StartStatusBarTimer(10, "Bloodboil", "Interface\\Icons\\Spell_Shadow_BloodBoil")
-- 		end
-- 	elseif event == "FelRageWarn" then
-- 		self:Announce(DBM_BLOODBOIL_WARN_FELRAGE_SOON, 2)
-- 	elseif event == "NormalWarn" then
-- 		self:Announce(DBM_BLOODBOIL_WARN_NORMAL_SOON, 2)
-- 	elseif event == "SmashWarn" then
-- 		self:Announce(DBM_BLOODBOIL_WARN_SMASH_SOON, 2)
-- 	elseif event == "EnrageWarn" and type(arg1) == "number" then
-- 		if arg1 >= 60 then
-- 			self:Announce(string.format(DBM_BLOODBOIL_WARN_ENRAGE, (arg1/60), DBM_MIN), 1)
-- 		else
-- 			self:Announce(string.format(DBM_BLOODBOIL_WARN_ENRAGE, arg1, DBM_SEC), 3)
-- 		end
-- 	end
-- end

-- function Bloodboil:OnSync(msg)
-- 	if msg == "Bloodboil" then
-- 		boilCounter = boilCounter + 1
-- 		self:Announce(DBM_BLOODBOIL_WARN_BLOODBOIL:format(boilCounter), 1)
-- 		self:StartStatusBarTimer(10, "Bloodboil", "Interface\\Icons\\Spell_Shadow_BloodBoil")
-- 	elseif msg:sub(0, 7) == "FelRage" then
-- 		msg = msg:sub(8)
-- 		self:EndStatusBarTimer("Bloodboil")
-- 		self:StartStatusBarTimer(28, "Normal Phase", "Interface\\Icons\\Spell_Nature_WispSplode")
-- 		self:ScheduleSelf(23, "NormalWarn")
-- 		self:Announce(DBM_BLOODBOIL_WARN_FELRAGE:format(msg), 4)
-- 		boilCounter = 0
-- 	elseif msg:sub(0, 11) == "ArcingSmash" then
-- 		msg = msg:sub(12)
-- 		self:StartStatusBarTimer(4, "Arcing Smash", "Interface\\Icons\\Ability_Warrior_Cleave")
-- 		if self.Options.WarnSmash then
-- 			self:ScheduleSelf(3, "SmashWarn")		
-- 			self:Announce(DBM_BLOODBOIL_WARN_SMASH, 4)
-- 		end
-- 	end
-- end
