<!--- Ensure the CFML compiler interprets multi-byte characters and symbols as UTF-8 --->
<cfprocessingdirective pageencoding="utf-8">
<!--- Force the HTTP response header to serve UTF-8 to the browser --->
<cfcontent type="text/html; charset=utf-8">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Feast Mode: Fifth Annual Jesse Vancil Memorial Christmas Feast</title>
    <style>
        :root {
            --christmas-red: #c41e3a;
            --christmas-dark-red: #8b0000;
            --christmas-green: #145a32;
            --christmas-dark-green: #0b3d20;
            --christmas-gold: #f4d03f;
            --card-bg: rgba(20, 40, 28, 0.94);
            --text-light: #fefefe;
            --text-muted: #d0ded6;
            --border-color: rgba(244, 208, 63, 0.35);
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
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 32px 16px;
        }

        .container {
            max-width: 860px;
            width: 100%;
            margin: 0 auto;
        }

        .card {
            background: var(--card-bg);
            border: 2px solid var(--christmas-green);
            outline: 1px solid var(--christmas-gold);
            border-radius: 14px;
            box-shadow: 0 12px 36px rgba(0, 0, 0, 0.65), 0 0 28px rgba(196, 30, 58, 0.25);
            padding: 36px 32px;
            text-align: center;
            backdrop-filter: blur(8px);
        }

        .badge {
            display: inline-block;
            background: linear-gradient(135deg, var(--christmas-red), var(--christmas-dark-red));
            color: var(--text-light);
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            padding: 6px 18px;
            border-radius: 50px;
            border: 1px solid var(--christmas-gold);
            margin-bottom: 16px;
        }

        h1 {
            font-size: 2.0rem;
            color: var(--christmas-gold);
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.6);
            margin-bottom: 8px;
            line-height: 1.2;
        }

        .subtitle {
            font-size: 1.55rem;
            color: #ffffff;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .event-meta {
            font-size: 0.95rem;
            color: var(--christmas-gold);
            margin-bottom: 24px;
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

        /* Call To Action Buttons */
        .cta-container {
            margin: 30px 0 20px 0;
            display: flex;
            justify-content: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .btn-signup {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, var(--christmas-red), var(--christmas-dark-red));
            color: #ffffff;
            text-decoration: none;
            font-size: 1.15rem;
            font-weight: 700;
            padding: 14px 32px;
            border-radius: 8px;
            border: 1px solid var(--christmas-gold);
            box-shadow: 0 4px 14px rgba(196, 30, 58, 0.5);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }

        .btn-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(196, 30, 58, 0.7);
            color: #ffffff;
        }

        /* System Info Footer */
        .server-info {
            margin-top: 28px;
            padding-top: 18px;
            border-top: 1px solid rgba(244, 208, 63, 0.2);
            font-size: 0.82rem;
            color: var(--text-muted);
            line-height: 1.6;
        }

        .server-info strong {
            color: var(--christmas-gold);
        }
    </style>
</head>
<body>

<div class="container">
    <div class="card">
        <div class="badge">&#127876; Holiday Celebration &#127876;</div>
        <h1>Fifth Annual Jesse Vancil Memorial Christmas FEAST</h1>
        <p class="subtitle">&amp; Ken Rausch's Retirement Party (for real this time!)</p>
        <p class="event-meta">&#128197; Wednesday, December 2nd @ Noon &bull; &#128205; IT Commons (Outside of Josh's Office)</p>

        <!-- Video Front and Center -->
        <div class="video-wrapper">
            <video controls preload="metadata">
                <source src="assets/Jesse_Vancil_and_Ken_Rausch_Video.mp4" type="video/mp4">
                Your browser does not support the video tag.
            </video>
        </div>

        <!-- Call to Action for Sign-Up -->
        <div class="cta-container">
            <a href="signup.cfm" class="btn-signup">
                &#127873; Sign Up for a Dish or Volunteer Role &rarr;
            </a>
        </div>

        <!-- Dynamic CFML Server Metadata -->
        <div class="server-info">
            <cfoutput>
                <p>Host: <strong>#cgi.server_name#</strong> &bull; Engine: <strong>#server.coldfusion.productname# #server.coldfusion.productversion#</strong></p>
                <p>Current Server Time: #dateTimeFormat(now(), "full")#</p>
                <p>Hosts: <strong>The Goodtimes Planning Committee</strong></p>
            </cfoutput>
        </div>
    </div>
</div>

</body>
</html>