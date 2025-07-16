namespace PVM
{
    namespace Overview
    {
        [Setting name="Show Tooltip" category="PVM LIST"]
        bool setting_pvm_list_show_tooltip = true;
        [Setting name="Show Thumbnail in tooltip" category="PVM LIST" if="setting_pvm_list_show_tooltip"]
        bool setting_pvm_list_show_thumbnail = true;
        //[Setting name="Use Tmx Thumbnail" category="PVM LIST" if="setting_pvm_list_show_thumbnail" hidden]
        bool setting_pvm_list_use_tmx = true;
        [Setting name="Thumbnail Size" category="PVM LIST" min="128" max="512" if="setting_pvm_list_show_thumbnail"]
        int setting_pvm_list_thumbnail_size = 256;

        Medal noPbMedal = Medal(-1, "Unfinished", "\\$888", Icons::Kenney::Radio);

        namespace Stats
        {
            int totalMaps = 0;
            
            int totalUnfinished = 0;
            
            int totalFinished = 0;
            int totalNoob = 0;
            int totalIntermediate = 0;
            int totalChallenger = 0;
            int totalPlayer = 0;
            int totalAlien = 0;
            int totalAlienPlus = 0;

            void Update()
            {
                totalMaps = PVM::pvmMapList.Length;
                for (int i = 0; i < totalMaps; i++)
                {
                    MapData map = PVM::pvmMapList[i];
                    int medal = PVM::GetBestMedalOnMap(map);
                    if (medal == -1)
                    {
                        totalUnfinished++;
                        continue;
                    }

                    totalFinished++;
                    if (medal >= PVM::NOOB)
                    {
                        totalNoob++;
                    }
                    if (medal >= PVM::INTERMEDIATE)
                    {
                        totalIntermediate++;
                    }
                    if (medal >= PVM::Challenger)
                    {
                        totalChallenger++;
                    }
                    if (medal >= PVM::PLAYER)
                    {
                        totalPlayer++;
                    }
                    if (medal >= PVM::ALIEN)
                    {
                        totalAlien++;
                    }
                    if (medal >= PVM::ALIEN_PLUS)
                    {
                        totalAlienPlus++;
                    }
                }
            }

            void UpdateSingle(MapData& map)
            {

            }

            void Reset()
            {
                totalMaps = PVM::pvmMapList.Length;

                totalUnfinished = 0;
                totalFinished = 0;
                totalNoob = 0;
                totalIntermediate = 0;
                totalChallenger = 0;
                totalPlayer = 0;
                totalAlien = 0;
                totalAlienPlus = 0;
            }

            void RenderStats()
            {
                UI::BeginGroup();
                
                UI::Text("");
                _renderStat(totalUnfinished, noPbMedal);
                _renderStat(totalFinished, PVM::medals[PVM::NO_MEDAL]);
                _renderStat(totalNoob, PVM::medals[PVM::NOOB]);
                _renderStat(totalIntermediate, PVM::medals[PVM::INTERMEDIATE]);
                _renderStat(totalChallenger, PVM::medals[PVM::Challenger]);
                _renderStat(totalPlayer, PVM::medals[PVM::PLAYER]);
                _renderStat(totalAlien, PVM::medals[PVM::ALIEN]);
                _renderStat(totalAlienPlus, PVM::medals[PVM::ALIEN_PLUS]);                

                UI::EndGroup();
            }

            void _renderStat(int amount, Medal medal)
            {
                if (medal is null)
                {
                    medal = noPbMedal;
                }

                UI::SameLine();
                UI::Text(medal.GetIcon() + "\\$z (" + amount + "/" + totalMaps + ")");    
                if (UI::IsItemHovered())            
                {
                    UI::BeginTooltip();
                    UI::Text(medal.label);
                    UI::EndTooltip();
                }
            }
        }

        [Setting name="show_overview" hidden]
        bool showOverview = true;
        bool initialized = false;

        void Init()
        {
            Logging::Debug("Initialization of pvm list window");
            if (initialized)
            {
                return;
            }

            for (int i = 0; i < PVM::pvmMapList.Length; i++)
            {
                PVM::pvmMapList[i].idx = i == 0 ? 0 : i % 3 + 1;
            }
            startnew(SyncPbs);

            initialized = true;
        }

        void Render()
        {
            if (!showOverview)
            {
                return;
            }

            if (!initialized)
            {
                Init();
            }

            vec2 size = vec2(800, 600);
            vec2 pos = (vec2(Draw::GetWidth(), Draw::GetHeight()) - size) / 2;

            UI::SetNextWindowSize(int(size.x), int(size.y));
            UI::SetNextWindowPos(int(pos.x), int(pos.y));
            float nameWidth = Draw::MeasureString("AAAAAAAAAAAAAAAAAAAAAAAA").x;
            float timeWidth = Draw::MeasureString("10:59:59.999").x;
            float medalWidth = Draw::MeasureString(PVM::medals[PVM::ALIEN_PLUS].GetIcon()).x;
            float gradeWidth = Draw::MeasureString("Omniscient").x;

            if (UI::Begin("PVM Overview", showOverview))
            {
                if (_done < PVM::pvmMapList.Length)
                {                    
                    UI::ProgressBar(float(_done) / PVM::pvmMapList.Length, vec2(size.x, 8));
                    Stats::Reset();
                    Stats::Update();
                }

                Stats::RenderStats();

                UI::BeginChild("pvm maps");
                UI::BeginGroup();
                // name, author, current medal, Play, TMX
                if (UI::BeginTable("pvm overview", 6, UI::TableFlags::SizingFixedFit | UI::TableFlags::RowBg))
                {
                    UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, nameWidth);
                    UI::TableSetupColumn("author", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("grade", UI::TableColumnFlags::WidthFixed, gradeWidth);
                    UI::TableSetupColumn("medal", UI::TableColumnFlags::WidthFixed, medalWidth + timeWidth + 1);
                    //UI::TableSetupColumn("time", UI::TableColumnFlags::WidthFixed, timeWidth);
                    UI::TableSetupColumn("playBtn");
                    UI::TableSetupColumn("tmxBtn");
                    shownTooltip = false;

                    UI::ListClipper clip(PVM::pvmMapList.Length);
                    while (clip.Step())
                    {
                        for (int i = clip.DisplayStart; i < clip.DisplayEnd && i < PVM::pvmMapList.Length; i++)
                        {
                            RenderMapInfo(PVM::pvmMapList[i], i);
                        }
                    }
                 
                    UI::EndTable();
            
                }

                UI::EndGroup();
                UI::EndChild();
                UI::End();
            }
        }

        void RenderStats()
        {

        }

        void RenderMapInfo(MapData& mapData, int idx)
        {
            UI::PushID(mapData.uid);
            
            UI::TableNextRow();

            UI::TableNextColumn();
            
            vec2 startPos = UI::GetCursorScreenPos();
            UI::Text(mapData.name);
            // PVMTooltip(mapData);

            UI::TableNextColumn();
            UI::Text("\\$777by\\$z " + mapData.author);
            // PVMTooltip(mapData);

            UI::TableNextColumn();
            UI::Text(mapData.pvm_grade);
            // PVMTooltip(mapData);

            UI::TableNextColumn();            
            string timeText = mapData.pb == -1 ? "\\$666no pb\\$z" : PVM::ReadableTime(mapData.pb);
            UI::Text(GetMedalToShow(mapData) + " \\$z" + timeText);
            // PVMTooltip(mapData);
            if (UI::IsItemClicked())
            {
                Utils::TimeToClipboard(mapData.pb);
            }
            // AddTimeTooltip(mapData);
            // PVMTooltip(mapData);

            UI::TableNextColumn();
            if (UI::Button("Play"))
            {                
                if (PVM::currentMapData !is null && PVM::currentMapData.uid != mapData.uid || PVM::currentMapData is null)
                {
                    UI::ShowNotification("Loading map " + mapData.name);
                    mapData.LoadMap();
                    showOverview = false;
                }                
            }

            UI::TableNextColumn();
            if (UI::Button("TMX"))
            {
                OpenBrowserURL("https://trackmania.exchange/mapshow/" + mapData.tmxId);
            }
            vec2 endPos = UI::GetCursorScreenPos();
            endPos.x = endPos.x + UI::GetItemRect().z;
            UI::PopID();
            
            PVMTooltip(mapData, vec4(startPos, endPos));
            
        }

        string GetMedalToShow(MapData map)
        {
            int pb = map.pb;
            if (pb == -1)
            {
                //print("requesting info for " + map.name);
                //UpdatePB(map);
                return noPbMedal.GetIcon();
            }

            for (int i = PVM::ALIEN_PLUS; i >= PVM::NOOB; i--)
            {
                if (pb <= map.GetMedalTime(i))
                {
                    Medal medal = PVM::medals[i];
                    return medal.GetIcon();
                }
            }

            return medals[0].GetIcon();
        }

        int _done = 0;
        MapData@[] updating;
        void SyncPbs()
        {      
            _done = 1;     
            int max = 10;

            int i = 0;
            Logging::Debug("Syncing pvm pbs");
            while (i < PVM::pvmMapList.Length)
            {
                for (int t = 0; t < updating.Length; t++)
                {
                    if (!updating[t].loadingPb)
                    {
                        updating.RemoveAt(t--);
                        _done++;
                    }
                }

                if (updating.Length <= max)
                {
                    MapData@ map = PVM::pvmMapList[i++];
                    map.LoadPb();
                    updating.InsertLast(map);
                }

                yield();
            }
        }

        MapData@ GetMapData(string uid)
        {
            int idx = GetMapDataIndex(uid);
            return idx == -1 ? MapData() : PVM::pvmMapList[idx];
        }

        int GetMapDataIndex(string uid)
        {
            for (int i = 0; i < PVM::pvmMapList.Length; i++)
            {
                if (PVM::pvmMapList[i].uid == uid)
                {
                    return i;
                }
            }
            return -1;
        }

        bool shownTooltip = false;
        void PVMTooltip(MapData& map, vec4 rowSize)
        {
            if (!setting_pvm_list_show_tooltip)
            {
                return;
            }

            vec2 mpos = UI::GetMousePos();
            if (!Utils::IsInside(mpos, rowSize) || shownTooltip)
            {
                return;
            }

            UI::BeginTooltip();
            shownTooltip = true;

            vec2 cpos = UI::GetCursorPos();
            float x = cpos.x;
            if (setting_pvm_list_show_thumbnail)
            {
                CachedImage@ img = Images::GetFromTmxId(map.tmxId);
                if (img.texture !is null)
                {
                    UI::Image(img.texture, Utils::GetResized(img.texture.GetSize(), setting_pvm_list_thumbnail_size));                 
                }
                else
                { 
                    if (img.error)
                    {
                        if (img.unsupportedFormat)
                        {
                            UI::Text("\\$f00??");
                            UI::SameLine();
                        }
                        else if (img.notFound)
                        {
                            UI::Text("\\$f00404");
                            UI::SameLine();
                        }
                    }
                    string hourglass = Utils::GetHourGlass();
                    UI::Text(hourglass);
                }
            }
            for (int i = PVM::ALIEN_PLUS; i >= PVM::NOOB; i--)
            {
                uint time = map.GetMedalTime(i);
                if (time == 0)
                {
                    continue;
                }
                UI::SetCursorPosX(x);
                UI::Text(medals[i].GetIcon());
                UI::SameLine();

                UI::Text(PVM::ReadableTime(time));
            }
            UI::EndTooltip();
        }
    }
}