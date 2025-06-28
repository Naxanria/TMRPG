namespace API
{
    CNadeoServicesMap@ GetMapFromUid(const string &in mapUid)
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
        auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr.Map_NadeoServices_GetFromUid(userId, mapUid);
        WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr);

        if (resp.HasFailed || !resp.HasSucceeded) {
            UI::ShowNotification("Couldn't load map info :(");
            warn('GetMapFromUid failed for ' + mapUid + ": " + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
            return null;
        }
        return resp.Map;
    }

    uint Map_GetRecord_v2(const string &in mapUid)
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        auto mccma = app.MenuManager.MenuCustom_CurrentManiaApp;
        auto userId = mccma.UserMgr.Users[0].Id;
        return mccma.ScoreMgr.Map_GetRecord_v2(userId, mapUid, "PersonalBest", "", "TimeAttack", "");
    }

    CMapRecord@ GetPlayerRecordOnMap(const string &in mapUid)
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        auto mccma = app.MenuManager.MenuCustom_CurrentManiaApp;
        auto userId = mccma.UserMgr.Users[0].Id;

        MwFastBuffer<wstring> wsids = MwFastBuffer<wstring>();
        wsids.Add(mccma.LocalUser.WebServicesUserId);

        auto task = mccma.ScoreMgr.Map_GetPlayerListRecordList(userId, wsids, mapUid, "PersonalBest", "", "TimeAttack", "");
        
        WaitAndClearTaskLater(task, mccma.ScoreMgr);

        if (task.HasFailed || !task.HasSucceeded)
        {
            warn("Failed to get player record on map: " + mapUid + " Error: " + task.ErrorCode + ", " + task.ErrorType + ", " + task.ErrorDescription);
        }

        if (task.MapRecordList.Length == 0)
        {
            return null;
        }

        return task.MapRecordList[0];
    }

    void WaitAndClearTaskLater(CWebServicesTaskResult@ task, CMwNod@ owner)
    {
        while (task.IsProcessing)
        {
            yield();
        }

        if (task.HasSucceeded)
        {
            // todo: clear tasks properly
            // auto scoreMgr = cast<CGameScoreAndLeaderBoardManagerScript>(owner);

            // scoreMgr.TaskResult_Release(task.Id);            
        }
    }

    void LoadMapNow(const string &in uid)
    {
        if (!Permissions::PlayLocalMap())
        {
            UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", "Refusing to load map because you lack necessary permissions. Club access required");
            return;
        }
        auto map = GetMapFromUid(uid);
        string url = map.FileUrl;

        auto app = cast<CGameManiaPlanet>(GetApp());
        ReturnToMenu(true);
        app.ManiaTitleControlScriptAPI.PlayMap(url, "", "");
    }

    void ReturnToMenu(bool yieldTillReady = false)
    {
        auto app = cast<CGameManiaPlanet>(GetApp());
        if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed)
        {
            app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
        }

        app.BackToMainMenu();
        while (yieldTillReady && !app.ManiaTitleControlScriptAPI.IsReady)
        {
            yield();
        }
    }
}