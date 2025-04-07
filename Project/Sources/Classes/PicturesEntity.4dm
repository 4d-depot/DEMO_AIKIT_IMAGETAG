Class extends Entity

exposed Function get6FirstElements($selectedEntity : cs:C1710.PicturesEntity) : cs:C1710.KeywordsSelection
	var $firstSixKeywordsSelection : cs:C1710.KeywordsSelection
	$firstSixKeywordsSelection:=ds:C1482.Keywords.newSelection()
	
	If (Not:C34(Undefined:C82($selectedEntity)))
		var $pictureID : Integer
		$pictureID:=$selectedEntity.ID
		var $relatedPictureKeywords : cs:C1710.PictureKeywordsSelection
		$relatedPictureKeywords:=ds:C1482.PictureKeywords.query("IDPictures = :1"; $pictureID)
		If (Not:C34(Undefined:C82($relatedPictureKeywords)) & ($relatedPictureKeywords.length>0))
			var $keywordsMap : Collection
			$keywordsMap:=New collection:C1472()
			For each ($pictureKeyword; $relatedPictureKeywords)
				var $keywordID : Integer
				$keywordID:=$pictureKeyword.IDKeywords
				var $keywordEntity : cs:C1710.KeywordsEntity
				$keywordEntity:=ds:C1482.Keywords.get($keywordID)
				If (Not:C34(Undefined:C82($keywordEntity)))
					If ($keywordsMap.indexOf($keywordEntity.keyword)=-1)
						$firstSixKeywordsSelection.add($keywordEntity)
						$keywordsMap.push($keywordEntity.keyword)
					End if 
				End if 
			End for each 
			var $counter : Integer:=0
			var $filteredSelection : cs:C1710.KeywordsSelection
			$filteredSelection:=ds:C1482.Keywords.newSelection()
			For each ($keywordEntity; $firstSixKeywordsSelection)
				$filteredSelection.add($keywordEntity)
				$counter+=1
				If ($counter=6)
					break
				End if 
			End for each 
			return $filteredSelection
		End if 
	End if 
	return $firstSixKeywordsSelection
	