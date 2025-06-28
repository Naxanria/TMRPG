class MapData
{
    bool hasPvm;
    bool isOnSite;
    string uid;
    uint tmxId;

    string name;
    string author;

    string pvm_grade;
    uint pvm_noob;
    uint pvm_intermediate;
    uint pvm_challenger;
    uint pvm_players;
    uint pvm_aliens;
    uint pvm_aliens_plus;

    int pb = -1;
    bool loadingPb = false;
    int idx = 0;

    MapData()
    { }

    MapData(Json::Value json)
    {
        hasPvm = true;
        isOnSite = true;

        name = json["name"];
        author = json["author"];
        tmxId = json["tmId"];
        uid = json["uid"];        

        Json::Value pvm = json["pvm"];
        pvm_noob = pvm["noob"];
        pvm_intermediate = pvm["intermediate"];
        pvm_challenger = pvm["challenger"];
        pvm_players = pvm["player"];
        pvm_aliens = pvm["alien"];
        pvm_grade = pvm["grade"];
        pvm_aliens_plus = pvm.HasKey("alien_plus") ? pvm["alien_plus"] : 0;
    }

    string ToString()
    {
        return "Name: " + name + ", Author: " + author + ", UID: " + uid;
    }

    uint GetMedalTime(int medalID)
    {
        switch (medalID)
        {
            case 1:
                return pvm_noob;

            case 2:
                return pvm_intermediate;

            case 3:
                return pvm_challenger;

            case 4:
                return pvm_players;

            case 5:
                return pvm_aliens;
                
            case 6 :
                return pvm_aliens_plus;
        }

        return 0;
    }

    void LoadPb()
    {
        if (loadingPb)
        {
            return;
        }

        loadingPb = true;

        auto rec = API::GetPlayerRecordOnMap(uid);
        if (rec !is null)
        {
            bool better = pb > 0 && rec.Time < pb;
            if (pb < 0 && rec.Time > 0 && !better)
            {
                better = true;
            }
            if (better)
            {
                pb = rec.Time;
            }
        }

        loadingPb = false;
    }

    void LoadMap()
    {
        startnew(API::LoadMapNow, uid);
    }
}