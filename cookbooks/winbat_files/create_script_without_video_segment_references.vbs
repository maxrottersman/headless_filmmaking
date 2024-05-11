On Error Resume Next

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(WScript.Arguments(0), 1)

If Err.Number <> 0 Then
    WScript.Echo "Error opening input file: " & Err.Description
    WScript.Quit 1
End If

strContent = objFile.ReadAll
objFile.Close

Set objRegEx = New RegExp
objRegEx.Pattern = "^\[.*\]\r?\n"
objRegEx.Multiline = True
objRegEx.Global = True
strCleanedContent = objRegEx.Replace(strContent, "")

strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strOutputFile = strScriptPath & "\\" & objFSO.GetBaseName(WScript.Arguments(0)) & "_cleaned.txt"
Set objOutputFile = objFSO.OpenTextFile(strOutputFile, 2, True)

If Err.Number <> 0 Then
    WScript.Echo "Error opening output file: " & Err.Description
    WScript.Quit 1
End If

objOutputFile.Write strCleanedContent
objOutputFile.Close

'WScript.Echo "File cleaned and saved as " & strOutputFile