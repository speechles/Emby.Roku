'*****************************************************************
'**  Media Browser Roku Client - TV Show Genre Page
'*****************************************************************


'**********************************************************
'** Show TV Show Genre Page
'**********************************************************

Function ShowTVShowGenrePage(genre As String) As Integer

    if validateParam(genre, "roString", "ShowTVShowGenrePage") = false return -1

    ' Setup Screen
    port   = CreateObject("roMessagePort")
    screen = CreateObject("roGridScreen")
    screen.SetMessagePort(port)

    screen.SetBreadcrumbText(genre, "TV")
    screen.SetGridStyle("two-row-flat-landscape-custom")
    screen.SetDisplayMode("scale-to-fit")

    ' Show Screen
    screen.SetupLists(1)
    screen.SetListNames([genre + " TV Shows"])

    rowData = CreateObject("roArray", 2, true)

    tvShowAll = GetTVShowInGenre(genre)
    rowData[0] = tvShowAll
    screen.SetContentList(0, tvShowAll)

    screen.Show()

    ' Hide Description Popup
    screen.SetDescriptionVisible(false)

    while true
        msg = wait(0, screen.GetMessagePort())

        if type(msg) = "roGridScreenEvent" Then
            if msg.isListItemFocused() then

            else if msg.isListItemSelected() Then
                row = msg.GetIndex()
                selection = msg.getData()

                If rowData[row][selection].ContentType = "Series" Then
                    ShowTVSeasonsListPage(rowData[row][selection])
                Else 
                    Print "Unknown Type found"
                End If

            else if msg.isScreenClosed() then
                return -1
            end if
        end if
    end while

    return 0
End Function


'**********************************************************
'** Get TV Shows From a Specific Genre From Server
'**********************************************************

Function GetTVShowInGenre(genre As String) As Object

    ' Clean Genre Name
    obj = CreateObject("roUrlTransfer")
    genre = obj.Escape(genre)

    request = CreateURLTransferObjectJson(GetServerBaseUrl() + "/Users/" + m.curUserProfile.Id + "/Items?Recursive=true&IncludeItemTypes=Series&Genres=" + genre + "&Fields=ItemCounts%2CGenres&SortBy=SortName&SortOrder=Ascending", true)

    if (request.AsyncGetToString())
        while (true)
            msg = wait(0, request.GetPort())

            if (type(msg) = "roUrlEvent")
                code = msg.GetResponseCode()

                if (code = 200)
                    list     = CreateObject("roArray", 2, true)
                    jsonData = ParseJSON(msg.GetString())
                    for each itemData in jsonData.Items
                        seriesData = {
                            Id: itemData.Id
                            Title: itemData.Name
                            ContentType: "Series"
                            ShortDescriptionLine1: itemData.Name
                            ShortDescriptionLine2: Pluralize(itemData.ChildCount, "season")
                        }

                        ' Check If Item has Image, otherwise use default
                        If itemData.BackdropImageTags[0]<>"" And itemData.BackdropImageTags[0]<>invalid
                            seriesData.HDPosterUrl = GetServerBaseUrl() + "/Items/" + itemData.Id + "/Images/Backdrop/0?height=150&width=&tag=" + itemData.BackdropImageTags[0]
                            seriesData.SDPosterUrl = GetServerBaseUrl() + "/Items/" + itemData.Id + "/Images/Backdrop/0?height=94&width=&tag=" + itemData.BackdropImageTags[0]
                        Else 
                            seriesData.HDPosterUrl = "pkg://images/items/collection.png"
                            seriesData.SDPosterUrl = "pkg://images/items/collection.png"
                        End If

                        list.push( seriesData )
                    end for
                    return list
                endif
            else if (event = invalid)
                request.AsyncCancel()
            endif
        end while
    endif

    Return invalid
End Function