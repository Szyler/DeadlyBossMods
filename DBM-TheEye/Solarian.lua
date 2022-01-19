local mod	= DBM:NewMod("Solarian", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 132 $"):sub(12, -3))
mod:SetCreatureID(18805)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START"
)


-- local warn
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase2Soon		= mod:NewAnnounce("WarnPhase2Soon")
local specWarnHeal			= mod:NewSpecialWarningInterupt(2135264) --Heroic and ascended : 2135265
local specWarnPriest		= mod:NewSpecialWarning("specWarnPriest")
local specWarnLunar			= mod:NewSpecialWarningRun(2135278) --Heroic: 2135279 ,Ascended 10Man: 2135280 , 25Man: 2135281
local specWarnSolar			= mod:NewSpecialWarningMove(2135287) --Heroic: 2135288, Ascended 10Man: 2135289 , 25Man: 2135290
local warnWarnFireL			= mod:NewSpellAnnounce(2135230) --Heroic: 2135231, Ascended 10Man: 2135232, 25Man: 2135233
local warnWarnFireS			= mod:NewSpellAnnounce(2135234) --Heroic: 2135235, Ascended 10Man: 2135236 , 25Man: 2135237
local specWarnLunarStacks	= mod:NewSpecialWarningStack(2135230, nil, 3)
local specWarnSolarStacks	= mod:NewSpecialWarningStack(2135234, nil, 3)
local specWarnVoidSpawn		= mod:NewSpecialWarning("SpecWarnVoidSpawn")
-- local specWarnDisrupt		= mod:NewSpecialWarningSpell("SpecWarnVoidSpawn")

