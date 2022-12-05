
>This ASNA Visual RPG for .NET example shows how to use NLog to log application errors in ASP.NET. See [the Windows NLog example](https://github.com/ASNA/nlog-windows-example) to read about the details of NLog. All of that information applies to Web use. The primary thing that changes is that the log isn't stored in AppData folder, but rather in the root of the Web app. 


### ASP.NET Global Error Handling 

To catch unhandled exceptions in an AVR for .NET ASP.NET Web app you need to enable global error handling. If you've not already done that, see the [MS docs on ASP.NET WebForms global error handling](https://learn.microsoft.com/en-us/aspnet/web-forms/overview/getting-started/getting-started-with-aspnet-45-web-forms/aspnet-error-handling) for details on how to do that. 

You can also read more about using global error handling with AVR in [this example](https://github.com/ASNA/global-asp-net-exception-handling).



### Writing to the Windows event log

This section doesn't directly relate to NLog, but rather it uses built-in .NET facilities to write to the Windows Event Log. Administrators who watch the Windows Event Log regular may want to see errors logged here.

You don't need to log a great deal of detail here, just enough to make the administrators aware of the issue. Additional detail is logged with NLog. 


#### Use PowerShell to manage Windows Event Log

You need to create a new Event Log and an Event log source first. You can do this very easily with PowerShell.

Register a new Event Log and Event Log source with the Windows Event Log

```
New-EventLog -LogName CoolWebApp -Source "Production"
```

Unregister an Event Log

```
Remove-Eventlog -logname "CoolWebApp"
```

Show ten most recent entries in a log

```
get-eventlog -logname CoolWebApp -newest 10
```

The Systems.Diagnostics namespace enables writing to the Windows Event Log:

```
BegUsing eventLogEntry Type(System.Diagnostics.EventLog) +
                       Value(*New System.Diagnostics.EventLog("CoolWebApp"))  
    message = GetErrorText(ex) 
               
    eventLogEntry.Source = "Production"
    eventLogEntry.WriteEntry(message, System.Diagnostics.EventLogEntryType.Error) 
EndUsing 
```


#### ASP.NET NLog nlog.config configuration file

The entire ASP.NET NLog nlog.config configuration file is shown below.

```
<?xml version="1.0" encoding="utf-8" ?>
<nlog xmlns="http://www.nlog-project.org/schemas/NLog.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.nlog-project.org/schemas/NLog.xsd NLog.xsd"
      autoReload="true"
      throwExceptions="false"
      throwConfigExceptions="true"
      internalLogLevel="Off"
      internalLogFile="c:\temp\nlog-internal.log">

    <!-- optional, add some variables
  https://github.com/nlog/NLog/wiki/Configuration-file#variables
  -->
    <variable name="logLevel" value="Error" />

    <targets>

        <!--
    add your targets here
    See https://github.com/nlog/NLog/wiki/Targets for possible targets.
    See https://github.com/nlog/NLog/wiki/Layout-Renderers for the possible layout renderers.
    -->

        <!--  Write events to a file with the date in the filename.  -->
        <target
            xsi:type="File"
            name="logfile"
            fileName="${basedir}/logs/${shortdate}.log"
            layout="${longdate} ${uppercase:${level}} ${message} ${exception} [${stacktrace}] ${onexception:${newline}EXCEPTION OCCURRED\:${newline}${exception:format=type,message,stacktrace,method:maxInnerExceptionLevel=5:innerFormat=type,message,method}}" 
        />
    </targets>

    <rules>
        <logger name="*" minlevel="${var:logLevel}" writeTo="logfile" />
    </rules>
</nlog>

```

The only difference between it and the Windows NLog configuration file is the location NLog file. 

The Windows log file name is configured to write to the AppData folder: 

```
fileName="${specialfolder:folder=ApplicationData}/winapp/logs/${shortdate}.log"
```

The Web log file name is configured to write to the root directory of the Web app:

```
fileName="${basedir}/logs/${shortdate}.log"
```


