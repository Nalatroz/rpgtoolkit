VERSION 5.00
Begin VB.Form commandRef 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "RPGCode Version 3 Language Specification"
   ClientHeight    =   4755
   ClientLeft      =   3885
   ClientTop       =   1050
   ClientWidth     =   6255
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "COMMANDR.frx":0000
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   4755
   ScaleWidth      =   6255
   StartUpPosition =   1  'CenterOwner
   Tag             =   "1208"
   Begin VB.CommandButton cmdInsert 
      Caption         =   "Insert"
      Height          =   375
      Left            =   5040
      TabIndex        =   3
      Top             =   600
      Width           =   1095
   End
   Begin VB.CommandButton cmdOK 
      Cancel          =   -1  'True
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   5040
      TabIndex        =   2
      Top             =   120
      Width           =   1095
   End
   Begin VB.TextBox description 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   120
      MultiLine       =   -1  'True
      TabIndex        =   1
      Top             =   3840
      Width           =   6015
   End
   Begin VB.ListBox commands 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3570
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4815
   End
   Begin VB.Label lblCommands 
      Caption         =   "0 of 0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   5040
      TabIndex        =   4
      Top             =   1200
      Width           =   1095
   End
End
Attribute VB_Name = "commandRef"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
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

Option Explicit

Private commandData() As String

Private Sub cmdInsert_Click(): On Error Resume Next
'=========================================================================
'Copy the selected command text into the open program editor.
'=========================================================================
    If commands.ListIndex <> 0 Then
        'First line is just the description!
        activeRPGCode.CodeForm.SelText = commands.List(commands.ListIndex) & vbCrLf
    End If
End Sub

Private Sub cmdOK_Click(): On Error Resume Next
    Unload commandRef
End Sub

Private Sub commands_Click(): On Error Resume Next
'=========================================================================
'Selecting a command in the window.
'=========================================================================
    description.Text = commandData(0, commands.ListIndex + 1) & vbCrLf & commandData(1, commands.ListIndex + 1)
    lblCommands.Caption = CStr(commands.ListIndex) & " of " & CStr(commands.ListCount - 1)
End Sub

Private Sub commands_DblClick(): On Error Resume Next
    Call cmdInsert_Click
End Sub

Private Sub Form_Load(): On Error Resume Next
'=========================================================================
'Form Load
'=========================================================================
    Dim file As String, num As Long, line As String
    
    ' Call LocalizeForm(Me)
    file = helpPath & ObtainCaptionFromTag(DB_QuickRefFile, resourcePath & m_LangFile)
    ChDir (currentDir)
    
    'Loop over the lines in the help file.
    'When a ":COMMAND" is encountered, the next line is the command - add it to the list box.
    If fileExists(file) Then
        num = FreeFile
        Open file For Input As num
        
            'Total number of commands in the list - at the top of the list under ":COUNT" line.
            Do Until EOF(num)
            
                line = UCase$(fread(num))
            
                If line = ":COUNT" Then
                    'Redim the data array to hold the commands.
                    'This If will be called before any commands are read!
                    ReDim commandData(1, CLng(fread(num)))
                    
                ElseIf line = ":COMMAND" Then
                
                    'The next line is the command for the list.
                    commands.AddItem fread(num)
                    
                    If UCase$(fread(num)) = ":DESCR" Then
                        If commands.ListCount > UBound(commandData, 2) Then
                            ReDim Preserve commandData(1, commands.ListCount)
                        End If
                        'The next two lines are the descriptions.
                        commandData(0, commands.ListCount) = fread(num)
                        commandData(1, commands.ListCount) = fread(num)
                    End If
                End If
            Loop
        Close num
        'Set the list box to the top.
        commands.ListIndex = 0
        lblCommands.Caption = CStr(commands.ListIndex) & " of " & CStr(commands.ListCount - 1)
    Else
        MsgBox LoadStringLoc(961, "Reference File Not Found!"), , LoadStringLoc(962, "Command Reference")
        Unload commandRef
    End If
    
End Sub
