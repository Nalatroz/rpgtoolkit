Attribute VB_Name = "transAnim"
'=========================================================================
'All contents copyright 2003, 2004, Christopher Matthews or Contributors
'All rights reserved.  YOU MAY NOT REMOVE THIS NOTICE.
'Read LICENSE.txt for licensing info
'=========================================================================

'=========================================================================
' Procedures for displaying toolkit animations during RPGCode programs
' Status: A+
'=========================================================================

Option Explicit

'=========================================================================
' Plays the loaded animation at x, y
'=========================================================================
Public Sub TransAnimateAt(ByVal x As Long, ByVal y As Long)
    On Error Resume Next
    Call AnimateAtCanvas( _
                            animationMem, _
                            x, _
                            y, _
                            tilesX * 32, _
                            tilesY * 32, _
                            cnvRpgCodeScreen _
                                               )
End Sub

'=========================================================================
' Plays an animation on a canvas
'=========================================================================
Private Sub AnimateAtCanvas( _
                               ByRef theAnim As TKAnimation, _
                               ByVal x As Long, _
                               ByVal y As Long, _
                               ByVal pixelsMaxX As Long, _
                               ByVal pixelsMaxY As Long, _
                               ByVal cnv As Long _
                                                   )

    On Error Resume Next

    'Save the screen
    Dim oldScreen As Long
    oldScreen = createCanvas(resX, resY)
    Call canvasGetScreen(oldScreen)

    'Create a temp canvas a blt the canvas passed in onto it
    Dim cnvTemp As Long
    cnvTemp = createCanvas(pixelsMaxX, pixelsMaxY)
    Call canvas2CanvasBlt(cnv, cnvTemp, 0, 0)

    Dim frames As Long          'frames in animation
    Dim currentFrame As Long    'current frame in animation

    'Get max frames
    frames = animGetMaxFrame(theAnim)

    'For each frame
    For currentFrame = 0 To frames

        'Draw the frame
        Call canvas2CanvasBlt(cnvTemp, cnv, 0, 0)
        Call AnimDrawFrameCanvas(theAnim, currentFrame, x, y, cnv)

        'Render the screen
        If cnv = cnvRpgCodeScreen Then
            Call renderRPGCodeScreen
        Else
            Call renderCanvas(cnv)
        End If

        'Delay
        Call animDelay(theAnim.animPause)

    Next currentFrame

    'Restore screen
    Call canvas2CanvasBlt(oldScreen, cnv, 0, 0)
    If (cnv = cnvRpgCodeScreen) Then
        Call renderRPGCodeScreen
    Else
        Call renderCanvas(cnv)
    End If

    'Destroy the temp canvas
    Call destroyCanvas(cnvTemp)
    Call destroyCanvas(oldScreen)

End Sub

