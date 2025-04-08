
Class extends EntitySelection

Function FilterEntitiesByKeywords($searchText : Text) : cs:C1710.PicturesSelection
	var $searchWords : Collection
	$searchWords:=New collection:C1472()
	
	var $startPos : Integer:=1
	var $nextPos : Integer
	
	While (True:C214)
		$nextPos:=Position:C15(" "; $searchText; $startPos)
		If ($nextPos=0)
			var $lastWord : Text
			$lastWord:=Substring:C12($searchText; $startPos; Length:C16($searchText)-$startPos+1)
			If ($lastWord#"")
				$searchWords.push($lastWord)
			End if 
			break
		Else 
			var $word : Text
			$word:=Substring:C12($searchText; $startPos; $nextPos-$startPos)
			If ($word#"")
				$searchWords.push($word)
			End if 
			$startPos:=$nextPos+1
		End if 
	End while 
	
	If ($searchWords.length=0)
		return ds:C1482.Pictures.all()
	End if 
	
	var $keywords : cs:C1710.KeywordsSelection
	$keywords:=ds:C1482.Keywords.query("keyword in :1"; $searchWords)
	
	If ($keywords.length=0)
		return ds:C1482.Pictures.all()
	End if 
	
	var $filteredEntities : cs:C1710.PicturesSelection
	$filteredEntities:=ds:C1482.Pictures.all()
	For each ($word; $searchWords)
		var $keyword : cs:C1710.KeywordsEntity
		$keyword:=ds:C1482.Keywords.query("keyword = :1"; $word).first()
		If ($keyword#Null:C1517)
			var $pictureKeywords : cs:C1710.PictureKeywordsSelection
			$pictureKeywords:=ds:C1482.PictureKeywords.query("IDKeywords = :1"; $keyword.ID)
			If ($pictureKeywords.length=0)
				return ds:C1482.Pictures.newSelection()
			End if 
			var $pictureIDs : Collection
			$pictureIDs:=$pictureKeywords.IDPictures
			$filteredEntities:=$filteredEntities.query("ID in :1"; $pictureIDs)
			If ($filteredEntities.length=0)
				return ds:C1482.Pictures.newSelection()
			End if 
		Else 
			return ds:C1482.Pictures.newSelection()
		End if 
	End for each 
	
	return $filteredEntities