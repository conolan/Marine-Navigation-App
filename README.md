# Marine navigation app

In January 2015 I set out to create a new marine navigation app for IOS and Android. I'm an avid sailor, and have been using apps from Navionics and Imray on phones and iPad for a few years. I was never very happy with the interfaces and operation details of either offering.

I'm also a firm believer in hybrid or cross-platform coding, ever since I started using Macromind Director in the early 1990s to create Mac and Windows 3.1 CD-Rom games.

The app used several features: GPS Location, download from server, upload to server, image encryption.

The app is based on British Admiralty (UKHO) Raster Charts. These are scans of the paper charts and each file comes with the latitude and longitude of the top right and bottom left corners. This demo versin uses two US charts which are free of copyright issues.

In essence, I was creating a raster-based chart app but adding layers as vectors that added to the information and experience. A lot of chart apps are totally vector-based, which is efficient, but has issues around the look and more importantly what items (think rocks) are shown at what zoom levels. Raster charts have everything of relevance to safe boating on the chart. Vectors are seamless, but have to switch off small details at higher zoom levels and sometime there are consequences.

Corona SDK
All of this work was being done on a Windows PC. A Mac is needed to build the app for IOS, and for this I used macincloud, a virtual mac that costs $1 per hour to rent. Dropbox was the link between the PC and virtual Mac. In fact I kept all files in a dropbox folder so that the Mac files automatically updated.

A neat feature that CoronaLabs released around that time was Corona Viewer, a utility that saved lots of test setup time. Essentially it's a runtime version of the SDK that you install on a phone or tablet. That's linked to a dropbox folder and the app automatically updates on the device when a file is saved in the master dropbox folder. That saved time because the alternative was launch macincloud, build app, download to PC, connect  iPad, transfer, then test.

Corona is easy to use, and the lua code is similar to javascript. It's truly cross-platform (Android and IOS) and Macintosh and Windows apps are currently in beta. All using the same code. Within my project, I only check for IOS/Android once, and that's so I can distinguish between phones and tablets by size. All functions, encryption, GPS, web access are handled by the same code. In other projects I've done, sending emails and text messages is the same regardless of platform.
