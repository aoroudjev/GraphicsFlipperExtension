using System;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Diagnostics;
using System.Threading;

class NativeHost {
    struct BrowserConfig {
        public string LocalStatePath;
        public string ProcessName;
        public string Executable;
    }

    static BrowserConfig GetConfig(string browser) {
        if (browser == "chrome") {
            return new BrowserConfig {
                LocalStatePath = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "Google", "Chrome", "User Data", "Local State"),
                ProcessName = "chrome",
                Executable  = "chrome.exe"
            };
        }
        return new BrowserConfig {
            LocalStatePath = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "Microsoft", "Edge", "User Data", "Local State"),
            ProcessName = "msedge",
            Executable  = "msedge.exe"
        };
    }

    static void Main() {
        try {
            string message = ReadMessage();
            var bm = Regex.Match(message, "\"browser\"\\s*:\\s*\"(\\w+)\"");
            string browser = bm.Success ? bm.Groups[1].Value : "edge";
            var cfg = GetConfig(browser);

            if (message.Contains("\"get_status\"")) {
                bool enabled = GetState(cfg.LocalStatePath);
                SendMessage("{\"status\":\"ok\",\"enabled\":" + enabled.ToString().ToLower() + "}");
            } else if (message.Contains("\"toggle\"")) {
                SendMessage("{\"status\":\"ok\",\"restarting\":true}");
                var t = new Thread(() => DoToggleAndRestart(cfg));
                t.IsBackground = false;
                t.Start();
            } else {
                SendMessage("{\"status\":\"error\",\"message\":\"Unknown action\"}");
            }
        } catch (Exception ex) {
            try {
                string safe = ex.Message.Replace("\\", "\\\\").Replace("\"", "\\\"");
                SendMessage("{\"status\":\"error\",\"message\":\"" + safe + "\"}");
            } catch { }
        }
    }

    static string ReadMessage() {
        var stdin = Console.OpenStandardInput();
        var lenBuf = new byte[4];
        int read = 0;
        while (read < 4) read += stdin.Read(lenBuf, read, 4 - read);
        int len = BitConverter.ToInt32(lenBuf, 0);
        var buf = new byte[len];
        read = 0;
        while (read < len) read += stdin.Read(buf, read, len - read);
        return Encoding.UTF8.GetString(buf);
    }

    static void SendMessage(string json) {
        byte[] bytes = Encoding.UTF8.GetBytes(json);
        var stdout = Console.OpenStandardOutput();
        stdout.Write(BitConverter.GetBytes(bytes.Length), 0, 4);
        stdout.Write(bytes, 0, bytes.Length);
        stdout.Flush();
    }

    static bool GetState(string localStatePath) {
        if (!File.Exists(localStatePath)) return true;
        string content = File.ReadAllText(localStatePath);
        var m = Regex.Match(content,
            "\"hardware_acceleration_mode\"\\s*:\\s*\\{\\s*\"enabled\"\\s*:\\s*(true|false)");
        return !m.Success || m.Groups[1].Value == "true";
    }

    static void DoToggleAndRestart(BrowserConfig cfg) {
        Thread.Sleep(500);

        foreach (var p in Process.GetProcessesByName(cfg.ProcessName)) {
            try { p.Kill(); } catch { }
        }
        Thread.Sleep(2000);

        if (File.Exists(cfg.LocalStatePath)) {
            string content = File.ReadAllText(cfg.LocalStatePath);
            bool current = GetState(cfg.LocalStatePath);
            string next = (!current).ToString().ToLower();

            content = Regex.Replace(content,
                "(\"hardware_acceleration_mode\"\\s*:\\s*\\{\\s*\"enabled\"\\s*:\\s*)(true|false)",
                "${1}" + next);
            content = Regex.Replace(content,
                "(\"hardware_acceleration_mode_previous\"\\s*:\\s*)(true|false)",
                "${1}" + next);

            File.WriteAllText(cfg.LocalStatePath, content, new UTF8Encoding(false));
        }

        Process.Start(new ProcessStartInfo {
            FileName = cfg.Executable,
            Arguments = "--restore-last-session",
            UseShellExecute = true
        });
    }
}
