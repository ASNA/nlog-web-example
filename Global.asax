<%@ Application Language="AVR"%>

<script runat="server">

	BegSr Application_Start
		DclSrParm sender Type(*Object)
		DclSrParm e Type(EventArgs)

		// Code that runs on application startup

	EndSr

	BegSr Application_End
		DclSrParm sender Type(*Object)
		DclSrParm e Type(EventArgs)

		//  Code that runs on application shutdown
	EndSr
        
	BegSr Application_Error
		DclSrParm sender Type(*Object)
		DclSrParm e Type(EventArgs)

        DclFld logger Type(NLog.Logger) 
        DclFld message Type(*String)
        DclFld ex Type(Exception) 

        ex = Server.GetLastError()

        // The following test is surely redundant (you only get here if an unhandled exception
        // occurs) but the MS docs show it in their examples so I am including it here.
        If (ex *Is HttpUnhandledException) 
            // Log the error to the Windows Event Log.
            BegUsing eventLogEntry Type(System.Diagnostics.EventLog) +
                                   Value(*New System.Diagnostics.EventLog("CoolWebApp"))  
                message = GetErrorText(ex) 
                           
                eventLogEntry.Source = "Production"
                eventLogEntry.WriteEntry(message, System.Diagnostics.EventLogEntryType.Error)
            EndUsing 

            // Log the error to the log file in the '/logs' directory. 
            logger = NLog.LogManager.GetLogger("MyLogger") 
            logger.Fatal(ex, ex.Message)

            Server.ClearError()
            Response.Redirect("Error.aspx") 
            // Server.Transfer("Error.aspx", *true)
        EndIf     
	EndSr

    BegFunc GetErrorText Type(*String) 
        DclSrParm ex Type(Exception) 
    
        DclFld sb Type(StringBuilder) New()
        DclFld messages Type(Stack(*Of String)) New()
        DclFld counter Type(*Integer4) 
        
        sb.AppendLine("A fatal exception has occurred.") 
        sb.AppendLine("Exceptions are shown inner-most first. The first exception probably caused the issue.") 
      
        CollectExceptionMessagesByInnerMostFirst(ex, messages)

        counter = 0
        ForEach message Type(*String) Collection(messages) 
            counter += 1
            sb.AppendLine(String.Format("  Exception #{0}: {1}", counter, message)) 
        EndFor

        sb.AppendLine("See the application log in the '/logs' directory for more detail.")  

        LeaveSr sb.ToString()
    EndFunc

    BegSr CollectExceptionMessagesByInnerMostFirst  
        DclSrParm ex Type(Exception) 
        DclSrParm messages Type(Stack(*Of *String)) 

        DoWhile ex <> *Nothing
            messages.Push(ex.Message)
            ex = ex.InnerException
        EndDo 
    EndSr

	BegSr Session_Start
		DclSrParm sender Type(*Object)
		DclSrParm e Type(EventArgs)

		// Code that runs when a new session is started

	EndSr

	BegSr Session_End
		DclSrParm sender Type(*Object)
		DclSrParm e Type(EventArgs)

		// Code that runs when a session ends. 
		// Note: The Session_End event is raised only when the sessionstate mode
		// is set to InProc in the Web.config file. If session mode is set to StateServer 
		// or SQLServer, the event is not raised.

	EndSr

       
</script>
