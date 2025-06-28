namespace PVM 
{
    enum AuthorVisibility 
    {
        SHOW_PVM_NAME,
        SHOW_INGAME_NAME,
        HIDDEN
    };

    [Setting name="Hide when Interface is hidden" category="PVM"]
    bool setting_hide_on_interface_hidden = true;

    [Setting name="Show pvm" category="PVM"]
    bool setting_show_pvm = true;
    [Setting name="Show Labels" category="PVM"]
    bool setting_show_labels = true;

    [Setting name="Show Map Name" category="PVM"]
    AuthorVisibility setting_show_mapname = AuthorVisibility::SHOW_INGAME_NAME;
    [Setting name="Show Author Name" category="PVM"]
    AuthorVisibility setting_show_author = AuthorVisibility::SHOW_INGAME_NAME;
    [Setting name="Show Grade" category="PVM"]
    bool setting_show_pvm_grade = true;

    //[Setting name="No Way time" category="PVM"]
    // deprecated and replaced by alien++ time
    bool setting_show_pvm_no_way = false;

    [Setting name="Alien++ time" category="PVM"]
    bool setting_show_pvm_alien_plus = true;
    [Setting name="Alien time" category="PVM"]
    bool setting_show_pvm_alien = true;
    [Setting name="Player time" category="PVM"]
    bool setting_show_pvm_player = true;
    [Setting name="Challenger time" category="PVM"]
    bool setting_show_pvm_challenger = true;
    [Setting name="Intermediate time" category="PVM"]
    bool setting_show_pvm_intermediate = true;
    [Setting name="Noob time" category="PVM"]
    bool setting_show_pvm_noob = true;

    [Setting name="Show personal best" category="PVM"]
    bool setting_show_personal_best = true;
    [Setting name="Show delta" category="PVM"]
    bool setting_show_pvm_delta = true;

    [Setting name="Lock Position" category="PVM"]
    bool setting_lock_position = false;
    [Setting name="Window Position" category="PVM"]
    vec2 anchor = vec2(200, 200);

    // magic numbers
    const int NOOB = 1;
    const int INTERMEDIATE = 2;
    const int Challenger = 3;
    const int PLAYER = 4;
    const int ALIEN = 5;
    const int ALIEN_PLUS = 6;

    Json::Value pvmJson;

    //CGameCtnChallenge currentMap;
    MapData currentMapData = MapData();
    dictionary pvmMaps = {};
    MapData@[] pvmMapList;

    string currentMapUID = "";
    int personalBest = -1;
    string currentMapName = "";
    string currentAuthor = "";
    bool fetching = false;

    array<Medal> medals = 
    {
        Medal(0, "", Colours::MEDAL_UNKNOWN, Icons::Circle),
        Medal(NOOB, "Noob", Colours::MEDAL_NOOB, Icons::Circle),
        Medal(INTERMEDIATE, "Intermediate", Colours::MEDAL_INTERMEDIATE, Icons::Circle),
        Medal(Challenger, "Challenger", Colours::MEDAL_CHALLENGER, Icons::Circle),
        Medal(PLAYER, "Player", Colours::MEDAL_PLAYER, Icons::Circle),
        Medal(ALIEN, "Alien", Colours::MEDAL_ALIEN, Icons::Circle),
        Medal(ALIEN_PLUS, "Alien++", Colours::MEDAL_ALIEN_PLUS, Icons::Crosshairs)
    };

    void Update(string uid, int pb)
    {
        bool mapChange = currentMapUID != uid;
        if (mapChange)
        {
            MapChange(uid);
        }

        currentMapUID = uid;
        bool pbChange = !mapChange && pb != personalBest;

        if (pbChange)
        {
            PersonalBestChange(pb);
        }
        personalBest = pb;
        currentMapData.pb = pb;
        UpdatePB(pb, uid);
    }

    void MapChange(string newUid)
    {
        // todo: implement
    }

    void PersonalBestChange(int newPb)
    {
        //UpdatePB(newPb, currentMapUID);
    }

    void UpdatePB(int time, string uid)
    {
        if (!pvmMaps.Exists(uid))
        {
            return;
        }

        int tmxId = cast<MapData>(pvmMaps[uid]).tmxId;
        for (int i = 0; i < pvmMapList.Length; i++)
        {
            if (pvmMapList[i].tmxId == tmxId)
            {
                pvmMapList[i].pb = time;
                pvmMaps[currentMapData.uid] = pvmMapList[i];
            }
        }
    }

    void Reset()
    {
        personalBest = -1;
        currentMapData = MapData();
        currentMapUID = "";
    }

    void Render()
    {
        if (!setting_show_pvm)
        {
            return;
        }

        if (setting_hide_on_interface_hidden && !UI::IsGameUIVisible())
        {
            return;
        }

        if (!CheckCurrentMap() || !currentMapData.hasPvm)
        {
            return;
        }

        if (currentMapData.uid != currentMapUID)
        {
            // not loaded properly yet
            return;
        }

        int winFlags = UI::WindowFlags::NoDocking | UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoTitleBar;

        if(setting_lock_position) 
        {
            UI::SetNextWindowPos(int(anchor.x), int(anchor.y), UI::Cond::Always);
        }
        else
        {
            UI::SetNextWindowPos(int(anchor.x), int(anchor.y), UI::Cond::FirstUseEver);
        }


        UI::Begin("PVM Medals", winFlags);
        if (!setting_lock_position)
        {
            anchor = UI::GetWindowPos();
        }

        UI::BeginGroup();

        bool showHeader = setting_show_author != AuthorVisibility::HIDDEN || setting_show_mapname != AuthorVisibility::HIDDEN || setting_show_pvm_grade;

        bool tableEnd = false;
        if (showHeader)
        {
            tableEnd = UI::BeginTable("pvm_header", 1, UI::TableFlags::SizingFixedFit);

            if (setting_show_mapname != AuthorVisibility::HIDDEN)
            {
                UI::TableNextRow();
                UI::TableNextColumn();
                
                string mapName = setting_show_mapname == AuthorVisibility::SHOW_PVM_NAME ? currentMapData.name : currentMapName;
                UI::Text(mapName);
            }

            if (setting_show_author != AuthorVisibility::HIDDEN)
            {
                UI::TableNextRow();
                UI::TableNextColumn();


                string authorName = setting_show_author == AuthorVisibility::SHOW_PVM_NAME ? currentMapData.author : currentAuthor;
                UI::Text(Colours::FORMAT_AUTHOR_COLOUR + authorName);
            }

            if (setting_show_pvm_grade)
            {
                UI::TableNextRow();
                UI::TableNextColumn();

                // todo: add per grade colours
                UI::Text(Colours::FORMAT_GRADE_COLOUR + "Grade: " + currentMapData.pvm_grade);
            }

            if (tableEnd)
            {
                UI::EndTable();
            }
        }

        int columns = 2;

        if (setting_show_labels)
        {
            columns++;
        }

        if (setting_show_pvm_delta)
        {
            columns++;
        }

        tableEnd = UI::BeginTable("pvm_medals", columns, UI::TableFlags::SizingFixedFit);
        bool shownPB = false;

        for (int i = ALIEN_PLUS; i >= NOOB; i--)
        {
            int medalTime = GetMedalTime(i);
            Medal medal = medals[i];

            if (medalTime <= 0)
            {
                // no such medal time so we can skip it
                continue;
            }

            if (setting_show_personal_best)
            {            
                if (personalBest != -1 && personalBest <= medalTime && !shownPB)
                {
                    InsertPB(personalBest, i);
                    shownPB = true;
                }
            }

            if (ShowPvmMedal(i))
            {                
                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(medal.GetIcon());
                
                if (setting_show_labels)
                {
                    UI::TableNextColumn();
                    UI::Text(medal.GetLabel());
                }

                UI::TableNextColumn();
                UI::Text(ReadableTime(medalTime));

                if (setting_show_pvm_delta)
                {
                    UI::TableNextColumn();
                    if (personalBest == -1)
                    {
                        UI::Text("");
                    }
                    else
                    {
                        int delta = personalBest - medalTime;
                        if (delta < 0)
                        {
                            UI::Text(Colours::TIME_DELTA_AHEAD + ReadableTime(delta * -1));
                        }
                        else
                        {
                            UI::Text(Colours::TIME_DELTA_BEHIND + ReadableTime(delta));
                        }
                    }
                }
            }
        }

        if (setting_show_personal_best && personalBest > GetMedalTime(NOOB) && !shownPB)
        {
            InsertPB(personalBest, 0);
        }
        else if (setting_show_personal_best && personalBest == -1 && !shownPB)
        {
            InsertPB(0, 0);
        }
    //    InsertPB(personalBest, 0);

        if (tableEnd)
        {
            UI::EndTable();
        }

        UI::EndGroup();

        UI::End();
    }

    void InsertPB(int pb, int medalID)
    {   
        UI::TableNextRow();

        UI::TableNextColumn();
        UI::Text(medals[medalID].GetIcon());
        
        if (setting_show_labels)
        {
            UI::TableNextColumn();
            UI::Text(Colours::TIME_PERSONAL_BEST + "PB");
        }

        UI::TableNextColumn();
        UI::Text(Colours::TIME_PERSONAL_BEST + ReadableTime(pb));

        if (setting_show_pvm_delta)
        {
            UI::TableNextColumn();
            UI::Text("");
        }

        UI::SameLine();
        UI::TextDisabled(Icons::Clipboard);
        if (UI::IsItemClicked())
        {
            string pbString = Utils::FormatForSheet(personalBest); 
            IO::SetClipboard(pbString);
            UI::ShowNotification(Icons::Clipboard + " Personal best time copied to clipboard " + pbString);
        }
    }


    bool ShowPvmMedal(int medalID)
    {
        switch (medalID)
        {
            case 1:            
                return setting_show_pvm_noob;

            case 2:
                return setting_show_pvm_intermediate;

            case 3:
                return setting_show_pvm_challenger;

            case 4:
                return setting_show_pvm_player;

            case 5:
                return setting_show_pvm_alien;

            case 6:
                return setting_show_pvm_alien_plus;

        }

        // just show w/e nonsense was requested
        return true;
    }

    uint GetMedalTime(int medalID)
    {
        return currentMapData.GetMedalTime(medalID);
        // switch (medalID)
        // {
        //     case 1:
        //         return currentMapData.pvm_noob;

        //     case 2:
        //         return currentMapData.pvm_intermediate;

        //     case 3:
        //         return currentMapData.pvm_challenger;

        //     case 4:
        //         return currentMapData.pvm_players;

        //     case 5:
        //         return currentMapData.pvm_aliens;
                
        //     case 6 :
        //         return currentMapData.pvm_aliens_plus;
        // }

        // return 0;
    }

    string ReadableTime(int time)
    {
        if (time == 0)
        {
            return "-:--.---";
        }

        return Time::Format(time);
    }

    bool ReloadPvm()
    {
        if (fetching)
        {
            return true;
        }

        Reset();
        return LoadPvmJson();
    }

    bool LoadPvmJson()
    {   
        pvmMaps = dictionary();
        pvmMapList.RemoveRange(0, pvmMapList.Length);

        string url = "https://raw.githubusercontent.com/Naxanria/tm_stuff/refs/heads/main/pvm.json";
        print("Fetching pvm info from '" + url + "'");
        Net::HttpRequest@ req = Net::HttpRequest();
        req.Url = url;

        fetching = true;
        req.Start();
        while(!req.Finished())
        {
            yield();
        }

        if (req.ResponseCode() == 204)
        {
            print("No data");
            return true;
        }
        if (req.ResponseCode() != 200)
        {
            error("Request failed: " + req.ResponseCode());
            error("Error: ");
            error(req.Body);

            return false;
        }

        pvmJson = Json::Parse(req.String());

        for (int i = 0; i < pvmJson.Length; i++)
        {
            Json::Value mapInfo = pvmJson[i];
            MapData@ mapData = MapData(mapInfo);
            // print(mapData.ToString());

            pvmMaps[mapData.uid] = mapData;
            pvmMapList.InsertLast(@mapData);
        } 
        fetching = false;

        Overview::initialized = false;

        print("Found " + pvmJson.Length + " pvm maps");

        return true;
    }

    bool CheckCurrentMap()
    {
        if (fetching)
        {
            return false;
        }

        auto app = cast<CTrackMania>(GetApp());
        
        auto map = app.RootMap;

        // make sure we are in a map
        if (map is null)
        {

            return false;
        }

        string uid = map.MapInfo.MapUid;
        if (currentMapData.uid == uid)
        {
            // no need to recreate the mapdata for same map
            return true;
        }

        // new map?
        // print("Found new map with id " + uid);

        if (pvmMaps.Exists(uid))
        {
            currentMapData = cast<MapData>(pvmMaps[uid]);
        }
        else
        {
            currentMapData = MapData();
            currentMapData.hasPvm = false;
            currentMapData.isOnSite = false;

            currentMapData.name = Text::StripFormatCodes(map.MapInfo.Name);
            currentMapData.author = map.MapInfo.AuthorNickName;
            currentMapData.uid = map.MapInfo.MapUid;
        }

        currentMapName = Text::StripFormatCodes(map.MapInfo.Name);
        currentAuthor = Text::StripFormatCodes(map.MapInfo.AuthorNickName);

        return true;
    }
}