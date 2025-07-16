class MapCard
{
    float border_size = 3.0;
    float border_rounding = 30.0;

    MapData@ map;

    MapCard(MapData@ map)
    {
        this.map = map;
    }

    void Render(float x, float y)
    {
        vec4 rect = vec4(x, y, 100, 100);
        // render image background
        // render border, colour dependent pvm grade if exists
        // UI::DrawList::AddRect(rect, GetBorderColor(), border_rounding, border_size);
        // render mapname + author
        
        // render player time if exists
        // render pvm medals if pvm


    }

    vec4 GetBorderColor()
    {
        if (map.hasPvm)
        {
            // todo: return grade colour
            return Colours::GRADE_COLOUR_E;
        }

        return Colours::COL_WHITE;
    }
}