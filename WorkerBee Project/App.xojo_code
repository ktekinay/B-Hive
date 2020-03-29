#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  
		  //**********************************************************/
		  //*                                                        */
		  //*       Get the object that will handle processing       */
		  //*                                                        */
		  //**********************************************************/
		  
		  
		  MyWorkerBee = new ExampleWorkerBee
		  
		  
		  
		  
		  //
		  // Expect a switch with the IPC path
		  //
		  const kIPCPathSwitch as string = "--bhiveipc="
		  
		  //
		  // Format of the data will be Base64-encoded path
		  //
		  var ipcPath as string
		  for each arg as string in args
		    if arg.BeginsWith( kIPCPathSwitch ) then
		      ipcPath = DecodeBase64( arg.Middle( kIPCPathSwitch.Length ) )
		      exit for arg
		    end if
		  next
		  
		  //
		  // No switch? Call the debug code
		  //
		  if ipcPath = "" then
		    //
		    // Debug code here
		    //
		    
		  else
		    
		    MyIPC = new IPCSocket
		    
		    AddHandler MyIPC.Connected, AddressOf MyIPC_Connected
		    AddHandler MyIPC.DataAvailable, AddressOf MyIPC_DataAvailable
		    AddHandler MyIPC.Error, AddressOf MyIPC_Error
		    
		    MyIPC.Path = ipcPath
		    MyIPC.Listen
		    
		  end if
		End Function
	#tag EndEvent

	#tag Event
		Function UnhandledException(error As RuntimeException) As Boolean
		  print "Exception: " + Introspection.GetType( error).Name
		  Quit 1
		  return true
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub MyIPC_Connected(sender As IPCSocket)
		  sender.Write "HELLO"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MyIPC_DataAvailable(sender As IPCSocket)
		  //
		  // Format will be in the format:
		  // 
		  //   masterSequence<m>localSequence<s>data<<end>>&u01
		  //
		  // A negative masterSequence means a redo
		  //
		  
		  const kEndOfDataMarker as string = "<<end>>" + &u01
		  const kMasterSequenceMarker as string = "<m>"
		  const kLocalSequenceMarker as string = "<l>"
		  const kResultMarker as string = "Result: " 
		  
		  var chunk as string = sender.ReadAll
		  
		  if chunk.IsEmpty then
		    return
		  end if
		  
		  if chunk.Bytes < kEndOfDataMarker.Bytes then
		    if ReadBuffer.Count = 0 then
		      ReadBuffer.AddRow chunk
		      return
		    end if
		    
		    chunk = String.FromArray( ReadBuffer, "" ) + chunk
		    ReadBuffer.RemoveAllRows
		    
		    if chunk.Bytes < kEndOfDataMarker.Bytes then
		      ReadBuffer.AddRow chunk
		      return
		    end if
		  end if
		  
		  if chunk.RightBytes( kEndOfDataMarker.Bytes ) <> kEndOfDataMarker then
		    ReadBuffer.AddRow chunk
		    
		  else
		    
		    chunk = chunk.LeftBytes( chunk.Bytes - kEndOfDataMarker.Bytes ) // Knock off the marker
		    
		    var raw as string
		    if ReadBuffer.Count <> 0 then
		      raw = String.FromArray( ReadBuffer, "" ).DefineEncoding( Encodings.UTF8 )
		      ReadBuffer.RemoveAllRows
		      raw = raw + chunk
		    else
		      raw = chunk
		    end if
		    
		    var startIndex as integer
		    var endIndex as integer
		    
		    endIndex = raw.IndexOfBytes( kMasterSequenceMarker )
		    var masterSequence as integer = raw.MiddleBytes( startIndex, endIndex - startIndex ).ToInteger
		    startIndex = endIndex + kMasterSequenceMarker.Bytes
		    
		    endIndex = raw.IndexOfBytes( kLocalSequenceMarker )
		    var localSequence as integer = raw.MiddleBytes( startIndex, endIndex - startIndex ).ToInteger
		    
		    var isRedo as boolean = masterSequence < 0
		    if isRedo then
		      masterSequence = 0 - masterSequence
		    end if
		    
		    startIndex = endIndex + kLocalSequenceMarker.Bytes
		    var data as string = raw.MiddleBytes( startIndex )
		    
		    if masterSequence = 0 then
		      MyWorkerBee.Setup( data )
		    else
		      var result as string = MyWorkerBee.ProcessData( data, localSequence, masterSequence, isRedo )
		      MyIPC.Write kResultMarker + result
		    end if
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MyIPC_Error(sender As IPCSocket, error As RuntimeException)
		  #pragma unused sender
		  raise error 
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private MyIPC As IPCSocket
	#tag EndProperty

	#tag Property, Flags = &h21
		Private MyWorkerBee As WorkerBeeInterface
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ReadBuffer() As String
	#tag EndProperty


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
