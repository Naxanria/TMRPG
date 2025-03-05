

void Main()
{
    auto app = cast<CTrackMania>(GetApp());
    auto network = cast<CTrackManiaNetwork>(app.Network);

    if (!PVM::LoadPvmJson())
    {
        // todo: have fallback local data?    

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

        yield(100); // wait ~1s per loop
    }
}


void RenderMenu()
{
    string icon = (PVM::setting_show_pvm) ? Icons::Check : Icons::Times;
    if (UI::MenuItem("PVM " + icon))
    {
        PVM::setting_show_pvm = !PVM::setting_show_pvm;
    }
}

void Render()
{
    if (PVM::setting_show_pvm)
    {
        PVM::Render();
    }
}

