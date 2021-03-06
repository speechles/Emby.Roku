'**********************************************************
'** parseSearchResultsResponse
'**********************************************************

Function parseSearchResultsResponse(response as String, row as integer, mode ="" as String) As Object

    if response <> invalid

        contentList = CreateObject("roArray", 25, true)
        jsonObj     = ParseJSON(response)

        if jsonObj = invalid
	    createDialog("JSON Error!", "Error while parsing JSON response for Search Results Response", "OK", true)
            return invalid
        end if

        totalRecordCount = jsonObj.TotalRecordCount
        indexCount       = 0
        indexSelected    = 0

        for each i in jsonObj.SearchHints
            metaData = {}

	    metaData.ContentType = getContentType(i, mode)
	    metaData.MediaType = i.MediaType
	    metaData.MediaSources = i.MediaSources
            metaData.Id = i.ItemId
            metaData.ShortDescriptionLine1 = firstOf(i.Name, "Unknown")
            metaData.Title = firstOf(i.Name, "Unknown")
	    metaData.PrimaryImageAspectRatio = i.PrimaryImageAspectRatio

	    description = getDescription(i, mode)
	    metaData.FullDescription = description
	    metaData.Description = description
	    metaData.Overview = description

	    if i.Type = "Episode"
		metaData.ShortDescriptionLine1 =  firstOf(i.Series, "Unknown")
		episodeInfo = ""

		if i.ParentIndexNumber <> invalid
			episodeInfo = itostr(i.ParentIndexNumber)
		end if

		if i.IndexNumber <> invalid
			episodeInfo = episodeInfo + "x" + ZeroPad(itostr(i.IndexNumber))
		end if

		if episodeInfo <> ""
			episodeInfo = episodeInfo + " - " + firstOf(i.Name, "")
		else
			episodeInfo = firstOf(i.Name, "")
		end if

		metaData.ShortDescriptionLine2 = episodeInfo
				
	    end if
	    if (row > 7 and row < 10) or row = 11
		sizes = GetImageSizes("arced-square")
	    else if row = 4
		sizes = GetImageSizes("flat-portrait")
	    else
            	sizes = GetImageSizes("two-row-flat-landscape-custom")
	    end if

            if i.Type = "Studio" or i.Type = "MusicStudio" or i.Type = "Movie" or i.Type = "BoxSet" or i.Type = "Series" or i.type ="Folder"

		if i.ThumbImageItemId <> "" And i.ThumbImageItemId <> invalid
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.ThumbImageItemId) + "/Images/Thumb/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.ThumbImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.ThumbImageTag)

                else if i.BackdropImageItemId <> "" And i.BackdropImageItemId <> invalid
				
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.BackdropImageItemId) + "/Images/Backdrop/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.BackdropImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.BackdropImageTag)

                else 
                    metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                    metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

                end if

            else if i.Type = "Episode" or i.MediaType = "Video" or i.Type = "MusicAlbum" or i.MediaType = "Audio" or i.type = "Photo" or i.type = "PhotoAlbum" or i.Type = "Genre" or i.Type = "MusicGenre"

                if i.PrimaryImageTag <> "" And i.PrimaryImageTag <> invalid
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.ItemId) + "/Images/Primary/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.PrimaryImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.PrimaryImageTag)

                else 
                    metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                    metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

                end if
		
                ' Set the Artist Name
                if i.AlbumArtist <> "" And i.AlbumArtist <> invalid
                	metaData.ShortDescriptionLine2 = i.AlbumArtist
                else if i.Artists <> invalid And i.Artists[0] <> "" And i.Artists[0] <> invalid
                	metaData.ShortDescriptionLine2 = i.Artists[0]
                end if

            else if i.Type = "MusicGenre" or i.Type = "Genre"

                if i.BackdropImageItemId <> "" And i.BackdropImageItemId <> invalid
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.BackdropImageItemId) + "/Images/Backdrop/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.BackdropImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.BackdropImageTag)

                else if i.ThumbImageItemId <> "" And i.ThumbImageItemId <> invalid
				
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.ThumbImageItemId) + "/Images/Thumb/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.ThumbImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.ThumbImageTag)

                else 
                    metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                    metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

                end if

            else if i.Type = "MusicArtist"

                if i.BackdropImageItemId <> "" And i.BackdropImageItemId <> invalid
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.BackdropImageItemId) + "/Images/Backdrop/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.BackdropImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.BackdropImageTag)

                else if i.PrimaryImageTag <> "" And i.PrimaryImageTag <> invalid
				
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.ItemId) + "/Images/Primary/0"

                    metaData.HDPosterUrl = BuildImage(imageUrl, sizes.hdWidth, sizes.hdHeight, i.PrimaryImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, sizes.sdWidth, sizes.sdHeight, i.PrimaryImageTag)

                else 
                    metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                    metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

                end if

            else if i.Type = "Person"
			
                if i.PrimaryImageTag <> "" And i.PrimaryImageTag <> invalid
                    imageUrl = GetServerBaseUrl() + "/Items/" + HttpEncode(i.ItemId) + "/Images/Primary/0"
					
					portraitSizes = GetImageSizes("flat-portrait")
                    metaData.HDPosterUrl = BuildImage(imageUrl, portraitSizes.hdWidth, portraitSizes.hdHeight, i.PrimaryImageTag)
                    metaData.SDPosterUrl = BuildImage(imageUrl, portraitSizes.sdWidth, portraitSizes.sdHeight, i.PrimaryImageTag)

                else 
                    metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                    metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

                end if

            else

                metaData.HDPosterUrl = GetViewController().getThemeImageUrl("hd-landscape.jpg")
                metaData.SDPosterUrl = GetViewController().getThemeImageUrl("sd-landscape.jpg")

            end if

            contentList.push( metaData )
        end for
		limit = FirstOf(regread("prefsearchmax"),"50").ToInt()
		if totalRecordCount > limit then totalRecordCount = limit

        return {
            Items: contentList
            TotalCount: totalRecordCount
        }
    else
	createDialog("Parsing Error!", "Error parsing search results.", "OK", true)
        Debug("Error parsing search results")
    end if

    return invalid
End Function