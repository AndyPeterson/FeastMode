<!--- Ensure the CFML compiler interprets multi-byte characters and symbols as UTF-8 --->
<cfprocessingdirective pageencoding="utf-8">
<!--- Force the HTTP response header to serve UTF-8 to the browser --->
<cfcontent type="text/html; charset=utf-8">

<cfscript>
    // -------------------------------------------------------------
    // 1. DATA STORAGE SETUP (Robust Absolute Path)
    // -------------------------------------------------------------
    dataDir = getDirectoryFromPath( getCurrentTemplatePath() );
    dataFile = dataDir & "WhiteElephant.json";

    // Initialize the JSON data store if it does not already exist
    if ( !fileExists( dataFile ) ) {
        initialStructure = {
            "signups": []
        };
        fileWrite( dataFile, serializeJSON( initialStructure ), "utf-8" );
    }

    // Feedback & form state variables
    feedbackMessage = "";
    feedbackType = ""; // "success" or "error"
    submittedEmail = "";

    // -------------------------------------------------------------
    // 2. FORM SUBMISSION PROCESSING
    // -------------------------------------------------------------
    if ( cgi.request_method == "POST" ) {
        userEmail = trim( form.email ?: "" );
        submittedEmail = userEmail;

        if ( len( userEmail ) == 0 ) {
            feedbackType = "error";
            feedbackMessage = "Your email address is required. Please enter your email to sign up.";
        } else if ( !isValid( "email", userEmail ) ) {
            feedbackType = "error";
            feedbackMessage = "Please enter a valid email address (e.g., name@example.com).";
        } else {
            try {
                cflock( name="white_elephant_json_lock", type="exclusive", timeout=15, throwontimeout=true ) {
                    rawJson = fileRead( dataFile, "utf-8" );
                    dataStore = isJSON( rawJson ) ? deserializeJSON( rawJson ) : { "signups": [] };

                    if ( !structKeyExists( dataStore, "signups" ) || !isArray( dataStore.signups ) ) {
                        dataStore.signups = [];
                    }

                    // Prevent duplicate email registrations (case-insensitive)
                    alreadyRegistered = false;
                    for ( entry in dataStore.signups ) {
                        if ( structKeyExists( entry, "email" ) && compareNoCase( entry.email, userEmail ) == 0 ) {
                            alreadyRegistered = true;
                            break;
                        }
                    }

                    if ( alreadyRegistered ) {
                        feedbackType = "error";
                        feedbackMessage = userEmail & " is already signed up for the Sneaky White Elephant Gift Exchange!";
                    } else {
                        newSignup = {
                            "id": createUUID(),
                            "submittedAt": dateTimeFormat( now(), "yyyy-mm-dd HH:nn:ss" ),
                            "email": userEmail
                        };
                        arrayAppend( dataStore.signups, newSignup );

                        fileWrite( dataFile, serializeJSON( dataStore ), "utf-8" );

                        feedbackType = "success";
                        feedbackMessage = "You're in! " & userEmail & " has been signed up for the Sneaky White Elephant Gift Exchange.";
                        submittedEmail = "";
                    }
                }
            } catch ( any e ) {
                feedbackType = "error";
                feedbackMessage = "An error occurred while saving your sign-up: " & e.message;
            }
        }
    }

    // -------------------------------------------------------------
    // 3. READ CURRENT SIGNUP COUNT FOR DISPLAY
    // -------------------------------------------------------------
    try {
        cflock( name="white_elephant_json_lock", type="readonly", timeout=10, throwontimeout=false ) {
            currentRawJson = fileRead( dataFile, "utf-8" );
            registry = isJSON( currentRawJson ) ? deserializeJSON( currentRawJson ) : { "signups": [] };
        }
    } catch ( any e ) {
        registry = { "signups": [] };
    }

    if ( !structKeyExists( registry, "signups" ) || !isArray( registry.signups ) ) {
        registry.signups = [];
    }
    signupCount = arrayLen( registry.signups );
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sneaky White Elephant Gift Exchange Sign-Up - FEAST MODE</title>
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

        .nav-links {
            display: flex;
            justify-content: center;
            gap: 20px;
            flex-wrap: wrap;
            margin-top: 12px;
        }

        .nav-back {
            display: inline-block;
            color: var(--christmas-gold);
            text-decoration: none;
            font-size: 0.9rem;
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

        /* Summary / Guidelines Card */
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
            margin-bottom: 28px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        }

        .form-section-title {
            color: var(--christmas-gold);
            font-size: 1.25rem;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
            margin: 0 0 18px 0;
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

        input[type="email"],
        input[type="text"] {
            width: 100%;
            padding: 10px 12px;
            border-radius: 6px;
            border: 1px solid var(--christmas-green);
            background: rgba(8, 20, 13, 0.85);
            color: #ffffff;
            font-size: 0.95rem;
            font-family: inherit;
        }

        input[type="email"]:focus,
        input[type="text"]:focus {
            outline: none;
            border-color: var(--christmas-gold);
            box-shadow: 0 0 8px rgba(244, 208, 63, 0.4);
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

        .status-pill {
            background: rgba(196, 30, 58, 0.12);
            border: 1px dashed var(--christmas-gold);
            border-radius: 8px;
            padding: 14px 20px;
            text-align: center;
            font-size: 0.95rem;
            color: var(--text-muted);
            margin-bottom: 24px;
        }

        .status-pill strong {
            color: var(--christmas-gold);
        }

        /* Registry List Card */
        .registry-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 26px;
            margin-bottom: 28px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
        }

        .registry-title {
            color: var(--christmas-gold);
            font-size: 1.3rem;
            margin-bottom: 16px;
            border-bottom: 2px solid var(--christmas-green);
            padding-bottom: 10px;
        }

        .signup-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        .signup-list li {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            border-bottom: 1px solid rgba(244, 208, 63, 0.15);
            font-size: 0.95rem;
        }

        .signup-list li:last-child {
            border-bottom: none;
        }

        .signup-list li:hover {
            background: rgba(255, 255, 255, 0.03);
        }

        .signup-num {
            color: var(--christmas-gold);
            font-weight: 700;
            min-width: 26px;
        }

        .empty-row {
            text-align: center;
            color: var(--text-muted);
            padding: 18px;
            font-style: italic;
        }
    </style>
</head>
<body>

<div class="container">

    <!-- Top Header -->
    <div class="header-card">
        <h1>&#127873; Sneaky White Elephant Gift Exchange &#128024;</h1>
        <p class="event-meta">FEAST MODE Holiday Celebration &bull; Wednesday @ ~3:00 PM (After the Feast)</p>
        <p style="color: var(--text-muted); font-size: 0.92rem;">
            Enter your email address below to join the Sneaky White Elephant Gift Exchange!
        </p>
        <div class="nav-links">
            <a href="index.cfm" class="nav-back">&larr; Back to Feast Welcome</a>
            <a href="signup.cfm" class="nav-back">&#127858; Potluck &amp; Volunteer Sign-Up &rarr;</a>
        </div>
    </div>

    <!-- Feedback Message -->
    <cfif len( feedbackMessage )>
        <div class="alert <cfif feedbackType EQ 'success'>alert-success<cfelse>alert-error</cfif>">
            <cfoutput>#encodeForHTML( feedbackMessage )#</cfoutput>
        </div>
    </cfif>

    <!-- Event Summary & Rules Box -->
    <div class="guidelines-box">
        <h3>&#10052; How It Works</h3>
        <p>The White Elephant Gift Exchange follows the same rules as last year. We will open gifts in the order of 2026 trivia scores, lowest to highest. The next person whose turn it is to open a gift will have to decide whether they want to open a gift from under the tree, or switch with somebody. Switching is allowed only one time per gift, and the person who is &ldquo;switched on&rdquo; cannot &ldquo;re-switch.&rdquo; $15 to $20 bucks for the gift. We will do this sometime around 3:00 PM on Wednesday afternoon, after the FEAST.</p>
    </div>

    <!-- Sign-Up Form -->
    <div class="form-card">
        <form method="POST" action="GiftExchange.cfm">
            <h2 class="form-section-title">&#9993; Gift Exchange Registration</h2>

            <div class="form-group">
                <label for="email">Email Address <span class="required-star">* (Required)</span></label>
                <cfoutput>
                    <input
                        type="email"
                        id="email"
                        name="email"
                        value="#encodeForHTMLAttribute( submittedEmail )#"
                        required
                        placeholder="e.g., alex.miller@example.com"
                        maxlength="150"
                    >
                </cfoutput>
            </div>

            <button type="submit" class="btn-submit">Sign Up for Gift Exchange &#127873;</button>
        </form>
    </div>

    <!-- Participant Count Summary -->
    <div class="status-pill">
        &#127876; Currently signed up: <cfoutput><strong>#signupCount#</strong></cfoutput> <cfif signupCount EQ 1>participant<cfelse>participants</cfif>
    </div>

    <!-- Signed-Up Email List -->
    <div class="registry-card">
        <h2 class="registry-title">&#127873; Signed-Up Participants</h2>
        <cfif signupCount EQ 0>
            <div class="empty-row">No participants signed up yet. Be the first to join!</div>
        <cfelse>
            <ul class="signup-list">
                <cfloop from="1" to="#signupCount#" index="i">
                    <cfset entry = registry.signups[i]>
                    <cfoutput>
                        <li>
                            <span class="signup-num">#i#.</span>
                            <span>#encodeForHTML( entry.email )#</span>
                        </li>
                    </cfoutput>
                </cfloop>
            </ul>
        </cfif>
    </div>

</div>

</body>
</html>
