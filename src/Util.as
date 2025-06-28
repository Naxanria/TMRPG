namespace Utils
{    
    string FormatForSheet(int time)
    {
        if (time <= 0)
        {
            return "00:00:00.000";
        }

        int min = time / 60000;
        time -= min * 60000;
        
        int sec = time / 1000;
        time -= sec * 1000;

        int ms = time;

        return LeadZeroes(2, min) + ":" + LeadZeroes(2, sec) + "." + LeadZeroes(3, ms);
    }

    string LeadZeroes(int length, int n)
    {
        string s = "";
        for (int i = 1; i < length; i++)
        {
            if (n < Math::Pow(10, i))
            {
                s += "0";
            }
        }

        return s + n;
    }

    void TimeToClipboard(int time)
    {
        string pbString = Utils::FormatForSheet(time); 
        IO::SetClipboard(pbString);
        UI::ShowNotification(Icons::Clipboard + " Personal best time copied to clipboard " + pbString);
    }
}
