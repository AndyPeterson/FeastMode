<!--- Ensure UTF-8 encoding and JSON response header --->
<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="application/json; charset=utf-8">
<cfsetting showdebugoutput="false">

<cfscript>
    responsePayload = {
        "success": false,
        "message": "",
        "model": "",
        "spreadSummary": "",
        "suggestions": []
    };

    try {
        // -------------------------------------------------------------
        // 1. READ CURRENT POTLUCK SPREAD FROM signups.json
        // -------------------------------------------------------------
        dataDir = getDirectoryFromPath( getCurrentTemplatePath() );
        dataFile = dataDir & "signups.json";
        dishes = [];

        if ( fileExists( dataFile ) ) {
            cflock( name="feast_json_lock", type="readonly", timeout=10, throwontimeout=false ) {
                rawJson = fileRead( dataFile, "utf-8" );
                if ( isJSON( rawJson ) ) {
                    parsed = deserializeJSON( rawJson );
                    if ( structKeyExists( parsed, "dishes" ) && isArray( parsed.dishes ) ) {
                        dishes = parsed.dishes;
                    }
                }
            }
        }

        allowedCategories = [ "Main Dish", "Soup", "Salad", "Appetizer", "Dessert", "Drinks" ];
        categoryCounts = {
            "Main Dish": 0,
            "Soup": 0,
            "Salad": 0,
            "Appetizer": 0,
            "Dessert": 0,
            "Drinks": 0
        };

        dishSummaries = [];
        for ( item in dishes ) {
            cat = trim( item.dishCategory ?: "" );
            dName = trim( item.dishName ?: "" );
            diet = trim( item.dietaryRestrictions ?: "" );

            // Skip attendee-only ($5 fund) placeholder entries with "None"
            if ( cat == "None" && dName == "None" ) {
                continue;
            }

            if ( structKeyExists( categoryCounts, cat ) ) {
                categoryCounts[ cat ]++;
            }

            entryLabel = ( len( cat ) ? "[#cat#] " : "" ) & ( len( dName ) ? dName : "TBD" );
            if ( len( diet ) && diet != "None" ) {
                entryLabel &= " (Dietary/Notes: #diet#)";
            }
            arrayAppend( dishSummaries, entryLabel );
        }

        // Optional user preference hint (from POST or URL)
        userPreference = trim( form.preference ?: ( url.preference ?: "" ) );
        if ( len( userPreference ) > 200 ) {
            userPreference = left( userPreference, 200 );
        }

        // -------------------------------------------------------------
        // 2. RESOLVE GEMINI CREDENTIALS (.env FIRST, THEN ENV VAR / CF ADMIN)
        // -------------------------------------------------------------
        apiKey = "";
        modelName = "";

        // Read local .env file first so edits take effect immediately without restarting CommandBox
        envFilePath = dataDir & ".env";
        if ( fileExists( envFilePath ) ) {
            rawEnvText = replace( fileRead( envFilePath, "utf-8" ), chr(65279), "", "all" );
            envLines = listToArray( rawEnvText, chr(10) & chr(13) );
            for ( line in envLines ) {
                trimmedLine = trim( line );
                if ( len( trimmedLine ) == 0 || left( trimmedLine, 1 ) == "##" ) continue;
                eqPos = find( "=", trimmedLine );
                if ( eqPos > 1 ) {
                    k = trim( left( trimmedLine, eqPos - 1 ) );
                    v = trim( mid( trimmedLine, eqPos + 1, len( trimmedLine ) ) );
                    // Strip surrounding quotes if present
                    if ( len( v ) >= 2 && ( ( left( v, 1 ) == '"' && right( v, 1 ) == '"' ) || ( left( v, 1 ) == "'" && right( v, 1 ) == "'" ) ) ) {
                        v = mid( v, 2, len( v ) - 2 );
                    }
                    if ( ( k == "GEMINI_API_KEY" || k == "GOOGLE_API_KEY" ) && v != "your_gemini_api_key_here" ) {
                        apiKey = v;
                    }
                    if ( k == "GEMINI_MODEL" && len( v ) ) {
                        modelName = v;
                    }
                }
            }
        }

        // Fallback to OS environment variables / Java system properties
        sysEnv = server.system.environment ?: {};
        sysProps = server.system.properties ?: {};
        if ( !len( apiKey ) ) {
            envKeyCandidate = trim( sysEnv.GEMINI_API_KEY ?: ( sysProps.GEMINI_API_KEY ?: ( sysEnv.GOOGLE_API_KEY ?: ( sysProps.GOOGLE_API_KEY ?: "" ) ) ) );
            if ( envKeyCandidate != "your_gemini_api_key_here" ) {
                apiKey = envKeyCandidate;
            }
        }
        if ( !len( modelName ) ) {
            modelName = trim( sysEnv.GEMINI_MODEL ?: ( sysProps.GEMINI_MODEL ?: "" ) );
        }

        if ( !len( modelName ) ) {
            modelName = "gemini-2.5-flash";
        }

        // Instantiate ColdFusion 2025's native chatModel() BIF with JSON responseFormat
        if ( len( apiKey ) ) {
            geminiConfig = {
                "provider"      : "gemini",
                "apiKey"        : apiKey,
                "modelName"     : modelName,
                "responseFormat": "json",
                "temperature"   : 0.7,
                "maxTokens"     : 4096,
                "timeout"       : 30
            };
            aiModel = chatModel( geminiConfig );
        } else {
            // Try a named "gemini" alias in ColdFusion Administrator > AI > LLMs if no .env key was supplied
            try {
                aiModel = chatModel( "gemini" );
                modelName = aiModel.getModelName();
            } catch ( any adminErr ) {
                throw(
                    type = "FeastMode.MissingApiKey",
                    message = "No Gemini API key configured yet. Add GEMINI_API_KEY=your_key to c:\Web\FeastMode\.env (no restart needed!) or add an LLM named 'gemini' in ColdFusion Administrator > AI > LLMs."
                );
            }
        }

        // -------------------------------------------------------------
        // 3. PROMPT + CF2025 NATIVE STRUCTURED JSON SCHEMA REQUEST
        // -------------------------------------------------------------
        spreadText = arrayLen( dishSummaries )
            ? arrayToList( dishSummaries, chr(10) & "- " )
            : "No dishes signed up yet!";

        countsText = "Main Dish: #categoryCounts['Main Dish']#, Soup: #categoryCounts['Soup']#, Salad: #categoryCounts['Salad']#, Appetizer: #categoryCounts['Appetizer']#, Dessert: #categoryCounts['Dessert']#, Drinks: #categoryCounts['Drinks']#";

        systemPrompt = "You are the festive, witty, and practical 'Feast Mode Chef' for an office holiday potluck (the 5th Annual Jesse Vancil Memorial Christmas Feast & Ken Rausch's Retirement Celebration). "
            & "Analyze the current potluck sign-up spread, spot underrepresented categories or great flavor pairings, and recommend 4 distinct, crowd-pleasing potluck items that coworkers can realistically make or pick up. "
            & "Every suggestion's category MUST be one of these exact strings: Main Dish, Soup, Salad, Appetizer, Dessert, Drinks. "
            & "Include helpful allergen/dietary notes (e.g., 'Vegetarian, Contains Dairy & Gluten' or 'Vegan, Gluten-Free') and set needsWarmer=true only if it requires a slow cooker/warmer outlet. "
            & "Respond ONLY with a valid JSON object containing 'spreadSummary' (string) and 'suggestions' (array of 4 objects with keys: dishName, category, dietaryNotes, needsWarmer, reason).";

        userPrompt = "Current category counts: #countsText#" & chr(10)
            & "Current signed-up dishes:" & chr(10) & "- #spreadText#" & chr(10);

        if ( len( userPreference ) ) {
            userPrompt &= chr(10) & "Attendee preference / constraint: #userPreference# (tailor all 4 suggestions to honor this while still complementing the potluck spread!).";
        } else {
            userPrompt &= chr(10) & "Give a balanced variety focusing especially on categories that currently have fewer entries or pair wonderfully with the existing dishes.";
        }

        // Single-turn call on ColdFusion 2025's native Gemini ChatModel (enforcing JSON output)
        fullPrompt = systemPrompt & chr(10) & chr(10)
            & userPrompt & chr(10) & chr(10)
            & 'Return ONLY valid JSON matching this exact structure: {"spreadSummary":"1-2 sentence overview of gaps and pairings","suggestions":[{"dishName":"string","category":"Main Dish|Soup|Salad|Appetizer|Dessert|Drinks","dietaryNotes":"string","needsWarmer":false,"reason":"1 sentence why this fits"}]}';

        aiRawResponse = aiModel.chat( fullPrompt );

        rawMsg = isStruct( aiRawResponse ) && structKeyExists( aiRawResponse, "message" )
            ? aiRawResponse.message
            : aiRawResponse;

        if ( isStruct( rawMsg ) ) {
            parsedResult = rawMsg;
        } else {
            cleanedJson = trim( toString( rawMsg ) );
            // Strip markdown code fences if present
            if ( left( cleanedJson, 3 ) == "```" ) {
                cleanedJson = reReplace( cleanedJson, "^```(?:json)?\s*", "" );
                cleanedJson = reReplace( cleanedJson, "\s*```$", "" );
            }
            firstBrace = find( "{", cleanedJson );
            lastBrace = len( cleanedJson ) - find( "}", reverse( cleanedJson ) ) + 1;
            if ( firstBrace > 0 && lastBrace > firstBrace ) {
                cleanedJson = mid( cleanedJson, firstBrace, lastBrace - firstBrace + 1 );
            }
            parsedResult = deserializeJSON( cleanedJson );
        }

        // Normalize categories so they always match the <select> options on signup.cfm
        cleanSuggestions = [];
        if ( structKeyExists( parsedResult, "suggestions" ) && isArray( parsedResult.suggestions ) ) {
            for ( s in parsedResult.suggestions ) {
                catVal = trim( s.category ?: "Appetizer" );
                if ( !arrayFindNoCase( allowedCategories, catVal ) ) {
                    catVal = "Appetizer";
                } else {
                    // Preserve exact casing expected by <select>
                    catVal = allowedCategories[ arrayFindNoCase( allowedCategories, catVal ) ];
                }
                arrayAppend( cleanSuggestions, {
                    "dishName"    : trim( s.dishName ?: "" ),
                    "category"    : catVal,
                    "dietaryNotes": trim( s.dietaryNotes ?: "None" ),
                    "needsWarmer" : isBoolean( s.needsWarmer ?: false ) ? javacast( "boolean", s.needsWarmer ) : false,
                    "reason"      : trim( s.reason ?: "" )
                });
            }
        }

        responsePayload.success = true;
        responsePayload.model = modelName;
        responsePayload.spreadSummary = trim( parsedResult.spreadSummary ?: "" );
        responsePayload.suggestions = cleanSuggestions;

    } catch ( any e ) {
        responsePayload.success = false;
        responsePayload.message = e.message;
    }

    writeOutput( serializeJSON( responsePayload ) );
</cfscript>
