local mod	= DBM:NewMod("Shahraz", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 5019 $"):sub(12, -3))
mod:SetCreatureID(22947)
mod:RegisterCombat("yell", DBM_SHAHRAZ_YELL_PULL)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH"
)

local warningFatalAttraction	= mod:NewSpellAnnounce(2144012, 3)
local warningThoughts			= mod:NewSpellAnnounce(ID, 3)
local warning20					= mod:NewSpellAnnounce(ID, 3)
local warning10					= mod:NewSpellAnnounce(ID, 3)

local timerNextFatalAttraction	= mod:NewNextTimer(30, 2144012)
local timerNextForcedThoughts	= mod:NewNextTimer(40, ID)
local timerNextBeam				= mod:NewNextTimer(30, ID)

--Sinful
local warningSinfulThoughts		= mod:NewSpellAnnounce(2144033, 3)
local warningSinfulBeam			= mod:NewSpellAnnounce(2144012, 3)
local timerNextSinfulBeam		= mod:NewCastTimer(3, 2144012)
local timerSinfulThoughts		= mod:NewBuffActiveTimer(300, 2144033)

--Sinister
local warningSinisterThoughts	= mod:NewSpellAnnounce(2144033, 3)
local warningSinisterBeam		= mod:NewSpellAnnounce(2144012, 3)
local timerNextSinisterBeam		= mod:NewCastTimer(3, 2144012)
local timerSinisterThoughts		= mod:NewBuffActiveTimer(300, 2144033)

--Vile
local warningVileThoughts		= mod:NewSpellAnnounce(2144033, 3)
local warningVileBeam			= mod:NewSpellAnnounce(2144012, 3)
local timerNextVileBeam			= mod:NewCastTimer(3, 2144012)
local timerVileThoughts			= mod:NewBuffActiveTimer(300, 2144033)

--Wicked
local warningWickedThoughts		= mod:NewSpellAnnounce(2144033, 3)
local warningWickedBeam			= mod:NewSpellAnnounce(2144012, 3)
local timerNextWickedBeam		= mod:NewCastTimer(3, 2144012)
local timerWickedThoughts		= mod:NewBuffActiveTimer(300, 2144033)

--local
local isMother		=	false
local below20		=	false
local below10		=	false

function mod:OnCombatStart(delay)
	timerNextForcedThoughts:Start(15-delay)
	self:ScheduleMethod(15-delay, "NewThoughts")
	-- isMother	=	false
	-- below20		=	false
	-- below10		=	false
end

function mod:OnCombatEnd()
	DBM.RangeCheck:Hide()
	self:UnscheduleMethod("NewThoughts")
end

function mod:NewThoughts()
	self:UnscheduleMethod("NewThoughts")
	timerNextForcedThoughts:Start()
	self:ScheduleMethod(40, "NewThoughts")
end

--Szyler add debuff stack warning for tank debuffs (Mater, Filia, Avia, Virgo)
function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(2144012) then
		warningFatalAttraction:Show()
		timerNextFatalAttraction:Start()
	--sinful
	elseif args:IsSpellID(2144033, 2144034, 2144035, 2144036) then
		if args.destName == UnitName("player") then
			warningSinfulThoughts:Show()
			timerSinfulThoughts:Start()
			timerSinisterThoughts:Stop()
			timerVileThoughts:Stop()
			timerWickedThoughts:Stop()
		end
	--sinister
	elseif args:IsSpellID(2144033, 2144034, 2144035, 2144036) then
		if args.destName == UnitName("player") then
			warningSinfulThoughts:Show()
			timerSinfulThoughts:Start()
			timerSinisterThoughts:Stop()
			timerVileThoughts:Stop()
			timerWickedThoughts:Stop()
		end
	--vile
	elseif args:IsSpellID(2144033, 2144034, 2144035, 2144036) then
		if args.destName == UnitName("player") then
			warningSinfulThoughts:Show()
			timerSinfulThoughts:Start()
			timerSinisterThoughts:Stop()
			timerVileThoughts:Stop()
			timerWickedThoughts:Stop()
		end
	--wicked
	elseif args:IsSpellID(2144033, 2144034, 2144035, 2144036) then
		if args.destName == UnitName("player") then
			warningSinfulThoughts:Show()
			timerSinfulThoughts:Start()
			timerSinisterThoughts:Stop()
			timerVileThoughts:Stop()
			timerWickedThoughts:Stop()
		end
	end
end

function mod:UNIT_HEALTH(unit)
	if isMother and (not below20 and not below10) and (mod:GetUnitCreatureId(unit) == 22947) then
		local hp = (math.max(0,UnitHealth(unit)) / math.max(1, UnitHealthMax(unit))) * 100;
		if (hp <= 20) then
			warning20:Show()
			below20 = true;
		elseif (hp <= 10) then
			warning10:Show()
			below10 = true;
        end
    end
