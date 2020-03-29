#tag Interface
Protected Interface WorkerBeeInterface
	#tag Method, Flags = &h0
		Function ProcessData(data As String, localSequence As Integer, masterSequence As Integer, isRedo As Boolean) As String
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Setup(data As String)
		  
		End Sub
	#tag EndMethod


End Interface
#tag EndInterface
