#tag Class
Protected Class WorkerBee
	#tag Method, Flags = &h0
		Sub FetchData(ByRef data As String, ByRef localSequence As Integer, ByRef masterSequence As Integer)
		  #if TargetConsole then
		    
		    var raw as string = Input( kPromptMoreData )
		    
		    //
		    // Format will be masterSequence:localSequence:data
		    //
		    // A negative number means it's a resend
		    //
		    static rx as RegEx
		    if rx is nil then
		      rx = new RegEx
		      rx.SearchPattern = "^(-?\d+):(-?\d+):([\s\S]*)"
		    end if
		    
		    var match as RegExMatch = rx.Search( raw )
		    masterSeqeunce = match.SubExpressionString( 1 ).ToInteger
		    localSequence = match.SubExpressionString( 2 ).ToInteger
		    data = match.SubExpressionString( 3 )
		    
		    
		  #else
		    
		    #pragma unused data
		    #pragma unused localSequence
		    #pragma unused masterSequence
		    
		  #endif
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ProcessData(data As String, localSequence As Integer, masterSequence As Integer) As String
		  //
		  // Takes the data as returned by the host
		  // Negative master sequence means a resend
		  //
		  
		  var wasResent as boolean = masterSequence < 0
		  if wasResent then
		    masterSequence = 0 - masterSequence
		  end if
		  
		  return RaiseEvent ProcessData( data, localSequence, masterSequence, wasResent )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Setup()
		  #if TargetConsole then
		    
		    var data as string = Input( kPromptInitialSetup )
		    RaiseEvent Setup( data )
		    
		  #endif
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 50726F6365737320746865206461746120616E642072657475726E2074686520726573756C742E
		Event ProcessData(data As String, localSequence As Integer, masterSequence As Integer, wasResent As Boolean) As String
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 496E697469616C20736574757020646174612066726F6D2074686520686F73742E
		Event Setup(data As String)
	#tag EndHook


	#tag Constant, Name = kPromptInitialSetup, Type = String, Dynamic = False, Default = \"WorkerBee Inital Setup: ", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPromptMoreData, Type = String, Dynamic = False, Default = \"WokerBee More Data: ", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kPromptReturnedData, Type = String, Dynamic = False, Default = \"WorkerBee Returned Data: ", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
