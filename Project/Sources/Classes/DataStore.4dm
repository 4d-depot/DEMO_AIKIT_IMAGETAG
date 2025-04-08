Class extends DataStoreImplementation

exposed Function promptApi($urlInputText : Text; $isUrl : Boolean; $isIA : Boolean; $imageToUpload : cs:C1710.PicturesEntity) : cs:C1710.PicturesEntity
	
	var $client:=cs:C1710.AIKit.OpenAI.new("YourApiKey")
	
	var $formPrompt : Text
	var $prompt : Text
	
	
	// CHECK IF THE INPUT IS A URL
	If ($isUrl=True:C214)
		// CHECK IF THE INPUT SHOULD BE PROCESSED USING AI
		If ($isIA=True:C214)
			// ------------------------------------ IMAGE GENERATION USING OPENAI API  ------------------------------------ //
			$prompt:=$client.images.generate($urlInputText; {size: "1024x1024"}).image.url
		Else 
			// IF NOT USING AI, DIRECTLY USE THE INPUT URL AS THE PROMPT
			$prompt:=$urlInputText
		End if 
	Else 
		// CONVERT THE IMAGE BLOB INTO BASE64 FORMAT IF IT'S NOT A URL
		var $blob:=$imageToUpload.picture
		var $base64Encoded : Text
		BASE64 ENCODE:C895($blob; $base64Encoded)
		$prompt:="data:image/jpeg;base64,"+$base64Encoded
	End if 
	
	// ------------------------------- EXTRACTING KEYWORDS FROM THE PICTURE USING OPENAI API -------------------------//
	$formPrompt:="Generate between 10 and 20 relevant keywords about this picture in English."+\
		" The keywords must be separated by a single space with no other text."
	
	var $result:=$client.chat.vision.create($prompt).prompt($formPrompt).choice.message.content
	var $terms:=New collection:C1472()
	var $startPos : Integer:=1
	var $nextPos : Integer
	// LOOP TO EXTRACT EACH KEYWORD SEPARATED BY SPACES
	While (True:C214)
		$nextPos:=Position:C15(" "; $result; $startPos)
		If ($nextPos=0)
			var $lastKeyword : Text
			$lastKeyword:=Substring:C12($result; $startPos; Length:C16($result)-$startPos+1)
			$terms.push($lastKeyword)
			break
		End if 
		var $keyword : Text
		$keyword:=Substring:C12($result; $startPos; $nextPos-$startPos)
		$terms.push($keyword)
		$startPos:=$nextPos+1
	End while 
	
	// STEP 1: SAVE THE IMAGE IN THE DATABASE
	var $pictureEntity : cs:C1710.PicturesEntity
	$pictureEntity:=ds:C1482.Pictures.new()
	// DOWNLOAD THE IMAGE IF THE INPUT WAS A URL
	If ($isUrl=True:C214)
		var $resultDL : Blob
		var $request : 4D:C1709.HTTPRequest
		$request:=4D:C1709.HTTPRequest.new($prompt)
		$request.wait()
		If (Num:C11($request.response.status)=200)
			$resultDL:=$request.response.body
		Else 
			ALERT:C41("Erreur lors du téléchargement de l'image.")
			ALERT:C41($prompt)
		End if 
		$pictureEntity.picture:=$resultDL
	Else 
		$pictureEntity.picture:=$imageToUpload.picture
	End if 
	$pictureEntity.prompt:=$urlInputText
	$pictureEntity.save()
	
	// STEP 2: SAVE ASSOCIATED KEYWORDS
	For each ($term; $terms)
		// CHECK IF THE KEYWORD ALREADY EXISTS
		var $existingKeywords:=ds:C1482.Keywords.query("keyword = :1"; $term)
		var $keywordToUse : cs:C1710.KeywordsEntity
		If ($existingKeywords.length=0)  // If the keyword doesn't exist
			// CREATE A NEW KEYWORD ENTITY IF IT DOESN'T EXIST
			var $newKeyword : cs:C1710.KeywordsEntity
			$newKeyword:=ds:C1482.Keywords.new()
			$newKeyword.keyword:=$term
			$newKeyword.save()
			$keywordToUse:=$newKeyword
		Else 
			$keywordToUse:=$existingKeywords.first()
		End if 
		
		// CHECK IF THE RELATIONSHIP BETWEEN THE IMAGE AND THE KEYWORD ALREADY EXISTS
		var $existingRelation:=ds:C1482.PictureKeywords.query("IDPictures = :1 AND IDKeywords = :2"; $pictureEntity.ID; $keywordToUse.ID)
		If ($existingRelation.length=0)
			var $pictureKeywordEntity : cs:C1710.PictureKeywordsEntity
			$pictureKeywordEntity:=ds:C1482.PictureKeywords.new()
			$pictureKeywordEntity.IDPictures:=$pictureEntity.ID
			$pictureKeywordEntity.IDKeywords:=$keywordToUse.ID
			Try
				$pictureKeywordEntity.save()
			Catch
				var $errorMessages:=""
				For each ($error; Last errors:C1799)
					
					If ($errorMessages#"")
						$errorMessages:=$errorMessages+"\n\n"+$error.message
					Else 
						$errorMessages:=$error.message
					End if 
				End for each 
				ALERT:C41("Erreur lors de la sauvegarde de la relation : "+$errorMessages)
			End try
		End if 
	End for each 
	return $pictureEntity
	
	// GET KEYWORDS ASSOCIATED WITH A PICTURE
exposed Function getPictureKeywords($pictureEntity : cs:C1710.PicturesEntity) : cs:C1710.KeywordsSelection
	var $keywordsSelection : cs:C1710.KeywordsSelection
	$keywordsSelection:=ds:C1482.Keywords.query("Keywords_to_PictureKeywords.IDPictures = :1"; $pictureEntity.ID)
	return $keywordsSelection
	
	// RETRIEVE THE FIRST 6 KEYWORDS OF A PICTURE
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