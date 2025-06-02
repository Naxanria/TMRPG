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

        yield(100); // wait ~1s per loop
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
        else if(UI::MenuItem("\\$0f0" + Icons::Recycle + "\\$z Reload"))
        {
            if (!PVM::fetching)
            {
                print("Reloading pvm");
                awaitingReload = true;
            }
        } 
        UI::EndMenu();       
    }


    // string icon = (PVM::setting_show_pvm) ? Icons::Check : Icons::Times;
    // if (UI::MenuItem("PVM " + icon))
    // {
    //     PVM::setting_show_pvm = !PVM::setting_show_pvm;
    // }
}

void PVMLOADERROR()
{
    UI::ShowNotification(Icons::Bullhorn, "Failed to load the pvm data. Please try again later", vec4(0.9, 0, 0, 1));
}

void Render()
{
    if (PVM::setting_show_pvm)
    {
        PVM::Render();
    }
}

