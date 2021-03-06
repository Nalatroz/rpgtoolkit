Attribute VB_Name = "toolkitMain"
'========================================================================
' The RPG Toolkit, Version 3
' This file copyright (C) 2007 Christopher Matthews & contributors
'
' Contributors:
'    - Colin James Fitzpatrick
'    - Jonathan D. Hughes
'========================================================================
'
' This program is free software; you can redistribute it and/or
' modify it under the terms of the GNU General Public License
' as published by the Free Software Foundation; either version 2
' of the License, or (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
'
'========================================================================

'=======================================================================
' Toolkit3 Entry Point
'=======================================================================

Option Explicit

'=======================================================================
' Toolkit main entry point
'=======================================================================
Public Sub Main()
    On Error Resume Next
    Call initCommonControls ' Applys XP visual styles, if available
    Set configfile = New CConfig
    Call initRuntimes
    Call createFileAssociations
    Call StartTracing("tktrace.txt")
    Call Randomize(timer)
    Set g_CBoardPreferences = New CBoardPreferences
    Call setupAutoTiler
    Call TileAnmClear(tileAnmList(activeTileAnmIndex).theData)
    Call initCanvasEngine
    Call initDirectories
    Call initTileEditor
    Call initPlayers
    Call initLocalization
    Call initTimer
    Call tkMainForm.Show
    Call displayTip
    Call askTutorial
End Sub

'=======================================================================
' Create "resource", "game", and "help" folders
'=======================================================================
Private Sub initDirectories()
    On Error Resume Next
    currentDir = CurDir$()
    Call MkDir(Mid(resourcePath, 1, Len(resourcePath) - 1))
    Call MkDir(Mid(gamPath, 1, Len(gamPath) - 1))
    Call MkDir(Mid(helpPath, 1, Len(helpPath) - 1))
End Sub

'=======================================================================
' Initiates player structure
'=======================================================================
Private Sub initPlayers()
    On Error Resume Next
    Dim i As Long
    For i = 1 To 6
        playerList(activePlayerIndex).theData.armorType(i) = 1
    Next i
    playerList(activePlayerIndex).theData.maxLevel = 99
    playerList(activePlayerIndex).theData.experienceIncrease = 2
End Sub

'=======================================================================
' Initiate runtimes
'=======================================================================
Private Sub initRuntimes()
    On Error Resume Next
    If Command$() <> "" Then Call ChDir(App.path)
    If Not (initRuntime()) Then
        Call ChDir("C:\Program Files\Toolkit3\")
        currentDir = CurDir()
        If Not initRuntime() Then
            Call MsgBox("Could not initialize actkrt3.dll.  Do you have actkrt3.dll, freeimage.dll, and audiere.dll in the working directory?")
            End
        End If
    End If
End Sub

'=======================================================================
' Initiate splash screen timer
'=======================================================================
Private Sub initTimer()
    On Error Resume Next
    frmMain.Timer1.Interval = 1
    If (Command$() <> "") Then
        'Do nothing
    ElseIf GetSetting("RPGToolkit3", "Settings", "Splash", "1") = "0" Then
        'Do nothing
    Else
        frmMain.Timer1.Interval = 3800
        Call frmMain.Show(vbModal)
    End If
End Sub

'=======================================================================
' Initiate the tile editor
'=======================================================================
Private Sub initTileEditor()
    On Error Resume Next
    
    ' Initiate a first tile editor doc (for tilemem use elsewhere - bug fix).
    tileedit.indice = newTileEditIndice()
    Call clearTileDoc(openTileEditorDocs(tileedit.indice))
    
End Sub

'=======================================================================
' Initiate the localization system
'=======================================================================
Private Sub initLocalization()
    On Error Resume Next
    If m_LangFile = "" Then
        m_LangFile = "0english.lng"
    End If
    Call ChangeLanguage(resourcePath & m_LangFile)
    Call InitLocalizeSystem
    ' Call LocalizeForm(frmMain)
End Sub

'=======================================================================
' Display a tip if they are enabled
'=======================================================================
Private Sub displayTip()
    On Error Resume Next
    If configfile.tipsOnOff = 1 Then
        Call tips.Show(vbModal)
    End If
End Sub

'=======================================================================
' Ask to show the tutorial if we haven't before
'=======================================================================
Private Sub askTutorial()
    On Error Resume Next
    If configfile.tutCurrentLesson = 0 Then
        Call tutorialask.Show(vbModal)
    End If
End Sub
