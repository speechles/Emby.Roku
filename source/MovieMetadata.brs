'**********************************************************
'** parseSuggestedMoviesResponse
'**********************************************************

Function parseSuggestedMoviesResponse(response) As Object
	if response <> invalid
		contentList = CreateObject("roArray", 20, true)
		fixedResponse = normalizeJson(response)
		result        = ParseJSON(fixedResponse)
		if result = invalid
			createDialog("Parsing Error!", "Error in parseSuggestedMoviesResponse.", "OK", true)
			Debug("Error in parseSuggestedMoviesResponse")
			return invalid
		end if
		' Only Grab 1 Category
		category = result[rnd(result.count())-1]
		' Results are empty
		if category = invalid then
			return {
				Items: contentList
				TotalCount: contentList.Count()
			}
		end if
		ImageType = FirstOf(RegUserRead("homeImageType"),"0").ToInt()

		for each i in category.Items
			metaData = getMetadataFromServerItem(i, imageType, "mixed-aspect-ratio-portrait")
			contentList.push( metaData )
		end for
		return {
			Items: contentList
			RecommendationType: category.RecommendationType
			BaselineItemName: category.BaselineItemName
			TotalCount: contentList.Count()
		}
	else
		createDialog("Response Error!", "No Suggested Movie Found. (invalid)", "OK", true)
	end if
	return invalid
End Function