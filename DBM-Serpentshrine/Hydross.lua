local mod	= DBM:NewMod("Hydross", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))
mod:SetCreatureID(21216)
mod:RegisterCombat("combat", 21216)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)

local warnMarkF			= mod:NewAnnounce(L.WarnMark, 3, 351203)
local warnMarkN			= mod:NewAnnounce(L.WarnMark, 3, 351204)
local warnPhase			= mod:NewAnnounce("WarnPhase", 4)
local warnTomb			= mod:NewTargetAnnounce(38235, 3)
local specWarnTidal		= mod:NewSpecialWarning("Tidalwave, stack!")
local warnSludge		= mod:NewTargetAnnounce(38246, 2)--Maybe filter it some if spammy?

-- local specWarnMark	= mod:NewSpecialWarning("SpecWarnMark")

local timerNextTomb		= mod:NewNextTimer(30, 38235)
local timerNextTidal	= mod:NewNextTimer(45, 85416)
local timerTidal		= mod:NewNextTimer(5, 85416)
local timerSludge		= mod:NewTargetTimer(12, 38246)
-- local timerMark		= mod:NewTimer(15, "TimerMark", 351203)

local berserkTimer		= mod:NewBerserkTimer(600)

local lastMarkF = 0
local lastMarkN = 0
-- local markOfH, markOfC = DBM:GetSpellInfo(351203), DBM:GetSpellInfo(351204)

mod:AddBoolOption("RangeFrame", true)

function mod:tidalWave(timer)
	local timer = 0
	self:UnscheduleMethod("tidalWave")
	specWarnTidal:Show()
	timerNextTidal:Start()
	self:ScheduleMethod(45-timer, "tidalWave")
end

function mod:OnCombatStart(delay)
	-- timerMark:Start(16-delay, markOfH, "10%")
	berserkTimer:Start(-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show()
	end
	timerNextTomb:Start(10-delay)
	timerNextTidal:Start(30-delay)
	self:ScheduleMethod(30-delay, "tidalWave")
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(38235, 351290, 351291) then
		warnTomb:Show(args.destName)
		timerNextTomb:Start()
	elseif args.spellId == 38246 then
		warnSludge:Show(args.destName)
		timerSludge:Start(args.destName)
	-- elseif args.spellId == 351203 then
	-- 	timerMark:Cancel()
	-- 	timerMark:Start()
	elseif args:IsSpellID(37961) then -- Corruption transform on boss
		warnPhase:Show(L.Nature)
		timerNextTomb:Stop()
		-- timerMark:Start(16, markOfC, "10%")
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if 	args:IsSpellID(	351203, 351286, 351287) then	-- Heroic: 351286, Mythic: 351287 --Hydros
		if args.amount and (GetTime() - lastMarkF) > 2 and args.amount >= 10 and args.amount % 5 == 0 then
			lastMarkF = GetTime()
			warnMarkF:Show(args.amount, args.spellName)
		end
	elseif args:IsSpellID(	351204, 351288, 351289) then   	-- Heroic: 351288, Mythic: 351289 --Corruption
		if args.amount and (GetTime() - lastMarkN) > 2 and args.amount >= 10 and args.amount % 5 == 0 then
			lastMarkN = GetTime()
			warnMarkN:Show(args.amount, args.spellName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 38235 then
		timerNextTomb:Stop(args.destName)
		timerNextTidal:AddTime(2)
	elseif args:IsSpellID(351279) then -- Losing Corruption transform on boss
		warnPhase:Show(L.Frost)
		timerNextTidal:AddTime(2)
		-- timerMark:Start(16, markOfH, "10%")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(85416, 351276, 351277) then     
		specWarnTidal:Show()
		timerNextTidal:Start()
		timerTidal:Start()
		if mod:IsDifficulty("heroic10", "heroic25") then
			timerTidal:Schedule(5)
			timerTidal:Schedule(10)
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(351276) and (GetTime() - lastTidalWave) > 10 then
		lastTidalWave = GetTime()
		self:tidalWave(4)--speed up the timer by 4 seconds due to the delay from visual to damage
	end
end

-- 351203 - Mark of Hydross
-- 351204 - Mark of Corruption