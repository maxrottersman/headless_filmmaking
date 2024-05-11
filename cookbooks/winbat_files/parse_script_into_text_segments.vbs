On Error Resume Next

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(WScript.Arguments(0), ForReading)

If Err.Number <> 0 Then
    WScript.Echo "Error opening input file: " & Err.Description
    WScript.Quit 1
End If

strContent = objFile.ReadAll
objFile.Close

Set objRegEx = New RegExp
objRegEx.Pattern = "\[([^\]]+)\]"
objRegEx.Global = True

Set matches = objRegEx.Execute(strContent)

strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strSegmentsFolder = strScriptPath & "\script_segments"

If Not objFSO.FolderExists(strSegmentsFolder) Then
    objFSO.CreateFolder(strSegmentsFolder)
    If Err.Number <> 0 Then
        WScript.Echo "Error creating subfolder: " & strSegmentsFolder & " - " & Err.Description
        WScript.Quit 1
    End If
End If

strLogFile = strScriptPath & "\log.txt"
Set objLogFile = objFSO.OpenTextFile(strLogFile, ForWriting, True)

For i = 0 To matches.Count - 1
    strFileName = matches(i).SubMatches(0)
    strFileName = Replace(strFileName, "/", "_")
    strFileName = Replace(strFileName, "\", "_")
    strFileName = Replace(strFileName, ":", "_")
    strFileName = Replace(strFileName, "*", "_")
    strFileName = Replace(strFileName, "?", "_")
    strFileName = Replace(strFileName, """", "_")
    strFileName = Replace(strFileName, "<", "_")
    strFileName = Replace(strFileName, ">", "_")
    strFileName = Replace(strFileName, "|", "_")
    
    strFilePath = strSegmentsFolder & "\" & strFileName & ".txt"
    
    intStartPos = matches(i).FirstIndex + matches(i).Length
    
    If i < matches.Count - 1 Then
        intEndPos = matches(i + 1).FirstIndex
    Else
        intEndPos = Len(strContent)
    End If
    
    strText = Trim(Mid(strContent, intStartPos, intEndPos - intStartPos))
    
    ' Find the position of the first non-whitespace character after the last ]
    intTextStartPos = intStartPos
    While intTextStartPos < intEndPos And (Mid(strContent, intTextStartPos, 1) = "]" Or Mid(strContent, intTextStartPos, 1) = vbCr Or Mid(strContent, intTextStartPos, 1) = vbLf)
        intTextStartPos = intTextStartPos + 1
    Wend
    
    ' Extract the text starting from the first non-whitespace character after the last ]
    strText = Trim(Mid(strContent, intTextStartPos, intEndPos - intTextStartPos))
    
    ' Remove any blank lines at the beginning of the text
    While Left(strText, 2) = vbCrLf
        strText = Mid(strText, 3)
    Wend
    
    objLogFile.WriteLine "Extracting text for file: " & strFilePath
    objLogFile.WriteLine "Start Position: " & intTextStartPos
    objLogFile.WriteLine "End Position: " & intEndPos
    objLogFile.WriteLine "Extracted Text: " & strText
    objLogFile.WriteLine "----------------------------------"
    
    Set objOutputFile = objFSO.OpenTextFile(strFilePath, ForWriting, True)
    
    If Err.Number <> 0 Then
        WScript.Echo "Error creating output file: " & strFilePath & " - " & Err.Description
        objLogFile.WriteLine "Error creating output file: " & strFilePath & " - " & Err.Description
    Else
        objOutputFile.Write strText
        objOutputFile.Close
    End If
Next

objLogFile.Close

'SWScript.Echo "Processing completed. Check the log file for more details: " & strLogFile