end

--Shahraz:AddOption("WarnBeam", false, DBM_SHAHRAZ_OPTION_BEAM)
--Shahraz:AddOption("WarnBeamSoon", false, DBM_SHAHRAZ_OPTION_BEAM_SOON)
--Shahraz:AddOption("WhisperFA", false, DBM_SEND_WHISPER)

--Shahraz:AddBarOption("Enrage")
--Shahraz:AddBarOption("Next Beam", false)

-- local fa = {}
-- local icon = 8


-- self:StartStatusBarTimer(600 - delay, "Enrage", "Interface\\Icons\\Spell_Shadow_UnholyFrenzy")
-- self:ScheduleSelf(300 - delay, "EnrageWarn", 300)
-- self:ScheduleSelf(480 - delay, "EnrageWarn", 120)
-- self:ScheduleSelf(540 - delay, "EnrageWarn", 60)
-- self:ScheduleSelf(570 - delay, "EnrageWarn", 30)
-- self:ScheduleSelf(590 - delay, "EnrageWarn", 10)

-- fa = {}
-- icon = 8

-- function Shahraz:OnEvent(event, arg1)
-- 	if event == "SPELL_AURA_APPLIED" then
-- 		if arg1.spellId == 41001 then
-- 			self:SendSync("FA"..tostring(arg1.destName))
-- 		elseif arg1.spellId == 40860 then
-- 			self:SendSync("BeamVile")
-- 		end
-- 	elseif event == "SPELL_DAMAGE" then
-- 		if arg1.spellId == 40859 then
-- 			self:SendSync("BeamSinister")
-- 		elseif arg1.spellId == 40827 then
-- 			self:SendSync("BeamSinful")
-- 		elseif arg1.spellId == 40861 then
-- 			self:SendSync("BeamWicked")
-- 		end
-- 	elseif event == "EnrageWarn" and type(arg1) == "number" then
-- 		if arg1 >= 60 then
-- 			self:Announce(string.format(DBM_SHAHRAZ_WARN_ENRAGE, (arg1/60), DBM_MIN), 1)
-- 		else
-- 			self:Announce(string.format(DBM_SHAHRAZ_WARN_ENRAGE, arg1, DBM_SEC), 3)
-- 		end
-- 	elseif event == "WarnFA" then
-- 		local msg = ""
-- 		for i, v in ipairs(fa) do
-- 			msg = msg..">"..v.."<, "
-- 		end
-- 		msg = msg:sub(0, -3)
-- 		fa = {}
-- 		self:Announce(DBM_SHAHRAZ_WARN_FA:format(msg), 4)
-- 		icon = 8
-- 	elseif event == "WarnBeam" then
-- 		if self.Options.WarnBeamSoon then
-- 			self:Announce(DBM_SHAHRAZ_WARN_BEAM_SOON, 1)
-- 		end
-- 	end
-- end

-- function Shahraz:OnSync(msg)
-- 	if msg:sub(0, 2) == "FA" then
-- 		msg = msg:sub(3)
-- 		table.insert(fa, msg)
-- 		if self.Options.Announce and DBM.Rank >= 1 then
-- 			if self.Options.WhisperFA then
-- 				self:SendHiddenWhisper(DBM_SHAHRAZ_WHISPER_FA, msg)
-- 			end
-- 			self:SetIcon(msg, 7.5, icon)
-- 			icon = icon - 1
-- 		end
-- 		if msg == UnitName("player") then
-- 			self:AddSpecialWarning(DBM_SHAHRAZ_SPECWARN_FA)
-- 		end
-- 		self:UnScheduleSelf("WarnFA")
-- 		if #fa == 3 then
-- 			self:OnEvent("WarnFA")
-- 		else
-- 			self:ScheduleSelf(1, "WarnFA")
-- 		end
-- 	elseif msg:sub(0, 4) == "Beam" then
-- 		if self.Options.WarnBeam then
-- 			msg = msg:sub(5)
-- 			if msg == "Vile" then
-- 				self:Announce(DBM_SHAHRAZ_WARN_BEAM_VILE, 2)
-- 			elseif msg == "Sinister" then
-- 				self:Announce(DBM_SHAHRAZ_WARN_BEAM_SINISTER, 2)
-- 			elseif msg == "Sinful" then
-- 				self:Announce(DBM_SHAHRAZ_WARN_BEAM_SINFUL, 2)
-- 			elseif msg == "Wicked" then
-- 				self:Announce(DBM_SHAHRAZ_WARN_BEAM_WICKED, 2)
-- 			end
-- 		end
-- 		self:ScheduleSelf(6, "WarnBeam")
-- 		self:StartStatusBarTimer(9, "Next Beam", "Interface\\Icons\\Spell_Shadow_ShadowBolt")
-- 	end
-- end

