local mod	= DBM:NewMod("Prince", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 172 $"):sub(12, -3))
mod:SetCreatureID(15690)
--mod:RegisterCombat("yell", L.DBM_PRINCE_YELL_PULL)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_INSTAKILL",
	"SPELL_CAST_SUCCESS",
	"UNIT_HEALTH"
)

local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnPhase3				= mod:NewPhaseAnnounce(3)
local warningNovaCast			= mod:NewCastAnnounce(30852, 3)
-- local warningInfernalSoon		= mod:NewSoonAnnounce(37277, 2) -- not needed
local warningInfernal			= mod:NewSpellAnnounce(37277, 3)
local warningEnfeeble			= mod:NewTargetAnnounce(30843, 4)
local warningAmpMagic			= mod:NewSpellAnnounce(39095, 3)
local warningSWP				= mod:NewTargetAnnounce(30898, 2, nil, false)
local warningDoom				= mod:NewSpellAnnounce(85069, 1)
local warningShadowRealm		= mod:NewTargetAnnounce(85077, 3)

local specWarnEnfeeble			= mod:NewSpecialWarningYou(30843)
local specWarnNova				= mod:NewSpecialWarningRun(30852)
local specWarnSWP				= mod:NewSpecialWarningYou(30898)	
local specWarnSRealm			= mod:NewSpecialWarningYou(85077)
--local specWarnInfernal			= mod:NewSpecialWarning(L.InfernalOnYou) not used

local timerNovaCast				= mod:NewCastTimer(2, 30852)
local timerNextInfernal			= mod:NewTimer(18.5, "Summon Infernal #%s", 37277)
local timerEnfeeble				= mod:NewCDTimer(30, 30843)
local timerDoom					= mod:NewCDTimer(24, 85069)
local timerShadowRealm			= mod:NewCDTimer(45, 85077)
local timerAmpDmg				= mod:NewTimer(25, L.AmplifyDamage, 85207)

local miscCrystalKill1			= mod:NewAnnounce(L.ShadowCrystalDead1, 3, 85078, nil,false)
local miscCrystalKill2			= mod:NewAnnounce(L.ShadowCrystalDead2, 3, 85078, nil,false)
local miscCrystalKill3			= mod:NewAnnounce(L.ShadowCrystalDead3, 3, 85078, nil,false)

local phase	= 0
local ampDmg = 1
local enfeebleTargets = {}
local firstInfernal = false
local CrystalsKilled = 0
local InfernalCount = 1
local isPrince = false;
local below30 = false;

mod:AddBoolOption(L.ShadowCrystal)

local function showEnfeebleWarning()
	warningEnfeeble:Show(table.concat(enfeebleTargets, "<, >"))
	table.wipe(enfeebleTargets)
end

function mod:OnCombatStart(delay)
	phase = 1
	CrystalsKilled = 0
	ampDmg = 1
	InfernalCount = 1
	isPrince = true
	below30 = false
	timerDoom:Start(30-delay)
	table.wipe(enfeebleTargets)
	timerNextInfernal:Start(21-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(30852) then
		warningNovaCast:Show()
		timerNovaCast:Start()
		specWarnNova:Show()
	end
end

function mod:SPELL_INSTAKILL(args)
	if args:IsSpellID(85078) and CrystalsKilled == 0 and args:IsPlayerSource() then
		CrystalsKilled = CrystalsKilled + 1
		if self.Options.ShadowCrystal then
			miscCrystalKill1:Show()
		end
	elseif args:IsSpellID(85078) and CrystalsKilled == 1 and args:IsPlayerSource() then
		CrystalsKilled = CrystalsKilled + 1
		if self.Options.ShadowCrystal then
			miscCrystalKill2:Show()
		end
	elseif args:IsSpellID(85078) and CrystalsKilled == 2 and args:IsPlayerSource() then
		CrystalsKilled = 0
		if self.Options.ShadowCrystal then
			miscCrystalKill3:Show()
		end
	end
end	
		

--function mod:Infernals()
--	warningInfernal:Show()
--	if Phase == 3 then
--		timerNextInfernal:Start(9)
--	else		
--		timerNextInfernal:Start()
--	end
--end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(30854, 30898, 85291) then
		warningSWP:Show(args.destName)
		if args:IsPlayer() then
			specWarnSWP:Show()
		end	
	elseif args:IsSpellID(85207) and args:IsPlayer() then
		ampDmg = ampDmg + 1;
		warningAmpMagic:Show()
		timerAmpDmg:Start(tostring(ampDmg))
	elseif args:IsSpellID(30843) then
		enfeebleTargets[#enfeebleTargets + 1] = args.destName
		timerEnfeeble:Start()
		if args:IsPlayer() then
			specWarnEnfeeble:Show()
		end
		self:Unschedule(showEnfeebleWarning)
		self:Schedule(0.3, showEnfeebleWarning)
	end	
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(85069) then
		warningDoom:Show()
			if phase == 3 then
				timerDoom:Start(12)
			else
				timerDoom:Start()
			end
	elseif args:IsSpellID(85077) then
		warningShadowRealm:Show(args.destName)
			if args.IsPlayer() then
				specWarnSRealm:Show()
			end
			if mod:IsDifficulty("heroic10") then
				timerShadowRealm:Start(23)
			else
				timerShadowRealm:Start()
			end
		end
	end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(85207) and args:IsPlayer() then
		ampDmg = ampDmg + 1;
		warningAmpMagic:Show()
		timerAmpDmg:Start(tostring(ampDmg))
	end
end
		

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_PRINCE_YELL_INF1 or msg == L.DBM_PRINCE_YELL_INF2 then
		warningInfernal:Show()
		InfernalCount = InfernalCount + 1
--		print("Next infernal is #"..InfernalCount)
			if phase == 3 then
				timerNextInfernal:Start(9, tostring(InfernalCount))
			else
				timerNextInfernal:Start(tostring(InfernalCount))
			end
--		if Phase == 3 then
--			timerNextInfernal:Update(3.5, 12.5)--we attempt to update bars to show 18.5sec left. this will more than likely error out, it's not tested.
--		else		
--			timerNextInfernal:Update(26.5, 45)--we attempt to update bars to show 18.5sec left. this will more than likely error out, it's not tested.
--		end
--	elseif msg == L.DBM_PRINCE_YELL_P3 then   -- Ascension doesn't use P3 yell.
--		phase = 3
--		warnPhase3:Show()
--		timerAmpDmg:Start(5, tostring(ampDmg))
	elseif msg == L.DBM_PRINCE_YELL_P2 then
		phase = 2
		warnPhase2:Show()
		timerShadowRealm:Start(15)
	end
end

function mod:UNIT_HEALTH(unit)
	if isPrince and (not below30) and (mod:GetUnitCreatureId(unit) == 15690) then
		local hp = (math.max(0,UnitHealth(unit)) / math.max(1, UnitHealthMax(unit))) * 100;
		if (hp <= 30) then
			phase = 3
			warnPhase3:Show()
			timerAmpDmg:Start(5, tostring(ampDmg))
			below30 = true;
        end
    end
end
