//+------------------------------------------------------------------+
//|                                                    CDKLogger.mqh |
//|                                                  Denis Kislitsyn |
//|                                              http://kislitsyn.me |
//|
//| 2025-06-20: [+] LSF_LOG(msg, log_level) define for Logger.Log()
//| 2025-05-16: [*] Fixed error log with NO level
//| 2025-01-24:
//|   [+] LSF_* with lazy StringFormat call
//| 2024-11-25:
//|   [+] LSF define to add __FUNCTION__ & __LINE__
//| 2024-10-13: 
//|   [+] Filter list. Message will be logged only if contains one of filter list str.
//| 2024-06-26: 
//|   [*] Class is renamed to CDKLogger
//|   [+] Init(const string _name, const LogLevel _level, const string _format = NULL)
//| 2024-06-20: 
//|   [+] Assert method with same message for True and False
//|
//| USAGE:
//
//  CDKLogger logger;
//  
//  // STEP 1. Init Logger with "MyLoggerName" name and INFO level
//  logger.Init("MyLoggerName", INFO);
//  
//  // You can change default logger format "%name%:[%level%] %message%" to your own
//  // Use any pattern combination 
//  logger.Format = "%YYYY%-%MM%-%DD% %hh%:%mm%-%ss% - %name%:[%level%] %message%"; 
// 
//  // STEP 2. If you like to filter message only with substings,
//  //         fill the FilterInList 
//  // 2.1. Add a substings to FilterIntList
//  logger.FilterInList.Add("Including-Substring-#1");        
//  logger.FilterInList.Add("Including-Substring-#2");        
//  
//  // 2.2. Split string by ";" separator to add all substrings to FilterInList in one line
//  logger.FilterInFromStringWithSep("Including-Substring-#3;Including-Substring-#4", ";");  
//
//  // STEP 3. If you like to filter OUT message with substings, but leave all others,
//  //         fill the FilterOutList 
//  // 3.1. Add a substings to FilterOutList
//  logger.FilterOutList.Add("Excluding-Substring-#1");        
//  logger.FilterOutList.Add("Excluding-Substring-#2");        
//  
//  // 3.2. Split string by ";" separator to add all substrings to FilterOutList in one line
//  logger.FilterOutFromStringWithSep("Excluding-Substring-#3;Excluding-Substring-#4", ";");  // use Filter In put your filter str sep by ; here
//
//  // STEP 4. Logging
//  logger.Debug("Debug: Including-Substring-#1", false);                  // Debug with no Alert
//  logger.Info("Info: Including-Substring-#1", true);                     // Info with Alert dialog
//  logger.Warn("Warn: Including-Substring-#1"); 
//  logger.Error("Error: Including-Substring-#1: Excluding-Substring-#1"); // Skipped because of FilterOutList
//  logger.Critical("Critical: Including-Substring-#1");
//  
//  logger.Assert(true, 
//                "Log msg if true", INFO,   // if ok
//                "Log msg if false", ERROR, // if fails
//                true);                     // Show Alert as well
//  logger.Assert(true, 
//                "Same msg for true & false", 
//                INFO,   // Log level if ok
//                ERROR,  // Log level if fails
//                false); // No Alert 
//+------------------------------------------------------------------+

#property copyright "Denis Kislitsyn"
#property link      "http:/kislitsyn.me"
#property version   "0.0.4"

#define LSF(_sf) __FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf

#define LSF_LOG(_sf, _log_level) Logger.Log(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf, _log_level);
#define LSF_DEBUG(_sf)    if(DEBUG >= Logger.Level)    Logger.Debug(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf);
#define LSF_INFO(_sf)     if(INFO >= Logger.Level)     Logger.Info(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf);
#define LSF_WARN(_sf)     if(WARN >= Logger.Level)     Logger.Warn(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf);
#define LSF_ERROR(_sf)    if(ERROR >= Logger.Level)    Logger.Error(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf);
#define LSF_CRITICAL(_sf) if(CRITICAL >= Logger.Level) Logger.Critical(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf);
#define LSF_ASSERT(_cond, _sf, _ok_ll, _fail_ll)  {if(_cond) { \
                                                    if(_ok_ll >= Logger.Level)  \
                                                      Logger.Log(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf, _ok_ll); \
                                                  } else  \
                                                    if(_fail_ll >= Logger.Level)  \
                                                      Logger.Log(__FUNCTION__ + "/" + (string)__LINE__ + ": " + _sf, _fail_ll);} 
                                                  


