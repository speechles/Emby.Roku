'******************************************************
' createTvLibraryScreen
'******************************************************

Function createTvLibraryScreen(viewController as Object, parentId as String) As Object

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

	names = ["Shows", "Jump In", "Next Up", "Favorite Shows", "Favorite Episodes", "Upcoming Episodes", "Genres", "Networks"]
	keys = ["0", "1", "2", "3", "4", "5", "6", "7"]

	loader = CreateObject("roAssociativeArray")
	loader.getUrl = getTvLibraryRowScreenUrl
	loader.parsePagedResult = parseTvLibraryScreenResult
	loader.getLocalData = getTvLibraryScreenLocalData
	loader.parentId = parentId

    if imageType = 0 then
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "mixed-aspect-ratio")
    Else
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "two-row-flat-landscape-custom")
    End If

	screen.baseActivate = screen.Activate
	screen.Activate = tvScreenActivate

    screen.displayDescription = (firstOf(RegUserRead("tvDescription"), "1")).ToInt()

	screen.createContextMenu = tvScreenCreateContextMenu

    return screen

End Function

Sub tvScreenActivate(priorScreen)

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()
	displayDescription = (firstOf(RegUserRead("tvDescription"), "1")).ToInt()
	
    if imageType = 0 then
		gridStyle = "mixed-aspect-ratio"
    Else
		gridStyle = "two-row-flat-landscape-custom"
    End If

	m.baseActivate(priorScreen)

	if gridStyle <> m.gridStyle or displayDescription <> m.displayDescription then
		
		m.displayDescription = displayDescription
		m.gridStyle = gridStyle
		m.DestroyAndRecreate()

	end if

End Sub

Function tvScreenCreateContextMenu()
	
	options = {
		settingsPrefix: "tv"
		sortOptions: ["Name", "Date Added", "Date Played", "Release Date", "Random", "Play Count", "Critic Rating", "Community Rating", "Budget", "Revenue"]
		filterOptions: ["None", "Continuing Series", "Ended Series", "Played", "Unplayed", "Resumable"]

		showSortOrder: true
	}
	createContextMenuDialog(options)

	return true

End Function

Function getTvLibraryScreenLocalData(row as Integer, id as String, startItem as Integer, count as Integer) as Object

	if row = 1 then
		return getAlphabetList("TvAlphabet", m.parentId)
	end If

    return invalid

End Function

