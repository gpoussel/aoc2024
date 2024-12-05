Sub LaunchComputation(ByVal column As Integer)
    ' Iterate over cells of column (infinite loop because we don't know the input size)
    Dim row As Integer
    Dim cell, cell2 As Range
    row = 2
    Dim ruleSize, updateSize As Integer
    ruleSize = 0
    updateSize = 0
    Dim section as Integer ' 0: rules, 1: updates
    section = 0
    Do While True
        Set cell = Cells(row, column)
        If cell.Value = "" Then
            If section = 0 Then
                section = 1
            Else
                Exit Do
            End If
        Else
            If section = 0 Then
                ruleSize = ruleSize + 1
            Else
                updateSize = updateSize + 1
            End If
        End If
        
        ' Next row
        row = row + 1
    Loop

    Dim ruleRange, updatesRange As Range
    Set ruleRange = Range(Cells(2, column), Cells(ruleSize + 1, column))
    Set updatesRange = Range(Cells(ruleSize + 3, column), Cells(ruleSize + 2 + updateSize, column))

    Dim part1 As Integer
    Dim part2 As Integer

    ' Part 1

    For Each cell In updatesRange
        'Split cell content on , separator
        Dim parts() As String
        parts = Split(cell.Value, ",")
        Dim i As Integer
        i = 1
        
        Dim valid As Boolean
        valid = True
        Do While i < UBound(parts) + 1
            Dim prevPart, part As Integer
            prevPart = Int(Val(parts(i - 1)))
            part = Int(Val(parts(i)))
            

            If Not ruleRange.Find(part & "|" & prevPart) Is Nothing Then
                valid = False
                Exit Do
            End If
            i = i + 1
        Loop

        If valid Then
            part1 = part1 + parts(UBound(parts) / 2)
        Else
            Dim sortedParts() As Integer
            ReDim sortedParts(UBound(parts))
            For i = 0 To UBound(parts)
                sortedParts(i) = Int(Val(parts(i)))
            Next i
            Dim j As Integer
            For i = 0 To UBound(parts)
                For j = i + 1 To UBound(parts)
                    If Not ruleRange.Find(sortedParts(i) & "|" & sortedParts(j)) Is Nothing Then
                        Dim tmp As Integer
                        tmp = sortedParts(i)
                        sortedParts(i) = sortedParts(j)
                        sortedParts(j) = tmp
                    End If
                Next j
            Next i
            
            part2 = part2 + sortedParts(UBound(sortedParts) / 2)
        End If

        row = row + 1
    Next cell


    Cells(column + 1, 6).Value = part1
    Cells(column + 1, 7).Value = part2
End Sub

Sub Compute()
    LaunchComputation(1)
    LaunchComputation(2)
End Sub
