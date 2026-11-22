<!--- Ensure the CFML compiler interprets multi-byte characters and symbols as UTF-8 --->
<cfprocessingdirective pageencoding="utf-8">
<!--- Force the HTTP response header to serve UTF-8 to the browser --->
<cfcontent type="text/html; charset=utf-8">

<cfscript>
    // -------------------------------------------------------------
    // 1. DATA STORAGE SETUP (Robust Absolute Path)
    // -------------------------------------------------------------
    // Using getCurrentTemplatePath ensures all users target the exact same file
    dataDir = getDirectoryFromPath( getCurrentTemplatePath() );
    dataFile = dataDir & "signups.json";

    // Initialize the JSON data store if it does not already exist
    if ( !fileExists( dataFile ) ) {
        initialStructure = {
            "attendees": [],
            "dishes": [],
            "volunteers": []
        };
        fileWrite( dataFile, serializeJSON( initialStructure ), "utf-8" );
    }

    // Feedback message variables
    feedbackMessage = "";
    feedbackType = ""; // "success" or "error"

    // -------------------------------------------------------------
    // 2. FORM SUBMISSION PROCESSING
    // -------------------------------------------------------------
    if ( cgi.request_method == "POST" ) {

        userName = trim( form.userName ?: "" );
        hasAgreedToDonation = structKeyExists( form, "agreeDonation" );
        userDishName = trim( form.dishName ?: "" );
        userDishCategory = trim( form.dishCategory ?: "" );
        userDietary = trim( form.dietaryRestrictions ?: "" );
        userVolunteerRole = trim( form.volunteerRole ?: "" );
        userVolunteerNotes = trim( form.volunteerNotes ?: "" );
        userNeedsWarmer = structKeyExists( form, "needsWarmer" );

        // Validation Checks
        if ( len( userName ) == 0 ) {
            feedbackType = "error";
            feedbackMessage = "Your Name is required. Please enter your name to register.";
        } else if ( !hasAgreedToDonation ) {
            feedbackType = "error";
            feedbackMessage = "Please agree to the $5 donation to the GoodTimes Planning Committee to complete your sign-up.";
        } else {
            try {
                // Read and mutate within an exclusive lock to avoid file-write race conditions
                cflock( name="feast_json_lock", type="exclusive", timeout=15, throwontimeout=true ) {
                    rawJson = fileRead( dataFile, "utf-8" );
                    dataStore = isJSON( rawJson ) ? deserializeJSON( rawJson ) : { "attendees": [], "dishes": [], "volunteers": [] };

                    // Ensure all array structures exist
                    if ( !structKeyExists( dataStore, "attendees" ) ) dataStore.attendees = [];
                    if ( !structKeyExists( dataStore, "dishes" ) ) dataStore.dishes = [];
                    if ( !structKeyExists( dataStore, "volunteers" ) ) dataStore.volunteers = [];

                    submissionTimestamp = dateTimeFormat( now(), "yyyy-mm-dd HH:nn:ss" );
                    submissionId = createUUID();

                    // ALWAYS record the attendee in the master attendee registry
                    newAttendee = {
                        "id": submissionId,
                        "submittedAt": submissionTimestamp,
                        "name": userName,
                        "dietaryRestrictions": len( userDietary ) ? userDietary : "None",
                        "hasDish": ( len( userDishName ) > 0 || len( userDishCategory ) > 0 ),
                        "dishName": userDishName,
                        "volunteerRole": userVolunteerRole
                    };
                    arrayAppend( dataStore.attendees, newAttendee );

                    // RECORD DISH / CONTRIBUTION:
                    // If the user specified a dish or category, record it.
                    // If they did NOT provide a dish, record them as an Attendee Contributor ($5 Fund)
                    // so their name and dietary requirements always appear in the contributions registry.
                    if ( len( userDishName ) > 0 || len( userDishCategory ) > 0 ) {
                        newDish = {
                            "id": submissionId,
                            "submittedAt": submissionTimestamp,
                            "name": userName,
                            "dishCategory": len( userDishCategory ) ? userDishCategory : "General Contribution",
                            "dishName": len( userDishName ) ? userDishName : "TBD",
                            "dietaryRestrictions": len( userDietary ) ? userDietary : "None",
                            "needsWarmer": userNeedsWarmer
                        };
                        arrayAppend( dataStore.dishes, newDish );
                    } else {
                        // Attendee only (no dish brought) - record under contributions as $5 Deli & Soup Fund
                        newDish = {
                            "id": submissionId,
                            "submittedAt": submissionTimestamp,
                            "name": userName,
                            "dishCategory": "None",
                            "dishName": "None",
                            "dietaryRestrictions": len( userDietary ) ? userDietary : "None",
                            "needsWarmer": false
                        };
                        arrayAppend( dataStore.dishes, newDish );
                    }

                    // RECORD VOLUNTEER SELECTION if chosen
                    if ( len( userVolunteerRole ) > 0 ) {
                        newVolunteer = {
                            "id": submissionId,
                            "submittedAt": submissionTimestamp,
                            "name": userName,
                            "role": userVolunteerRole,
                            "notes": userVolunteerNotes
                        };
                        arrayAppend( dataStore.volunteers, newVolunteer );
                    }

                    // Commit back to signups.json in UTF-8
                    fileWrite( dataFile, serializeJSON( dataStore ), "utf-8" );

                    // ONLY declare success if the file write operation succeeded
                    feedbackType = "success";
                    feedbackMessage = "Thank you, " & encodeForHTML( userName ) & "! Your sign-up has been successfully recorded.";
                }
            } catch ( any e ) {
                feedbackType = "error";
                feedbackMessage = "An error occurred while saving your sign-up: " & encodeForHTML( e.message );
            }
        }
    }

    // -------------------------------------------------------------
    // 3. READ CURRENT REGISTRY FOR DISPLAY
    // -------------------------------------------------------------
    try {
        cflock( name="feast_json_lock", type="readonly", timeout=10, throwontimeout=false ) {
            currentRawJson = fileRead( dataFile, "utf-8" );
            registry = isJSON( currentRawJson ) ? deserializeJSON( currentRawJson ) : { "attendees": [], "dishes": [], "volunteers": [] };
        }
    } catch ( any e ) {
        registry = { "attendees": [], "dishes": [], "volunteers": [] };
    }

    if ( !structKeyExists( registry, "dishes" ) ) registry.dishes = [];
    if ( !structKeyExists( registry, "volunteers" ) ) registry.volunteers = [];
    if ( !structKeyExists( registry, "attendees" ) ) registry.attendees = [];
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Potluck &amp; Volunteer Sign-Up - Jesse Vancil Memorial Feast</title>
    <style>
        :root {
            --christmas-red: #c41e3a;
            --christmas-dark-red: #8b0000;
            --christmas-green: #145a32;
            --christmas-dark-green: #0b3d20;
            --christmas-gold: #f4d03f;
            --card-bg: rgba(20, 40, 28, 0.94);
            --card-surface: rgba(14, 30, 20, 0.85);
            --text-light: #fefefe;
            --text-muted: #d0ded6;
            --border-color: rgba(244, 208, 63, 0.35);
            --error-red: #ff4d4d;
            --success-green: #2ecc71;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: radial-gradient(circle at 50% 15%, #1e4620 0%, #0d2818 55%, #05140b 100%);
            color: var(--text-light);
            min-height: 100vh;
            padding: 32px 16px;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
        }

        .header-card {
            background: var(--card-bg);
            border: 2px solid var(--christmas-green);
            outline: 1px solid var(--christmas-gold);
            border-radius: 12px;
            padding: 28px;
            text-align: center;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.5);
            margin-bottom: 24px;
        }

        h1 {
            color: var(--christmas-gold);
            font-size: 2rem;
            margin-bottom: 6px;
        }

        .event-meta {
            color: var(--christmas-gold);
            font-size: 0.95rem;
            margin-bottom: 12px;
        }

        .nav-back {
            display: inline-block;
            color: var(--christmas-gold);
            text-decoration: none;
            font-size: 0.9rem;
            margin-top: 10px;
            transition: color 0.15s ease;
        }

        .nav-back:hover {
            color: #ffffff;
            text-decoration: underline;
        }

        /* Feedback Banners */
        .alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-weight: 600;
            text-align: center;
        }
        .alert-success {
            background: rgba(46, 204, 113, 0.2);
            border: 1px solid var(--success-green);
            color: #bbf7d0;
        }
        .alert-error {
            background: rgba(255, 77, 77, 0.2);
            border: 1px solid var(--error-red);
            color: #fecaca;
        }

        /* Guidelines Card */
        .guidelines-box {
            background: rgba(196, 30, 58, 0.12);
            border: 1px dashed var(--christmas-gold);
            border-radius: 8px;
            padding: 18px 22px;
            margin-bottom: 24px;
            font-size: 0.92rem;
            line-height: 1.6;
        }
        .guidelines-box h3 {
            color: var(--christmas-gold);
            margin-bottom: 8px;
        }

        /* Form Styles */
        .form-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 30px;
            margin-bottom: 32px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        }

        .form-section-title {
            color: var(--christmas-gold);
            font-size: 1.25rem;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
            margin: 20px 0 16px 0;
        }
        .form-section-title:first-of-type {
            margin-top: 0;
        }

        .form-group {
            margin-bottom: 18px;
        }

        label {
            display: block;
            margin-bottom: 6px;
            font-size: 0.92rem;
            font-weight: 600;
            color: var(--text-light);
        }

        .required-star {
            color: var(--christmas-gold);
        }

        input[type="text"], select, textarea {
            width: 100%;
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid var(--christmas-green);
            background: rgba(8, 20, 13, 0.85);
            color: #ffffff;
            font-size: 0.95rem;
            font-family: inherit;
        }

        input[type="text"]:focus, select:focus, textarea:focus {
            outline: none;
            border-color: var(--christmas-gold);
            box-shadow: 0 0 8px rgba(244, 208, 63, 0.4);
        }

        /* Highlighted donation box */
        .donation-agreement-box {
            background: rgba(196, 30, 58, 0.18);
            border: 1px solid rgba(244, 208, 63, 0.45);
            border-radius: 8px;
            padding: 14px 16px;
            margin: 18px 0 14px 0;
        }

        .checkbox-container {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            cursor: pointer;
            margin: 0;
        }

        .checkbox-container input[type="checkbox"] {
            margin-top: 3px;
            width: 18px;
            height: 18px;
            accent-color: var(--christmas-red);
            cursor: pointer;
        }

        .checkbox-label {
            font-size: 0.95rem;
            font-weight: 600;
            color: #ffffff;
            line-height: 1.4;
            cursor: pointer;
        }

        .checkbox-subtext {
            display: block;
            font-size: 0.82rem;
            color: var(--text-muted);
            margin-top: 3px;
            font-weight: normal;
        }

        .checkbox-wrapper-secondary {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding: 8px 4px;
        }

        .checkbox-wrapper-secondary input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: var(--christmas-green);
            cursor: pointer;
        }

        .btn-submit {
            display: block;
            width: 100%;
            background: linear-gradient(135deg, var(--christmas-red), var(--christmas-dark-red));
            color: #ffffff;
            border: 1px solid var(--christmas-gold);
            padding: 14px;
            font-size: 1.1rem;
            font-weight: 700;
            border-radius: 8px;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(196, 30, 58, 0.4);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
            margin-top: 24px;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(196, 30, 58, 0.6);
        }

        /* Registry Tables */
        .registry-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 26px;
            margin-bottom: 28px;
        }

        .registry-title {
            color: var(--christmas-gold);
            font-size: 1.3rem;
            margin-bottom: 16px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
            margin-bottom: 16px;
        }

        th {
            background: rgba(14, 30, 20, 0.9);
            color: var(--christmas-gold);
            text-align: left;
            padding: 10px 12px;
            border-bottom: 2px solid var(--christmas-green);
        }

        td {
            padding: 10px 12px;
            border-bottom: 1px solid rgba(244, 208, 63, 0.15);
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.03);
        }

        .tag-warmer {
            background: rgba(244, 208, 63, 0.2);
            color: var(--christmas-gold);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.78rem;
            margin-left: 6px;
        }

        .empty-row {
            text-align: center;
            color: var(--text-muted);
            padding: 18px;
            font-style: italic;
        }

        /* Video Showcase */
        .video-wrapper {
            position: relative;
            margin: 24px auto;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid var(--border-color);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.6);
            background: #000;
            max-width: 760px;
        }

        .video-wrapper video {
            width: 100%;
            height: auto;
            display: block;
        }
    </style>
