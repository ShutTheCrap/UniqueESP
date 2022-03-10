local ConsT: {[number]: string} = {'AncestryChanged', 'AttributeChanged', 'Changed', 'ChildAdded', 'ChildRemoved', 'DescendantAdded', 'DescendantRemoving', 'Destroying'}
local Classes: {[string]: {[number]: string}} = {
	['AnimationTrack'] = {'DidLoop', 'KeyframeReached', 'Stopped'},
	['Animator'] = {'AnimationPlayed'},
	['BasePart'] = {'Touched', 'TouchEnded'},
	['BindableEvent'] = {'Event'},
	['BulkImportService'] = {'AssetImported', 'BulkImportFinished', 'BulkImportStarted'},
	['Camera'] = {'FirstPersonTransition', 'InterpolationFinished'},
	['GuiButton'] = {'Activated', 'MouseButton1Click', 'MouseButton1Down', 'MouseButton1Up', 'MouseButton2Click', 'MouseButton2Down', 'MouseButton2Up'},
	['GuiObject'] = {'InputBegan', 'InputChanged', 'InputEnded', 'MouseEnter', 'MouseLeave', 'MouseMoved', 'MouseWheelBackward', 'MouseWheelForward', 'SelectionGained', 'SelectionLost', 'TouchLongPress', 'TouchPan', 'TouchPinch', 'TouchRotate', 'TouchSwipe', 'TouchTap'},
	['Humanoid'] = {'Climbing', 'ClusterCompositionFinished', 'Died', 'FallingDown', 'FreeFalling', 'GettingUp', 'HealthChanged', 'Jumping', 'MoveToFinished', 'PlatformStanding', 'Ragdoll', 'Running', 'Seated', 'StateChanged', 'StateEnabledChanged', 'Strafing', 'Swimming', 'Touched'},
	['HumanoidDescription'] = {'EmotesChanged', 'EquippedEmotesChanged'},
	['MarketplaceService'] = {'ClientLuaDialogRequested', 'ClientPurchaseSuccess', 'NativePurchaseFinished', 'PromptBundlePurchaseFinished', 'PromptBundlePurchaseRequested', 'PromptGamePassPurchaseFinished', 'PromptGamePassPurchaseRequested', 'PromptPremiumPurchaseFinished', 'PromptPremiumPurchaseRequested', 'PromptProductPurchaseRequested', 'PromptPurchaseFinished', 'PromptPurchaseRequested', 'PromptRobloxPurchaseRequested', 'PromptSubscriptionCancellationFinished', 'PromptSubscriptionCancellationRequested', 'PromptSubscriptionPurchaseFinished', 'PromptSubscriptionPurchaseRequested', 'ServerPurchaseVerification', 'ThirdPartyPurchaseFinished'},
	['LocalizationService'] = {'AutoTranslateWillRun'},
	['RocketPropulsion'] = {'ReachedTarget'},
	['Sound'] = {'Ended','DidLoop','Loaded','Paused','Played','Resumed','Stopped'},
	['Team'] = {'PlayerAdded', 'PlayerRemoved'},
	['Tool'] = {'Activated', 'Deactivated', 'Equipped', 'Unequipped'},
	['Tween'] = {'Completed'},
}
local function Test(Obj: Instance): ()
    for Indx: string, Tab: {[number]: string} in pairs(Classes)do
        if Obj:IsA(Indx)then
            for _:number, SignalN: string in ipairs(Tab)do
                local Cons: {[number]: RBXScriptConnection} = getconnections(Obj[SignalN])
                if Cons and #Cons > 0 then
                    rconsoleprint('Firing: ' .. SignalN .. ' - ' .. Obj:GetFullName() .. '\n')
                    for _: number, Signal: RBXScriptConnection in ipairs(Cons)do
                        local Func = Signal.Function
                        if Func then
                            task.spawn(Func)
                        end
                    end
                    rconsoleprint('Fired: ' .. SignalN .. ' - ' .. Obj:GetFullName() .. '\n')
                end
            end
        end
    end
    for _: number, SignalN: string in ipairs(ConsT)do
        local Cons: {[number]: RBXScriptConnection} = getconnections(Obj[SignalN])
        if Cons and #Cons > 0 then
            rconsoleprint('Firing: ' .. SignalN .. ' - ' .. Obj:GetFullName() .. '\n')
            for _: number, Signal: RBXScriptConnection in ipairs(Cons)do
                local Func = Signal.Function
                if Func then
                    task.spawn(Func)
                end
            end
            rconsoleprint('Fired: ' .. SignalN .. ' - ' .. Obj:GetFullName() .. '\n')
        end
    end
end
for _: number, Obj: Instance in ipairs(game:GetDescendants())do
	pcall(Test, Obj)
end
for _: number, Obj: Instance in ipairs(getnilinstances())do
	pcall(Test, Obj)
end
