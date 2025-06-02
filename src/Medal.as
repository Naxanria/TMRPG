class Medal
{
    int idx;
    string label;
    string colour;
    string icon;

    Medal()
    { }

    Medal(int idx, string label, string colour, string icon)
    {
        this.idx = idx;
        this.label = label;
        this.colour = colour;
        this.icon = icon;
    }

    string GetLabel()
    {
        return label;
    }

    string GetIcon()
    {
        return colour + icon;
    }
}