-- local timer
local berserkTimer			= mod:NewBerserkTimer(720)
local timerNextFireL        = mod:NewNextTimer(10, 2135230)
local timerNextFireS		= mod:NewNextTimer(10, 2135234)
local timerAdds				= mod:NewTimer(15, "TimerAdds","Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local timerNextLunar		= mod:NewNextTimer(15, 2135278)
local timerNextSolar		= mod:NewNextTimer(15, 2135287)
local timerNextLWrathPop	= mod:NewTargetTimer(10, 2135283)
local timerNextSWrathPop	= mod:NewTargetTimer(10, 2135292)
local timerVoidSpawn		= mod:NewTimer(20, "TimerVoidSpawn","Interface\\Icons\\spell_shadow_summonvoidwalker")
local timerNextHealS		= mod:NewCDTimer(12, 2135264, "TimerNextHealS")
local timerNextHealL		= mod:NewCDTimer(12, 2135264, "TimerNextHealL")

local yellLunarWrath		= mod:NewFadesYell(2135278)
local yellSolarWrath		= mod:NewFadesYell(2135287)

-- local variables
local nextPriest = ""
local isSolarian = false;
local below55 = false;
local AntiSpam = 0
local voidSpawnTimer = 0
local priestID = 0

-- local options
mod:AddBoolOption(L.WrathYellOpt)
mod:AddBoolOption(L.StartingPriest, false)
mod:AddBoolOption(L.StartingSolarian, false)


function mod:OnCombatStart(delay)
	AntiSpam = GetTime()
	nextPriest = ""
	isSolarian = false;
	below55 = false;
	self.vb.phase = 1
	berserkTimer:Start(-delay)
	timerNextFireS:Start(-delay)
	timerAdds:Start(-delay)
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SolarianYellAddPhase or msg:find(L.SolarianYellAddPhase) then
		timerNextFireL:Stop()
		timerNextFireS:Stop()
		timerNextLunar:Stop()
		timerNextSolar:Stop()
		if nextPriest == "" and self.Options.StartingPriest then
			if self.Options.StartingSolarian then
				nextPriest = "Solarian Priest"
			else
				nextPriest = "Lunarian Priest"
			end
		end
		if nextPriest == "Solarian Priest" then
			if DBM.GetRaidRank() >= 1 then
				priestID = self:GetUnitCreatureId(14551)
				self:SetIcon(priestID, 8)   --experimental 
			end
			if nextPriest ~= "" then
				specWarnPriest:Show(nextPriest)
			end
		elseif nextPriest == "Lunarian Priest"  or nextPriest == "" then
			priestID = self:GetUnitCreatureId(14552) --Needs correct ID for Lunarian Priest
			if DBM.GetRaidRank() >= 1 then
				self:SetIcon(nextPriest, 8)
			end
			if nextPriest ~= "" then
				specWarnPriest:Show(nextPriest)
			end
		end
	-- else 
	-- 	specWarnPriest:Show("Whichever Priest")
	elseif msg == L.SolarianPhase1 or msg:find(L.SolarianPhase1) then
		if UnitExists("Solarian Priest") and not UnitIsDead("Solarian Priest") then
			nextPriest = "Solarian Priest"
			timerNextSolar:Start()
			timerNextFireS:Start()
			timerNextHealL:Stop()
		elseif UnitExists("Lunarian Priest") and not UnitIsDead("Lunarian Priest") then
			nextPriest = "Lunarian Priest"
			timerNextLunar:Start()
			timerNextFireL:Start()
			timerNextHealS:Stop()
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(2135278, 2135279, 2135280, 2135281) then
		timerNextLunar:Start()
		timerNextLWrathPop:Start(args.destName)
		if args:IsPlayer() then
			 if self.Options.WrathYellOpt then
				SendChatMessage(L.LunarWrathYell, "YELL")
				yellLunarWrath:Countdown(10,3)
			end
		else 
			specWarnLunar:Show()
		end
	elseif args:IsSpellID(2135287, 2135288, 2135289, 2135290) then
		timerNextSolar:Start()
		timerNextSWrathPop:Start(args.destName)
		if args:IsPlayer() then
			if self.Options.WrathYellOpt then
				SendChatMessage(L.SolarWrathYell, "Yell")
				yellSolarWrath:Countdown(10,3)
			end
		else 
			specWarnSolar:Show()
		end
	elseif args:IsSpellID(2135260) then
		self.vb.phase = 2
		voidSpawnTimer = 24
		warnPhase2:Show()
		timerNextFireL:Stop()
		timerNextFireS:Stop()
		timerNextSolar:Stop()
		timerNextLunar:Stop()
		timerNextLWrathPop:Stop()
		timerNextSWrathPop:Stop()
		timerVoidSpawn:Start()
		specWarnVoidSpawn:Schedule(20)
	elseif UnitName(args.destName) == "Solarian Voidspawn" then
		if self:GetIcon(args.destGUID) ~= 8 and GetTime() - AntiSpam > 10 then
			AntiSpam = GetTime()
			specWarnVoidSpawn:Show()
			timerVoidSpawn:Start(voidSpawnTimer)
			voidSpawnTimer = voidSpawnTimer - 1 -- Spawning faster and faster
			if DBM:GetRaidRank() >= 1 then
				self:SetIcon(args.destGUID, 8, 20)
			end
		end
	elseif args:IsSpellID(2135230, 2135231, 2135232, 2135233)  then
		timerNextFireL:Start()
		warnWarnFireL:Show()
		if args.amount == 3 then
			specWarnLunarStacks:Show()
		end
	elseif args:IsSpellID(2135234, 2135235, 2135236, 2135237)  then
		timerNextFireS:Start()
		warnWarnFireS:Show()
		if args.amount == 3 then
			specWarnSolarStacks:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(2135230, 2135231, 2135232, 2135233)  then
		timerNextFireL:Start()
		warnWarnFireL:Show()
		if args.amount == 3 then
			specWarnLunarStacks:Show()
		end
	elseif args:IsSpellID(2135234, 2135235, 2135236, 2135237)  then
		timerNextFireS:Start()
		warnWarnFireS:Show()
		if args.amount == 3 then
			specWarnSolarStacks:Show()
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(2135264, 2135265) then
		specWarnHeal:Show()	-- need to add timer for next heal as well
		if args.sourceName == "Solarian Priest" then
			timerNextHealS:Start()
		else 
			timerNextHealL:Start()
		end
	end
end

-- function mod:SPELL_INTERRUPT(args)  -- Check Interval
-- 	if args:IsSpellID(2135264, 2135265) then
-- 		if args.destName == "Solarian Priest" then
-- 			timerNextHealS:Start()
-- 		else 
-- 			timerNextHealL:Start()
-- 		end
-- 	end
-- end

-- function mod:SPELL_HEAL(args)
-- 	if args:IsSpellID(2135264, 2135265) then
-- 		if args.sourceName == "Solarian Priest" then
-- 			timerNextHealS:Start()
-- 		else 
-- 			timerNextHealL:Start()
-- 		end
-- 	end
-- end

function mod:UNIT_DIED(unit)
  --[===[  local name = UnitName(unit);
    if name == "Solarian Priest" and self.vb.phase == 2 then
		lastPriestDied = name
		self.vb.phase = 1		rewriting it. Doesnt seem to work at all and its better to tie it to boss yell anyways IMO
		timerNextLunar:Start()
		timerNextFireL:Start()
	elseif name == "Lunarian Priest" and self.vb.phase == 2 then
		lastPriestDied = name
		self.vb.phase = 1
		timerNextSolar:Start()
		timerNextFireS:Start()
	end --]===]
end


function mod:OnCombatEnd()

end

function mod:UNIT_HEALTH(unit)
	if isSolarian and (not below55) and (mod:GetUnitCreatureId(unit) == 18805) then
		local hp = (math.max(0,UnitHealth(unit)) / math.max(1, UnitHealthMax(unit))) * 100;
		if (hp <= 55) then
			warnPhase2Soon:Show()
			below55 = true;
        end
    end
end

-- Old Solarian DBM Code


-- local warnPhase = false;
-- local split = false

-- Solarian:RegisterEvents(
-- 	"SPELL_CAST_START",
-- 	"SPELL_AURA_APPLIED",
-- 	"CHAT_MSG_MONSTER_YELL"
-- );

-- Solarian:SetCreatureID(18805)
-- Solarian:RegisterCombat("combat")

-- Solarian:AddOption("WarnWrath", true, DBM_SOLARIAN_OPTION_WARN_WRATH);
-- Solarian:AddOption("IconWrath", true, DBM_SOLARIAN_OPTION_ICON_WRATH);
-- Solarian:AddOption("SpecWrath", true, DBM_SOLARIAN_OPTION_SPECWARN_WRATH);
-- Solarian:AddOption("SoundWarning", false, DBM_SOLARIAN_OPTION_SOUND);
-- Solarian:AddOption("WhisperWrath", true, DBM_SOLARIAN_OPTION_WHISPER_WRATH);
-- Solarian:AddOption("WarnPhase", true, DBM_SOLARIAN_OPTION_WARN_PHASE);

-- Solarian:AddBarOption("Wrath: (.*)")
-- Solarian:AddBarOption("Split")
-- Solarian:AddBarOption("Agents")
-- Solarian:AddBarOption("Priests & Solarian")

-- function Solarian:OnCombatStart(delay)	
-- 	warnPhase = false;
-- 	split = false
-- 	self:ScheduleSelf(15, "CheckBack"); -- to prevent bugs if you are using an unsupported client language...
	
-- 	self:StartStatusBarTimer(50 - delay, "Split", "Interface\\Icons\\Spell_Holy_SummonLightwell");
-- 	if self.Options.WarnPhase then
-- 		self:ScheduleSelf(45 - delay, "SplitWarn");
-- 	end
-- end

-- function Solarian:OnCombatEnd()
-- 	split = false
-- end

-- local splitIds = {
-- 	[33189] = true,
-- 	[33281] = true,
-- 	[33282] = true,
-- 	[33347] = true,
-- 	[33348] = true,
-- 	[33349] = true,
-- 	[33350] = true,
-- 	[33351] = true,
-- 	[33352] = true,
-- 	[33353] = true,
-- 	[33354] = true,
-- 	[33355] = true,
-- }

-- function Solarian:OnEvent(event, arg1)
-- 	if event == "SPELL_AURA_APPLIED" then
-- 		if arg1.spellId == 42783 then
-- 			self:SendSync("Wrath"..tostring(arg1.destName));
-- 		end
-- 	elseif event == "SPELL_CAST_START" then
-- 		if arg1.spellId and splitIds[arg1.spellId] then -- wtf?
-- 			self:SendSync("Split");
-- 		end
-- 	elseif event == "CHAT_MSG_MONSTER_YELL" and arg1 then
-- 		if string.find(arg1, DBM_SOLARIAN_YELL_ENRAGE) then
-- 			self:Announce(DBM_SOLARIAN_ANNOUNCE_ENRAGE_PHASE, 3);
-- 			warnPhase = false;
-- 			self:EndStatusBarTimer("Split");
-- 			self:UnScheduleSelf("SplitWarn");
-- 			self:UnScheduleSelf("CheckBack");
-- 		end
-- 	elseif event == "SplitWarn" then
-- 		self:Announce(DBM_SOLARIAN_ANNOUNCE_SPLIT_SOON, 2);
-- 	elseif event == "PriestsWarn" then
-- 		self:Announce(DBM_SOLARIAN_ANNOUNCE_PRIESTS_SOON, 2);
-- 	elseif event == "PriestsNow" then
-- 		self:Announce(DBM_SOLARIAN_ANNOUNCE_PRIESTS_NOW, 3);
-- 	elseif event == "AgentsNow" then
-- 		self:Announce(DBM_SOLARIAN_ANNOUNCE_AGENTS_NOW, 2);
-- 	elseif event == "CheckBack" then
-- 		for i = 1, GetNumRaidMembers() do
-- 			if UnitName("raid"..i.."target") == DBM_SOLARIAN_NAME and UnitAffectingCombat("raid"..i.."target") then -- to prevent false positives after wipes
-- 				warnPhase = true;
-- 				break;
-- 			end
-- 		end
-- 	elseif event == "ResetSplit" then
-- 		split = false
-- 	end
-- end


-- function Solarian:OnSync(msg)
-- 	if string.sub(msg, 1, 5) == "Wrath" then
-- 		local target = string.sub(msg, 6);
-- 		if target then
-- 			if target == UnitName("player") then
-- 			   if self.Options.SpecWrath then 
-- 				  self:AddSpecialWarning(DBM_SOLARIAN_SPECWARN_WRATH); 
-- 			   end 
-- 			   if self.Options.SoundWarning then 
-- 				  PlaySoundFile("Sound\\Spells\\PVPFlagTaken.wav"); 
-- 				  PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav");
-- 			   end 
-- 			end
-- 			if self.Options.WarnWrath then
-- 				self:Announce(string.format(DBM_SOLARIAN_ANNOUNCE_WRATH, target), 1);
-- 			end
-- 			if self.Options.IconWrath then
-- 				self:SetIcon(target, 6);
-- 			end
-- 			if self.Options.WhisperWrath then
-- 				self:SendHiddenWhisper(DBM_SOLARIAN_SPECWARN_WRATH, target)
-- 			end
-- 			self:StartStatusBarTimer(6, "Wrath: "..target, "Interface\\Icons\\Spell_Arcane_ArcaneTorrent")
-- 		end
		
-- 	elseif msg == "Split" then
-- 		split = true
-- 		if self.Options.WarnPhase then
-- 			self:Announce(DBM_SOLARIAN_ANNOUNCE_SPLIT, 3);
-- 			self:ScheduleSelf(6, "AgentsNow");
-- 			self:ScheduleSelf(17, "PriestsWarn");
-- 			self:ScheduleSelf(22, "PriestsNow");
-- 			self:ScheduleSelf(85, "SplitWarn");
-- 		end		
-- 		self:StartStatusBarTimer(90, "Split", "Interface\\Icons\\Spell_Holy_SummonLightwell");
-- 		self:StartStatusBarTimer(22.5, "Priests & Solarian", "Interface\\Icons\\Spell_Holy_Renew");
-- 		self:StartStatusBarTimer(6.5, "Agents", "Interface\\Icons\\Spell_Holy_AuraMastery");
-- 		self:ScheduleEvent(50, "ResetSplit")
-- 	end
-- end

-- function Solarian:OnUpdate(elapsed) -- this can be used to detect the phase if nobody was in range after her teleport
-- 	if not split and self.InCombat then
-- 		local foundIt;
-- 		for i = 1, GetNumRaidMembers() do
-- 			if UnitName("raid"..i.."target") == DBM_SOLARIAN_NAME then
-- 				foundIt = true;
-- 				break;
-- 			end
-- 		end
-- 		if not foundIt and warnPhase then
-- 			self:SendSync("Split");
-- 			warnPhase = false;
-- 			self:ScheduleSelf(45, "CheckBack");
-- 		end
-- 	end
-- end