</head>
<body>

<div class="container">

    <!-- Top Header -->
    <div class="header-card">
        <h1>&#127876; FEAST MODE Potluck &amp; Volunteer Sign-Up &#127876;</h1>
        <p class="event-meta">Wednesday, December 2nd @ Noon &bull; IT Commons Area (Outside of Josh's Office)</p>
        <p style="color: var(--text-muted); font-size: 0.92rem;">
            In memory of Jesse Vancil who was always in FEAST MODE, Ken Rausch's retirement, and sharing holiday friendship!
        </p>
        <a href="index.cfm" class="nav-back">&larr; Back to Feast Welcome &amp; Video</a>
    </div>

    <!-- Feedback Message -->
    <cfif len( feedbackMessage )>
        <div class="alert <cfif feedbackType EQ 'success'>alert-success<cfelse>alert-error</cfif>">
            <cfoutput>#encodeForHTML( feedbackMessage )#</cfoutput>
               <div class="video-wrapper">
                    <video controls preload="metadata">
                    <source src="assets/Jesse_Vancil_and_Ken_Rausch_Video.mp4" type="video/mp4">
                    Your browser does not support the video tag.
                </video>
            </div> 
        </div>

                            <!-- Video Front and Center -->

    </cfif>

    <!-- Potluck Guidelines Box -->
    <div class="guidelines-box">
        <h3>&#10052; Potluck Guidelines &amp; Tips</h3>
        <p><strong>Cost:</strong> Your $5 donation to the GoodTimes Planning Committee will go towards soups, deli, and salads.</p>
        <p><strong>Labeling:</strong> Please label your serving utensils and note if your dish is vegetarian, vegan, gluten-free, or contains nuts/dairy.</p>
        <p><strong>Warmers &amp; Outlets:</strong> Bring your own warmer/cord if needed. Space is available on buffet side counters.</p>
        <p><strong>RSVP Deadline:</strong> Please RSVP by filling out this form ASAP.</p>
    </div>

    <!-- Sign-Up Form -->
    <div class="form-card">
        <form method="POST" action="signup.cfm">

            <h2 class="form-section-title">&#128100; Step 1: Your Information</h2>
            <div class="form-group">
                <label for="userName">Your Full Name <span class="required-star">* (Required)</span></label>
                <input type="text" id="userName" name="userName" required placeholder="e.g., Alex Miller" maxlength="100">
            </div>

            <h2 class="form-section-title">&#127873; Step 2: What are you bringing? (Optional)</h2>
            <div class="form-group">
                <label for="dishCategory">Dish Category</label>
                <select id="dishCategory" name="dishCategory">
                    <option value="">-- Select a Category --</option>
                    <option value="Main Dish">Main Dish</option>
                    <option value="Soup">Soup</option>
                    <option value="Salad">Salad</option>                    
                    <option value="Appetizer">Appetizer</option>
                    <option value="Dessert">Dessert</option>
                    <option value="Drinks">Drinks</option>
                    <option value="Other / Additional Monetary Contribution">Other / Additional Monetary Contribution</option>
                </select>
            </div>

            <div class="form-group">
                <label for="dishName">Name of Dish or Donation</label>
                <input type="text" id="dishName" name="dishName" placeholder="e.g., Green Bean Casserole, Honey Baked Ham" maxlength="120">
            </div>

            <div class="form-group">
                <label for="dietaryRestrictions">Dietary Restrictions / Allergens</label>
                <input type="text" id="dietaryRestrictions" name="dietaryRestrictions" placeholder="e.g., Vegetarian, Gluten-Free, Contains Walnuts" maxlength="150">
            </div>

            <!-- Required $5 Donation Agreement Checkbox -->
            <div class="donation-agreement-box">
                <label class="checkbox-container">
                    <input type="checkbox" name="agreeDonation" id="agreeDonation" value="1" required>
                    <div>
                        <span class="checkbox-label">
                            I agree to donate $5 to the GoodTimes Planning Committee <span class="required-star">* (Required)</span>
                        </span>
                        <span class="checkbox-subtext">
                            Donations fund the warm soups, deli platters, salads, and holiday tableware.
                        </span>
                    </div>
                </label>
            </div>

            <!-- Warmer / Electrical Outlet Checkbox -->
            <div class="checkbox-wrapper-secondary">
                <input type="checkbox" name="needsWarmer" id="needsWarmer" value="1">
                <label for="needsWarmer" style="margin-bottom:0; font-weight:normal; cursor:pointer;">
                    Requires an Electrical Outlet / Warmer Counter Space
                </label>
            </div>

            <h2 class="form-section-title">&#127877; Step 3: Volunteer &amp; Supply Helper (Optional)</h2>
            <div class="form-group">
                <label for="volunteerRole">Volunteer Role</label>
                <select id="volunteerRole" name="volunteerRole">
                    <option value="">-- No Volunteer Role (Attendee only) --</option>
                    <!--- <option value="Setup & Table Decor (11:15 AM)">Setup &amp; Table Decor (11:15 AM)</option>
                    <option value="Paper Plates, Napkins & Cutlery">Paper Plates, Napkins &amp; Cutlery</option> --->
                    <option value="Setup 9:00 AM">Setup (9:00 AM)</option>
                    <option value="Cleanup & Breakdown (1:00 PM)">Cleanup &amp; Breakdown (1:00 PM)</option>
                </select>
            </div>

            <div class="form-group">
                <label for="volunteerNotes">Notes</label>
                <input type="text" id="volunteerNotes" name="volunteerNotes" placeholder="e.g., Also bringing 50 forks and festive napkins" maxlength="150">
            </div>

            <button type="submit" class="btn-submit">Submit Sign-Up &amp; RSVP &#10003;</button>
        </form>
    </div>

    <!-- Live Potluck Registry -->
    <div class="registry-card">
        <h2 class="registry-title">&#127858; Current Potluck Contributions</h2>
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th>Dish / Contribution</th>
                    <th>Category</th>
                    <th>Dietary / Notes</th>
                </tr>
            </thead>
            <tbody>
                <cfif arrayLen( registry.dishes ) EQ 0>
                    <tr>
                        <td colspan="5" class="empty-row">No dishes registered yet. Be the first to claim a dish!</td>
                    </tr>
                <cfelse>
                    <cfloop from="1" to="#arrayLen( registry.dishes )#" index="i">
                        <cfset dish = registry.dishes[i]>
                        <cfoutput>
                            <tr>
                                <td>#i#</td>
                                <td><strong>#encodeForHTML( dish.name )#</strong></td>
                                <td>
                                    #encodeForHTML( dish.dishName )#
                                    <cfif structKeyExists( dish, "needsWarmer" ) AND dish.needsWarmer>
                                        <span class="tag-warmer">&##9889; Outlet</span>
                                    </cfif>
                                </td>
                                <td>#encodeForHTML( dish.dishCategory )#</td>
                                <td>#encodeForHTML( dish.dietaryRestrictions )#</td>
                            </tr>
                        </cfoutput>
                    </cfloop>
                </cfif>
            </tbody>
        </table>

        <!-- Volunteer Registry -->
        <h2 class="registry-title" style="margin-top: 26px;">&#127877; Volunteer Helpers</h2>
        <table>
            <thead>
                <tr>
                    <th>Volunteer Role</th>
                    <th>Helper Name</th>
                    <th>Notes / Items Provided</th>
                </tr>
            </thead>
            <tbody>
                <cfif arrayLen( registry.volunteers ) EQ 0>
                    <tr>
                        <td colspan="3" class="empty-row">No helpers registered yet. Sign up above to lend a hand!</td>
                    </tr>
                <cfelse>
                    <cfloop array="#registry.volunteers#" index="vol">
                        <cfoutput>
                            <tr>
                                <td><strong>#encodeForHTML( vol.role )#</strong></td>
                                <td>#encodeForHTML( vol.name )#</td>
                                <td>#encodeForHTML( vol.notes )#</td>
                            </tr>
                        </cfoutput>
                    </cfloop>
                </cfif>
            </tbody>
        </table>
    </div>

</div>

</body>
</html>
