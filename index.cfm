<!--- Ensure the CFML compiler interprets multi-byte characters and symbols as UTF-8 --->
<cfprocessingdirective pageencoding="utf-8">
<!--- Force the HTTP response header to serve UTF-8 to the browser --->
<cfcontent type="text/html; charset=utf-8">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FEAST MODE - Jesse Vancil Memorial Feast &amp; Ken Rausch Retirement</title>
    <style>
        :root {
            --christmas-red: #c41e3a;
            --christmas-dark-red: #8b0000;
            --christmas-green: #145a32;
            --christmas-dark-green: #0b3d20;
            --christmas-gold: #f4d03f;
            --card-bg: rgba(20, 40, 28, 0.94);
            --card-surface: rgba(14, 30, 20, 0.88);
            --text-light: #fefefe;
            --text-muted: #d0ded6;
            --border-gold: rgba(244, 208, 63, 0.45);
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
            display: flex;
            justify-content: center;
            align-items: flex-start;
            min-height: 100vh;
            padding: 32px 16px;
        }

        .container {
            width: 100%;
            max-width: 960px;
            text-align: center;
            border: 2px solid var(--christmas-green);
            outline: 2px solid var(--christmas-gold);
            padding: 32px 28px;
            border-radius: 16px;
            background: var(--card-bg);
            box-shadow: 0 16px 45px rgba(0, 0, 0, 0.65);
        }

        /* Hero Banner Section */
        .hero-banner-frame {
            width: 100%;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid var(--christmas-gold);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.55);
            background: #000000;
            margin-bottom: 24px;
            position: relative;
        }

        .hero-banner-img {
            width: 100%;
            height: auto;
            max-height: 380px;
            object-fit: cover;
            object-position: center;
            display: block;
            transition: transform 0.4s ease;
        }

        .hero-banner-frame:hover .hero-banner-img {
            transform: scale(1.015);
        }

        .hero-badge {
            position: absolute;
            bottom: 12px;
            right: 14px;
            background: rgba(14, 30, 20, 0.88);
            border: 1px solid var(--christmas-gold);
            color: var(--christmas-gold);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            letter-spacing: 0.5px;
            backdrop-filter: blur(4px);
        }

        /* Titles and Headers */
        .ribbon-title {
            background: linear-gradient(135deg, var(--christmas-red), var(--christmas-dark-red));
            border: 1.5px solid var(--christmas-gold);
            border-radius: 10px;
            padding: 16px 20px;
            margin-bottom: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.4);
        }

        .event-eyebrow {
            color: var(--christmas-gold);
            font-size: 0.95rem;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 4px;
        }

        h1 {
            color: #ffffff;
            font-size: 2.15rem;
            font-weight: 900;
            margin-bottom: 6px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.6);
        }

        .subtitle {
            color: #ffe6e6;
            font-size: 1.15rem;
            font-style: italic;
            font-weight: 600;
        }

        .event-info {
            background: rgba(10, 25, 16, 0.75);
            border: 1px dashed var(--christmas-gold);
            border-radius: 8px;
            padding: 12px 18px;
            margin: 18px auto 26px auto;
            max-width: 840px;
            color: var(--christmas-gold);
            font-weight: 600;
            font-size: 1rem;
        }

        /* Video Showcase */
        .video-wrapper {
            margin: 0 auto 28px auto;
            max-width: 800px;
            border: 2px solid var(--border-gold);
            border-radius: 12px;
            overflow: hidden;
            background: #000000;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.6);
        }

        video {
            width: 100%;
            height: auto;
            display: block;
        }

        /* Navigation Buttons */
        .action-container {
            margin: 26px 0 30px 0;
            display: flex;
            justify-content: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .btn-rsvp {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: linear-gradient(135deg, var(--christmas-red), var(--christmas-dark-red));
            color: #ffffff;
            font-size: 1.15rem;
            font-weight: 700;
            text-decoration: none;
            padding: 14px 28px;
            border-radius: 8px;
            border: 1px solid var(--christmas-gold);
            box-shadow: 0 4px 15px rgba(196, 30, 58, 0.45);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }

        .btn-rsvp:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(196, 30, 58, 0.65);
            color: #ffffff;
        }

        .btn-flyer {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(14, 30, 20, 0.95);
            color: var(--christmas-gold);
            font-size: 1.05rem;
            font-weight: 700;
            text-decoration: none;
            padding: 14px 24px;
            border-radius: 8px;
            border: 1px solid var(--christmas-gold);
            transition: transform 0.15s ease, background 0.15s ease;
        }

        .btn-flyer:hover {
            transform: translateY(-2px);
            background: rgba(20, 48, 30, 0.95);
            color: #ffffff;
        }

        /* CFML Server Metadata Footer */
        .server-meta {
            margin-top: 24px;
            padding-top: 18px;
            border-top: 1px solid rgba(244, 208, 63, 0.2);
            font-size: 0.85rem;
            color: var(--text-muted);
            line-height: 1.6;
        }

        .server-meta strong {
            color: var(--christmas-gold);
        }
    </style>
</head>
<body>

    <div class="container">

        <!-- Panoramic Office Party Hero Banner -->
        <div class="hero-banner-frame">
            <img 
                src="Characature.png" 
                alt="5th Annual Jesse Vancil Memorial Feast Celebration Caricature" 
                class="hero-banner-img"
                onerror="this.onerror=null; this.src='assets/Characature.png';"
            >
            <div class="hero-badge">&#127876; Feast Mode 2026</div>
        </div>

        <!-- Event Ribbon & Title -->
        <div class="ribbon-title">
            <div class="event-eyebrow">You're Invited to the 5th Annual</div>
            <h1>&#127876; Jesse Vancil Memorial Christmas Feast &#127876;</h1>
            <div class="subtitle">&amp; Ken Rausch's Retirement Celebration (For real this time!)</div>
        </div>

        <!-- Date & Location -->
        <div class="event-info">
            <span style="white-space: nowrap;">&#128197; Wednesday, December 2nd @ 12:00 PM (Noon)</span> &bull;
            <span style="white-space: nowrap;">&#128205; IT Commons outside of Josh's Office</span> &bull;
            <span style="white-space: nowrap;">&#128181;&nbsp;Only $5!</span>
        </div>

        <!-- Featured Video Player -->
        <div class="video-wrapper">
            <video controls poster="Characature.png">
                <source src="assets/Jesse_Vancil_and_Ken_Rausch_Video.mp4" type="video/mp4">
                <source src="Jesse_Vancil_and_Ken_Rausch_Video.mp4" type="video/mp4">
                Your browser does not support the video tag.
            </video>
        </div>

        <!-- Action Buttons -->
        <div class="action-container">
            <a href="signup.cfm" class="btn-rsvp">
                <span>&#127873;</span> RSVP &amp; Sign Up for Potluck
            </a>
           <!---  <a href="flyer.cfm" class="btn-flyer">
                <span>&#128196;</span> View Event Flyer
            </a> --->
        </div>

        <!-- CFML Server Information -->
        <div class="server-meta">
            <cfoutput>
                <p>Host: <strong>#cgi.server_name#</strong> | CFML Engine: <strong>#server.coldfusion.productname# #server.coldfusion.productversion#</strong></p>
                <p>Current Time: <strong>#dateTimeFormat(now(), "full")#</strong></p>
            </cfoutput>
        </div>

    </div>

</body>
</html>
