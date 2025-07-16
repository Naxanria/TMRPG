namespace Logging
{
    [Setting name="LogLevel" category="General"]
    LogLevel setting_loglevel = LogLevel::Info;

    enum LogLevel
    {
        Error,
        Warn,
        Info,
        Debug,
        Trace
    }

    string GetPluginName()
    {
        return Meta::ExecutingPlugin().Name;
    }

    void Error(const string &in msg, bool showNotification = false)
    {
        if (setting_loglevel >= LogLevel::Error)
        {
            if (showNotification)
            {
                vec4 col = vec4(1.0, 0., 0., 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + GetPluginName() + " - Error", msg, 10000);
            }

            error("[ERROR] " + msg);
        }
    }

    void Warn(const string &in msg, bool showNotification = false)
    {
        if (setting_loglevel >= LogLevel::Warn)
        {
            if (showNotification)
            {
                vec4 col = vec4(1.0, 0.7, 0., 1.0);
                UI::ShowNotification(Icons::Kenney::ButtonTimes + " " + GetPluginName() + " - Warning", msg, 5000);
            }

            warn("[WARN] " + msg);
        }
    }

    void Info(const string &in msg)
    {
        if (setting_loglevel >= LogLevel::Info)
        {
            print("[INFO] " + msg);
        }
    }

    void Debug(const string &in msg)
    {
        if (setting_loglevel >= LogLevel::Debug)
        {
            print("[DEBUG] " + msg);
        }
    }

    void Trace(const string &in msg)
    {
        if (setting_loglevel >= LogLevel::Trace)
        {
            print("[TRACE] " + msg);
        }
    }

}