bool awaitingReload = false;

void Main()
{
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if (!PVM::LoadPvmJson())
    {
        // todo: have fallback local data?    
        PVMLOADERROR();
    }

    startnew(API::ClearTaskCoroutine);

    while (true)
    {
        auto map = app.RootMap;

        if (map !is null && map.MapInfo.MapUid != "" && app.Editor is null)        
        {
            // todo: accomodate for MP4
        

            if (network.ClientManiaAppPlayground !is null)
            {
                auto userMgr = network.ClientManiaAppPlayground.UserMgr;
                MwId userId;

                if (userMgr.Users.Length > 0)
                {
                    userId = userMgr.Users[0].Id;
                }
                else
                {
                    userId.Value = uint(-1);
                }

                string currentMapUID = map.MapInfo.MapUid;
                auto scoreMgr = network.ClientManiaAppPlayground.ScoreMgr;
                int personalBest = scoreMgr.Map_GetRecord_v2(userId, map.MapInfo.MapUid, "PersonalBest", "", "TimeAttack", "");

                PVM::Update(currentMapUID, personalBest);
            }
            else
            {
                PVM::Reset();                
            }
        }

        if (awaitingReload)
        {
            if (!PVM::ReloadPvm())
            {
                PVMLOADERROR();
            }
            awaitingReload = false;
        }

        yield();
    }
}

string CheckIcon(bool test)
{
    if (test)
    {
        return "\\$0e0" + Icons::Check + "\\$z";
    }

    return "\\$e00" + Icons::Times + "\\$z";
}

void RenderMenu()
{
    if (UI::BeginMenu(Colours::MEDAL_ALIEN + Icons::Circle + "\\$z PVM"))
    {
        if (UI::MenuItem(Icons::Eye + " Show " + CheckIcon(PVM::setting_show_pvm)))
        {
            PVM::setting_show_pvm = !PVM::setting_show_pvm;
        }

        if (UI::MenuItem(Icons::ListAlt + " Show List"))
        {
            PVM::Overview::showOverview = true;
        }
        
        if(UI::MenuItem("\\$0f0" + Icons::Recycle + "\\$z Reload"))
        {
            if (!PVM::fetching)
            {
                Logging::Info("Reloading pvm");
                awaitingReload = true;
            }
        }

        if (UI::MenuItem("\\$999" + Icons::Kenney::List + " \\$zOpen pvm sheet"))
        {
            OpenBrowserURL("https://docs.google.com/spreadsheets/d/1z1n6LfHMskAzD4N6CTNrnhyjFtgN_54TGlAyoU6eOnk/edit?usp=sharing");
        }

        UI::EndMenu();       
    }
}

void DebugLoadPb()
{
     PVM::pvmMapList[0].LoadPb();
}

void PVMLOADERROR()
{
    Logging::Error("Failed to load the pvm data. Please try again later", true);
}

void Render()
{
    if (PVM::setting_show_pvm)
    {
        PVM::Render();
    }

    if (PVM::Overview::showOverview)
    {
        PVM::Overview::Render();
    }
}

