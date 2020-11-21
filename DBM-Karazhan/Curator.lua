local mod	= DBM:NewMod("Curator", "DBM-Karazhan")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 163 $"):sub(12, -3))
mod:SetCreatureID(15691)
--mod:RegisterCombat("yell", L.DBM_CURA_YELL_PULL)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_HEALTH"
)

local warnEvoSoon			= mod:NewPreWarnAnnounce(30254, 10, 2)
local warnEvo				= mod:NewSpellAnnounce(30254, 3)
local warnArcaneInfusion	= mod:NewSpellAnnounce(30403, 3)
local warnTerminate			= mod:NewTargetAnnounce(85082, 3)
local specWarnTerminate		= mod:NewSpecialWarning("%s Termination on YOU! %s"); --,1,85082)
local warnBreakCrystal		= mod:NewAnnounce("Break A Crystal", 2);

local timerTerminate	= mod:NewTargetTimer(10, 85082)
local timerTerminateCD	= mod:NewCDTimer(15, 85082) --15 seconds??
local timerEvo			= mod:NewBuffActiveTimer(20, 30254)
local timerNextEvo		= mod:NewNextTimer(110, 30254)

local berserkTimer		= mod:NewBerserkTimer(720)
local isCurator 		= false

mod:SetUsedIcons(6, 7)
local terminateIcon = 6;
mod:AddBoolOption("CuratorIcon")
mod:AddBoolOption("RangeFrame", true)

local iconText = {
	[6] = "{Square}",
	[7] = "{Cross}",
};

function mod:OnCombatStart(delay)
	timerTerminateCD:Start(30-delay)
	berserkTimer:Start(-delay)
	timerNextEvo:Start(95-delay)
	warnEvoSoon:Schedule(85-delay)
	warnBreakCrystal:Schedule((95-35)-delay);
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
	isCurator = true
	terminateIcon = 6;
end

function mod:OnCombatEnd()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(30403) then
		warnArcaneInfusion:Show()
		timerNextEvo:Stop()
		timerEvo:Stop()
		--warnBreakCrystal:Cancel();
	elseif args:IsSpellID(85082) then
		if self.Options.CuratorIcon then
			terminateIcon = (terminateIcon == 6) and 7 or 6;
			self:SetIcon(args.destName, terminateIcon, 10)
		end
		warnTerminate:Show(args.destName)
		timerTerminate:Start(args.destName)
		timerTerminateCD:Start()
		if args:IsPlayer() then
			local myIconText = self.Options.CuratorIcon and iconText[terminateIcon] or "";
			local myIconTex = ICON_LIST[terminateIcon].."12:12|t";
			specWarnTerminate:Show(myIconTex,myIconTex);
			SendChatMessage(L.YellTermination:format(myIconText,args.destName,myIconText),"YELL");
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.DBM_CURA_YELL_OOM then
		warnEvoSoon:Cancel()
		warnEvo:Show()
		timerNextEvo:Start()
		timerEvo:Start()
		warnEvoSoon:Schedule(95);
		warnBreakCrystal:Cancel();
		warnBreakCrystal:Schedule(110-35);
	end
end