Function getTvLibraryRowScreenUrl(row as Integer, id as String) as String

    filterBy       = (firstOf(RegUserRead("tvFilterBy"), "0")).ToInt()
    sortBy         = (firstOf(RegUserRead("tvSortBy"), "0")).ToInt()
    sortOrder      = (firstOf(RegUserRead("tvSortOrder"), "0")).ToInt()

    ' URL
    url = GetServerBaseUrl()

    query = {}

	if row = 0
		' Tv
		url = url  + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?recursive=true"
		
		if filterBy = 1
			query.AddReplace("SeriesStatus", "Continuing")
		else if filterBy = 2
			query.AddReplace("SeriesStatus", "Ended")
		else if filterBy = 3
			query.AddReplace("Filters", "IsPlayed")
		else if filterBy = 4
			query.AddReplace("Filters", "IsUnPlayed")
		else if filterBy = 5
			query.AddReplace("Filters", "IsResumable")
		end if

		if sortBy = 1
			query.AddReplace("SortBy", "DateCreated,SortName")
		else if sortBy = 2
			query.AddReplace("SortBy", "PremiereDate,SortName")
		else if sortBy = 3
			query.AddReplace("SortBy", "PremiereDate,SortName")
		else if sortBy = 4
			query.AddReplace("SortBy", "Random,SortName")
		else if sortBy = 5
			query.AddReplace("SortBy", "PlayCount,SortName")
		else if sortBy = 6
			query.AddReplace("SortBy", "CommunityRating,SortName")
		else
			query.AddReplace("SortBy", "SortName")
		end if

		if sortOrder = 1
			query.AddReplace("SortOrder", "Descending")
		end if

		query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("ParentId", m.parentId)
		query.AddReplace("IncludeItemTypes", "Series")

	else if row = 1
		' Alphabet - should never get in here
		
	else if row = 2
		' Tv next up
		url = url  + "/Shows/NextUp?recursive=true"
		query.AddReplace("SortBy", "SortName")
		query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("userid", getGlobalVar("user").Id)
		query.AddReplace("ParentId", m.parentId)
		'query.AddReplace("ImageTypeLimit", "1")
	else if row = 3
		' Tv Favorites Series
		url = url + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?recursive=true"
		query.AddReplace("filters", "IsFavorite")
		query.AddReplace("sortby", "SortName")
		query.AddReplace("sortorder", "Ascending")
		query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("IncludeItemTypes", "Series")
		query.AddReplace("ParentId", m.parentId)
		'query.AddReplace("ImageTypeLimit", "1")
	else if row = 4
		' Tv Favorite Episodes
		url = url + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?includeitemtypes=Episode"
		query.AddReplace("recursive", "true")
		query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("sortby", "SortName")
		query.AddReplace("sortorder", "Ascending")
		query.AddReplace("filters", "IsFavorite")
		query.AddReplace("ParentId", m.parentId)
		'query.AddReplace("ImageTypeLimit", "1")
	else if row = 5
		' Upcoming Tv Shows
		url = url + "/Shows/Upcoming?recursive=true&limit=200"
		'query.AddReplace("SortBy", "SortName")
		'query.AddReplace("sortorder", "Ascending")
		query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("userid", getGlobalVar("user").Id)
		query.AddReplace("ParentId", m.parentId)
		query.AddReplace("ImageTypeLimit", "1")
	'else if row = 8
		' Favorite People
		'url = url  + "/Persons?recursive=true"
		'query.AddReplace("filters", "IsFavorite")
		'query.AddReplace("sortby", "SortName")
		'query.AddReplace("sortorder", "Ascending")
		'query.AddReplace("fields", "PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		'query.AddReplace("parentId", m.parentId)
		'query.AddReplace("IncludeItemTypes", "Series,Episode")
		'query.AddReplace("UserId", getGlobalVar("user").Id)
		'query.AddReplace("ImageTypeLimit", "1")

	else if row = 6
		' Tv genres
		url = url  + "/Genres?recursive=true"
		query.AddReplace("SortBy", "SortName")
		query.AddReplace("sortorder", "Ascending")
		query.AddReplace("fields", "ItemCounts,PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("userid", getGlobalVar("user").Id)
		query.AddReplace("IncludeItemTypes", "Series")
		query.AddReplace("ParentId", m.parentId)
		query.AddReplace("ImageTypeLimit", "1")
	else if row = 7
		' Tv Studios
		url = url  + "/Studios?recursive=true"
		query.AddReplace("SortBy", "SortName")
		query.AddReplace("sortorder", "Ascending")
		query.AddReplace("fields", "ItemCounts,PrimaryImageAspectRatio,Overview,AirTime,ParentId")
		query.AddReplace("userid", getGlobalVar("user").Id)
		query.AddReplace("IncludeItemTypes", "Series")
		query.AddReplace("ParentId", m.parentId)
		'query.AddReplace("ImageTypeLimit", "1")
	end If

	for each key in query
		url = url + "&" + key +"=" + HttpEncode(query[key])
	end for
    return url

End Function

Function parseTvLibraryScreenResult(row as Integer, id as string, startIndex as Integer, json as String) as Object

	imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()
	primaryImageStyle = "mixed-aspect-ratio-portrait"
	mode = ""

	if row = 2 
		mode = "seriesimageasprimary" 
	else if row = 4
		mode = "seriesimageasprimary"
	else if row = 5
		mode = "seriesimageasprimary"
	else if row = 6
		mode = "tvgenre"
	else if row = 7
		mode = "tvstudio"
		imageType = 1
	end if

	response = parseItemsResponse(json, imageType, primaryImageStyle, mode)
	if row > 5 then response.Items = AddParentID(response.Items, m.parentId)
	return response
		

End Function


'******************************************************
' createTvSeasonsScreen
'******************************************************

Function createTvSeasonsScreen(viewController as Object, seriesInfo As Object) As Object
    
	obj = CreatePosterScreen(viewController, seriesInfo, "flat-episodic-16x9")

	obj.seriesInfo = seriesInfo
	obj.GetDataContainer = getTvSeasonsDataContainer
	obj.dataLoaderHttpHandler = getTvSeasonsPagedDataLoader(seriesInfo.Id)

    return obj

End Function

Function getTvSeasonsPagedDataLoader(seriesId as String) as Object

	obj = CreateObject("roAssociativeArray")

	obj.seriesId = seriesId
	obj.getUrl = getTvSeasonUrl
	obj.parsePagedResult = parseTvEpisodesResponse

	return obj

End Function

'**********************************************************
'** parseTvEpisodesResponse
'**********************************************************
Function parseTvEpisodesResponse(row as Integer, id as string, startIndex as Integer, json as String) as Object

	return parseItemsResponse(json, 0, "flat-episodic-16x9", "episodedetails")

End Function

Function getTvSeasonUrl(row as Integer, seasonId as String) as String

	seriesId = m.seriesId

    ' URL
    url = GetServerBaseUrl() + "/Shows/" + HttpEncode(seriesId) + "/Episodes?SeasonId=" + seasonId

	userId = getGlobalVar("user").Id

	url = url + "&userId=" + userId
	url = url + "&fields=PrimaryImageAspectRatio,Overview,AirTime,ParentId"

	return url

End Function


Function getTvSeasonsDataContainer(viewController as Object, item as Object) as Object

    seasonData = getTvSeasons(item.Id)

    if seasonData = invalid
        return invalid
    end if

    seasonIds   = seasonData[0]
    seasonNames = seasonData[1]
    seasonNumbers = seasonData[2]

	obj = CreateObject("roAssociativeArray")
	obj.names = seasonNames
	obj.keys = seasonIds
	obj.items = []

	nextEpisode = getTvNextEpisode(item.Id)

	if nextEpisode <> invalid And nextEpisode.Season <> invalid

		index = 0

		for each i in seasonNumbers
			if nextEpisode.Season = i then 
				
				exit for
			end if
		
			index = index + 1
		end for

		obj.focusedIndex = index
		obj.focusedIndexItem = nextEpisode.Episode
		debug("FocusedIndex: " + tostr(index))
		debug("FocusedIndexItem: " + tostr(nextEpisode.Episode))
	else
		debug("No Next Up")
	end if

	return obj

End Function

'******************************************************
' createTvGenreScreen
'******************************************************

Function createTvGenreScreen(viewController as Object, genre As String, parentId = invalid) As Object

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

	names = ["Shows","Favorite Shows"]
	keys = [genre,genre]

	loader = CreateObject("roAssociativeArray")
	loader.getUrl = getTvGenreScreenUrl
	loader.parsePagedResult = parseTvGenreScreenResult
	loader.parentId = parentId

    if imageType = 0 then
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "mixed-aspect-ratio")
    Else
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "two-row-flat-landscape-custom")
    End If

    screen.displayDescription = (firstOf(RegUserRead("tvDescription"), "1")).ToInt()

    return screen

