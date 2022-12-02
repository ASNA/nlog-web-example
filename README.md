


See [the Windows NLog example](https://github.com/ASNA/nlog-windows-example) to read about the details of NLog. All of that information applies to Web use. The one thing that changes is that the log isn't stored in AppData folder, but rather in the root of the Web app. 










### Writing to the Windows event log

This An optional logging feature 


https://github.com/ASNA/nlog-windows-example### 


Use PowerShell to manage Windows Event Log

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