#include <Arrays\ArrayString.mqh>

enum LogLevel {
  DEBUG=10,
  INFO=20,
  WARN=30,
  ERROR=40,
  CRITICAL=50,
  NO=100,
};
   
class CDKLogger {
  protected:
    bool            CDKLogger::IsMessageFitsFilterList(const string _msg, CArrayString& _filter_list);    
    int             CDKLogger::FillListFromStringWithSep(string _str, const string _sep, CArrayString& _list);
  public:
    string          Name;          // Logger name
    LogLevel        Level;         // Level
    string          Format;        // Avaliable patterns: %YYYY%, %MM%, %DD%, %hh%, %mm%, %ss%, %name%, %level%, %message%
    CArrayString    FilterInList;  // List of strings that must be present in the message to be logged
    CArrayString    FilterOutList; // List of strings that must be NOT present in the message to be logged

    void            CDKLogger::CDKLogger(void);
    void            CDKLogger::CDKLogger(string LoggerName, LogLevel MessageLevel = LogLevel(INFO));
    
    void            CDKLogger::Init(const string _name, const LogLevel _level, const string _format = NULL);
    int             CDKLogger::FilterInFromStringWithSep(string _str, const string _sep);
    int             CDKLogger::FilterOutFromStringWithSep(string _str, const string _sep);
    
    string          CDKLogger::Log(string MessageTest, LogLevel MessageLevel = LogLevel(INFO), const bool ToAlert = false);  
    string          CDKLogger::Debug(string MessageTest, const bool ToAlert = false);
    string          CDKLogger::Info(string MessageTest, const bool ToAlert = false);
    string          CDKLogger::Warn(string MessageTest, const bool ToAlert = false);
    string          CDKLogger::Error(string MessageTest, const bool ToAlert = false);
    string          CDKLogger::Critical(string MessageTest, const bool ToAlert = false);
    string          CDKLogger::Assert(const bool aCondition, 
                                      const string aTrueMessage, const LogLevel aTrueLevel = INFO, 
                                      const string aFalseMessage = "", const LogLevel aFalseLevel = ERROR,
                                      const bool ToAlert = false);
    string          CDKLogger::Assert(const bool aCondition, 
                                      const string aMessage, 
                                      const LogLevel aTrueLevel = INFO, 
                                      const LogLevel aFalseLevel = ERROR,
                                      const bool ToAlert = false);
};

//+------------------------------------------------------------------+
//| Check _msg contains one of _filter_list str
//+------------------------------------------------------------------+
bool CDKLogger::IsMessageFitsFilterList(const string _msg, CArrayString& _filter_list) {    
  for(int i=0;i<_filter_list.Total();i++) 
    if(StringFind(_msg, _filter_list.At(i))>=0)
      return true;
  
  return false;
}

//+------------------------------------------------------------------+
//| Construtor
//+------------------------------------------------------------------+
void CDKLogger::CDKLogger(void) {
  Level = LogLevel(INFO);
}

//+------------------------------------------------------------------+
//| Construtor
//+------------------------------------------------------------------+
void CDKLogger::CDKLogger(string LoggerName, LogLevel MessageLevel = LogLevel(INFO)) {
  Name = LoggerName;
  Level = LogLevel(INFO);
}

//+------------------------------------------------------------------+
//| Init Logger
//+------------------------------------------------------------------+
void CDKLogger::Init(const string _name, const LogLevel _level, const string _format = NULL) {
  Name = _name;
  Level = _level;
  if (_format == NULL) Format = "%name%:[%level%] %message%";
  else Format = _format;
}               

//+------------------------------------------------------------------+
//| Splits string into parts using _sep and fills _list.
//| Returns the number of added strings to _list.
//+------------------------------------------------------------------+
int CDKLogger::FillListFromStringWithSep(string _str, const string _sep, CArrayString& _list) {
  int chunk_cnt = 0;
  int idx = StringFind(_str, _sep);
  while(idx >= 0) {
    string chunk = StringSubstr(_str, 0, idx);
    if (chunk != "") {
      _list.Add(chunk);
      chunk_cnt++;
    }
    
    _str = StringSubstr(_str, idx+StringLen(_sep));
    idx = StringFind(_str, _sep);
  }
  
  if(_str != "") {
    _list.Add(_str);
    chunk_cnt++;
  }
  
  return chunk_cnt;  
}

