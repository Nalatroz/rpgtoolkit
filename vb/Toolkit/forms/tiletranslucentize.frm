VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Begin VB.Form tiletranslucentize 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Translucentize"
   ClientHeight    =   2175
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   2775
   Icon            =   "tiletranslucentize.frx":0000
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2175
   ScaleWidth      =   2775
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Height          =   375
      Left            =   1440
      TabIndex        =   2
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   1440
      TabIndex        =   1
      Top             =   1680
      Width           =   1215
   End
   Begin VB.CheckBox chkPreview 
      Caption         =   "Preview"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   1200
      Width           =   975
   End
   Begin MSComctlLib.Slider sldTranslucentize 
      Height          =   495
      Left            =   120
      TabIndex        =   3
      Top             =   480
      Width           =   2535
      _ExtentX        =   4471
      _ExtentY        =   873
      _Version        =   393216
      Min             =   1
      Max             =   3
      SelStart        =   1
      Value           =   1
   End
   Begin VB.Label lblStatus 
      Caption         =   "Translucentize Light"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   120
      Width           =   1815
   End
End
Attribute VB_Name = "tiletranslucentize"
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

Private x As Integer, y As Integer

'========================================================================
' sldTranslucentize_Scroll
'========================================================================
Private Sub sldTranslucentize_Scroll()
    With lblStatus
        Select Case sldTranslucentize.value
            Case 1
                .Caption = "Translucentize Light"
            Case 2
                .Caption = "Translucentize Medium"
            Case 3
                .Caption = "Translucentize High"
        End Select
    End With
    
    If chkPreview.value = 1 Then Call Preview(sldTranslucentize.value)
End Sub
'========================================================================
' The preview checkbox
'========================================================================
Private Sub chkPreview_Click()
    'If they uncheck it, we should turn the tile back to how it was at the start
    If chkPreview.value = 0 Then
        For x = 1 To xRange
            For y = 1 To 32
                'If tilemem(x, y) <> -1 Then
                    tileMem(x, y) = tilePreview(x, y)
                'End If
            Next y
        Next x
    activeTile.tileRedraw
    'If they check it, preview the tile!
    Else
        Call Preview(sldTranslucentize.value)
    End If
End Sub

'========================================================================
' The OK button
'========================================================================
Private Sub cmdOK_Click()
    On Error GoTo ErrorHandler
    
    'We only want to redraw the tile again is preview is NOT checked... why? The
    'tile is made with random numbers, so if the user likes the tile he just made (
    'using preview) and then clicks on OK, the tile is texturized again, so it looks
    'different again. We don't want this, so I added the If here.
    If chkPreview.value = 0 Then
        Call Preview(sldTranslucentize.value)
        activeTile.tileRedraw
    End If
    
    'The user wants to save the changes
    saveChanges = True
    
    Unload Me
    Exit Sub
'Begin error handling code:
ErrorHandler:
    Call HandleError
    Resume Next
End Sub

'========================================================================
' The cancel button
'========================================================================
'Since cancel was clicked, the user doesn't wants to edit the tile...
'Because of this, we don't set the SaveChanges variable to true.
Private Sub cmdCancel_Click()
    Unload Me
End Sub

'========================================================================
' Form_Activate
'========================================================================
Private Sub Form_Activate()
    On Error GoTo ErrorHandler
    ' Call LocalizeForm(Me)
    
    'Used to store the current tile for when the "preview" function is used
    For x = 1 To xRange
        For y = 1 To 32
            'If tilemem(x, y) <> -1 Then
                tilePreview(x, y) = tileMem(x, y)
            'End If
        Next y
    Next x
    
    'Set the variable to False at the start
    saveChanges = False
    
    Exit Sub
    
'Begin error handling code:
ErrorHandler:
    Call HandleError
    Resume Next
End Sub

'========================================================================
' Form_Unload
'========================================================================
Private Sub Form_Unload(Cancel As Integer)
    'If the user has pressed the X in the form, he doesn't wants to add the changes

    If Not saveChanges Then
    'Use new undo
    Call activeTile.setUndo
    For x = 1 To xRange
        For y = 1 To 32
            'If tilemem(x, y) <> -1 Then
                tileMem(x, y) = tilePreview(x, y)
            'End If
        Next y
    Next x
    activeTile.tileRedraw
    End If
End Sub
'========================================================================
' Preview the tile
'========================================================================
Sub Preview(level As Integer)
    'Level: 1 - heavy, 2- mid, 3- light
    'Since I'm using a slidebar now, the levels are the other way around (1 is
    'light, 2 is mid, 3 is heavy). Because of this, we'll first change the variables
    If level = 1 Then
        level = 3
    ElseIf level = 3 Then
        level = 1
    End If
    
    'First we need to to set the tile back to how it was at the start
    For x = 1 To xRange
        For y = 1 To 32
            'If tilemem(x, y) <> -1 Then
                tileMem(x, y) = tilePreview(x, y)
            'End If
        Next y
    Next x

    'Ok that's done, let's preview!
    level = level * 2
    If level = 2 Then
        For x = 1 To xRange Step level
            For y = 1 To 32 Step level
                If tileMem(x, y) <> -1 Then
                    tileMem(x, y) = -1
                    If x = 1 Then
                        tileMem(xRange, y + level / 2) = -1
                    Else
                        tileMem(x - level / 2, y + level / 2) = -1
                    End If
                End If
            Next y
        Next x
    Else
        level = level / 2
        For x = 1 To xRange Step level
            For y = 1 To 32 Step level
                If tileMem(x, y) <> -1 Then
                    tileMem(x, y) = -1
                End If
            Next y
        Next x
    End If
    'Redraw
    tkMainForm.isoMirror.Cls
    Call activeTile.tileRedraw
End Sub

