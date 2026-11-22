<!--- Ensure the CFML compiler interprets multi-byte characters and symbols as UTF-8 --->
<cfprocessingdirective pageencoding="utf-8">
<cfcontent type="text/html; charset=utf-8">

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jesse Vancil Memorial Feast - Official Flyer</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: #050b07;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 24px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .flyer-container {
            width: 800px;
            background: radial-gradient(circle at 50% 20%, #174223 0%, #0d2818 55%, #05140b 100%);
            border: 3px solid #f4d03f;
            outline: 6px solid #8b0000;
            border-radius: 18px;
            padding: 38px 32px;
            color: #fefefe;
            box-shadow: 0 16px 45px rgba(0, 0, 0, 0.7);
            text-align: center;
        }

        .banner-header {
            background: linear-gradient(135deg, #c41e3a, #8b0000);
            border: 2px solid #f4d03f;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 26px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.45);
        }

        .banner-subhead {
            color: #f4d03f;
            font-size: 0.95rem;
            font-weight: 700;
            letter-spacing: 2px;
            text-transform: uppercase;
        }

        h1 {
            color: #ffffff;
            font-size: 2.25rem;
            font-weight: 900;
            margin: 6px 0;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.6);
        }

        .banner-tagline {
            color: #ffeedb;
            font-size: 1.18rem;
            font-weight: 600;
            font-style: italic;
        }

        .honoree-grid {
            display: flex;
            justify-content: center;
            gap: 36px;
            margin: 28px 0;
        }

        .honoree-card {
            background: rgba(14, 30, 20, 0.9);
            border: 2px solid #f4d03f;
            border-radius: 14px;
            padding: 18px;
            width: 270px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.45);
        }

        .photo-frame {
            width: 180px;
            height: 220px;
            margin: 0 auto 12px auto;
            border-radius: 10px;
            overflow: hidden;
            border: 3px solid #c41e3a;
            box-shadow: 0 4px 12px rgba(0,0,0,0.6);
            background: #000;
        }

        .photo-frame img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }

        .honoree-role {
            color: #f4d03f;
            font-size: 1.15rem;
            font-weight: 700;
            margin-bottom: 2px;
        }

        .honoree-name {
            color: #ffffff;
            font-size: 1.12rem;
            font-weight: 700;
        }

        .honoree-desc {
            color: #d0ded6;
            font-size: 0.84rem;
            margin-top: 6px;
            line-height: 1.4;
        }

        .event-box {
            background: rgba(196, 30, 58, 0.22);
            border: 1.5px dashed #f4d03f;
            border-radius: 12px;
            padding: 16px 20px;
            margin: 20px auto;
            max-width: 620px;
        }

        .event-datetime {
            font-size: 1.35rem;
            font-weight: 800;
            color: #f4d03f;
            margin-bottom: 4px;
        }

        .event-location {
            font-size: 1.05rem;
            color: #ffffff;
        }

        .details-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin: 24px 0;
            text-align: left;
        }

        .detail-card {
            background: rgba(10, 25, 16, 0.88);
            border-radius: 8px;
            padding: 14px;
        }

        .detail-card.c1 { border-left: 4px solid #c41e3a; }
        .detail-card.c2 { border-left: 4px solid #f4d03f; }
        .detail-card.c3 { border-left: 4px solid #2ecc71; }

        .detail-title {
            color: #f4d03f;
            font-size: 0.95rem;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .detail-text {
            color: #d0ded6;
            font-size: 0.82rem;
            line-height: 1.4;
        }

        .rsvp-banner {
            background: linear-gradient(135deg, #145a32, #0b3d20);
            border: 2px solid #2ecc71;
            border-radius: 10px;
            padding: 16px 20px;
            margin-top: 10px;
        }

        .rsvp-headline {
            font-size: 1.15rem;
            font-weight: 700;
            color: #ffffff;
            margin-bottom: 4px;
        }

        .rsvp-link {
            color: #f4d03f;
            font-size: 1rem;
            font-weight: 700;
            text-decoration: underline;
        }

        .footer-note {
            margin-top: 20px;
            font-size: 0.88rem;
            color: #a3c4b0;
            font-style: italic;
        }
    </style>
</head>
<body>

<div class="flyer-container">

    <!-- Ribbon Header -->
    <div class="banner-header">
        <div class="banner-subhead">You're Invited to the 5th Annual</div>
        <h1>&#127876; Jesse Vancil Memorial Christmas Feast &#127876;</h1>
        <div class="banner-tagline">&amp; Ken Rausch's Retirement Party (For real this time!)</div>
    </div>

    <!-- Honorees Side by Side -->
    <div class="honoree-grid">
        <!-- Jesse Vancil -->
        <div class="honoree-card">
            <div class="photo-frame">
                <img src="jesseVancil.jpg" alt="Jesse Vancil" onerror="this.onerror=null; this.src='assets/jesseVancil.jpg';">
            </div>
            <div class="honoree-role">In Memory Of</div>
            <div class="honoree-name">Jesse Vancil</div>
            <div class="honoree-desc">Honoring his enduring love for holiday fellowship and great feasts.</div>
        </div>

        <!-- Ken Rausch -->
        <div class="honoree-card">
            <div class="photo-frame">
                <img src="KenRausch.png" alt="Ken Rausch" onerror="this.onerror=null; this.src='assets/KenRausch.png';">
            </div>
            <div class="honoree-role">Celebrating</div>
            <div class="honoree-name">Ken Rausch</div>
            <div class="honoree-desc">Wishing Ken the happiest retirement! Join us to raise a toast.</div>
        </div>
    </div>

    <!-- Date & Location Callout -->
    <div class="event-box">
        <div class="event-datetime">&#128197; Wednesday, December 2nd @ 12:00 PM (Noon)</div>
        <div class="event-location">&#128205; Location: <strong>Josh's Office / IT Commons</strong></div>
    </div>

    <!-- Info Pillars -->
    <div class="details-grid">
        <div class="detail-card c1">
            <div class="detail-title">&#127858; $5 Contribution</div>
            <div class="detail-text">Supports the GoodTimes Planning Committee for warm soups, deli platters, and salads.</div>
        </div>
        <div class="detail-card c2">
            <div class="detail-title">&#127873; Potluck Dishes</div>
            <div class="detail-text">Bring your favorite dish! Buffet counter space with outlets available for warmers.</div>
        </div>
        <div class="detail-card c3">
            <div class="detail-title">&#127877; Volunteer Helpers</div>
            <div class="detail-text">Helpers needed for setup (11:15 AM), paper goods &amp; drinks, and cleanup (1:00 PM).</div>
        </div>
    </div>

    <!-- RSVP Section -->
    <div class="rsvp-banner">
        <div class="rsvp-headline">&#9997; Sign Up Online Today!</div>
        <div>Visit <span class="rsvp-link">signup.cfm</span> on the local intranet to register your dish or RSVP.</div>
    </div>

    <div class="footer-note">
        Wishing everyone a warm, joyful, and peaceful holiday season! &#10052;
    </div>

</div>

</body>
</html>