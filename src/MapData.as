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
    uint pvm_no_way;

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
        pvm_no_way = pvm.HasKey("no_way") ? pvm["no_way"] : 0;
    }

    string ToString()
    {
        return "Name: " + name + ", Author: " + author + ", UID: " + uid;
    }

}