//+------------------------------------------------------------------+
//| Splits string into parts using _sep and fills Filter In list.
//| Returns the number of added strings.
//+------------------------------------------------------------------+
int CDKLogger::FilterInFromStringWithSep(string _str, const string _sep) {
  return FillListFromStringWithSep(_str, _sep, FilterInList);
}

//+------------------------------------------------------------------+
//| Splits string into parts using _sep and fills Filter Out list.
//| Returns the number of added strings.
//+------------------------------------------------------------------+
int CDKLogger::FilterOutFromStringWithSep(string _str, const string _sep) {
  return FillListFromStringWithSep(_str, _sep, FilterOutList);
}

//+------------------------------------------------------------------+
//| Output a message if it meets the following conditions
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Log(string MessageTest, LogLevel MessageLevel = LogLevel(INFO), const bool ToAlert = false) {
  if(MessageLevel == NO)
    return "";
  if(MessageLevel < Level) 
    return "";
  if(FilterInList.Total() > 0 && !IsMessageFitsFilterList(MessageTest, FilterInList)) 
    return "";
  if(FilterOutList.Total() > 0 && IsMessageFitsFilterList(MessageTest, FilterOutList)) 
    return "";    
  
  string message = "";
  if (Format != "") {         
    message = Format;
    datetime dt_local = TimeLocal();
    string date = TimeToString(dt_local, TIME_DATE);
    string sec = TimeToString(dt_local, TIME_SECONDS);
    
    
    StringReplace(message, "%YYYY%", StringSubstr(date, 0, 4));
    StringReplace(message, "%MM%", StringSubstr(date, 5, 2));
    StringReplace(message, "%DD%", StringSubstr(date, 8, 2));
    
    StringReplace(message, "%hh%", StringSubstr(sec, 0, 2));
    StringReplace(message, "%mm%", StringSubstr(sec, 3, 2));
    StringReplace(message, "%ss%", StringSubstr(sec, 6, 2));
    
    StringReplace(message, "%level%", EnumToString(MessageLevel));
    StringReplace(message, "%name%", Name);
    StringReplace(message, "%message%", MessageTest);
    
    Print(message);
    if (ToAlert) Alert(message);
  }
  else {
    message = StringFormat("[%s]:%s:[%s] %s",
                           TimeToString(TimeLocal()),
                           Name,
                           EnumToString(MessageLevel), 
                           MessageTest);
    Print(message); 
    if (ToAlert) Alert(message);
  }
  
  return message;
}; 

//+------------------------------------------------------------------+
//| Debug msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Debug(string MessageTest, const bool ToAlert = false) {
  return Log(MessageTest, LogLevel(DEBUG), ToAlert);
};           

//+------------------------------------------------------------------+
//| Info msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Info(string MessageTest, const bool ToAlert = false) {
  return Log(MessageTest, LogLevel(INFO), ToAlert);
}; 

//+------------------------------------------------------------------+
//| Warn msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Warn(string MessageTest, const bool ToAlert = false) {
  return Log(MessageTest, LogLevel(WARN), ToAlert);
};         

//+------------------------------------------------------------------+
//| Error msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Error(string MessageTest, const bool ToAlert = false) {
  return Log(MessageTest, LogLevel(ERROR), ToAlert);
};         

//+------------------------------------------------------------------+
//| Critical msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Critical(string MessageTest, const bool ToAlert = false) { 
  return Log(MessageTest, LogLevel(CRITICAL), ToAlert);
};  

//+------------------------------------------------------------------+
//| Assert msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Assert(const bool aCondition, 
                       const string aTrueMessage, const LogLevel aTrueLevel = INFO, 
                       const string aFalseMessage = "", const LogLevel aFalseLevel = ERROR,
                       const bool ToAlert = false) {
  if (!aCondition) {
    if (aFalseMessage != "")
      return Log(aFalseMessage, aFalseLevel, ToAlert);
  }
  else 
    return Log(aTrueMessage, aTrueLevel, ToAlert);
    
  return "";
}       

//+------------------------------------------------------------------+
//| Assert msg
//| Returns logged messgage or "" is it wan not logged
//+------------------------------------------------------------------+
string CDKLogger::Assert(const bool aCondition, 
                       const string aMessage, 
                       const LogLevel aTrueLevel = INFO, 
                       const LogLevel aFalseLevel = ERROR,
                       const bool ToAlert = false) {
  return Assert(aCondition, aMessage, aTrueLevel, aMessage, aFalseLevel, ToAlert);
}   