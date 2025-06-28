namespace PVM
{
    namespace Overview
    {
        [Setting name="show_overview" hidden]
        bool showOverview = true;
        bool initialized = false;

        void Init()
        {
            print("Initialization");
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
                }

                RenderStats();

                UI::BeginChild("pvm maps");
                UI::BeginGroup();
                // name, author, current medal, Play, TMX
                if (UI::BeginTable("pvm overview", 7, UI::TableFlags::SizingFixedFit))
                {
                    UI::TableSetupColumn("name", UI::TableColumnFlags::WidthFixed, nameWidth);
                    UI::TableSetupColumn("author", UI::TableColumnFlags::WidthStretch);
                    UI::TableSetupColumn("grade", UI::TableColumnFlags::WidthFixed, gradeWidth);
                    UI::TableSetupColumn("medal", UI::TableColumnFlags::WidthFixed, medalWidth);
                    UI::TableSetupColumn("time", UI::TableColumnFlags::WidthFixed, timeWidth);
                    UI::TableSetupColumn("playBtn");
                    UI::TableSetupColumn("tmxBtn");

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
            UI::Text(mapData.name);

            UI::TableNextColumn();
            UI::Text("\\$777by\\$z " + mapData.author);

            UI::TableNextColumn();
            UI::Text(mapData.pvm_grade);

            UI::TableNextColumn();
            UI::Text(GetMedalToShow(mapData));

            UI::TableNextColumn();
            string timeText = mapData.pb == -1 ? "\\$666no pb\\$z" : PVM::ReadableTime(mapData.pb);
            UI::Text(timeText);

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
            UI::PopID();
        }

        string GetMedalToShow(MapData map)
        {
            int pb = map.pb;
            if (pb == -1)
            {
                //print("requesting info for " + map.name);
                //UpdatePB(map);
                return "\\$888" + Icons::Kenney::Radio;
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
            print("Syncing pbs");
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
    }
}