End Function

Function getTvGenreScreenUrl(row as Integer, id as String) as String

	genre = id

    ' URL
    url = GetServerBaseUrl() + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?recursive=true"

    ' Query
    query = {
        fields: "Overview,AirTime,ParentId"
        sortby: "SortName"
        sortorder: "Ascending",
	genres: genre,
	ImageTypeLimit: "1"
        IncludeItemTypes: "Series"
    }
	if m.parentId <> invalid then query.parentId = m.parentId
    ' add favorites
    if row = 1 then query.AddReplace("filters", "IsFavorite")

	for each key in query
		url = url + "&" + key +"=" + HttpEncode(query[key])
	end for

    return url

End Function

Function parseTvGenreScreenResult(row as Integer, id as string, startIndex as Integer, json as String) as Object

	imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

    return parseItemsResponse(json, imageType, "mixed-aspect-ratio-portrait")

End Function

'******************************************************
' createTvStudiosScreen
'******************************************************

Function createTvStudioScreen(viewController as Object, studio As String, parentId = invalid) As Object

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

	names = ["Shows","Favorite Shows"]
	keys = [studio,studio]

	loader = CreateObject("roAssociativeArray")
	loader.getUrl = getTvStudioScreenUrl
	loader.parsePagedResult = parseTvStudioScreenResult
	loader.parentId = parentId

    if imageType = 0 then
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "mixed-aspect-ratio")
    Else
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "two-row-flat-landscape-custom")
    End If

    screen.displayDescription = (firstOf(RegUserRead("tvDescription"), "1")).ToInt()

    return screen

End Function

Function getTvStudioScreenUrl(row as Integer, id as String) as String

	studio = id

    ' URL
    url = GetServerBaseUrl() + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?recursive=true"

    ' Query
    query = {
        IncludeItemTypes: "Series"
        fields: "Overview,AirTime,ParentId"
        sortby: "SortName"
        sortorder: "Ascending",
	studios: studio,
	ImageTypeLimit: "1"
    }
	if m.parentId <> invalid then query.parentId = m.parentId
    ' add favorites
    if row = 1 then query.AddReplace("filters", "IsFavorite")

	for each key in query
		url = url + "&" + key +"=" + HttpEncode(query[key])
	end for

    return url

End Function

Function parseTvStudioScreenResult(row as Integer, id as string, startIndex as Integer, json as String) as Object

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()
    return parseItemsResponse(json, imageType, "mixed-aspect-ratio-portrait")

End Function

'******************************************************
' createTvAlphabetScreen
'******************************************************

Function createTvAlphabetScreen(viewController as Object, letter As String, parentId = invalid) As Object

    imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

	names = ["Shows","Favorite Shows"]
	keys = [letter,letter]

	loader = CreateObject("roAssociativeArray")
	loader.getUrl = getTvAlphabetScreenUrl
	loader.parsePagedResult = parseTvAlphabetScreenResult
	loader.parentId = parentId

    if imageType = 0 then
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "mixed-aspect-ratio")
    Else
        screen = createPaginatedGridScreen(viewController, names, keys, loader, "two-row-flat-landscape-custom")
    End If

	screen.displayDescription = (firstOf(RegUserRead("tvDescription"), "1")).ToInt()

    return screen

End Function

Function getTvAlphabetScreenUrl(row as Integer, id as String) as String

	letter = id

    ' URL
    url = GetServerBaseUrl() + "/Users/" + HttpEncode(getGlobalVar("user").Id) + "/Items?recursive=true"

    ' Query
    query = {
        IncludeItemTypes: "Series"
        fields: "PrimaryImageAspectRatio,Overview,AirTime,ParentId"
        sortby: "SortName"
        sortorder: "Ascending",
		ImageTypeLimit: "1"
    }
	
	if m.parentId <> invalid then query.parentId = m.parentId

    if row = 0 then
	if letter = "#" then
		filters = {
			NameLessThan: "a"
		}
    	else
        	filters = {
            		NameStartsWith: letter
        	}
	end if
    else
	if letter = "#" then
		filters = {
			NameLessThan: "a"
			isFavorite: "true"
		}
    	else
        	filters = {
            		NameStartsWith: letter
			isFavorite: "true"
        	}
	end if
    end if

    if filters <> invalid
        query = AddToQuery(query, filters)
    end if

	for each key in query
		url = url + "&" + key +"=" + HttpEncode(query[key])
	end for

    return url

End Function

Function parseTvAlphabetScreenResult(row as Integer, id as string, startIndex as Integer, json as String) as Object

	imageType      = (firstOf(RegUserRead("tvImageType"), "0")).ToInt()

    return parseItemsResponse(json, imageType, "mixed-aspect-ratio-portrait")

End Function